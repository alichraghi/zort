const std = @import("std");
const zort = @import("main.zig");
const mem = std.mem;
const math = std.math;
const MIN_MERGE = 256;

pub fn timSort(
    comptime T: type,
    allocator: mem.Allocator,
    arr: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) mem.Allocator.Error!void {
    var i: usize = MIN_MERGE;

    zort.insertionSortAdvanced(T, arr, 0, math.min(MIN_MERGE - 1, arr.len - 1), context, cmp);

    var left: usize = 0;
    while (left < arr.len) : (left += 2 * i) {
        var mid = left + i - 1;
        var right = math.min((left + 2 * i - 1), (arr.len - 1));

        if (mid < right) {
            try zort.merge(T, allocator, arr, left, mid, right, context, cmp);
        }
    }
}
