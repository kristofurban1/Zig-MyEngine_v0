const ZGL = @import("../ZGL.zig");
const NamedTypeCode = ZGL.NamedTypeCode;
const Vectors = ZGL.Vectors;
const Matrix = ZGL.Matrixes;


pub const ShaderUniformTypes = enum {
    Float,
    Integer,
    Unsigned,
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

pub const ShaderUniformTypesArray: [_]type = {
    f32,
    i32,
    u32,
    
};
const ZGL = @import("../ZGL.zig");
const NamedTypeCode = ZGL.NamedTypeCode;

pub const ShaderUniformTypes = enum {
    Float,
    Integer,
    Unsigned,
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
    base: *anyopaque,
    update_fn: *const fn (anytype) void,
};

pub fn ShaderUniform_Vector(comptime T: type) type {
    return struct {
        count: comptime_int,
        value: [count]T,
    };
}

};

pub const ShaderUniformInterface = struct {
    base: *anyopaque,
    update_fn: *const fn (anytype) void,
};

pub fn ShaderUniform_Vector(comptime T: type) type {
    return struct {
        count: comptime_int,
        value: [count]T,
    };
}
