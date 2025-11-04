const Vectors = @import("Vectors.zig");

pub fn Matrix(comptime T: type, comptime Width: comptime_int, comptime Heigth: comptime_int, comptime ColumnMajor: bool) type {
    return struct {
        pub const Self = @This();
        pub const VectorCount = if (ColumnMajor) Width else Heigth;
        pub const VectorLength = if (ColumnMajor) Heigth else Width;
        pub const Vector = Vectors.Vector(T, VectorLength);
        pub const Size = Width * Heigth;
        raw_matrix: [Size]T,

        pub fn splat(value: T) Self {
            var raw_matrix: [Size]T = undefined;
            for (0..VectorCount) |i| {
                const v = Vector.splat(value);
                @memcpy(raw_matrix[i .. i + VectorLength], v);
            }
            return .{
                .raw_matrix = raw_matrix,
            };
        }

        pub fn init(from: [Size]T) Self {
            return .{
                .raw_matrix = from,
            };
        }

        pub fn toIndex(x: usize, y: usize) usize {
            return if (ColumnMajor) Heigth * x + y else Width * y + x;
        }

        pub fn get(self: Self, x: usize, y: usize) T {
            return self.raw_matrix[toIndex(x, y)];
        }

        pub fn set(self: *Self, x: usize, y: usize, value: T) void {
            self.*.raw_matrix[toIndex(x, y)] = value;
        }

        pub fn scale(self: Self, scalar: T) Self {
            var raw_matrix: [Size]T = undefined;
            for (0..VectorCount) |i| {
                const v = self.raw_matrix[i .. i + VectorLength].scale(scalar);
                @memcpy(raw_matrix[i .. i + VectorLength], v);
            }
            return .{
                .raw_matrix = raw_matrix,
            };
        }
    };
}
//
// pub fn SMatrix(comptime T: type, comptime Size: comptime_int, comptime ColumnMayor: bool) type {
//     return Matrix(T, Size, Size, ColumnMayor);
// }
//
// pub fn UMatrix(comptime T: type, comptime Width: comptime_int, comptime Heigth: comptime_int) type {
//     return struct {
//         pub fn GetMatrix(comptime ColumnMajor: bool) type {
//             return Matrix(T, Width, Heigth, ColumnMajor);
//         }
//     };
// }
//
// pub fn USMatrix(comptime T: type, comptime Size: comptime_int) type {
//     return UMatrix(T, Size, Size);
// }
