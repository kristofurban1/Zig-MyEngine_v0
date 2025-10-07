const std = @import("std");
const ZGL = @import("../ZGL.zig");

const ObjectChain = ZGL.ObjectChain;
const Reporter = ZGL.Reporter;
const _g = ZGL.OPENGL;

pub const WindowHint = struct { hint: i32, value: i32 };

pub const Window = struct {
    window_title: [:0]const u8,
    window: *_g.GLFWwindow,
    swap_interval: i32 = 1,

    pub fn create(width: u32, height: u32, title: [:0]const u8, monitor: ?*_g.GLFWmonitor, share: ?*Window) !@This() {
        Reporter.report(.Info, "Creating window [{s}]...", .{title});

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

        return .{
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

    pub fn frame(self: *@This()) !void {
        ZGL.GlobalState.set_context(self);

        self.set_swap_interval(self.swap_interval);

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
