const std = @import("std");

const zort = @import("zort");

const gen = @import("generator.zig");

const INPUT_ITEMS = 10_000_000;
const RUNS = 5;
const TYPES = [_]type{ usize, isize };
const FLAVORS = .{ gen.random, gen.sorted, gen.reverse, gen.ascSaw, gen.descSaw };

const BenchResult = struct {
    command: []const u8,
    mean: u64,
    times: [RUNS]u64,
    tp: []const u8,
    flavor: []const u8,
};

pub fn main(init: std.process.Init) !void {
    // initialize the allocator
    const allocator = init.gpa;

    // parse arguments
    const args = try init.minimal.args.toSlice(init.arena.allocator());

    if (args.len < 2) {
        std.debug.print("no algorithm(s) specified\nexiting...\n", .{});
        return;
    }

    // prepare array for storing benchmark results
    var results = std.ArrayList(BenchResult).empty;
    defer results.deinit(allocator);

    inline for (TYPES) |tp| {
        inline for (FLAVORS) |flavor| {
            const flavor_name: []const u8 = switch (flavor) {
                gen.random => "random",
                gen.sorted => "sorted",
                gen.reverse => "reverse",
                gen.ascSaw => "ascending saw",
                gen.descSaw => "descending saw",
                else => unreachable,
            };
            std.debug.print(
                "Generating {s} data ({d} items of {s})... ",
                .{ flavor_name, INPUT_ITEMS, @typeName(tp) },
            );
            const arr = try @call(.auto, flavor, .{ tp, init.io, allocator, INPUT_ITEMS });
            defer allocator.free(arr);
            std.debug.print("Done. ", .{});

            for (args[1..]) |arg| {
                std.debug.print("\nStarting {s} sort...", .{arg});
                var res = try runIterations(tp, init.io, allocator, arg, arr);
                res.command = arg;
                res.tp = @typeName(tp);
                res.flavor = flavor_name;
                try results.append(allocator, res);
            }

            std.debug.print("\n", .{});
        }
    }

    try writeMermaid(allocator, init.io, results);
}

fn checkSorted(
    comptime T: type,
    arr: []T,
) bool {
    var i: usize = 1;
    while (i < arr.len) : (i += 1) {
        if (arr[i - 1] > arr[i]) {
            return false;
        }
    }
    return true;
}

fn runIterations(
    comptime T: type,
    io: std.Io,
    allocator: std.mem.Allocator,
    arg: [:0]const u8,
    arr: []T,
) !BenchResult {
    var result: BenchResult = undefined;

    var i: usize = 0;
    var failed_runs: usize = 0;
    while (i < RUNS) : (i += 1) {
        const items = try allocator.dupe(T, arr);
        defer allocator.free(items);

        if (std.mem.eql(u8, arg, "bubble"))
            result.times[i] = try bench(io, zort.bubbleSort, .{ T, items, {}, comptime std.sort.asc(T) })
        else if (std.mem.eql(u8, arg, "quick"))
            result.times[i] = try bench(io, zort.quickSort, .{ T, items, {}, comptime std.sort.asc(T) })
        else if (std.mem.eql(u8, arg, "selection"))
            result.times[i] = try bench(io, zort.selectionSort, .{ T, items, {}, comptime std.sort.asc(T) })
        else if (std.mem.eql(u8, arg, "comb"))
            result.times[i] = try bench(io, zort.combSort, .{ T, items, {}, comptime std.sort.asc(T) })
        else if (std.mem.eql(u8, arg, "shell"))
            result.times[i] = try bench(io, zort.shellSort, .{ T, items, {}, comptime std.sort.asc(T) })
        else if (std.mem.eql(u8, arg, "merge"))
            result.times[i] = try errbench(
                io,
                zort.mergeSort,
                .{ T, allocator, items, {}, comptime std.sort.asc(T) },
            )
        else if (std.mem.eql(u8, arg, "radix")) {
            result.times[i] = try errbench(
                io,
                zort.radixSort,
                .{ T, zort.SortOptions{}, allocator, items },
            );
        } else if (std.mem.eql(u8, arg, "tim"))
            result.times[i] = try errbench(
                io,
                zort.timSort,
                .{ T, allocator, items, {}, comptime std.sort.asc(T) },
            )
        else if (std.mem.eql(u8, arg, "tail"))
            result.times[i] = try errbench(
                io,
                zort.tailSort,
                .{ T, allocator, items, {}, comptime std.sort.asc(T) },
            )
        else if (std.mem.eql(u8, arg, "twin"))
            result.times[i] = try errbench(
                io,
                zort.twinSort,
                .{ T, allocator, items, {}, comptime std.sort.asc(T) },
            )
        else if (std.mem.eql(u8, arg, "std_block"))
            result.times[i] = try bench(
                io,
                std.sort.block,
                .{ T, items, {}, comptime std.sort.asc(T) },
            )
        else if (std.mem.eql(u8, arg, "std_pdq"))
            result.times[i] = try bench(
                io,
                std.sort.pdq,
                .{ T, items, {}, comptime std.sort.asc(T) },
            )
        else if (std.mem.eql(u8, arg, "std_heap"))
            result.times[i] = try bench(
                io,
                std.sort.heap,
                .{ T, items, {}, comptime std.sort.asc(T) },
            )
        else if (std.mem.eql(u8, arg, "std_insertion"))
            result.times[i] = try bench(
                io,
                std.sort.insertion,
                .{ T, items, {}, comptime std.sort.asc(T) },
            )
        else
            std.debug.panic("{s} is not a valid argument", .{arg});

        if (!checkSorted(T, items)) {
            failed_runs += 1;
        }

        if (failed_runs == 0) {
            std.debug.print("\r{s:<20} round: {d:>2}/{d:<10} time: {d} ms", .{ arg, i + 1, RUNS, result.times[i] });
        } else {
            std.debug.print("\r{s:<20} round: {d:>2}/{d:<10} time: {d} ms failed: {d}   ", .{ arg, i + 1, RUNS, result.times[i], failed_runs });
        }
    }

    var sum: usize = 0;
    for (result.times) |time| {
        sum += time;
    }
    result.mean = sum / RUNS;

    return result;
}

fn bench(io: std.Io, func: anytype, args: anytype) !u64 {
    var timer = std.Io.Clock.awake.now(io);
    @call(.auto, func, args);
    return @intCast(timer.untilNow(io, .awake).toMilliseconds());
}

fn errbench(io: std.Io, func: anytype, args: anytype) !u64 {
    var timer = std.Io.Clock.awake.now(io);
    try @call(.auto, func, args);
    return @intCast(timer.untilNow(io, .awake).toMilliseconds());
}

fn writeMermaid(allocator: std.mem.Allocator, io: std.Io, results: std.ArrayList(BenchResult)) !void {
    var buffer = try allocator.alloc(u8, 1024 * 8);
    var stdout_raw = std.Io.File.stdout().writer(io, buffer[0..]);

    var stdout = &stdout_raw.interface;

    var curr_type: []const u8 = "";
    var curr_flavor: []const u8 = "";

    const header_top =
        \\
        \\You can paste the following code snippet to a Markdown file:
        \\
    ;
    const header_bottom =
        \\    dateFormat x
        \\    axisFormat %S s
    ;

    try stdout.print("\n{s}\n", .{header_top});

    for (results.items) |res| {
        if (!std.mem.eql(u8, res.tp, curr_type)) {
            if (curr_type.len != 0) {
                try stdout.writeAll("```\n\n");
            }
            try stdout.print(
                "```mermaid\ngantt\n    title Sorting (ascending) {d} {s}\n{s}\n",
                .{ INPUT_ITEMS, res.tp, header_bottom },
            );
            curr_type = res.tp;
            curr_flavor = "";
        }
        if (!std.mem.eql(u8, res.flavor, curr_flavor)) {
            try stdout.print("    section {s}\n", .{res.flavor});
            curr_flavor = res.flavor;
        }
        try stdout.print("    {s} {d:.3}: 0,{d}\n", .{
            res.command,
            @as(f16, @floatFromInt(res.mean)) / std.time.ms_per_s,
            res.mean,
        });
    }

    try stdout.writeAll("```\n");

    try stdout_raw.flush();
    allocator.free(buffer);
}
