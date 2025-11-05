const std = @import("std");
const ZGL = @import("../ZGL.zig");

const _g = ZGL.OPENGL;
const Reporter = ZGL.Reporter;
const ObjectChain = ZGL.ObjectChain;

const NamedTypeCode = ZGL.NamedTypeCode;

const ShaderUniforms = @import("ShaderUniforms.zig");
const ShaderBuilderChain = @import("ShaderBuilderChain.zig");

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

        pub fn init(label: []const u8, allocator: std.mem.Allocator) @This() {
            var program = ShaderProgram{
                .label = label,
                .shader_program = _g.glCreateProgram(),
                .allocator = allocator,
            };
            program.uniforms = std.ArrayList(ShaderUniforms.ShaderUniformInterface).initCapacity(program.allocator, 0);
            return Builder{ .program = program };
        }

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

        pub fn attach_uniform(self: *@This(), uniform: ShaderUniforms.ShaderUniformInterface) void {
            uniform.program.* = self.program.shader_program;
            self.program.uniforms.append(self.program.allocator, uniform);
        }

        pub fn finish(self: @This()) ShaderProgram {
            return self.program;
        }
    };

    allocator: std.mem.Allocator,
    label: []const u8,
    shader_program: u32,
    uniforms: std.ArrayList(ShaderUniforms.ShaderUniformInterface) = undefined,

    pub fn init(label: []const u8, allocator: std.mem.Allocator) Builder {
        return Builder.init(label, allocator);
    }

    pub fn deinit(self: @This()) void {
        _g.glDeleteProgram(self.shader_program);
        self.uniforms.toOwnedSlice(self.allocator);
    }
};

pub fn ShaderProgramCompiler(comptime __shader_chain: anytype) type {
    const T = @TypeOf(__shader_chain);
    const LENGTH = ShaderBuilderChain.EnforceShaderBuilderChain(T);
    const _shader_chain: ShaderBuilderChain.ShaderBuilderChain(LENGTH) = __shader_chain;
    return struct {
        pub fn compile_shader(label: []const u8, allocator: std.mem.Allocator) !ShaderProgram {
            const builder = ShaderProgram.init(label, allocator);
            var shader_chain = _shader_chain;

            shader_chain.reset();
            while (shader_chain.next_ref()) |shader_ref| {
                switch (shader_ref) {
                    .shader => |shader| {
                        const id = try builder.attach_shader(shader.*);
                        shader.*.id = id;
                    },
                    .uniform => {}, // Ignore at this step
                }
            }

            try builder.link_program();

            shader_chain.reset();
            while (shader_chain.next_obj()) |shader_obj| {
                switch (shader_obj) {
                    .shader => |shader| builder.delete_shader(shader),
                    .uniform => {}, // Ignore at this step
                }
            }

            shader_chain.reset();
            while (shader_chain.next_obj()) |shader_obj| {
                switch (shader_obj) {
                    .shader => {}, // Ignore at this step
                    .uniform => |uniform| builder.attach_uniform(uniform),
                }
            }
            return builder.finish();
        }
    };
}
