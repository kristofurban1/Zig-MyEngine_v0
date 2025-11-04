const Vectors = @import("Vectors.zig");

pub fn Matrix(comptime T: type, comptime Width: comptime_int, comptime Heigth: comptime_int, comptime ColumnMajor: bool) type {
    return struct {
        pub const Self = @This();
        pub const VectorCount = if (ColumnMajor) Width else Heigth;
        pub const VectorLength = if (ColumnMajor) Heigth else Width;
        pub const Vector = Vectors.Vector(T, VectorLength);
        pub const MatrixVectors = [VectorCount]Vector;
        vectors: MatrixVectors,

        pub fn splat(value: T) Self {
            var vectors: MatrixVectors = undefined;
            for (0..VectorCount) |i| {
                vectors[i] = Vector.splat(value);
            }
            return .{
                .vectors = vectors,
            };
        }

        pub fn init(from: MatrixVectors) Self {
            return .{
                .vectors = from,
            };
        }

        pub fn scale(self: Self, scalar: T) Self {
            var vectors: MatrixVectors = undefined;
            for (0..VectorCount) |i| {
                vectors[i] = self.vectors[i].scale(scalar);
            }
            return .{
                .vectors = vectors,
            };
        }
    };
}
