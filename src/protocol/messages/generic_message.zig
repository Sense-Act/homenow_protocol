const std = @import("std");
const conf = @import("../../config.zig");
const expect = std.testing.expect;
const assert = std.debug.assert;

pub const GenericMessage = struct {
    content: [conf.CONTENT_LEN]u8,

    pub fn init(content: []const u8) GenericMessage {
        assert(content.len <= conf.CONTENT_LEN);

        var message_content = [_]u8{0} ** conf.CONTENT_LEN;
        std.mem.copyForwards(u8, &message_content, content[0..]);

        return .{
            .content = message_content,
        };
    }

    pub fn serialize(self: GenericMessage) [conf.CONTENT_LEN]u8 {
        var message_content = [_]u8{0} ** conf.CONTENT_LEN;

        std.mem.copyForwards(u8, &message_content, &self.content);

        return message_content;
    }

    pub fn deserialize(content: []const u8) GenericMessage {
        assert(content.len <= conf.CONTENT_LEN);

        var message_content = [_]u8{0} ** conf.CONTENT_LEN;
        std.mem.copyForwards(u8, &message_content, content[0..]);

        return .{ .content = message_content };
    }
};

test "serialization and deserialization of generic message" {
    const msg = "Hello World, I am a message!";
    var msg_container = [_]u8{0} ** conf.CONTENT_LEN;
    std.mem.copyForwards(u8, &msg_container, msg);

    const generic_message = GenericMessage.init(msg);

    const serialized = generic_message.serialize();
    const unserialized = GenericMessage.deserialize(&serialized);
    try expect(std.mem.eql(u8, &unserialized.content, &msg_container));
    try expect(std.meta.eql(generic_message, unserialized));
}
