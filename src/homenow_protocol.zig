const std = @import("std");
const pair_message = @import("messages/pair_message.zig");
const expect = std.testing.expect;

const MessageTask = enum(u8) { get = 0x00, set = 0x01, update = 0x02, pair = 0x03 };

const MessageType = union(enum) { pair: pair_message.PairMessage };

const HomeNowProtocol = struct {
    version: u16 = 0x0001,
    message_task: MessageTask,
    content: MessageType,

    fn serialize(self: *HomeNowProtocol) []u8 {
        _ = self;
        return .{ 9, 9 };
    }

    fn deserialize(content: []const u8) HomeNowProtocol {
        _ = content;

        const msg_task = MessageTask.get;
        const msg_type = MessageType{ .pair = pair_message.PairMessage{ .subtask = 0x01, .device_type = [_]u8{1} ** 244 } };
        return HomeNowProtocol{ .version = 0x0001, .message_task = msg_task, .content = msg_type };
    }
};

test "check correct sizes" {
    const content = [_]u8{ 1, 3, 4, 7 };
    const home = HomeNowProtocol.deserialize(&content);
    std.debug.print("{any}", .{home});
}
