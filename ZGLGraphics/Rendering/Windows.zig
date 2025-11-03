const std = @import("std");
const ZGL = @import("../ZGL.zig");

const ObjectChain = ZGL.ObjectChain;
const Reporter = ZGL.Reporter;
const _g = ZGL.OPENGL;
const Vector4 = ZGL.Vectors.Vector(f32, 4);

pub const WindowHint = struct { hint: i32, value: i32 };

pub const Window = struct {
    allocator: std.mem.Allocator = undefined,
    glad_version: i32 = 0,

    window_title: [:0]const u8,
    window: *_g.GLFWwindow,
    swap_interval: i32 = 1,
    clear_color: Vector4 = Vector4.splat(0),

    

    pub fn create(
        width: u32,
        height: u32,
        title: [:0]const u8,
        monitor: ?*_g.GLFWmonitor,
        share: ?*Window,
        hints: anytype,
        allocator: std.mem.Allocator,
    ) !@This() {
        Reporter.report(.Info, "Creating window [{s}]...", .{title});

        _ = hints;
        _g.glfwWindowHint(_g.GLFW_CONTEXT_VERSION_MAJOR, 4);
        _g.glfwWindowHint(_g.GLFW_CONTEXT_VERSION_MINOR, 5);
        _g.glfwWindowHint(_g.GLFW_OPENGL_PROFILE, _g.GLFW_OPENGL_CORE_PROFILE);

        _ = share;
        const _share: ?*_g.GLFWwindow = null;

        const window = _g.glfwCreateWindow(
            @intCast(width),
            @intCast(height),
            title,
            monitor,
            _share,
        );

        if (window == null) {
            Reporter.report(.Critical, "Window Creation failed! [{s}]", .{title});
            return error.GLFW_WINDOW_FAIL;
        }

        _g.glfwMakeContextCurrent(window);
        const gladVersion = _g.gladLoadGL(_g.glfwGetProcAddress);
        if (gladVersion == 0) {
            Reporter.report(.Critical, "GLAD Loading has failed!", .{});
            return error.GLAD_LOAD_FAILED;
        }
        Reporter.report(.Info, "GLAD Version: {s}", .{_g.glGetString(_g.GL_VERSION)});

        return .{
            .allocator = allocator,
            .window_title = title,
            .window = window.?,
            .swap_interval = 1,
        };
    }

    pub fn set_swap_interval(self: *@This(), interval: i32) void {
        if (self.swap_interval == interval) return;
        self.*.swap_interval = interval;
        _g.glfwSwapInterval(interval);
    }

    pub fn set_clear_color(self: *@This(), color: Vector4) void {
        self.clear_color = color;
    }

    pub fn frame(self: *@This()) !void {
        ZGL.GlobalState.set_context(self);

        self.set_swap_interval(self.swap_interval);

        const r, const g, const b, const a = self.clear_color.raw_vector;
        _g.glClearColor(r, g, b, a);
        _g.glClear(_g.GL_COLOR_BUFFER_BIT);

        if (_g.glfwWindowShouldClose(self.window)) {
            try Reporter.report(.Info, "Window Closed! [{s}]", .{self.window_title});
            return;
        }

        _g.glfwSwapBuffers(self.window);
        _g.glfwPollEvents();
    }

    pub fn deinit(self: @This()) !void {
        try Reporter.report(.Info, "Deleting window [{s}]...", .{self.window_title});

        _g.glfwDestroyWindow(self.window);
    }
};
