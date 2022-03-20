const std = @import("std");
const zort = @import("main.zig");
const mem = std.mem;
const math = std.math;
const MIN_MERGE = 8;

pub fn minRun(n: usize) usize {
    var i = n;
    var r: usize = 0;
    while (i >= MIN_MERGE) {
        r |= i & 1;
        i >>= 1;
    }
    return i + r;
}

pub fn timSort(comptime T: anytype, arr: []T, cmp: zort.CompareFn(T), allocator: mem.Allocator) mem.Allocator.Error!void {
    var i: usize = 0;
    const min_run = minRun(arr.len);

    while (i < arr.len) : (i += min_run) {
        zort.insertionSortAdvanced(T, arr, i, math.min(i + min_run - 1, arr.len - 1), cmp);
    }

    i = min_run;

    while (i < arr.len) : (i = 2 * i) {
        var left: usize = 0;
        while (left < arr.len) : (left += 2 * i) {
            var mid = left + i - 1;
            var right = math.min((left + 2 * i - 1), (arr.len - 1));

            if (mid < right) {
                try zort.merge(T, arr, left, mid, right, cmp, allocator);
            }
        }
    }
}
