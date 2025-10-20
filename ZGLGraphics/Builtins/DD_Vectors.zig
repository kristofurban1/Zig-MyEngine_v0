const Allocator = @import("std").mem.Allocator;

pub fn Vector(comptime _T: type, comptime _LEN: comptime_int) type {
    return struct {
        pub const T = _T;
        pub const LEN = _LEN;
        pub const Self = @This();

        slice: [LEN]T,

        
    };
}

/// Dynamic Vector runtime size, using borrowed slices.
pub fn DVector(comptime _T: type) type {
    return struct {
        pub const T = _T;
        pub const TVECTOR = DVector(T);
        pub const Self = @This();

        slice: []T,

        pub fn init(size: usize, allocator: Allocator) !Self {
            var slice = try allocator.alloc(T, size);
            for (0..size) |i| {
                slice[i] = 0;
            }

            return .{
                .slice = slice,
            };
        }

        /// Borrows a slice, this slice is not freed by Vector, but its owner.
        pub fn init_borrow(slice: []T, allocator: Allocator) Self {
            return .{
                .allocator = allocator,
                .slice = slice,
            };
        }

        /// Lenght of vector.
        pub fn len(self: Self) usize {
            return self.slice.len;
        }

        /// Returns the
        pub fn get(self: Self, index: usize) T {
            return self.slice[index];
        }

        pub fn set(self: Self, index: usize, value: T) void {
            self.slice[index] = value;
        }

        /// Pads or reduces an Vector to a target size. Creates an owned Vector, using provided Allocator.
        pub fn padAlloc(vector: TVECTOR, target_size: usize, allocator: Allocator) Self {
            var padded: []T = allocator.alloc(T, target_size);

            for (0..target_size) |i| {
                if (i <= vector.len()) {
                    padded[i] = vector.get(i);
                } else {
                    padded[i] = 0;
                }
            }
        }

        //// Pads or reduces an Vector to a target size. Creates an owned Vector, using Vector's allocator.
        // pub fn pad(self: Self, target_size: usize) Self {
        //     padAlloc(self, target_size, self.allocator);
        // }

    };
}
