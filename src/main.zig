const std = @import("std");
//const ZGL = @import("zgl");

const Vectors = @import("zgl").Vectors;

// fn reporter_callback(report: ZGL.Reporter.Report) void {
//     std.debug.print(ZGL.Reporter.Report.FMT_DEFAULT, .{ report.timestamp, report.level.name(), report.message });
// }

// fn test_event() void {
//     ZGL.Reporter.report(.Info, "Hey there i am looper!", .{});
// }

pub fn main() !void {
    // ZGL.Reporter.set_immidiate_callback(reporter_callback);
    // try ZGL.init(std.heap.page_allocator);

    // try ZGL.GlobalState.main_loop_event().connect(test_event);

    // try ZGL._test();

    const v1 = Vectors.Vector3{ .raw_vector = [_]f32{ 1, 2, 3 } };
    const v2 = Vectors.Vector3{ .raw_vector = [_]f32{ 10, 20, 30 } };

    const result = v1.add(v2);
    std.debug.print("Result: {}\n", .{result.raw_vector});
    const result2 = v1.sub(v2);
    std.debug.print("Result: {}\n", .{result2.raw_vector});
    const result3 = v1.scalar_mult(5);
    std.debug.print("Result: {}\n", .{result3.raw_vector});
    const r4 = v1.abs();
    std.debug.print("Result: {}\n", .{r4});
    const r5 = v1.mult(v2);
    std.debug.print("Result: {}\n", .{r5.raw_vector});
    const r6 = v1.dot(v2);
    std.debug.print("Result: {}\n", .{r6});

    const v3 = Vectors.Vector2.init(.{ 1, 0 });
    const v4 = Vectors.Vector2.init(.{ 0, 1 });
    const r7 = v3.angle(v4);
    std.debug.print("Result: {}\n", .{std.math.radiansToDegrees(r7)});

    const r8 = v1.cross(v2);
    std.debug.print("Result: {}\n", .{r8});
}
