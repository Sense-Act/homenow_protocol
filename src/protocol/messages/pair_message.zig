const std = @import("std");
const conf = @import("../../config.zig");
const expect = std.testing.expect;

const DEVICE_TYPE_LEN = 246;

pub const PairMessage = struct {
    subtask: u8, // 1 B
    device_type: [DEVICE_TYPE_LEN]u8,

    pub fn init(subtask: u8, device_type: []const u8) PairMessage {
        std.debug.assert(device_type.len <= DEVICE_TYPE_LEN);
        var content = [_]u8{0} ** DEVICE_TYPE_LEN;
        std.mem.copyForwards(u8, &content, device_type);
        return .{
            .subtask = subtask,
            .device_type = content,
        };
    }

    pub fn serialize(self: PairMessage) [conf.CONTENT_LEN]u8 {
        var content = [_]u8{0} ** conf.CONTENT_LEN;
        content[0] = self.subtask;
        std.mem.copyForwards(u8, content[1..], &self.device_type);

        return content;
    }

    pub fn deserialize(content: []const u8) PairMessage {
        std.debug.assert(content.len >= 2 and content.len <= conf.CONTENT_LEN);
        const subtask = content[0];
        var device_type = [_]u8{0} ** DEVICE_TYPE_LEN;
        std.mem.copyForwards(u8, &device_type, content[1..]);

        return .{
            .subtask = subtask,
            .device_type = device_type,
        };
    }
};

test "single serialization and deserialization equalization of PairMessage" {
    const sub_task = 3;
    const device_type = [_]u8{ 2, 3, 5, 10, 19, 1 };
    const pair_message = PairMessage.init(sub_task, &device_type);

    const pair_message_ser = pair_message.serialize();
    const pair_message_des = PairMessage.deserialize(&pair_message_ser);
    try expect(std.meta.eql(pair_message, pair_message_des));
}
