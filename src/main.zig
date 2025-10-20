//const std = @import("std");
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

    const Vec3_i32 = Vectors.Vector(i32, 3);
    const Vec2_i32 = Vectors.Vector(i32, 2);
    const Vec3_f32 = Vectors.Vector(f32, 3);

    const v1 = Vec3_i32{ .vector = @Vector(3, i32){ 1, 2, 3 } };
    const v2 = Vec2_i32{ .vector = @Vector(2, i32){ 4, 5 } };
    const v3 = Vec3_f32{ .vector = @Vector(3, f32){ 1.0, 2.2, 3.5 } };

    _ = Vectors.VectorOperations.add(v1, false);

    _ = Vectors.VectorOperations.add(v1, v2);

    _ = Vectors.VectorOperations.add(v1, v3);

    _ = Vectors.VectorOperations.add(v1, v1);
}
