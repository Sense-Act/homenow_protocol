const std = @import("std");
const expect = std.testing.expect;

pub const PairMessage = struct {
    subtask: u8, // 1 B
    device_type: [246]u8, // 246 B

    pub fn init(subtask: u8, device_type: []const u8) PairMessage {
        std.debug.assert(device_type.len <= 246);
        var content = [_]u8{0} ** 246;
        std.mem.copyForwards(u8, &content, device_type);
        return .{
            .subtask = subtask,
            .device_type = content,
        };
    }

    pub fn serialize(self: PairMessage) [247]u8 {
        var content = [_]u8{0} ** 247;
        content[0] = self.subtask;
        std.mem.copyForwards(u8, content[1..], &self.device_type);

        return content;
    }

    pub fn deserialize(content: []const u8) PairMessage {
        std.debug.assert(content.len >= 2 and content.len <= 247);
        const subtask = content[0];
        var device_type = [_]u8{0} ** 246;
        std.mem.copyForwards(u8, &device_type, content[1..]);

        return PairMessage{
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
