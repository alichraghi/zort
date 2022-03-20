const std = @import("std");
const zort = @import("main.zig");
const mem = std.mem;
const math = std.math;
const MIN_MERGE = 256;

pub fn timSort(comptime T: anytype, arr: []T, cmp: zort.CompareFn(T), allocator: mem.Allocator) mem.Allocator.Error!void {
    var i: usize = MIN_MERGE;

    zort.insertionSortAdvanced(T, arr, 0, math.min(MIN_MERGE - 1, arr.len - 1), cmp);

    var left: usize = 0;
    while (left < arr.len) : (left += 2 * i) {
        var mid = left + i - 1;
        var right = math.min((left + 2 * i - 1), (arr.len - 1));

        if (mid < right) {
            try zort.merge(T, arr, left, mid, right, cmp, allocator);
        }
    }
}
