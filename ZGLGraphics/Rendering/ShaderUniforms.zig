const ZGL = @import("../ZGL.zig");
const _g = ZGL.OPENGL;
const Allocator = @import("std").mem.Allocator;
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
pub const ShaderUniformDescriptor = union(enum) {
    vector: struct {
        vectorType: ShaderUniformVectorTypes,
        length: usize,
    },
    matrix: struct {
        matrixType: ShaderUniformMatrixTypes,
        columnMajor: bool = true,
    },

    pub fn GetType(self: @This()) type {
        return switch (self) {
            .vector => |vector| ShaderUniform_Vector(vector.vectorType, vector.length),
            .matrix => |matrix| ShaderUniform_Matrix(matrix.matrixType, matrix.columnMajor),
        };
    }

    pub fn getUpdateFn(self: @This()) *const fn (anytype) void {
        return &self.GetType().update;
    }
};

pub fn ShaderUniformType(comptime DESCRIPTOR: ShaderUniformDescriptor) type {
    return struct {
        pub const Descriptor = DESCRIPTOR;
        pub const UniformType = Descriptor.GetType();

        pub fn create(name: [:0]const u8) ShaderUniform {
            return ShaderUniform.create(name, @This());
        }
    };
}

pub const ShaderUniform = struct {
    baseDescriptor: ShaderUniformDescriptor,
    name: [:0]const u8,

    base: ?*anyopaque = null,
    program: ?c_uint = null,

    pub fn create(name: [:0]const u8, shaderUniformType: anytype) @This() {
        return .{
            .baseDescriptor = shaderUniformType.Descriptor,
            .name = name,
        };
    }

    pub fn finalize(self: *@This(), shaderProgram: c_uint, allocator: Allocator) !void {
        // _ = self;
        // _ = shaderProgram;
        // _ = allocator;
        self.*.base = try allocator.create(self.baseDescriptor.GetType());
        self.*.program = shaderProgram;
        self.base.?.*.finalize_interface(self);
    }

    pub fn destroy(self: @This(), allocator: Allocator) void {
        allocator.free(self.base);
    }

    pub fn update(self: @This()) void {
        self.baseDescriptor.getUpdateFn()(self.base.?);
    }
};

pub fn ShaderUniform_Vector(comptime uniformType: ShaderUniformVectorTypes, comptime LENGTH: comptime_int) type {
    const T = switch (uniformType) {
        .Float => f32,
        .Integer => i32,
        .Unsigned => u32,
    };
    if (LENGTH <= 0 or LENGTH > 4) @compileError("ShaderUniform Vector must be 1-4 in Length!");
    return struct {
        pub const UniformType = uniformType;
        pub const Length = LENGTH;
        pub const Vector = Vectors.Vector(T, LENGTH);

        name: *[:0]const u8,
        program: *c_uint = undefined,
        vector: Vector,

        pub fn finalize_interface(self: *@This(), interface: *ShaderUniform) void {
            self.*.name = &interface.name;
            self.*.program = &interface.program;
            self.*.vector = Vector.splat(0);
        }

        pub fn update(_self: anytype) void {
            const self: @This() = _self;

            const location: _g.GLUINT = _g.glGetUniformLocation(self.program.*, self.name.*);

            switch (uniformType) {
                .Float => switch (LENGTH) {
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
                .Integer => switch (LENGTH) {
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
                .Unsigned => switch (LENGTH) {
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

pub fn ShaderUniform_Matrix(comptime uniformType: ShaderUniformMatrixTypes, comptime ColumnMajor: bool) type {
    const Width, const Heigth = switch (uniformType) {
        .Matrix2 => .{ 2, 2 },
        .Matrix3 => .{ 3, 3 },
        .Matrix4 => .{ 4, 4 },
        .Matrix2x3 => .{ 2, 3 },
        .Matrix2x4 => .{ 2, 4 },
        .Matrix3x2 => .{ 3, 2 },
        .Matrix3x4 => .{ 3, 4 },
        .Matrix4x2 => .{ 4, 2 },
        .Matrix4x3 => .{ 4, 3 },
    };
    const Matrix = Matrices.Matrix(f32, Width, Heigth, ColumnMajor);
    _ = Matrix;
    return struct {};
}
