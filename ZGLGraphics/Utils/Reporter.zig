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
        if (allocator == null) unreachable;
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
    if (allocator != null) unreachable; // Init only permitted once

    allocator = _allocator;
    buffer = try std.ArrayList(Report).initCapacity(allocator.?, 0);

    if (allocator == null) unreachable;
}

pub fn deinit() void {
    if (allocator == null) return;

    buffer.deinit(allocator.?);
}

const ImmidiateCallback = ?*const fn (Report) void;
var immidiate_callback: ImmidiateCallback = null;

pub fn report(level: ReportLevels, comptime fmt: []const u8, args: anytype) !void {
    const report_entry = try Report.init(level, fmt, args);
    if (immidiate_callback) |callback| {
        callback(report_entry);
    } else {
        try buffer.append(allocator.?, report_entry);
    }
}

pub fn set_immidiate_callback(comptime callback: ImmidiateCallback) void {
    //_ = callback;
    immidiate_callback = callback;
    return;
}

/// Returns a raw slice of reports. The slice and each slice value must be freed!
pub fn read_buffer_raw() ![]Report {
    if (allocator == null) unreachable;
    return try buffer.toOwnedSlice(allocator.?);
}

pub fn read_buffer_fmt(fmt: []const u8, writer: std.io.Writer) !void {
    if (allocator == null) unreachable;

    const reports = try buffer.toOwnedSlice(allocator.?);
    for (reports) |report_entry| {
        writer.print(fmt, .{ report_entry.level, report_entry.message });
        report_entry.deinit();
        allocator.?.free(reports);
    }
}

/// Calls the provided function with each report. It must not be freed!
pub fn read_buffer_callback(callback: fn (Report) void) !void {
    if (allocator == null) unreachable;

    const reports = try buffer.toOwnedSlice(allocator.?);
    for (reports) |report_entry| {
        callback(report_entry);
        report_entry.deinit();
    }
    allocator.?.free(reports);
}
