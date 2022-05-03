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
                result.times[i] = try bench(zort.bubbleSort, .{ usize, items, asc })
            else if (std.mem.eql(u8, arg, "quick"))
                result.times[i] = try bench(zort.quickSort, .{ usize, items, asc })
            else if (std.mem.eql(u8, arg, "insertion"))
                result.times[i] = try bench(zort.insertionSort, .{ usize, items, asc })
            else if (std.mem.eql(u8, arg, "selection"))
                result.times[i] = try bench(zort.selectionSort, .{ usize, items, asc })
            else if (std.mem.eql(u8, arg, "comb"))
                result.times[i] = try bench(zort.combSort, .{ usize, items, asc })
            else if (std.mem.eql(u8, arg, "shell"))
                result.times[i] = try bench(zort.shellSort, .{ usize, items, asc })
            else if (std.mem.eql(u8, arg, "heap"))
                result.times[i] = try bench(zort.heapSort, .{ usize, items, asc })
            else if (std.mem.eql(u8, arg, "merge"))
                result.times[i] = try errbench(
                    zort.mergeSort,
                    .{ usize, items, asc, testing.allocator },
                )
            else if (std.mem.eql(u8, arg, "radix"))
                result.times[i] = try errbench(
                    zort.radixSort,
                    .{ usize, items, testing.allocator },
                )
            else if (std.mem.eql(u8, arg, "tim"))
                result.times[i] = try errbench(
                    zort.timSort,
                    .{ usize, items, asc, testing.allocator },
                )
            else if (std.mem.eql(u8, arg, "twin"))
                result.times[i] = try errbench(
                    zort.twinSort,
                    .{ std.testing.allocator, usize, items, {}, comptime std.sort.asc(usize) },
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

    try writeResults(results);
}

fn asc(a: usize, b: usize) bool {
    return a < b;
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

fn writeResults(results: std.ArrayList(BenchResult)) !void {
    const stdout = std.io.getStdOut().writer();

    var w = std.json.writeStream(stdout, 10);

    try w.beginObject();
    try w.objectField("results");
    try w.beginArray();

    for (results.items) |res| {
        try w.arrayElem();
        try w.beginObject();

        try w.objectField("command");
        try w.emitString(res.command);

        try w.objectField("mean");
        try w.emitNumber(res.mean);

        try w.objectField("times");
        try w.beginArray();
        for (res.times) |time| {
            try w.arrayElem();
            try w.emitNumber(time);
        }
        try w.endArray();

        try w.endObject();
    }

    try w.endArray();

    try w.endObject();
}
