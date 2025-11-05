const ZGL = @import("../ZGL.zig");
const _g = ZGL.OPENGL;
const ShaderProgram = ZGL.Shaders.ShaderProgram;
const Vectors = ZGL.Vectors;
const Matrices = ZGL.Matrixes;

pub const ShaderUniformVectorTypes = enum {
    Float,
    Integer,
    Unsigned,
};
pub const ShaderUniformMatrixTypes = enum {
    Matrix2,
    Matrix3,
    Matrix4,
    Matrix2x3,
    Matrix3x2,
    Matrix2x4,
    Matrix4x2,
    Matrix3x4,
    Matrix4x3,
};

pub const ShaderUniformInterface = struct {
    uniformType: union { vector: ShaderUniformVectorTypes, matrix: ShaderUniformMatrixTypes },
    base: *anyopaque,
    update_fn: *const fn (base: anytype) void,
    program: *c_uint,
};

pub fn ShaderUniform_Vector(comptime uniformType: ShaderUniformVectorTypes, comptime Length: comptime_int) type {
    const T = switch (uniformType) {
        .Float => f32,
        .Integer => i32,
        .Unsigned => u32,
    };
    if (Length <= 0 or Length > 4) @compileError("ShaderUniform Vector must be 1-4 in Length!");
    return struct {
        pub const Vector = Vectors.Vector(T, Length);

        name: [:0]const u8,
        program: c_uint = undefined,
        vector: Vector,

        pub fn interface(self: @This()) ShaderUniformInterface {
            return .{
                .uniformType = .{ .vector = uniformType },
                .base = &self,
                .update_fn = &update,
                .program = &self.program,
            };
        }

        pub fn init(uniformName: [:0]const u8) @This() {
            return .{
                .name = uniformName,
                .vector = Vector.splat(0),
            };
        }

        pub fn update(self: @This()) void {
            const location: _g.GLUINT = _g.glGetUniformLocation(self.program, self.name);

            switch (uniformType) {
                .Float => switch (Length) {
                    1 => _g.glUniform1f(
                        location,
                        self.vector.get(0),
                    ),
                    2 => _g.glUniform2f(
                        location,
                        self.vector.get(0),
                        self.vector.get(1),
                    ),
                    3 => _g.glUniform3f(
                        location,
                        self.vector.get(0),
                        self.vector.get(1),
                        self.vector.get(2),
                    ),
                    4 => _g.glUniform4f(
                        location,
                        self.vector.get(0),
                        self.vector.get(1),
                        self.vector.get(2),
                        self.vector.get(3),
                    ),
                    else => unreachable,
                },
                .Integer => switch (Length) {
                    1 => _g.glUniform1i(
                        location,
                        self.vector.get(0),
                    ),
                    2 => _g.glUniform2i(
                        location,
                        self.vector.get(0),
                        self.vector.get(1),
                    ),
                    3 => _g.glUniform3i(
                        location,
                        self.vector.get(0),
                        self.vector.get(1),
                        self.vector.get(2),
                    ),
                    4 => _g.glUniform4i(
                        location,
                        self.vector.get(0),
                        self.vector.get(1),
                        self.vector.get(2),
                        self.vector.get(3),
                    ),
                    else => unreachable,
                },
                .Unsigned => switch (Length) {
                    1 => _g.glUniform1ui(
                        location,
                        self.vector.get(0),
                    ),
                    2 => _g.glUniform2ui(
                        location,
                        self.vector.get(0),
                        self.vector.get(1),
                    ),
                    3 => _g.glUniform3ui(
                        location,
                        self.vector.get(0),
                        self.vector.get(1),
                        self.vector.get(2),
                    ),
                    4 => _g.glUniform4ui(
                        location,
                        self.vector.get(0),
                        self.vector.get(1),
                        self.vector.get(2),
                        self.vector.get(3),
                    ),
                    else => unreachable,
                },
            }
        }

        pub fn setValue(self: *@This(), vector: Vector) void {
            self.*.vector = vector;
        }
    };
}

pub fn ShaderUniform_Matrix(comptime Width: comptime_int, comptime Heigth: comptime_int) type {
    const MatrixHelper = Matrices.UMatrix(f32, Width, Heigth);
    _ = MatrixHelper;
    return struct {};
}
