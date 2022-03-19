const std = @import("std");
const zort = @import("main.zig");
const mem = std.mem;
const math = std.math;

pub fn timSort(comptime T: anytype, arr: []T, cmp: zort.CompareFn(T), allocator: mem.Allocator) mem.Allocator.Error!void {
    const RUN = 32;

    var i: usize = 0;

    while (i < arr.len) : (i += RUN) {
        zort.insertionSortAdvanced(T, arr, i, math.min(i + RUN - 1, arr.len - 1), cmp);
    }

    i = RUN;

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
