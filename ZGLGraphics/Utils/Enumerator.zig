pub fn Enumerator(comptime T: type) type {
    return struct {
        array: []T,
        current: usize,

        pub fn init(array: []T) @This() {
            return .{
                .array = array,
                .current = 0,
            };
        }

        pub fn reset(self: *@This()) void {
            self.*.current = 0;
        }

        pub fn next(self: *@This()) ?T {
            if (self.current >= self.array.len) {
                return null;
            }
            defer self.*.current += 1;
            return self.array[self.current];
        }
    };
}
