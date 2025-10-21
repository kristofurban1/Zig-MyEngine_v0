//const std = @import("std");

pub fn Vector(comptime T: type, comptime L: comptime_int) type {
    return struct {
        pub const _T = T;
        pub const _L = L;

        pub const Add = VectorOperations.Add(@This());
        vector: @Vector(L, T),
        add: *const fn (@This(), @This()) @This() = Add,
    };
}

fn assert_vector(comptime vec: anytype) void {
    const V = @TypeOf(vec);
    if (!(@hasDecl(V, "_T") and @hasDecl(V, "_L")))
        @compileError("Given type is not Vector!");

    const _type: type = vec._T;
    const _len: comptime_int = vec._L;
    if (V != Vector(_type, _len))
        @compileError("Given type is not Vector!");
}

fn assert_vector_type_match(comptime vec1: anytype, comptime vec2: anytype) void {
    assert_vector(vec1);
    assert_vector(vec2);

    if (vec1._T != vec2._T)
        @compileError("Given vector's types do not match!");
}

fn assert_vector_length_match(comptime vec1: anytype, comptime vec2: anytype) void {
    assert_vector(vec1);
    assert_vector(vec2);

    if (vec1._L != vec2._L)
        @compileError("Given vector's length do not match!");
}

pub const VectorOperations = struct {
    pub fn Add(comptime T: type) (*const fn (T, T) T) {
        return struct {
            pub fn add(vec1: T, vec2: T) T {
                return T{ .vector = vec1.vector + vec2.vector };
            }
        }.add;
    }
};
