const std = @import("std");
const expect = std.testing.expect;
const assert = std.debug.assert;

const CONTENT_LEN = 247;

pub const GetMessage = struct {
    content: [CONTENT_LEN]u8,

    pub fn init(content: []const u8) GetMessage {
        assert(content.len <= CONTENT_LEN);

        var message_content = [_]u8{0} ** CONTENT_LEN;
        std.mem.copyForwards(u8, &message_content, &content);

        return .{
            .content = message_content,
        };
    }
};
