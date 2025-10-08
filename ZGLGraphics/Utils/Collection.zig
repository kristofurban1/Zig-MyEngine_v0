const std = @import("std");

pub fn Collection(comptime T: type) type {
    return struct {
        pub const ERR = error{
            OutOfMemory,
        };
        
        allocator: std.mem.Allocator = undefined,
        items: std.ArrayList(T) = undefined,

        /// Cleanup Treshold[0-1]: Clean invalidated items when under % treshold.
        pub fn init(allocator: std.mem.Allocator) ERR!@This() {
            return .{
                .allocator = allocator,
                .items = try std.ArrayList(T).initCapacity(allocator, 0),
            };
        }

        pub fn has(self: @This(), item: T) bool {
            for (self.items.items) |_item| {
                if (_item == item) return true;
            }
            return false;
        }

        fn find(self: @This(), item: T) usize {
            for (0.., self.items.items) |i, _item| {
                if (_item == item) return i;
            }
            unreachable; // Must be in array to call find!
        }

        pub fn add(self: *@This(), item: T) ERR!void {
            if (self.has(item)) return;
            return self.*.items.append(self.allocator, item);
        }

        pub fn remove(self: *@This(), item: T) ERR!void {
            if (!self.has(item)) return;

            self.*.items.swapRemove(self.find(item));
        }

        pub fn deinit(self: @This()) void {
            self.items.deinit(self.allocator);
        }
    };
}
