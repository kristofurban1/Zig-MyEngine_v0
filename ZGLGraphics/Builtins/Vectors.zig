const Math = @import("std").math;
const ReduceOp = @import("std").builtin.ReduceOp;

pub fn Vector(comptime T: type, comptime L: comptime_int) type {
    return struct {
        pub const Self = @This();
        pub const RawVector = @Vector(L, T);
        raw_vector: RawVector,

        pub fn reduce(self: Self, comptime operation: ReduceOp) @TypeOf(@reduce(operation, self.raw_vector)) {
            return @reduce(operation, self.raw_vector);
        }

        pub fn init(from: RawVector) Self {
            return .{
                .raw_vector = from,
            };
        }
        pub fn splat(value: T) Self {
            const result: RawVector = @splat(value);
            return init(result);
        }

        pub fn abs(self: Self) f32 {
            const squared = self.mult(self);
            const sum = squared.reduce(.Add);
            return @sqrt(sum);
        }
        pub fn add(self: Self, other: Self) Self {
            const result = self.raw_vector + other.raw_vector;
            return init(result);
        }

        pub fn sub(self: Self, other: Self) Self {
            const result = self.raw_vector - other.raw_vector;
            return init(result);
        }
        pub fn mult(self: Self, other: Self) Self {
            const result = self.raw_vector * other.raw_vector;
            return init(result);
        }
        pub fn scale(self: Self, scalar: T) Self {
            return self.mult(splat(scalar));
        }
        pub fn dot(self: Self, other: Self) f32 {
            return self.mult(other).reduce(.Add);
        }

        // Vector2 Operations

        /// Angle of 2 'Vector2's in Radians. Using dot product.
        pub fn angle(self: Self, other: Self) f32 {
            if (comptime L != 2) @compileError("Vector.Angle is only compatible with Vecctor2s!");
            const cos_angle = self.dot(other) / (self.abs() * other.abs());
            return Math.acos(cos_angle);
        }

        // Vector3 Operation
        /// Cross product of 2 Vector3s.
        pub fn cross(self: Self, other: Self) Self {
            if (comptime L != 3) @compileError("Vector.Cross is only compatible with Vecctor3s!");
            //const i = self.
            _ = self;
            _ = other;
            return splat(0);
        }
    };
}

pub fn TypedVector(comptime T: type) *const fn (comptime_int) type {
    const _s = struct {
        fn _Vector(comptime len: comptime_int) type {
            return Vector(T, len);
        }
    };
    return &_s._Vector;
}

pub const Vector2 = Vector(f32, 2);
pub const LVector2 = Vector(f64, 2);
pub const IVector2 = Vector(i32, 2);

pub const Vector3 = Vector(f32, 3);
pub const LVector3 = Vector(f64, 3);
pub const IVector3 = Vector(i32, 3);
