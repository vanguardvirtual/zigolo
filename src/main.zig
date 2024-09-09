const std = @import("std");
const init_checks = @import("services/init_checks.zig");

pub fn main() !void {
    try init_checks.init_checks();
}
