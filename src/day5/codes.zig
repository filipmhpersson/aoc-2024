const std = @import("std");
const testing = std.testing;
const sort = std.mem.sort;
const assert = std.debug.assert;
const stdout = std.io.getStdOut().writer();

pub fn runDay5() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var file = try std.fs.cwd().openFile("./src/day5/data", .{});
    const allocator = arena.allocator();

    const input = try file.readToEndAlloc(allocator, 1024 * 1024);
    const result = try parseInput(input, allocator);
    try stdout.print("Result from day 4 step 1 {d}\n", .{result});
}

fn parseInput(input: []const u8, allocator: std.mem.Allocator) anyerror!usize {
    var split = std.mem.split(u8, input, "\n");

    var firstRules = std.AutoHashMap(usize, std.ArrayList(usize)).init(allocator);
    //var lastRules = std.HashMap([]u8, []u8, .{}, 80).init(allocator.*);
    var parsingRules = true;
    var finalResult: usize = 0;

    while (split.next()) |row| {
        if (parsingRules) {
            if (std.mem.eql(u8, row, "")) {
                parsingRules = false;
                continue;
            }
            var rowSplit = std.mem.split(u8, row, "|");
            const first = try std.fmt.parseInt(usize, rowSplit.next().?, 10);
            const last = try std.fmt.parseInt(usize, rowSplit.next().?, 10);

            if (firstRules.getPtr(first)) |get|{

                std.debug.print("HS count {d} ADD MORE {d} last {d} count {d}\n", .{firstRules.count(),first, last ,get.*.items.len});
                try get.*.append(last);
            } else {
                var arrayList = std.ArrayList(usize).init(allocator);
                try arrayList.append(last);
                try firstRules.put(first, arrayList);
            }
        } else {
            std.debug.print("ROW {s}\n", .{row});
            var rowSplit = std.mem.split(u8, row, ",");
            var values = std.ArrayList(usize).init(allocator);
            while (rowSplit.next()) |value| {

                const parsedValue = std.fmt.parseInt(usize, value, 10) catch return finalResult; 
                try values.append(parsedValue);
            }

            var allRulesFollowed = true;
            var middleNumber: usize = undefined;
            const middle = values.items.len / 2;
            valueCheck: for (values.items, 0..) |value, i| {
                    std.debug.print("CHECKING VALUE {d}\n", .{value});
                if (i == middle) {
                    
                    std.debug.print("   MIDDLE\n", .{});
                    middleNumber = value;
                }
                const numbersLeft = values.items[i + 1 ..];
                if (numbersLeft.len < 1) {
                    std.debug.print("   LAST\n", .{});
                    break;
                }
                const rules = firstRules.get(value) orelse {
                    std.debug.print("DIDNT FIND VALUE {d} in array\n", .{value});
                    allRulesFollowed = false;
                    break;
                };

                rulesCheck: for (numbersLeft) |check| {
                    for (rules.items) |rule| {
                        if (check == rule) {
                            std.debug.print("   FOUND\n", .{});
                            break :rulesCheck;
                        }
                    }
                    allRulesFollowed = false;
                    break :valueCheck;
                }
            }
            if (allRulesFollowed) {
                std.debug.print("Adding number {d} to result {d}\n",.{middleNumber, finalResult});
                finalResult += middleNumber;
            }
        }
    }
    return finalResult;
}

test "Test result" {
    const testdata =
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    ;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const result = parseInput(testdata, allocator);
    try testing.expectEqual(143, result);
}
