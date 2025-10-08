const std = @import("std");
const SafeCollection = @import("../Utils/SafeCollection.zig").SafeCollection;

pub fn Event(comptime T: type) type {

    // Must be callable!
    comptime {
        const info = @typeInfo(T);
        if (info != .pointer and info != .@"fn")
            @compileError("Event<T> must be fn or const pointer to fn!");
        if (info == .pointer and @typeInfo(info.pointer.child) != .@"fn" and info.pointer.is_const != false)
            @compileError("Event<T> must be fn or const pointer to fn!");
    }
    return struct {
        pub const TSafeCollection = SafeCollection(T);
        pub const ERR = TSafeCollection.ERR;

        collection: TSafeCollection,

        /// Cleanup Treshold[0-1]: Clean invalidated items when under % treshold.
        pub fn init(allocator: std.mem.Allocator) !@This() {
            return .{
                .collection = try TSafeCollection.init(allocator),
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

        pub fn fire(self: *@This(), args: anytype) void {
            self.*.collection.reset(); // For safety
            while (self.*.collection.next()) |listener| {
                @call(.auto, listener, args);
            }
        }

        pub fn deinit(self: @This()) void {
            self.*.collection.deinit();
        }
    };
}
