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
    const Collection = SafeCollection(T);
    return struct {
        pub const Interface = struct {
            connect: *const fn (listener: T) anyerror!void,
            disconnect: *const fn (listener: T) anyerror!void,
        };

        collection: Collection,

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
                .collection = try Collection.init(allocator, cleanup_treshold),
            };
        }

        pub fn is_connected(self: @This(), listener: T) bool {
            return self.collection.has(listener);
        }

        pub fn connect(self: *@This(), listener: T) !void {
            try self.*.collection.add(listener);
        }
        pub fn disconnect(self: *@This(), listener: T) !void {
            try self.*.collection.remove(listener);
        }
        pub fn cleanup(self: *@This()) !void {
            try self.*.collection.cleanup();
        }
        pub fn reset(self: *@This()) void {
            self.*.collection.reset();
        }
        pub fn enumerate(self: *@This()) ?T {
            return self.*.collection.enumerate();
        }
        pub fn deinit(self: @This()) void {
            self.*.collection.deinit();
        }
    };
}
