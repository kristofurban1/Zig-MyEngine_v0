const std = @import("std");
const ZGL = @import("zgl");

fn reporter_callback(report: ZGL.Reporter.Report) void {
    std.debug.print("-- {s} --: {s}\n", .{ @tagName(report.level), report.message });
}

fn test_event() void {
    ZGL.Reporter.report(.Info, "Hey there i am looper!", .{});
}

pub fn main() !void {
    ZGL.Reporter.set_immidiate_callback(reporter_callback);
    try ZGL.init(std.heap.page_allocator);

    try ZGL.GlobalState.main_loop_event().connect(test_event);

    try ZGL._test();
}
