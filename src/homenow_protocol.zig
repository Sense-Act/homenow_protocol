const std = @import("std");
const pair_message = @import("messages/pair_message.zig");
const expect = std.testing.expect;

pub const MessageTask = enum(u8) {
    get = 0x00,
    set = 0x01,
    update = 0x02,
    pair = 0x03,
};

pub const HomeNowVersion = enum(u16) {
    v0_0_0 = 0x0,
    vtest = 0xffff,
};

pub const MessageType = union(enum) {
    pair: pair_message.PairMessage,

    fn serialize(self: MessageType) [247]u8 {
        switch (self) {
            inline else => |impl| {
                const serialized_message = impl.serialize();
                var final_serialized_message = [_]u8{0} ** 247;
                std.mem.copyForwards(u8, &final_serialized_message, &serialized_message);
                return serialized_message;
            },
        }
    }

    fn deserialize(message_task: MessageTask, binary_data: [247]u8) MessageType {
        const message_type = switch (message_task) {
            .pair => {
                const msg = pair_message.PairMessage.deserialize(&binary_data);
                return MessageType{
                    .pair = msg,
                };
            },
            else => unreachable,
        };
        return message_type;
    }
};

pub const HomeNowProtocol = struct {
    version: HomeNowVersion = HomeNowVersion.v0_0_0, // 2 B
    message_task: MessageTask, // 1 B
    content: MessageType, // 247 B

    pub fn serialize(self: HomeNowProtocol) [250]u8 {
        var content = [_]u8{0} ** 250;
        var current_mem_offset: usize = 0;

        const version_u16: u16 = @intFromEnum(self.version);
        var version_bytes: [2]u8 = @bitCast(version_u16);

        const offset = current_mem_offset + version_bytes.len;
        std.mem.copyForwards(u8, content[current_mem_offset..offset], &version_bytes);
        current_mem_offset += offset;

        const message_task_u8: u8 = @intFromEnum(self.message_task);
        content[current_mem_offset] = message_task_u8;
        current_mem_offset += 1;

        const serialized_data = self.content.serialize();
        std.debug.assert(serialized_data.len == 247);
        std.mem.copyForwards(u8, content[current_mem_offset..], &serialized_data);

        return content;
    }

    pub fn deserialize(binary_data: [250]u8) HomeNowProtocol {
        const version_slice = binary_data[0..2];
        const version_val: u16 = (@as(u16, version_slice[0]) << 8) | version_slice[1];
        const version: HomeNowVersion = @enumFromInt(version_val);
        var current_pos: usize = 2;

        const message_task: MessageTask = @enumFromInt(binary_data[current_pos]);
        current_pos += 1;

        var message_content = [_]u8{0} ** 247;
        std.mem.copyForwards(u8, &message_content, binary_data[current_pos..]);
        const msg_content = MessageType.deserialize(message_task, message_content);

        // constructing HomeNowProtocol
        const homenow_protocol = HomeNowProtocol{
            .version = version,
            .message_task = message_task,
            .content = msg_content,
        };
        return homenow_protocol;
    }
};

test "single serialization and deserialization equalization of HomeNowProtocol" {
    const msg = [_]u8{ 10, 20, 30 };
    const sub_task = 1;
    const message_content = pair_message.PairMessage.init(sub_task, &msg);
    const home = HomeNowProtocol{
        .version = HomeNowVersion.vtest,
        .message_task = MessageTask.pair,
        .content = MessageType{ .pair = message_content },
    };

    const home_bytes = home.serialize();
    try expect(home_bytes.len == 250);

    const homenow_protocol = HomeNowProtocol.deserialize(home_bytes);

    const equal = std.meta.eql(homenow_protocol, home);
    try expect(equal);
}
