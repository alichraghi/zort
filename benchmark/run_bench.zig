const zort = @import("zort");
const std = @import("std");
const mem = std.mem;
const eql = std.mem.eql;
const process = std.process;
const testing = std.testing;
const sort = std.sort;

fn e(a: []const u8, b: []const u8) bool {
    return eql(u8, a, b);
}

fn asc(a: usize, b: usize) bool {
    return a < b;
}

pub fn main() !void {
    const args = try process.argsAlloc(testing.allocator);
    defer process.argsFree(testing.allocator, args);

    const rand_engine = std.rand.DefaultPrng.init(@intCast(u64, std.time.milliTimestamp())).random();
    var arr = std.ArrayList(usize).init(testing.allocator);
    defer arr.deinit();
    var i: usize = 0;
    // 10 ^ 7
    while (i < 10_000_000) : (i += 1) {
        try arr.append(rand_engine.intRangeAtMostBiased(usize, 0, 10000000));
    }
    var items = try testing.allocator.dupe(usize, arr.items);

    for (args[1..]) |arg| {
        if (e(arg, "bubble"))
            zort.bubbleSort(usize, items, asc)
        else if (e(arg, "quick"))
            zort.quickSort(usize, items, asc)
        else if (e(arg, "insertion"))
            zort.insertionSort(usize, items, asc)
        else if (e(arg, "selection"))
            zort.selectionSort(usize, items, asc)
        else if (e(arg, "comb"))
            zort.combSort(usize, items, asc)
        else if (e(arg, "shell"))
            zort.shellSort(usize, items, asc)
        else if (e(arg, "heap"))
            zort.heapSort(usize, items, asc)
        else if (e(arg, "merge"))
            try zort.mergeSort(usize, items, asc, testing.allocator)
        else if (e(arg, "radix"))
            try zort.radixSort(usize, items, testing.allocator)
        else if (e(arg, "tim"))
            try zort.timSort(usize, items, asc, testing.allocator)
        else if (e(arg, "std_block_merge"))
            sort.sort(usize, items, {}, comptime sort.asc(usize))
        else if (e(arg, "std_insertion"))
            sort.insertionSort(usize, items, {}, comptime sort.asc(usize))
        else
            std.debug.panic("{s} is not a valid argument", .{arg});
    }
}
