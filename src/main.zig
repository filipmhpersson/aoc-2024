const std = @import("std");
const day1 = @import("day1/historian.zig");
const day2 = @import("day2/reports.zig");
const day3 = @import("day3/mul.zig");
const day4 = @import("day4/xmas.zig");
const day5 = @import("day5/codes.zig");
const day6 = @import("day6/guards.zig");

pub fn main() anyerror!void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    //try day1.runDayOne();
    try day2.runDay2();
    try day6.runDay6();
    try day3.runDay3();
    try day4.runDay4();
    try day5.runDay5();
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
