//const std = @import("std");

fn vector_type_verify(comptime T: type) void {
    switch (@typeInfo(T)) {
        .int => return,
        .float => return,
        else => @compileError("Unsupported vector type! Must be Int or Float"),
    }
    unreachable;
}

pub fn Vector(comptime T: type, comptime L: comptime_int) type {
    return struct {
        pub const Add = VectorOperations.Add(@This());
        vector: @Vector(L, T),
        pub fn add(self: @This(), other: @This()) @This() {
            return Add(self, other);
        }
    };
}

pub fn DynVector(comptime T: type) type {
    return struct {
        vector: []T,
    };
}

const VectorCompatibilityUtils = struct {
    pub fn type_converter()
};

const VectorOperations = struct {
    pub fn Add(comptime T: type) (*const fn (T, T) T) {
        return struct {
            pub fn add(vec1: T, vec2: T) T {
                return T{ .vector = vec1.vector + vec2.vector };
            }
        }.add;
    }
};
