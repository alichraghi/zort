const zort = @import("zort");
const std = @import("std");
const testing = std.testing;

const Str = []const u8;

const INPUT_ITEMS = 10_000_000;
const RUNS = 10;

const BenchResult = struct {
    command: Str,
    mean: u64,
    times: [RUNS]u64,
};

pub fn main() !void {
    const args = try std.process.argsAlloc(testing.allocator);
    defer std.process.argsFree(testing.allocator, args);

    // generate random data
    const rand_engine = std.rand.DefaultPrng.init(@intCast(u64, std.time.milliTimestamp())).random();
    var arr = try std.ArrayList(usize).initCapacity(testing.allocator, INPUT_ITEMS);
    defer arr.deinit();
    std.debug.print("Generating random data ({d} items)... ", .{INPUT_ITEMS});
    var i: usize = 0;
    while (i < INPUT_ITEMS) : (i += 1) {
        arr.appendAssumeCapacity(rand_engine.intRangeAtMostBiased(usize, 0, INPUT_ITEMS));
    }
    std.debug.print("Done. ", .{});

    var results = std.ArrayList(BenchResult).init(std.testing.allocator);
    defer results.deinit();

    for (args[1..]) |arg| {
        std.debug.print("\nStarting {s} sort...", .{arg});
        var result: BenchResult = undefined;

        i = 0;
        while (i < RUNS) : (i += 1) {
            var items = try testing.allocator.dupe(usize, arr.items);

            if (std.mem.eql(u8, arg, "bubble"))
                result.times[i] = try bench(zort.bubbleSort, .{ usize, items, {}, comptime std.sort.asc(usize) })
            else if (std.mem.eql(u8, arg, "quick"))
                result.times[i] = try bench(zort.quickSort, .{ usize, items, {}, comptime std.sort.asc(usize) })
            else if (std.mem.eql(u8, arg, "insertion"))
                result.times[i] = try bench(zort.insertionSort, .{ usize, items, {}, comptime std.sort.asc(usize) })
            else if (std.mem.eql(u8, arg, "selection"))
                result.times[i] = try bench(zort.selectionSort, .{ usize, items, {}, comptime std.sort.asc(usize) })
            else if (std.mem.eql(u8, arg, "comb"))
                result.times[i] = try bench(zort.combSort, .{ usize, items, {}, comptime std.sort.asc(usize) })
            else if (std.mem.eql(u8, arg, "shell"))
                result.times[i] = try bench(zort.shellSort, .{ usize, items, {}, comptime std.sort.asc(usize) })
            else if (std.mem.eql(u8, arg, "heap"))
                result.times[i] = try bench(zort.heapSort, .{ usize, items, {}, comptime std.sort.asc(usize) })
            else if (std.mem.eql(u8, arg, "merge"))
                result.times[i] = try errbench(
                    zort.mergeSort,
                    .{ usize, testing.allocator, items, {}, comptime std.sort.asc(usize) },
                )
            else if (std.mem.eql(u8, arg, "radix"))
                result.times[i] = try errbench(
                    zort.radixSort,
                    .{ usize, testing.allocator, items },
                )
            else if (std.mem.eql(u8, arg, "tim"))
                result.times[i] = try errbench(
                    zort.timSort,
                    .{ usize, testing.allocator, items, {}, comptime std.sort.asc(usize) },
                )
            else if (std.mem.eql(u8, arg, "tail"))
                result.times[i] = try errbench(
                    zort.tailSort,
                    .{ usize, testing.allocator, items, {}, comptime std.sort.asc(usize) },
                )
            else if (std.mem.eql(u8, arg, "twin"))
                result.times[i] = try errbench(
                    zort.twinSort,
                    .{ usize, std.testing.allocator, items, {}, comptime std.sort.asc(usize) },
                )
            else if (std.mem.eql(u8, arg, "std_block_merge"))
                result.times[i] = try bench(
                    std.sort.sort,
                    .{ usize, items, {}, comptime std.sort.asc(usize) },
                )
            else if (std.mem.eql(u8, arg, "std_insertion"))
                result.times[i] = try bench(
                    std.sort.insertionSort,
                    .{ usize, items, {}, comptime std.sort.asc(usize) },
                )
            else if (std.mem.eql(u8, arg, "pdq"))
                result.times[i] = try bench(
                    zort.pdqSort,
                    .{ usize, items, {}, comptime std.sort.asc(usize) },
                )
            else
                std.debug.panic("{s} is not a valid argument", .{arg});

            std.debug.print("\r{s:<20} round: {d:>2}/{d:<10} time: {d} ms", .{ arg, i + 1, RUNS, result.times[i] });
        }

        var sum: usize = 0;
        for (result.times) |time| {
            sum += time;
        }
        result.command = try std.fmt.allocPrint(testing.allocator, "{s} {s}", .{ args[0], arg });
        result.mean = sum / RUNS;

        try results.append(result);
    }

    try writeMermaid(results);
}

fn bench(func: anytype, args: anytype) anyerror!u64 {
    var timer = try std.time.Timer.start();
    @call(.{}, func, args);
    return timer.read() / std.time.ns_per_ms;
}

fn errbench(func: anytype, args: anytype) anyerror!u64 {
    var timer = try std.time.Timer.start();
    try @call(.{}, func, args);
    return timer.read() / std.time.ns_per_ms;
}

fn writeMermaid(results: std.ArrayList(BenchResult)) !void {
    const stdout = std.io.getStdOut().writer();

    const header =
        \\
        \\You can paste the following code snippet to the README.md file:
        \\
        \\```mermaid
        \\gantt
        \\    title Sorting 10 million items
        \\    dateFormat x
        \\    axisFormat %S s
    ;

    try stdout.print("\n{s}\n", .{header});

    for (results.items) |res| {
        try stdout.print("    {s} {d:.3}: 0,{d}\n", .{ res.command, @intToFloat(f16, res.mean) / std.time.ms_per_s, res.mean });
    }

    _ = try stdout.write("```\n");
}
