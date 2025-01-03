const std = @import("std");
const testing = std.testing;
pub const day1 = @import("day1/historian.zig");
pub const day2 = @import("day2/reports.zig");
pub const day6 = @import("day6/guards.zig");

pub const day3 = @import("day3/mul.zig");
pub const day4 = @import("day4/xmas.zig");
pub const day5 = @import("day5/codes.zig");
pub const log_level: std.log.Level = .info;
export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}

//Hack to get tests to run for all files
test {
    std.testing.refAllDecls(@This());
}
