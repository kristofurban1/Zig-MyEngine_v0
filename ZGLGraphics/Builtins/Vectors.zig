const std = @import("std");

fn vector_type_verify(comptime T: type) void {
    switch (@typeInfo(T)) {
        .int => return,
        .float => return,
        else => @compileError("Unsupported vector type! Must be Int or Float"),
    }
    unreachable;
}

pub fn VectorInterface(comptime T: type) type {
    vector_type_verify(T);
    return struct {
        vector_ref: *anyopaque,

        raw_vec_fn: *const fn (ptr: *anyopaque) []T,
        len_fn: *const fn (ptr: *anyopaque) usize,
        get_fn: *const fn (ptr: *anyopaque, index: usize) T,
        set_fn: *const fn (ptr: *anyopaque, index: usize, value: T) void,

        pub fn len(self: @This()) usize {
            return self.len_fn(self.vector_ref);
        }
        pub fn get(self: @This(), index: usize) T {
            return self.get_fn(self.vector_ref, index);
        }
        pub fn get(self: @This(), index: usize, value: T) void {
            self.set_fn(self.vector_ref, index, value);
        }
    };
}

pub fn Vector(comptime T: type, comptime L: comptime_int) type {
    vector_type_verify(T);
    return struct {
        pub const Type = T;
        pub const Length = L;

        vector: [L]T,

        pub fn raw_vec(self: @This()) []T {
            return self.vector;
        }
        pub fn len(self: @This()) usize {
            _ = self;
            return Length;
        }
        pub fn get(self: @This(), index: usize) T {
            //// Index out of range
            if (index >= self.vector.len) unreachable;
            return self.vector[index];
        }
        pub fn set(self_ref: *@This(), index: usize, value: T) void {
            //// Index out of range
            if (index >= self_ref.*.vector.len) unreachable;
            self_ref.*.vector[index] = value;
        }

        pub fn interface(self_ref: *@This()) VectorInterface(T) {
            return .{
                .vector_ref = self_ref,
                .raw_vec_fn = &raw_vec,
                .len_fn = &len,
                .get_fn = &get,
                .set_fn = &set,
            };
        }
    };
}

pub fn DynVector(comptime T: type) type {
    return struct {
        vector: []T,

        pub fn raw_vec(self: @This()) []T {
            return self.vector;
        }
        pub fn len(self: @This()) usize {
            return self.vector.len;
        }
        pub fn get(self: @This(), index: usize) T {
            //// Index out of range
            if (index >= self.vector.len) unreachable;
            return self.vector[index];
        }
        pub fn set(self_ref: *@This(), index: usize, value: T) void {
            //// Index out of range
            if (index >= self_ref.*.vector.len) unreachable;
            self_ref.*.vector[index] = value;
        }

        pub fn interface(self_ref: *@This()) VectorInterface(T) {
            return .{
                .vector_ref = self_ref,
                .raw_vec_fn = &raw_vec,
                .len_fn = &len,
                .get_fn = &get,
                .set_fn = &set,
            };
        }
    };
}

const VectorCompatibilityUtils = struct {
    pub fn assert_vector(comptime T: type) void {
        const info = @typeInfo(T);
        switch (info) {
            .@"struct" => {},
            else => @compileError("Not a Vector!"),
        }

        if (@hasDecl(T, "Type") and @hasDecl(T, "Length")) return;
        @compileError("Not a Vector!");
    }

    // // Takes T types of 2 Vectors and returns a compatible type.
    // pub fn type_converter(comptime T1: type, comptime T2: type) type {
    //     vector_type_verify(T1);
    //     vector_type_verify(T2);

    //     const T1Info = @typeInfo(T1);

    //     const T2Info = @typeInfo(T2);

    //     // Conversion order: Float > Integer > Unsigned
    //     // Check floats.
    //     if (T1Info.float or T2Info.float) {
    //         // Both floats
    //         if (T1Info.float and T2Info.float) {
    //             return if (T1Info.float.bits >= T2Info.float.bits) T1 else T2;
    //         }
    //         // Only one float
    //         return if (T1Info.float) T1 else T2;
    //     }
    //     // No floats. Check Ints
    //     else if (T1Info.int.signedness == .signed or T2Info.int.signedness == .signed) {
    //         // Both ints
    //         if (T1Info.float and T2Info.float) {
    //             return if (T1Info.int.signedness >= T2Info.int.signedness) T1 else T2;
    //         }
    //         // Only one int
    //         return if (T1Info.int.signedness == .signed) T1 else T2;
    //     }
    // }
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
