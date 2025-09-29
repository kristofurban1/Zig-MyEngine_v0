const std = @import("std");
const _g = @import("_glfw_glad_.zig").import;

const C_STR = [:0]const u8; 


pub const Reporter = @import("Reporter.zig");
pub const Shaders = @import("Shaders.zig");

fn glfw_error_callback(error_code: c_int, description: [*c]const u8) callconv(.c) void {
    std.debug.print("GLFW ERROR {d}: {s}\n", .{ error_code, description });
}

pub fn _test() !void {
    _ = _g.glfwSetErrorCallback(&glfw_error_callback);

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

    while (_g.glfwWindowShouldClose(window) == 0) {
        _g.glfwSwapBuffers(window);
        _g.glfwPollEvents();
    }

    _g.glfwDestroyWindow(window);

    _g.glfwTerminate();
}
