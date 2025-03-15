const std = @import("std");
const hn = @import("protocol/homenow_protocol.zig");
const hn_pair = @import("protocol/messages/pair_message.zig");
const expect = std.testing.expect;

pub fn create_pair_message(subtask: u8, device_type: []const u8) hn.HomeNowProtocol {
    const pair_msg = hn_pair.PairMessage.init(subtask, device_type);

    const content = hn.MessageType{
        .pair = pair_msg,
    };

    const home_now_msg = hn.HomeNowProtocol{
        .message_task = hn.MessageTask.pair,
        .content = content,
    };

    return home_now_msg;
}

test "creating pair" {
    const device_type = "switch";
    const home_now_msg = create_pair_message(2, device_type);
    const content = home_now_msg.content.pair.device_type[0..device_type.len];
    try expect(std.mem.eql(
        u8,
        device_type,
        content,
    ));
}
