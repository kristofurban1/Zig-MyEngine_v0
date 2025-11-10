const std = @import("std");
const _g = @import("_glfw_glad_.zig").import;

const C_STR = [:0]const u8;

pub const OPENGL = @import("_glfw_glad_.zig").import;

// Utils
pub const ObjectChain = @import("Utils/ObjectChain.zig");
pub const NamedTypeCode = @import("Utils/NamedTypeCode.zig");
pub const Reporter = @import("Utils/Reporter.zig");
pub const Event = @import("Builtins/Event.zig").Event;

pub const Vectors = @import("Builtins/Vectors.zig");
pub const Matrices = @import("Builtins/Matrices.zig");

pub const Windows = @import("Rendering/Windows.zig");
pub const ShaderBuilderChain = @import("Rendering/ShaderBuilderChain.zig");
pub const Shaders = @import("Rendering/Shaders.zig");
pub const ShaderUniforms = @import("Rendering/ShaderUniforms.zig");
pub const VertexData = @import("Rendering/VertexData.zig");

var allocator: ?std.mem.Allocator = null;

pub const GlobalState = struct {
    const MainLoopCall = *const fn () void;
    const MainLoopEvent = Event(MainLoopCall);
    const ErrorCallback = ?*const fn (i32, []const u8) void;

    is_initialized: bool = false,

    context: ?*const Windows.Window = null,
    gladVersion: i32 = 0,

    user_error_callback: ErrorCallback = null,

    should_close: bool = false,

    main_loops: MainLoopEvent = undefined,

    fn init_assert() void {
        if (!globalState.is_initialized) unreachable;
    }

    fn glfw_error_callback(error_code: c_int, _description: [*c]const u8) callconv(.c) void {
        const description: []const u8 = std.mem.span(_description);
        if (globalState.user_error_callback) |callback| {
            callback(error_code, description);
        } else {
            Reporter.report(.Error, "GLFW Error [{d}]\n{s}\n", .{ error_code, description });
        }
    }

    pub fn set_glfw_error_callback(callback: ErrorCallback) void {
        init_assert();
        globalState.user_error_callback = callback;
    }

    pub fn is_glad_intialized() bool {
        return globalState.gladVersion != 0;
    }

    pub fn set_context(window: *const Windows.Window) !void {
        init_assert();
        globalState.context = window;
        _g.glfwMakeContextCurrent(window.window);

        if (globalState.gladVersion == 0) {
            globalState.gladVersion = _g.gladLoadGL(_g.glfwGetProcAddress);
            if (!is_glad_intialized()) {
                Reporter.report(.Critical, "GLAD Loading has failed!", .{});
                return error.GLAD_LOAD_FAILED;
            }
            Reporter.report(.Info, "GLAD Version: {s}", .{_g.glGetString(_g.GL_VERSION)});
        }
    }

    pub fn main_loop_event() *MainLoopEvent {
        return &globalState.main_loops;
    }

    pub fn main_loop() void {
        // Init main loop

        // Call mainloop subscribers
        globalState.main_loops.fire(.{});

        // End main loop
        _g.glfwPollEvents();
    }
};

var globalState = GlobalState{};

fn get_time_wrapper() f64 {
    return _g.glfwGetTime();
}

pub fn init(_allocator: std.mem.Allocator) !void {
    if (allocator != null) unreachable;
    allocator = _allocator;
    if (allocator == null) unreachable;

    _ = _g.glfwSetErrorCallback(GlobalState.glfw_error_callback);
    try Reporter.init(_allocator);

    if (_g.glfwInit() == 0) {
        Reporter.report(.Critical, "GLFW Initialization failure!", .{});
        return error.GLFW_INIT_FAIL;
    }

    Reporter.set_getTimeFn(get_time_wrapper);

    globalState.main_loops = try Event(GlobalState.MainLoopCall).init(allocator.?);

    globalState.is_initialized = true;
}

pub fn deinit() void {
    globalState.is_initialized = false;
    allocator = null;
    Reporter.deinit();
    _g.glfwTerminate();
}

pub fn _test(_allocator: std.mem.Allocator) !void {
    const window = try Windows.Window.create(640, 480, "OpenGL Triangle", null, null, null, allocator.?);
    try GlobalState.set_context(&window);

    const Shader = Shaders.Shader;

    const Uniform_Vector2I = ShaderUniforms.ShaderUniformType(.{ .vector = .{ .vectorType = .Integer, .length = 2 } });

    const shader_chain = comptime c: {
        const shader_chain = ShaderBuilderChain.CreateShaderBuilderChain()
            .chain(Shader{
                .type = .VERTEX,
                .program = @embedFile("vert.glsl"),
            })
            .chain(Shader{
                .type = .FRAGMENT,
                .program = @embedFile("frag.glsl"),
            })
            .chain(Uniform_Vector2I.create("Resolution"));
        break :c shader_chain;
    };

    const prog = try Shaders.ShaderProgramCompiler(shader_chain).compile_shader("Basic", _allocator);
    _ = prog;

    if (true) return;

    while (!globalState.should_close) {
        GlobalState.main_loop();
    }

    deinit();
}
