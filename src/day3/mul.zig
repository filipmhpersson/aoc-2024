const std = @import("std");
const testing = std.testing;
const sort = std.mem.sort;
const assert = std.debug.assert;
const stdout = std.io.getStdOut().writer();

pub fn runDay3() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var file = try std.fs.cwd().openFile("./src/day3/data", .{});
    const allocator = arena.allocator();

    const stepOneInput = try file.readToEndAlloc(allocator, 1024 * 1024);
    const resultDay3 = try calculateValidMul(stepOneInput);
    const resultDay3_2 = try calculateValidMulWithDo(stepOneInput);
    try stdout.print("Result from day 3 step 1 {d}\n", .{resultDay3});
    try stdout.print("Result from day 3 step 2 {d}\n", .{resultDay3_2});
}

pub fn calculateValidMulWithDo(input: []const u8) anyerror!usize {
    var i: usize = 0;
    var value: usize = 0;
    var do = DoState.Do;

    while (true) {
        const kw = nextKeyword(input, &i) orelse { break; };
        switch(kw) {
            Keyword.Do => {
                do = DoState.Do;
                continue;
            },
            Keyword.Dont => {
                do = DoState.Dont;
                continue;
            },
            Keyword.Mul => {
                if(do == DoState.Dont){
                    i +=4;
                    continue;
                }
            }            
        }
        const mulStartIndex = std.mem.indexOfPos(u8, input, i, "mul(") orelse {
            break;
        };

        const lParenIndex = mulStartIndex + 3;

        const rParenIndex = std.mem.indexOfPos(u8, input, mulStartIndex, ")") orelse {
            break;
        };

        i = lParenIndex ;

        var numbersIterator = std.mem.tokenizeAny(u8, input[lParenIndex + 1..rParenIndex], ",");

        std.debug.print("Iter {s}\n", .{numbersIterator.buffer});
        const firstNumber = std.fmt.parseInt(usize, numbersIterator.next() orelse "bad", 10) catch {
            continue;
        };

        const secondNumber = std.fmt.parseInt(usize, numbersIterator.next() orelse "bad", 10) catch {
            continue;
        };

        const empty = numbersIterator.next();

        if (empty == null) {
            value += firstNumber * secondNumber;
        }
    }
    return value;
}

pub fn calculateValidMul(input: []const u8) anyerror!usize {
    var i: usize = 0;
    var value: usize = 0;

    while (true) {
        const mulStartIndex = std.mem.indexOfPos(u8, input, i, "mul(") orelse {
            break;
        };

        const lParenIndex = mulStartIndex + 3;

        const rParenIndex = std.mem.indexOfPos(u8, input, mulStartIndex, ")") orelse {
            break;
        };

        i = lParenIndex ;

        var numbersIterator = std.mem.tokenizeAny(u8, input[lParenIndex + 1..rParenIndex], ",");

        const firstNumber = std.fmt.parseInt(usize, numbersIterator.next() orelse "bad", 10) catch {
            continue;
        };

        const secondNumber = std.fmt.parseInt(usize, numbersIterator.next() orelse "bad", 10) catch {
            continue;
        };

        const empty = numbersIterator.next();

        if (empty == null) {
            value += firstNumber * secondNumber;
        }
    }
    return value;
}

fn nextKeyword(input: []const u8, currIndex: * usize) ?Keyword {

    var i = currIndex.*;

    while(input.len > i) {
        switch (input[i]) {
            'm' => { 
                const mulCheck = input[i..(i + 4)];
                if(std.mem.eql(u8, mulCheck, "mul(")){
                    return Keyword.Mul;
                }
            },
            'd' => {
                const doCheck = input[i..i + 4];
                if(std.mem.eql(u8, doCheck, "do()")) {
                    currIndex.* = i + 4;
                    return Keyword.Do;
                }
                const dontCheck = input[i..i + 7];
                if(std.mem.eql(u8, dontCheck, "don't()")) {
                    currIndex.* = i + 7;
                    return Keyword.Dont;
                }
                
            },
            else => {}
        }
        i += 1;
    }
    return null;
}
const Direction = enum { Unknown, Asc, Desc };
const Keyword = enum { Mul, Do, Dont };
const DoState = enum {  Do, Dont };
test "Verify multiply data" {
    const testdata = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";

    const result = calculateValidMul(testdata);
    try testing.expectEqual(161, result);
}

test "Verify mul do data" {
    const testdata = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";

    const result = calculateValidMulWithDo(testdata);
    try testing.expectEqual(48, result);
}
