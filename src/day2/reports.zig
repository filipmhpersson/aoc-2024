const std = @import("std");
const testing = std.testing;
const sort = std.mem.sort;
const assert = std.debug.assert;
const stdout = std.io.getStdOut().writer();

pub fn runDay2() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var file = try std.fs.cwd().openFile("./src/day2/data", .{});
    const allocator = arena.allocator();

    const stepOneInput = try file.readToEndAlloc(allocator, 1024 * 1024);
    const result = try findSafeRepots(stepOneInput);
    const resultDay2 = try findSafeRepotsWithDampener(stepOneInput);
    try stdout.print("Result from day 2 step 1 {d}\n", .{result});
    try stdout.print("Result from day 2 step 2 {d}\n", .{resultDay2});
}

pub fn findSafeRepotsWithDampener(input: []const u8) anyerror!usize {
    var rows = std.mem.splitAny(u8, input, "\n");

    var safe: usize = 0;
    while (rows.next()) |row| {
        var ints = std.mem.splitAny(u8, row, " ");
        var errors: usize = 0;
        var direction: Direction = Direction.Unknown;
        while (ints.next()) |number| {
            if (ints.buffer.len < 5) {
                break;
            }
            const curr = try std.fmt.parseInt(usize, number, 10);
            const nextNumber = ints.peek() orelse {
                if (errors > 1) {
                    break;
                } else {
                    safe += 1;
                    break;
                }
            };
            const next = try std.fmt.parseInt(usize, nextNumber, 10);
            if (curr == next) {
                errors += 1;
                continue;
            }

            const currDirection = if (curr > next) Direction.Desc else Direction.Asc;
            if (direction == Direction.Unknown) {
                direction = currDirection;
            }

            if (currDirection != direction) {
                errors += 1;
                continue;
            }

            const speed = switch (direction) {
                Direction.Asc => next - curr,
                Direction.Desc => curr - next,
                Direction.Unknown => unreachable,
            };
            if (speed > 3) {
                errors += 1;
                continue;
            }
        }
    }
    return safe;
}

pub fn findSafeRepots(input: []const u8) anyerror!usize {
    var rows = std.mem.splitAny(u8, input, "\n");

    var safe: usize = 0;
    while (rows.next()) |row| {
        var ints = std.mem.splitAny(u8, row, " ");
        var direction: Direction = Direction.Unknown;
        while (ints.next()) |number| {
            if (ints.buffer.len < 5) {
                break;
            }
            const curr = try std.fmt.parseInt(usize, number, 10);
            const nextNumber = ints.peek() orelse {
                safe += 1;
                break;
            };
            const next = try std.fmt.parseInt(usize, nextNumber, 10);
            if (curr == next) {
                break;
            }

            const currDirection = if (curr > next) Direction.Desc else Direction.Asc;
            if (direction == Direction.Unknown) {
                direction = currDirection;
            }

            if (currDirection != direction) {
                break;
            }

            const speed = switch (direction) {
                Direction.Asc => next - curr,
                Direction.Desc => curr - next,
                Direction.Unknown => unreachable,
            };
            if (speed > 3) {
                break;
            }
        }
    }
    return safe;
}

const Direction = enum { Unknown, Asc, Desc };
test "Verify test data" {
    const testdata =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;

    const result = findSafeRepots(testdata);
    try testing.expectEqual(2, result);
}
