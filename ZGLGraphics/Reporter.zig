const std = @import("std");

var allocator: ?std.mem.Allocator = null;

pub const ReportLevels = enum {
    Critical,
    Error,
    Warning,
    Info,
};

pub const Report = struct {
    level: ReportLevels,
    message: []const u8,

    pub fn init(_level: ReportLevels, comptime fmt: []const u8, args: anytype) !@This() {
        _ = allocator orelse unreachable;
        return .{
            .level = _level,
            .message = try std.fmt.allocPrint(allocator.?, fmt, args),
        };
    }

    pub fn deinit(self: @This()) void {
        allocator.?.free(self.message);
    }
};

var buffer_lock = false;
var buffer: std.ArrayList(Report) = undefined;

pub fn init(_allocator: std.mem.Allocator) !void {
    if (allocator) unreachable; // Init only permitted once

    allocator = _allocator;
    buffer = try std.ArrayList(Report).initCapacity(allocator.?, 0);

    _ = allocator orelse unreachable;
}

pub fn deinit() void {
    _ = allocator orelse unreachable;

    buffer.deinit(allocator.?);
}

const ImmidiateCallback = struct { comptime callback: ?*const fn (Report) void = null };
var immidiate_callback: ImmidiateCallback = .{ .callback = null };

pub fn report(level: ReportLevels, comptime fmt: []const u8, args: anytype) !void {
    const report_entry = try Report.init(level, fmt, args);
    if (immidiate_callback.callback) |callback_prt| {
        callback_prt.*(report_entry);
    } else {
        try buffer.append(allocator.?, report_entry);
    }
}

pub fn set_immidiate_callback(comptime callback: ?*const fn (Report) void) void {
    immidiate_callback.callback = callback;
}

/// Returns a raw slice of reports. The slice and each slice value must be freed!
pub fn read_buffer_raw() ![]Report {
    _ = allocator orelse unreachable;
    return try buffer.toOwnedSlice(allocator.?);
}

pub fn read_buffer_fmt(fmt: []const u8, writer: std.io.Writer) !void {
    _ = allocator orelse unreachable;

    const reports = try buffer.toOwnedSlice(allocator.?);
    for (reports) |report_entry| {
        writer.print(fmt, .{ report_entry.level, report_entry.message });
        report_entry.deinit();
        allocator.?.free(reports);
    }
}

/// Calls the provided function with each report. It must not be freed!
pub fn read_buffer_callback(callback: fn (Report) void) !void {
    _ = allocator orelse unreachable;

    const reports = try buffer.toOwnedSlice(allocator.?);
    for (reports) |report_entry| {
        callback(report_entry);
        report_entry.deinit();
    }
    allocator.?.free(reports);
}
