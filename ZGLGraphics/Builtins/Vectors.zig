const Allocator = @import("std").mem.Allocator;

/// Vector wrapper for any Vector types.
pub const AnyVector = struct {
    T: type,
    LEN: i64,
    owned_vector: ?*anyopaque = null,

    /// Wrap vector
    pub fn init(vector: anytype) @This() {
        _ = vector;
    }

    /// Wrap vector, and take ownership of vector. Call deinit to free allocated memory for vector.
    pub fn init_borrow(vector: *anyopaque) @This() {
        _ = vector;
    }

    pub fn deinit(self: @This(), allocator: Allocator) void {
        if (self.owned_vector) |owned_vector| {
            allocator.free(owned_vector);
        }
    }
};

pub fn TypedVector(comptime _T: type) type {
    return struct {
        pub const T = _T;
        LEN: comptime_int,
        anyvector: AnyVector,

        pub fn init(anyvector: AnyVector) @This(){

        }
    };

}

pub fn Vector(comptime _T: type, _LEN: comptime_int) type {
    return struct {
        pub const T = _T;
        pub const LEN = _LEN;
        const VectorUNion = union(enum) {
            STATIC_VECTOR: @Vector(LEN, T),
            SIMPLE_VECTOR: [LEN] T,
            DYNAMIC_VECTOR: [] T,

            pub fn init_static(elements: []T) @THis() {
                return .{
                    .SIMPLE_VECTOR = elements,
                };
            }
        };0
        
        vector: VectorUNion,


        pub fn init_scalar(value: T) @This() {
            return .{
                .raw_vector = [LEN]T{value},
            };
        }

        pub fn init_zero() @This() {
            return init_scalar(0);
        }

        pub fn from_array(array: [LEN]T) @This() {
            return .{
                .raw_vector = array,
            };
        }

        pub fn concat(self: @This, vector: AnyVector)
    };
}
