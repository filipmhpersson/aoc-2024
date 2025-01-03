const std = @import("std");
const testing = std.testing;
const sort = std.mem.sort;
const assert = std.debug.assert;
const stdout = std.io.getStdOut().writer();

pub fn runDay4() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var file = try std.fs.cwd().openFile("./src/day4/input", .{});
    const allocator = arena.allocator();

    const input = try file.readToEndAlloc(allocator, 1024 * 1024);
    var res = std.mem.split(u8, input, "\n");

    var rows = std.ArrayList([]const u8).init(allocator);
    while (res.next()) |row| {
        if (row.len > 0) {
            try rows.append(row);
        }
    }
    const r = try rows.toOwnedSlice();
    const result = try calculateXmas(r);
    const resultStep2 = try calculateMas(r);

    try stdout.print("Result from day 4 step 1 {d}\n", .{result});
    try stdout.print("Result from day 4 step 2 {d}\n", .{resultStep2});
}

pub fn calculateXmas(input: [][]const u8) anyerror!usize {
    var x: usize = 0;
    var y: usize = 0;
    const rowLength = input[0].len;
    const rowCount = input.len;
    var result: usize = 0;
    while (true) {
        const curr = input[y][x];
        if (curr == 'X') {
            for (Directions) |direction| {
                if (lookForLetter(input, direction, @intCast(x), @intCast(y), 1)) {
                    result += 1;
                }
            }
        }
        if (x < rowLength - 1) {
            x += 1;
        } else {
            if (y < rowCount - 1) {
                y += 1;
                x = 0;
            } else {
                break;
            }
        }
    }
    return result;
}

pub fn calculateMas(input: [][]const u8) anyerror!usize {
    var x: usize = 1;
    var y: usize = 1;
    const rowLength = input[0].len;
    const rowCount = input.len;
    for (input) |row| {
        std.debug.print("ROW {s}\n", .{row});
    }
    var result: usize = 0;
    while (true) {
        const curr = input[y][x];
        if (curr == 'A') {
            if(lookForMas(input, x, y)) {
                result += 1;
            }
        }
        if (x < rowLength - 2) {
            x += 1;
        } else {
            if (y < rowCount - 2) {
                y += 1;
                x = 1;
            } else {
                break;
            }
        }
    }
    return result;
}

const value = "XMAS";

fn lookForLetter(input: [][]const u8, dir: Direction, x: isize, y: isize, needleIndex: usize) bool {
    const rowCount = input.len;

    const newX = x + dir.x;
    const newY = y + dir.y;

    if (newY == -1 or newY == rowCount) {
        return false;
    }
    const rowLength = input[@intCast(newY)].len;
    if (newX == -1 or newX >= rowLength) {
        return false;
    }
    //std.debug.print("Y ( rowCount {d}, y {d}) (rowLength {d}, x{d})\n", .{rowCount, newY, rowLength, newX});

    if (input[@intCast(newY)][@intCast(newX)] == value[needleIndex]) {
        if (needleIndex == value.len - 1) {
            return true;
        } else {
            return lookForLetter(input, dir, newX, newY, needleIndex + 1);
        }
    }
    return false;
}
fn lookForMas(input: [][]const u8, x: usize, y: usize) bool {
    const ne = input[y + 1][x + 1];
    const se = input[y - 1][x + 1];
    const sw = input[y - 1][x - 1];
    const nw = input[y + 1][x - 1];
    
    if((ne == 'M' and sw == 'S') or (ne == 'S' and sw == 'M')) {
        if((se == 'M' and nw == 'S') or (se == 'S' and nw == 'M')) {
            return true;
        }
    }

    return false;
}
const Directions: [8]Direction = [8]Direction{
    Direction{ .x = 0, .y = 1 },
    Direction{ .x = 1, .y = 1 },
    Direction{ .x = 1, .y = 0 },
    Direction{ .x = 1, .y = -1 },
    Direction{ .x = 0, .y = -1 },
    Direction{ .x = -1, .y = -1 },
    Direction{ .x = -1, .y = 0 },
    Direction{ .x = -1, .y = 1 },
};

const MasDirections: [4]Direction = [4]Direction{
    Direction{ .x = 1, .y = 1 },
    Direction{ .x = 1, .y = -1 },
    Direction{ .x = -1, .y = -1 },
    Direction{ .x = -1, .y = 1 },
};
const Direction = struct { x: isize, y: isize };


test "Verify mas" {
    const testdata =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;
    var res = std.mem.split(u8, testdata, "\n");
    const alloc = std.testing.allocator;
    var rows = std.ArrayList([]const u8).init(alloc);
    while (res.next()) |row| {
        try rows.append(row);
    }
    const r = try rows.toOwnedSlice();
    const result = calculateMas(r);
    defer alloc.free(r);
    try testing.expectEqual(9, result);
}
test "Verify xmas" {
    const testdata =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;
    var res = std.mem.split(u8, testdata, "\n");
    const alloc = std.testing.allocator;
    var rows = std.ArrayList([]const u8).init(alloc);
    while (res.next()) |row| {
        try rows.append(row);
    }
    const r = try rows.toOwnedSlice();
    const result = calculateXmas(r);
    defer alloc.free(r);
    try testing.expectEqual(18, result);
}
