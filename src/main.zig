const std = @import("std");
const ZGL = @import("zgl");

fn reporter_callback(report: ZGL.Reporter.Report) void {
    std.debug.print("-- {s} --: {s}\n", .{ @tagName(report.level), report.message });
}

pub fn main() !void {
    ZGL.Reporter.set_immidiate_callback(&reporter_callback);

    const Shader = ZGL.Shaders.ShaderProgram.Shader;
    const shader = Shader{
        .shader_type = .VERTEX,
        .shader_program = @embedFile("vert.glsl"),
        .next_in_chain = &Shader{
            .shader_type = .FRAGMENT,
            .shader_program = @embedFile("frag.glsl"),
            .next_in_chain = null,
        },
    };
    const prog = try ZGL.Shaders.create_render_shader(shader, "Basic");
    ZGL.Shaders.manage_shader(prog);
}
