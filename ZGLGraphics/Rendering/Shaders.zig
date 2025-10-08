const std = @import("std");
const ZGL = @import("../ZGL.zig");

const _g = ZGL.OPENGL;
const Reporter = ZGL.Reporter;
const ObjectChain = ZGL.ObjectChain;

const NamedTypeCode = ZGL.NamedTypeCode;

const ShaderVerifyInquryTypes = enum { COMPILE_STATUS, LINK_STATUS };

const ShaderVerifyInqury = NamedTypeCode.CreateNamedTypeCodeStore(ShaderVerifyInquryTypes)
    .chain(.{ .identifyer = .COMPILE_STATUS, .code = _g.GL_COMPILE_STATUS, .name = "COMPILE" })
    .chain(.{ .identifyer = .LINK_STATUS, .code = _g.GL_LINK_STATUS, .name = "LINK" });

fn verify_operation(id: u32, inqury: ShaderVerifyInquryTypes, shader_lable: []const u8) !void {
    const shader_verify_inqury = ShaderVerifyInqury.get(inqury).?;

    var success: i32 = 0;
    switch (shader_verify_inqury.identifyer) {
        .COMPILE_STATUS => _g.glGetShaderiv(id, shader_verify_inqury.code, &success),
        .LINK_STATUS => _g.glGetProgramiv(id, shader_verify_inqury.code, &success),
    }

    if (success != 0) {
        Reporter.report(.Info, "Shader {s} <{s}> Success!", .{ shader_lable, shader_verify_inqury.name });
    } else {
        const log_len = 510;
        var infoLog: [(log_len + 2):0]u8 = undefined;
        const infoLog_ptr: [*c]u8 = &infoLog;

        switch (shader_verify_inqury.identifyer) {
            .COMPILE_STATUS => _g.glGetShaderInfoLog(id, log_len, null, infoLog_ptr),
            .LINK_STATUS => _g.glGetProgramInfoLog(id, log_len, null, infoLog_ptr),
        }

        var len: usize = 0;
        for (infoLog) |c| {
            if (c == 0) break;
            len += 1;
        }
        const bounded_infolog = infoLog[0..len];

        Reporter.report(.Error, "Shader {s} <{s}> Faliure:\n{s}", .{ shader_lable, shader_verify_inqury.name, bounded_infolog });
        return error.ShaderVerificatonFailed;
    }
}

const ShaderTypes = enum(usize) { VERTEX, TESS_CONTROL, TESS_EVAL, GEOMETRY, FRAGMENT, COMPUTE };

const ShaderType = NamedTypeCode.CreateNamedTypeCodeStore(ShaderTypes)
    .chain(.{ .identifyer = .VERTEX, .code = _g.GL_VERTEX_SHADER, .name = "VERTEX" })
    .chain(.{ .identifyer = .TESS_CONTROL, .code = _g.GL_TESS_CONTROL_SHADER, .name = "TESS_CONTROL" })
    .chain(.{ .identifyer = .TESS_EVAL, .code = _g.GL_TESS_EVALUATION_SHADER, .name = "TESS_EVAL" })
    .chain(.{ .identifyer = .GEOMETRY, .code = _g.GL_GEOMETRY_SHADER, .name = "GEOMETRY" })
    .chain(.{ .identifyer = .FRAGMENT, .code = _g.GL_FRAGMENT_SHADER, .name = "FRAGMENT" })
    .chain(.{ .identifyer = .COMPUTE, .code = _g.GL_COMPUTE_SHADER, .name = "COMPUTE" });

fn create_shader(shader_type_identifyer: ShaderTypes, program: [:0]const u8) !u32 {
    const shader_type = ShaderType.get(shader_type_identifyer).?;

    const id = _g.glCreateShader(shader_type.code);
    const _program: [*c]const [*c]const u8 = @ptrCast(&program.ptr);
    _g.glShaderSource(id, 1, _program, null);
    _g.glCompileShader(id);

    try verify_operation(id, .COMPILE_STATUS, shader_type.name);

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
            const shader_type = ShaderType.get(shader.type);
            Reporter.report(.Info, "Attached shader {s} to program: {s}.", .{ shader_type.?.name, self.program.label });
            _g.glAttachShader(self.program.shader_program, shader_id);
            return shader_id;
        }

        pub fn link_program(self: @This()) !void {
            _g.glBindFragDataLocation(self.program.shader_program, 0, "FragColor");
            _g.glLinkProgram(self.program.shader_program);
            try verify_operation(
                self.program.shader_program,
                .LINK_STATUS,
                self.program.label,
            );
        }

        pub fn delete_shader(self: @This(), shader: Shader) void {
            _ = self;
            _g.glDeleteShader(shader.id.?);
        }

        pub fn finish(self: @This()) ShaderProgram {
            return self.program;
        }
    };

    label: []const u8,
    shader_program: u32,

    pub fn init(label: []const u8) Builder {
        const shader_program = _g.glCreateProgram();
        return Builder{ .program = .{
            .label = label,
            .shader_program = shader_program,
        } };
    }

    pub fn deinit(self: @This()) void {
        _g.glDeleteProgram(self.shader_program);
    }
};

pub fn ShaderProgramCompiler(comptime T: type) type {
    ObjectChain.EnforceObjectChain(T, Shader);
    return struct {
        pub fn compile_shader(shader_chain: T, label: []const u8) !ShaderProgram {
            const builder = ShaderProgram.init(label);
            var _shader_chain = shader_chain;

            _shader_chain.reset();
            while (_shader_chain.next_ref()) |shader_ref| {
                const id = try builder.attach_shader(shader_ref.*);
                shader_ref.*.id = id;
            }

            try builder.link_program();

            _shader_chain.reset();
            while (_shader_chain.next_obj()) |shader_obj| {
                builder.delete_shader(shader_obj);
            }

            return builder.finish();
        }
    };
}
