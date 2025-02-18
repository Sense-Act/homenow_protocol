const std = @import("std");
const net = @import("sub/net.zig");

pub export fn add(a: i32, b: i32) i32 {
    return a + b;
}

pub fn say_hello() void {
    const hello = net.hello_world();
    std.debug.print("{s}", .{hello});
}

const testing = std.testing;
test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}

test "basic hello" {
    _ = say_hello();
}
