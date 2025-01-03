const std = @import("std");
const testing = std.testing;
const sort = std.mem.sort;
const assert = std.debug.assert;
const stdout = std.io.getStdOut().writer();
pub fn runDayOne() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var file = try std.fs.cwd().openFile("./src/day1/data", .{});
    var allocator = arena.allocator();

    const stepOneInput = try file.readToEndAlloc(allocator, 1024 * 1024);
    const result = try pairUpLists(stepOneInput, &allocator);
    const stepTwoResult = try similarityScore(stepOneInput, &allocator);
    try stdout.print("Result from day 1 step 1 {d}\n", .{result});
    try stdout.print("Result from day 1 step 2 {d}\n", .{stepTwoResult});
}

pub fn similarityScore(input: []const u8, allocator: *const std.mem.Allocator) anyerror!usize {
    var rows = std.mem.splitAny(u8, input, "\n");
    var allPossibeValues = std.mem.zeroes([999999]usize);
    var left = std.ArrayList(usize).init(allocator.*);
    defer left.deinit();

    while (rows.next()) |row| {
        var ints = std.mem.splitAny(u8, row, "   ");
        if (ints.buffer.len < 5) {
            break;
        }
        const l = try std.fmt.parseInt(usize, ints.next().?, 10);
        const r = try std.fmt.parseInt(usize, ints.next().?, 10);
        allPossibeValues[r] += 1;
        try left.append(l);
    }

    var result: usize = 0;
    for (left.items) |item| {
        result += item * allPossibeValues[item];
    }
    return result;
}
pub fn pairUpLists(input: []const u8, allocator: *const std.mem.Allocator) anyerror!isize {
    var rows = std.mem.splitAny(u8, input, "\n");

    var right = std.ArrayList(isize).init(allocator.*);
    var left = std.ArrayList(isize).init(allocator.*);
    {
        while (rows.next()) |row| {
            var ints = std.mem.splitAny(u8, row, "   ");
            if (ints.buffer.len < 5) {
                break;
            }
            const l = try std.fmt.parseInt(isize, ints.next().?, 10);
            const r = try std.fmt.parseInt(isize, ints.next().?, 10);
            try left.append(l);
            try right.append(r);
        }
    }

    const leftSlice = try left.toOwnedSlice();
    const rightSlice = try right.toOwnedSlice();
    defer allocator.free(rightSlice);
    defer allocator.free(leftSlice);
    sort(isize, leftSlice, {}, std.sort.asc(isize));
    sort(isize, rightSlice, {}, std.sort.asc(isize));
    {
        var result: isize = 0;
        for (0..leftSlice.len) |i| {
            const l = leftSlice[i];
            const r = rightSlice[i];
            if (l > r) {
                result += l - r;
            } else {
                result += r - l;
            }
        }
        return result;
    }
}
