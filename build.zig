const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zgl_mod = b.createModule(.{
        .root_source_file = b.path("ZGLGraphics/ZGL.zig"),
        .optimize = optimize,
        .target = target,
    });

    zgl_mod.addIncludePath(b.path("deps/glad/include"));
    zgl_mod.addCSourceFile(.{
        .file = b.path("deps/glad/src/gl.c"),
        .language = .c,
        //.flags: = .{"-Ideps/glad/include"},
    });
    zgl_mod.addIncludePath(b.path("deps/GLFW"));
    zgl_mod.addLibraryPath(b.path("deps/GLFW"));
    zgl_mod.linkSystemLibrary("mingw32", .{});
    zgl_mod.linkSystemLibrary("opengl32", .{});
    zgl_mod.linkSystemLibrary("gdi32", .{});
    zgl_mod.linkSystemLibrary("user32", .{});
    zgl_mod.linkSystemLibrary("shell32", .{});
    zgl_mod.linkSystemLibrary("kernel32", .{});
    zgl_mod.linkSystemLibrary("glfw3", .{});

    const exe = b.addExecutable(.{
        .name = "MyEngine",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "zgl", .module = zgl_mod }},
        }),
    });

    exe.linkLibC();

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_exe_tests.step);
}
