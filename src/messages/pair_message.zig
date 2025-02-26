const std = @import("std");

pub const PairMessage = struct {
    subtask: u8,
    device_type: [244]u8,

    pub fn serialize(self: PairMessage) [245]u8 {
        var content = [_]u8{0} ** 245;
        content[0] = self.subtask;
        std.mem.copyForwards(u8, content[1..], &self.device_type);

        return content;
    }
};
