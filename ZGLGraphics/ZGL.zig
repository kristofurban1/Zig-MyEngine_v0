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

fn glfw_error_callback(error_code: c_int, description: [*c]const u8) callconv(.c) void {
    std.debug.print("GLFW ERROR {d}: {s}\n", .{ error_code, description });
}

var allocator: ?std.mem.Allocator = null;

const GlobalState = struct {
    context: ?*Windows.Window = null,
    gladVersion: i32 = 0,

    pub fn init() @This() {}

    pub fn set_context(self: *@This(), window: Windows.Window) void {
        self.*.context = window;

        if (self.gladVersion == 0)
            self.*.gladVersion = _g.gladLoadGL(_g.glfwGetProcAddress);
    }
};

pub var globalState = GlobalState.init();

pub fn init(_allocator: std.mem.Allocator) !void {
    if (allocator != null) unreachable;
    allocator = _allocator;
    if (allocator == null) unreachable;

    _ = _g.glfwSetErrorCallback(&glfw_error_callback);
    try Reporter.init(allocator.?);

    if (_g.glfwInit() == 0) {
        try Reporter.report(.Critical, "GLFW Initialization failure!", .{});
        return error.GLFW_INIT_FAIL;
    }
}

pub fn deinit() !void {}

pub fn _test() !void {
    try init(std.heap.page_allocator);

    var window = try Windows.Window.create(640, 480, "OpenGL Triangle", null, null);
    window = window;
    globalState.set_context(window);

    _ = _g.gladLoadGL(_g.glfwGetProcAddress);
    _g.glfwSwapInterval(1);

    try Reporter.report(.Info, "Opengl Version: {s}", .{_g.glGetString(_g.GL_VERSION)});

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
