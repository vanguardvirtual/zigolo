const std = @import("std");

const MessageType = enum { info, warning, err, tests };

pub fn logger(comptime prefix: MessageType, comptime message: []const u8, args: anytype) void {
    const prefix_color = switch (prefix) {
        .info => "\x1b[32m", // Green
        .warning => "\x1b[33m", // Yellow
        .err => "\x1b[31m", // Red
        .tests => "\x1b[36m", // Cyan
    };
    const reset_color = "\x1b[0m";
    const prefix_str = switch (prefix) {
        .info => "ℹ️ info",
        .warning => "⚠️ warning",
        .err => "❌ error",
        .tests => "🧪 test",
    };

    // Use @TypeOf(args) to check if arguments were passed
    if (@TypeOf(args) == void) {
        std.debug.print(prefix_color ++ "{s}: " ++ message ++ reset_color, .{prefix_str});
    } else {
        std.debug.print(prefix_color ++ "{s}: " ++ message ++ reset_color, .{prefix_str} ++ args);
    }
}
