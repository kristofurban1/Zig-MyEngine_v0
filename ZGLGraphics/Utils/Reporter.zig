const std = @import("std");

var allocator: ?std.mem.Allocator = null;

pub const ReportLevels = enum {
    Critical,
    Error,
    Warning,
    Info,

    pub fn name(level: @This()) []const u8 {
        return @tagName(level);
    }
};

const GetTimeFn = ?*const fn () f64;
var get_time_fn: GetTimeFn = null;

pub fn set_getTimeFn(_get_time_fn: GetTimeFn) void {
    get_time_fn = _get_time_fn;
}

pub const Report = struct {
    pub const FMT_NEWLINE = "\n";
    pub const FMT_REPORT_PREFIX = "[{d}] {s} -- ";
    pub const FMT_DEFAULT = FMT_NEWLINE ++ FMT_REPORT_PREFIX ++ "{s}";

    timestamp: f64,
    level: ReportLevels,
    message: []const u8,

    pub fn init(level: ReportLevels, comptime fmt: []const u8, args: anytype) !@This() {
        if (allocator == null) unreachable;

        const time = t: {
            if (get_time_fn) |_get_time_fn| {
                break :t _get_time_fn();
            }
            break :t 0;
        };

        return .{
            .timestamp = time,
            .level = level,
            .message = try std.fmt.allocPrint(allocator.?, fmt, args),
        };
    }

    pub fn level_str(level: ReportLevels) []const u8 {
        return @tagName(level);
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

fn fallback_reporter(level: ReportLevels, comptime fmt: []const u8, args: anytype) void {
    const time = t: {
        if (get_time_fn) |_get_time_fn| {
            break :t _get_time_fn();
        }
        break :t 0;
    };
    std.debug.print(Report.FMT_NEWLINE ++ "<FALLBACK>" ++ Report.FMT_REPORT_PREFIX ++ fmt ++ "\n", .{ time, level.name() } ++ args);
}

pub fn report(level: ReportLevels, comptime fmt: []const u8, args: anytype) void {
    const report_entry = Report.init(level, fmt, args) catch {
        fallback_reporter(level, fmt, args);
        return;
    };
    if (immidiate_callback) |callback| {
        callback(report_entry);
    } else {
        buffer.append(allocator.?, report_entry) catch {
            fallback_reporter(level, fmt, args);
            return;
        };
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

pub fn read_buffer_fmt(writer: std.io.Writer) !void {
    if (allocator == null) unreachable;

    const reports = try buffer.toOwnedSlice(allocator.?);
    for (reports) |report_entry| {
        writer.print(Report.FMT_DEFAULT, .{ report_entry.timestamp, report_entry.level.name(), report_entry.message });
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
