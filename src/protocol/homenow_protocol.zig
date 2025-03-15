const std = @import("std");
const conf = @import("../config.zig");
const pair_message = @import("messages/pair_message.zig");
const generic_message = @import("messages/generic_message.zig");
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
    get: generic_message.GenericMessage,
    set: generic_message.GenericMessage,
    update: generic_message.GenericMessage,

    fn serialize(self: MessageType) [conf.CONTENT_LEN]u8 {
        switch (self) {
            inline else => |impl| {
                const serialized_message = impl.serialize();
                var final_serialized_message = [_]u8{0} ** conf.CONTENT_LEN;
                std.mem.copyForwards(u8, &final_serialized_message, &serialized_message);
                return serialized_message;
            },
        }
    }

    fn deserialize(message_task: MessageTask, binary_data: [conf.CONTENT_LEN]u8) MessageType {
        const message_type = switch (message_task) {
            .get => {
                const msg = generic_message.GenericMessage.deserialize(&binary_data);
                return .{
                    .get = msg,
                };
            },
            .set => {
                const msg = generic_message.GenericMessage.deserialize(&binary_data);
                return .{
                    .set = msg,
                };
            },
            .update => {
                const msg = generic_message.GenericMessage.deserialize(&binary_data);
                return .{
                    .update = msg,
                };
            },
            .pair => {
                const msg = pair_message.PairMessage.deserialize(&binary_data);
                return .{
                    .pair = msg,
                };
            },
        };
        return message_type;
    }
};

pub const HomeNowProtocol = struct {
    version: HomeNowVersion = HomeNowVersion.v0_0_0, // 2 B
    message_task: MessageTask, // 1 B
    content: MessageType, // 247 B

    pub fn serialize(self: HomeNowProtocol) [conf.TOTAL_CONTENT_LEN]u8 {
        var content = [_]u8{0} ** conf.TOTAL_CONTENT_LEN;
        var current_mem_offset: usize = 0;

        const version_u16: u16 = @intFromEnum(self.version);
        var version_bytes: [conf.VERSION_LEN]u8 = @bitCast(version_u16);

        const offset = current_mem_offset + version_bytes.len;
        std.mem.copyForwards(u8, content[current_mem_offset..offset], &version_bytes);
        current_mem_offset += offset;

        const message_task_u8: u8 = @intFromEnum(self.message_task);
        content[current_mem_offset] = message_task_u8;
        current_mem_offset += 1;

        const serialized_data = self.content.serialize();
        std.debug.assert(serialized_data.len == conf.CONTENT_LEN);
        std.mem.copyForwards(u8, content[current_mem_offset..], &serialized_data);

        return content;
    }

    pub fn deserialize(binary_data: [conf.TOTAL_CONTENT_LEN]u8) HomeNowProtocol {
        const version_slice = binary_data[0..2];
        const version_val: u16 = (@as(u16, version_slice[0]) << 8) | version_slice[1];
        const version: HomeNowVersion = @enumFromInt(version_val);
        var current_pos: usize = 2;

        const message_task: MessageTask = @enumFromInt(binary_data[current_pos]);
        current_pos += 1;

        var message_content = [_]u8{0} ** conf.CONTENT_LEN;
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

test "get" {
    const version = HomeNowVersion.vtest;
    const msg_task = MessageTask.get;

    const msg = "Hello world how are you?";
    var msg_container = [_]u8{0} ** conf.CONTENT_LEN;
    std.mem.copyForwards(u8, &msg_container, msg);
    const content = generic_message.GenericMessage.init(&msg_container);

    const home = HomeNowProtocol{
        .version = version,
        .message_task = msg_task,
        .content = MessageType{ .get = content },
    };
    const serialize = home.serialize();
    const deserialize = HomeNowProtocol.deserialize(serialize);

    try expect(std.meta.eql(deserialize, home));
}

test "set" {
    const version = HomeNowVersion.vtest;
    const msg_task = MessageTask.set;

    const msg = "Hello world how are you?";
    var msg_container = [_]u8{0} ** conf.CONTENT_LEN;
    std.mem.copyForwards(u8, &msg_container, msg);
    const content = generic_message.GenericMessage.init(&msg_container);

    const home = HomeNowProtocol{
        .version = version,
        .message_task = msg_task,
        .content = MessageType{ .set = content },
    };
    const serialize = home.serialize();
    const deserialize = HomeNowProtocol.deserialize(serialize);

    try expect(std.meta.eql(deserialize, home));
}

test "update" {
    const version = HomeNowVersion.vtest;
    const msg_task = MessageTask.update;

    const msg = "Hello world how are you?";
    var msg_container = [_]u8{0} ** conf.CONTENT_LEN;
    std.mem.copyForwards(u8, &msg_container, msg);
    const content = generic_message.GenericMessage.init(&msg_container);

    const home = HomeNowProtocol{
        .version = version,
        .message_task = msg_task,
        .content = MessageType{ .update = content },
    };
    const serialize = home.serialize();
    const deserialize = HomeNowProtocol.deserialize(serialize);

    try expect(std.meta.eql(deserialize, home));
}

test "pair" {
    const msg = [_]u8{ 10, 20, 30 };
    const sub_task = 1;
    const message_content = pair_message.PairMessage.init(sub_task, &msg);
    const home = HomeNowProtocol{
        .version = HomeNowVersion.vtest,
        .message_task = MessageTask.pair,
        .content = MessageType{ .pair = message_content },
    };

    const home_bytes = home.serialize();
    try expect(home_bytes.len == conf.TOTAL_CONTENT_LEN);

    const homenow_protocol = HomeNowProtocol.deserialize(home_bytes);

    const equal = std.meta.eql(homenow_protocol, home);
    try expect(equal);
}
