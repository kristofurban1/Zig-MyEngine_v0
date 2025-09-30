const std = @import("std");
const ZGL = @import("zgl");
//
// fn reporter_callback(report: ZGL.Reporter.Report) void {
//     std.debug.print("-- {s} --: {s}\n", .{ @tagName(report.level), report.message });
// }

pub fn main() !void {
    // ZGL.Reporter.set_immidiate_callback(&reporter_callback);

    try ZGL.Shaders.init(std.heap.page_allocator);
    const Shader = ZGL.Shaders.Shader;

    const shader_chain = ZGL.ObjectChain.CreateChain(Shader)
        .chain(Shader{
            .shader_type = .VERTEX,
            .shader_program = @embedFile("vert.glsl"),
        })
        .chain(Shader{
        .shader_type = .FRAGMENT,
        .shader_program = @embedFile("frag.glsl"),
    });

    const prog = try ZGL.Shaders.create_render_shader(shader_chain, "Basic");
    _ = try ZGL.Shaders.manage_shader(prog);

    ZGL.Shaders.deinit();
}
