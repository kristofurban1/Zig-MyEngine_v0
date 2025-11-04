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
};

pub fn ShaderUniform_Vector(comptime uniformType: ShaderUniformVectorTypes, comptime Length: comptime_int) type {
    const T = switch (uniformType) {
        .Float => f32,
        .Integer => i32,
        .Unsigned => u32,
    };
    if (Length <= 0 or Length > 4) @compileError("ShaderUniform Vector must be 1-4 in Length!");
    return struct {
        name: [:0]const u8,
        program: ShaderProgram = undefined,
        vector: Vectors.Vector(T, Length),

        pub fn init(uniformName: [:0]const u8) @This() {
            return .{
                .name = uniformName,
            };
        }

        pub fn setShader(self: *@This(), shaderProgram: ShaderProgram) void {
            self.*.program = shaderProgram;
        }

        pub fn update(self: @This()) void {
            const location: _g.GLUINT = _g.glGetUniformLocation(self.program, self.name);

            switch (uniformType) {
                .Float => switch (Length) {
                    1 => _g.glUniform1f(location, self.vector.get(0)),
                },
            }
        }
    };
}

pub fn ShaderUniform_Matrix(comptime Width: comptime_int, comptime Heigth: comptime_int) type {
    const MatrixHelper = Matrices.UMatrix(f32, Width, Heigth);
    _ = MatrixHelper;
    return struct {};
}
