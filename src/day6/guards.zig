const std = @import("std");
const testing = std.testing;
const sort = std.mem.sort;
const assert = std.debug.assert;
const stdout = std.io.getStdOut().writer();

pub fn runDay2() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var file = try std.fs.cwd().openFile("./src/day6/data", .{});
    const allocator = arena.allocator();

    const stepTwoInput = try file.readToEndAlloc(allocator, 1024 * 1024);
    const stepTwoResult = try placeBlock(stepTwoInput, allocator);
    try stdout.print("Day 6 result {d}\n", .{stepTwoResult});
}

pub fn guardRoute(input: []const u8, allocator: std.mem.Allocator) anyerror!usize {
    var rows = std.ArrayList([]u8).init(allocator);
    var columns = std.ArrayList(u8).init(allocator);
    var guardPosition: Position = undefined;

    var moved: usize = 1;
    var stack: usize = 0;
    var inputRows = std.mem.splitAny(u8, input, "\n");
    {
        var i: usize = 0;
        while (inputRows.next()) |row| {
            var j: usize = 0;
            for (row) |char| {
                if (char == '^') {
                    std.debug.print("Found guard at x {d} and y {d} ", .{ j, i });
                    try columns.append('X');

                    guardPosition = Position{ .x = j, .y = i, .facing = Direction.N };
                } else {
                    try columns.append(char);
                }

                j += 1;
            }
            try rows.append(try columns.toOwnedSlice());
            i += 1;
        }
    }

    _ = walk(try rows.toOwnedSlice(), &guardPosition, &moved, &stack);
    return moved;
}
pub fn placeBlock(input: []const u8, allocator: std.mem.Allocator) anyerror!usize {
    var rows = std.ArrayList([]u8).init(allocator);
    var columns = std.ArrayList(u8).init(allocator);
    var guardPosition: Position = undefined;

    var moved: usize = 0;
    var inputRows = std.mem.splitAny(u8, input, "\n");
    {
        var i: usize = 0;
        while (inputRows.next()) |row| {
            var j: usize = 0;
            for (row) |char| {
                if (char == '^') {
                    std.debug.print("Found guard at x {d} and y {d} ", .{ j, i });
                    try columns.append('X');

                    guardPosition = Position{ .x = j, .y = i, .facing = Direction.N };
                } else {
                    try columns.append(char);
                }

                j += 1;
            }
            try rows.append(try columns.toOwnedSlice());
            i += 1;
        }
    }

    _ = walkWithObstacle(try rows.toOwnedSlice(), &guardPosition, &moved);
    return moved;
}
fn walk(grid: [][]u8, currentPos: *Position, count: *usize, stack: *usize) bool {
    stack.* += 1;
    if (stack.* == 10000) {
        return true;
    }
    var nxt = Position.move(currentPos.*);

    if (nxt.y != 0 and nxt.y == grid.len and nxt.facing == Direction.S) {
        return false;
    }
    const row = grid[nxt.y];
    if (row.len == 0) {
        return false;
    }
    if (nxt.x != 0 and nxt.x == row.len and nxt.facing == Direction.E) {
        return false;
    }

    const thingInLocation = row[nxt.x];
    if (thingInLocation != '.' and thingInLocation != 'X' and thingInLocation != '^' and thingInLocation != 'Y') {
        currentPos.turn();
        return walk(grid, currentPos, count, stack);
    } else {
        if (grid[nxt.y][nxt.x] != 'Y') {
            grid[nxt.y][nxt.x] = 'X';
        }

        if (thingInLocation != 'X')
            count.* += 1;

        if (nxt.x == 0 and nxt.facing == Direction.W) {
            return false;
        }
        if (nxt.y == 0 and nxt.facing == Direction.N) {
            return false;
        }
        return walk(grid, &nxt, count, stack);
    }
}
fn walkWithObstacle(grid: [][]u8, currentPos: *Position, count: *usize) void {
    var nxt = Position.move(currentPos.*);

    if (nxt.y != 0 and nxt.y == grid.len and nxt.facing == Direction.S) {
        return;
    }
    const row = grid[nxt.y];
    if (nxt.x != 0 and nxt.x == row.len and nxt.facing == Direction.E) {
        return;
    }

    {
        const tmp = grid[nxt.y][nxt.x];
        if (tmp != '#' and tmp != 'Y') {
            grid[nxt.y][nxt.x] = 'O';
            var ct: usize = 90;
            var stack: usize = 0;
            var c = Position{ .x = currentPos.x, .y = currentPos.y, .facing = currentPos.*.facing };
            const infinite = walk(grid, &c, &ct, &stack);
            if (infinite == true) {
                count.* += 1;
            }
            std.debug.print("TMP VAlue {c} \n", .{tmp});
            grid[nxt.y][nxt.x] = 'Y';
        }
    }

    const thingInLocation = row[nxt.x];
    if (thingInLocation != '.' and thingInLocation != 'X' and thingInLocation != '^' and thingInLocation != 'Y') {
        currentPos.turn();
        walkWithObstacle(grid, currentPos, count);
    } else {
        if (nxt.x == 0 and nxt.facing == Direction.W) {
            return;
        }

        if (nxt.y == 0 and nxt.facing == Direction.N) {
            return;
        }
        walkWithObstacle(grid, &nxt, count);
    }
}

fn printGrid(grid: [][]u8) void {
    std.debug.print("-------GRID-------\n", .{});
    for (0..grid.len) |i| {
        for (0..grid[i].len) |j| {
            std.debug.print("{c}", .{grid[i][j]});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("-------GRID-------\n", .{});
}
const Position = struct {
    x: usize,
    y: usize,
    facing: Direction,
    fn move(curr: Position) Position {
        var nxt = curr;
        switch (nxt.facing) {
            Direction.N => {
                nxt.y = nxt.y - 1;
            },
            Direction.E => {
                nxt.x = nxt.x + 1;
            },
            Direction.S => {
                nxt.y = nxt.y + 1;
            },
            Direction.W => {
                nxt.x = nxt.x - 1;
            },
        }
        return nxt;
    }
    fn turn(this: *Position) void {
        switch (this.*.facing) {
            Direction.N => {
                this.*.facing = Direction.E;
            },
            Direction.E => {
                this.*.facing = Direction.S;
            },
            Direction.S => {
                this.*.facing = Direction.W;
            },
            Direction.W => {
                this.*.facing = Direction.N;
            },
        }
    }
};

const Direction = enum { N, E, S, W };
test "Verify test data" {
    const testdata =
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\.......#..
        \\..........
        \\.#..^.....
        \\........#.
        \\#.........
        \\......#...
    ;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const result = guardRoute(testdata, allocator);
    try testing.expectEqual(41, result);
}
test "InfiniteCheck" {
    const testdata =
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\.......#..
        \\..........
        \\.#..^.....
        \\........#.
        \\#.........
        \\......#...
    ;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const result = placeBlock(testdata, allocator);
    try testing.expectEqual(6, result);
}
