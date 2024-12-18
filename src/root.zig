const std = @import("std");
const testing = std.testing;
pub const day1 = @import("day1/historian.zig");
pub const day2 = @import("day2/reports.zig");

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}

test {
    std.testing.refAllDecls(@This());
}
