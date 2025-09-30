const std = @import("std");
const testing = std.testing;
const ZGL = @import("ZGL.zig");

const _g = @import("_glfw_glad_.zig").import;
const Reporter = ZGL.Reporter;
const ObjectChain = ZGL.ObjectChain;

const NamedTypeCode = struct {
    code: u32,
    name: []const u8,
};

const ShaderVerifyInquryTypes = enum {
    GL_COMPILE_STATUS,
    GL_LINK_STATUS,
};
const ShaderVerifyInqury = [_]NamedTypeCode{
    .{ .code = 0x8B81, .name = "COMPILE" },
    .{ .code = 0x8B82, .name = "LINK" },
};

fn verify_shader(shader_id: u32, inqury: ShaderVerifyInquryTypes, shader_lable: []const u8) !void {
    var success: i32 = undefined;
    const log_len = 510;
    var infoLog: [(log_len + 2):0]u8 = undefined;
    const infoLog_ptr: [*c]u8 = &infoLog;
    _g.glGetShaderiv(shader_id, ShaderVerifyInqury[@intFromEnum(inqury)].code, &success);
    if (success != 0) {
        try Reporter.report(.Info, "Shader {s} <{s}> Success!", .{ shader_lable, ShaderVerifyInqury[@intFromEnum(inqury)].name });
    } else {
        _g.glGetShaderInfoLog(shader_id, log_len, null, infoLog_ptr);
        try Reporter.report(.Error, "Shader {s} <{s}> Faliure:\n{s}", .{ shader_lable, ShaderVerifyInqury[@intFromEnum(inqury)].name, infoLog });
        return error.ShaderVerificatonFailed;
    }
}

const ShaderTypes = enum(usize) {
    VERTEX,
    TESS_CONTROL,
    TESS_EVAL,
    GEOMETRY,
    FRAGMENT,
    COMPUTE,
};
const ShaderType = [_]NamedTypeCode{
    .{ .code = 0x8B31, .name = "VERTEX" },
    .{ .code = 0x8E88, .name = "TESS_CONTROL" },
    .{ .code = 0x8E87, .name = "TESS_EVAL" },
    .{ .code = 0x8DD9, .name = "GEOMETRY" },
    .{ .code = 0x8B30, .name = "FRAGMENT" },
    .{ .code = 0x91B9, .name = "COMPUTE" },
};

fn create_shader(shader_type: ShaderTypes, program: [:0]const u8) !u32 {
    const id = _g.glCreateShader(ShaderType[@intFromEnum(shader_type)].code);
    const _program: [*c]const [*c]const u8 = @ptrCast(&program.ptr);
    _g.glShaderSource(id, 1, _program, null);
    _g.glCompileShader(id);

    try verify_shader(id, .GL_COMPILE_STATUS, ShaderType[@intFromEnum(shader_type)].name);

    return id;
}

pub const Shader = struct {
    type: ShaderTypes,
    program: [:0]const u8,
    /// Not user managed, saves an allocation during chain evaluation. Do not modify.
    id: ?u32 = null,
};

pub const ShaderProgram = struct {
    const Builder = struct {
        program: ShaderProgram,

        pub fn attach_shader(self: @This(), shader: Shader) !u32 {
            const shader_id = try create_shader(
                shader.type,
                shader.program,
            );
            _g.glAttachShader(self.program.shader_program, shader_id);
            return shader_id;
        }

        pub fn link_program(self: @This()) !void {
            _g.glLinkProgram(self.program.shader_program);
            try verify_shader(
                self.program.shader_program,
                .GL_LINK_STATUS,
                self.program.label,
            );
        }

        pub fn finish(self: @This()) ShaderProgram {
            return self.program;
        }
    };

    label: []const u8,
    shader_program: u32,
    is_compute: bool,

    pub fn init(label: []const u8, is_compute: bool) Builder {
        const shader_program = _g.glCreateProgram();
        return Builder{ .program = .{
            .label = label,
            .shader_program = shader_program,
            .is_compute = is_compute,
        } };
    }

    // pub fn init(shader_chain: anytype, is_compute: bool, label: []const u8) !@This() {
    //     const ShaderChain = ObjectChain.ResolveObjectChain(shader_chain);
    //     var _shader_chain: ShaderChain = shader_chain;
    //     _shader_chain.reset();
    //     while (_shader_chain.next_ref()) |shader| {
    //         shader.*.shader_id = shader_id;
    //     }
    //     _g.glLinkProgram(shader_program_id);
    //
    //     _shader_chain.reset();
    //     while (_shader_chain.next_obj()) |shader| {
    //         _g.glDeleteShader(shader.shader_id);
    //     }
    //
    //     try verify_shader(shader_program_id, .GL_LINK_STATUS, "SHADER_PROGRAM: " ++ label);
    //
    //     return .{
    //         .shader_program = shader_program_id,
    //         .is_compute = is_compute,
    //     };
    // }

    pub fn deinit(self: *@This()) void {
        _g.glDeleteProgram(self.shader_program);
    }
};

pub fn CreateProgram(shader_chain: anytype) type {
    _ = shader_chain;
    return struct {};
}

pub fn create_render_shader(shader_chain: anytype, label: []const u8) !ShaderProgram {
    return ShaderProgram.init(shader_chain, false, label);
}

pub fn create_compute_shader(shader_chain: anytype, label: []const u8) !ShaderProgram {
    return ShaderProgram.init(shader_chain, true, label);
}

var allocator: std.mem.Allocator = undefined;
var managed_shaders: std.ArrayList(ShaderProgram) = undefined;

pub fn init(_allocator: std.mem.Allocator) !void {
    std.debug.assert(allocator == undefined);
    allocator = _allocator;
    std.debug.assert(allocator != undefined);

    managed_shaders = try std.ArrayList(ShaderProgram).initCapacity(allocator, 0);
}

/// Managed shaders are kept until Shaders.deinit, so the lifetime of the application. Do not deinit managed shaders!
fn manage_shader(shader_program: ShaderProgram) !u32 {
    std.debug.assert(allocator != undefined);
    try managed_shaders.append(allocator, shader_program);
    return managed_shaders.items.len - 1;
}

pub fn deinit() void {
    std.debug.assert(allocator != undefined);

    const shader_programs = try managed_shaders.toOwnedSlice(allocator);
    for (shader_programs) |shader_program| {
        shader_program.deinit();
    }
}
