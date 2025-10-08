const std = @import("std");
const _g = @import("_glfw_glad_.zig").import;

const C_STR = [:0]const u8;

pub const OPENGL = @import("_glfw_glad_.zig").import;

// Utils
pub const ObjectChain = @import("Utils/ObjectChain.zig");
pub const NamedTypeCode = @import("Utils/NamedTypeCode.zig");
pub const Reporter = @import("Utils/Reporter.zig");
pub const Event = @import("Builtins/Event.zig").Event;

pub const Windows = @import("Rendering/Windows.zig");
pub const Shaders = @import("Rendering/Shaders.zig");

var allocator: ?std.mem.Allocator = null;

pub const GlobalState = struct {
    const MainLoopCall = *const fn () void;
    const ErrorCallback = ?*const fn (i32, []const u8) void;

    is_initialized: bool = false,

    context: ?*const Windows.Window = null,
    gladVersion: i32 = 0,

    user_error_callback: ErrorCallback = null,

<<<<<<< HEAD
=======
    should_close: bool = false,

    main_loops: Event(MainLoopCall) = undefined,

>>>>>>> origin
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

<<<<<<< HEAD
    // pub fn
=======
    pub fn main_loop() void {
        // Init main loop

        // Call mainloop subscribers
        while (globalState.main_loops.enumerate()) |main_loop_call| {
            main_loop_call();
        }

        // End main loop
        _g.glfwPollEvents();
    }
>>>>>>> origin
};

var globalState = GlobalState{};

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

<<<<<<< HEAD
=======
    globalState.main_loops = try Event(GlobalState.MainLoopCall).init(allocator.?, 0.5);

>>>>>>> origin
    globalState.is_initialized = true;
}

pub fn deinit() void {
    globalState.is_initialized = false;
    allocator = null;
    Reporter.deinit();
    _g.glfwTerminate();
}

pub fn _test() !void {
    try init(std.heap.page_allocator);

    const window = try Windows.Window.create(640, 480, "OpenGL Triangle", null, null);
    try GlobalState.set_context(&window);

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
    _ = prog;

    while (!globalState.should_close) {
        GlobalState.main_loop();
    }

    deinit();
}
