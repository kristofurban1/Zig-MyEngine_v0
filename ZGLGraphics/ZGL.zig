const std = @import("std");
const _g = @import("_glfw_glad_.zig").import;

const C_STR = [:0]const u8;

pub const OPENGL = @import("_glfw_glad_.zig").import;

// Utils
pub const ObjectChain = @import("Utils/ObjectChain.zig");
pub const NamedTypeCode = @import("Utils/NamedTypeCode.zig");
pub const Reporter = @import("Utils/Reporter.zig");

pub const Windows = @import("Rendering/Windows.zig");
pub const Shaders = @import("Rendering/Shaders.zig");

var allocator: ?std.mem.Allocator = null;

pub const GlobalState = struct {
    const ErrorCallback = ?*const fn (i32, u8) void;

    is_initialized: bool = false,

    context: ?*Windows.Window = null,
    gladVersion: i32 = 0,

    user_error_callback: ErrorCallback = null,

    fn init_assert() void {
        if (!globalState.is_initialized) unreachable;
    }

    fn glfw_error_callback(error_code: c_int, description: [*c]const u8) callconv(.c) void {
        if (globalState.user_error_callback) |callback| {
            callback(error_code, description);
        } else {
            try Reporter.report(.Error, "GLFW Error [{d}]\n{s}\n", .{ error_code, description });
        }
    }

    pub fn set_glfw_error_callback(callback: ErrorCallback) void {
        init_assert();
        globalState.user_error_callback = callback;
    }

    pub fn set_context(window: Windows.Window) !void {
        init_assert();
        globalState.context = window;

        if (globalState.gladVersion == 0) {
            globalState.gladVersion = _g.gladLoadGL(_g.glfwGetProcAddress);
            if (globalState.gladVersion == 0) {
                try Reporter.report(.Critical, "GLAD Loading has failed!", .{});
                return error.GLAD_LOAD_FAILED;
            }
            try Reporter.report(.Info, "GLAD Version: {s}", .{_g.glGetString(_g.GL_VERSION)});
        }
    }

    // pub fn
};

var globalState = GlobalState{};

pub fn init(_allocator: std.mem.Allocator) !void {
    if (allocator != null) unreachable;
    allocator = _allocator;
    if (allocator == null) unreachable;

    _ = _g.glfwSetErrorCallback(GlobalState.glfw_error_callback);
    try Reporter.init(allocator.?);

    if (_g.glfwInit() == 0) {
        try Reporter.report(.Critical, "GLFW Initialization failure!", .{});
        return error.GLFW_INIT_FAIL;
    }

    globalState.is_initialized = true;
}

pub fn deinit() !void {}

pub fn _test() !void {
    try init(std.heap.page_allocator);

    const window = try Windows.Window.create(640, 480, "OpenGL Triangle", null, null);
    try globalState.set_context(window);

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

    const prog = try Shaders.ShaderProgramCompiler(@TypeOf(shader_chain)).compile_shader(shader_chain, "Basic");

    Reporter.deinit();
    _g.glfwTerminate();
}
