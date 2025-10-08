pub fn Enumerator(comptime T: type) type {
    return struct {
        array: []T,
        current: usize,

        pub fn init(array: *const []T) @This() {
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

            // Iterate over subscribers til we reach a valid subscriber.
            // We set enumeration idx to the next item, and we return the subscriber.
            for (self.current.., self.array[self.current..]) |idx, _item| {
                if (_item) |item| {
                    defer self.*.current = idx + 1;
                    return item;
                }
            }

            // There are no valid subscribers left. Ending enumeration.
            return null;
        }
    };
}
