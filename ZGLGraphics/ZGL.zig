const std = @import("std");
const _g = @import("_glfw_glad_.zig").import;

const C_STR = [:0]const u8;

pub const Reporter = @import("Reporter.zig");
pub const Shaders = @import("Shaders.zig");
pub const ObjectChain = @import("ObjectChain.zig");

fn glfw_error_callback(error_code: c_int, description: [*c]const u8) callconv(.c) void {
    std.debug.print("GLFW ERROR {d}: {s}\n", .{ error_code, description });
}

pub fn _test() !void {
    _ = _g.glfwSetErrorCallback(&glfw_error_callback);

    const allocator = std.heap.page_allocator;
    try Shaders.init(allocator);
    try Reporter.init(allocator);

    if (_g.glfwInit() == 0) {
        std.debug.print("GLFW INITIALIZATION FAILURE\n", .{});
        return error.GLFW_INIT_FAIL;
    }

    _g.glfwWindowHint(_g.GLFW_CONTEXT_VERSION_MAJOR, 3);
    _g.glfwWindowHint(_g.GLFW_CONTEXT_VERSION_MINOR, 3);
    _g.glfwWindowHint(_g.GLFW_OPENGL_PROFILE, _g.GLFW_OPENGL_CORE_PROFILE);

    const window = _g.glfwCreateWindow(640, 480, "OpenGL Triangle", null, null);
    if (window == null) {
        _g.glfwTerminate();

        std.debug.print("GLFW WINDOW FAILURE\n", .{});
        return error.GLFW_WINDOW_FAIL;
    }

    _g.glfwMakeContextCurrent(window);
    _ = _g.gladLoadGL(_g.glfwGetProcAddress);
    _g.glfwSwapInterval(1);

    const Shader = Shaders.Shader;

    const shader_chain = ObjectChain.CreateChain(Shader)
        .chain(Shader{
            .type = .VERTEX,
            .program = @embedFile("vert.glsl"),
        })
        .chain(Shader{
        .type = .FRAGMENT,
        .program = @embedFile("frag.glsl"),
    });

    const prog: ?Shaders.ShaderProgram = Shaders.ShaderProgramCompiler(ObjectChain.ObjChain(Shader, 2)).compile_shader(shader_chain, "Basic") catch null;
    if (prog == null) {
        std.debug.print("Shader Creation failure caught\n", .{});
    } else _ = try Shaders.manage_shader(prog.?);

    const reports = try Reporter.read_buffer_raw();
    defer allocator.free(reports);
    for (reports) |report| {
        std.debug.print("--{s}-- {s}\n", .{ @tagName(report.level), report.message });
        report.deinit();
    }

    while (_g.glfwWindowShouldClose(window) == 0) {
        _g.glfwSwapBuffers(window);
        _g.glfwPollEvents();
    }

    _g.glfwDestroyWindow(window);
    try Shaders.deinit();
    Reporter.deinit();
    _g.glfwTerminate();
}
