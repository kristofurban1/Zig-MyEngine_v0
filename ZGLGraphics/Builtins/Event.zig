const std = @import("std");
const SafeCollection = @import("../Utils/SafeCollection.zig").SafeCollection;

pub fn Event(comptime T: type) type {

    // Must be callable!
    comptime {
        const info = @typeInfo(T);
        if (info != .pointer and info != .@"fn")
            @compileError("Event<T> must be fn or pointer to fn!");
        if (info == .pointer and @typeInfo(info.pointer.child) != .@"fn" and info.pointer.is_const != false)
            @compileError("Event<T> must be fn or const pointer to fn!");
    }
    return struct {
        pub const TSafeCollection = SafeCollection(T);
        pub const ERR = TSafeCollection.ERR;

        pub const Interface = struct {
            connect: *const fn (T) ERR!void,
            disconnect: *const fn (T) ERR!void,
        };

        collection: TSafeCollection,

        pub fn interface(self: @This()) Interface {
            const collection_interface = self.collection.interface();
            return .{
                .connect = collection_interface.add,
                .disconnect = collection_interface.remove,
            };
        }

        /// Cleanup Treshold[0-1]: Clean invalidated items when under % treshold.
        pub fn init(allocator: std.mem.Allocator, cleanup_treshold: f32) !@This() {
            return .{
                .collection = try TSafeCollection.init(allocator, cleanup_treshold),
            };
        }

        pub fn is_connected(self: @This(), listener: T) bool {
            return self.collection.has(listener);
        }

        pub fn is_enumerating(self: @This()) bool {
            return self.collection.is_enumerating();
        }

        pub fn connect(self: *@This(), listener: T) ERR!void {
            try self.*.collection.add(listener);
        }
        pub fn disconnect(self: *@This(), listener: T) ERR!void {
            try self.*.collection.remove(listener);
        }
        pub fn cleanup(self: *@This()) ERR!void {
            try self.*.collection.cleanup();
        }
        pub fn reset(self: *@This()) void {
            self.*.collection.reset();
        }
        pub fn enumerate(self: *@This()) ?TSafeCollection.TEnumerator {
            return self.*.collection.enumerator();
        }
        pub fn next(self: *@This()) ?T {
            return self.*.collection.next();
        }

        pub fn deinit(self: @This()) void {
            self.*.collection.deinit();
        }
    };
}
