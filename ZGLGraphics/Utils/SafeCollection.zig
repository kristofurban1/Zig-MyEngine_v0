const std = @import("std");

pub const Collection = @import("Collection.zig").Collection;
pub const Enumerator = @import("Enumerator.zig").Enumerator;

pub fn SafeCollection(comptime T: type) type {
    return struct {
        pub const TCollection = Collection(T);
        pub const TEnumerator = Enumerator(T);

        pub const ERR = error{
            BusyEnumerating,
            OutOfMemory,
        };

        collection: TCollection,
        _enumerator: ?TEnumerator = null,

        pub fn init(allocator: std.mem.Allocator) !@This() {
            return .{
                .collection = try TCollection.init(allocator),
            };
        }

        pub fn has(self: @This(), item: T) bool {
            return self.collection.has(item);
        }

        pub fn is_enumerating(self: @This()) bool {
            return self._enumerator != null;
        }

        pub fn add(self: *@This(), item: T) !void {
            if (self.is_enumerating()) return ERR.BusyEnumerating;
            return self.collection.add(item);
        }

        pub fn remove(self: *@This(), item: T) !void {
            if (self.is_enumerating()) return ERR.BusyEnumerating;
            return self.collection.remove(item);
        }

        pub fn cleanup(self: *@This()) !void {
            if (self.is_enumerating()) return ERR.BusyEnumerating;
            return self.collection.cleanup();
        }

        pub fn enumerator(self: *@This()) TEnumerator {
            if (self.*._enumerator) |_enumerator|
                return _enumerator;
            self.*._enumerator = TEnumerator.init(self.*.collection.items.items);
            return self.*._enumerator.?;
        }

        pub fn reset(self: *@This()) void {
            // _enumerator = null instead of _enumerator.reset().
            // Since next starts a new enumerator when null, it will be inheritly reset when nessesery.
            // But this reset enables write access without enumeration running its course.
            self.*._enumerator = null;
        }

        pub fn next(self: *@This()) ?T {
            var _enumerator = self.*.enumerator();
            const _next = _enumerator.next();
            if (_next == null) self.reset(); // Reset Enumerator (to enable write access)
            return _next;
        }

        pub fn deinit(self: @This()) void {
            return self.collection.deinit();
        }
    };
}
