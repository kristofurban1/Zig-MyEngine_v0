const std = @import("std");

pub fn Collection(comptime T: type) type {
    return struct {
        pub const ERR = error{
            OutOfMemory,
        };

        pub const CollectionInterface = struct {
            add: fn (item: T) ERR!void,
            remove: fn (item: T) ERR!void,
        };

        allocator: std.mem.Allocator = undefined,
        valid_items: usize = 0,
        items: std.ArrayList(?T) = undefined,
        cleanup_treshold: f32,

        pub fn interface(self: @This()) CollectionInterface {
            const self_ptr = &self;
            return .{
                .add = struct {
                    fn add(obj: T) ERR!void {
                        return self_ptr.add(obj);
                    }
                }.add,
                .remove = struct {
                    fn remove(obj: T) ERR!void {
                        return self_ptr.remove(obj);
                    }
                }.remove,
            };
        }

        /// Cleanup Treshold[0-1]: Clean invalidated items when under % treshold.
        pub fn init(allocator: std.mem.Allocator, cleanup_treshold: f32) ERR!@This() {
            return .{
                .allocator = allocator,
                .valid_items = 0,
                .items = try std.ArrayList(?T).initCapacity(allocator, 0),
                .cleanup_treshold = cleanup_treshold,
            };
        }

        pub fn has(self: @This(), item: T) bool {
            for (self.subscribers.items) |sub| {
                if (sub == null) continue;
                if (sub.? == item) return true;
            }
            return false;
        }

        pub fn add(self: *@This(), item: T) ERR!void {
            if (self.has(item)) return;

            // We need to increment valid items at the end.
            defer self.*.valid_items += 1;
            errdefer (if (self.valid_items > 0) {
                self.*.valid_items -= 1;
            });

            if (self.valid_items == self.items.items.len)
                return self.*.items.append(self.allocator, item);

            // We find the free spot
            const free_idx = find_free: {
                for (0.., self.items.items) |i, _item| {
                    if (_item) |_| {
                        i += 1;
                    } else break :find_free i;
                }
                break :find_free self.items.items.len;
            };

            // We assert there is a free spot!
            if (free_idx == self.items.items.len) unreachable;

            self.*.items.items[free_idx] = item;
        }

        pub fn remove(self: *@This(), item: T) ERR!void {
            if (!self.has(item)) return;

            const item_idx = find_item: {
                for (0.., self.items.items) |i, sub| {
                    if (sub) |_| {
                        i += 1;
                    } else break :find_item i;
                }
                break :find_item self.items.items.len;
            };

            // We assert that its in there!
            if (item_idx == self.items.items.len) unreachable;

            self.*.items.items[item_idx] = null;
            self.*.valid_items -= 1;

            // Cleanup check
            if (self.valid_items < self.items.items.len * self.cleanup_treshold) try self.*.cleanup();
        }

        pub fn cleanup(self: *@This()) ERR!void {
            var valid_subs = try std.ArrayList(?T).initCapacity(self.allocator, self.valid_items);
            for (self.items.items) |_sub| {
                if (_sub) |sub| {
                    valid_subs.append(sub);
                }
            }
            self.*.items.clearAndFree(self.allocator);
            self.*.items = valid_subs;
        }

        pub fn deinit(self: @This()) void {
            self.items.deinit(self.allocator);
        }
    };
}
