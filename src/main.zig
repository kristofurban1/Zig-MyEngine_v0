const std = @import("std");
const ZGL = @import("zgl");
//
// fn reporter_callback(report: ZGL.Reporter.Report) void {
//     std.debug.print("-- {s} --: {s}\n", .{ @tagName(report.level), report.message });
// }

pub fn main() !void {
    // ZGL.Reporter.set_immidiate_callback(&reporter_callback);

    try ZGL._test();
}
