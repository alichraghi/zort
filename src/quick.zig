const std = @import("std");
const zort = @import("main.zig");
const math = std.math;
const mem = std.mem;

pub fn quickSort(
    comptime T: type,
    arr: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) void {
    return quickSortAdvanced(T, arr, 0, math.max(arr.len, 1) - 1, context, cmp);
}

pub fn quickSortAdvanced(
    comptime T: type,
    arr: []T,
    left: usize,
    right: usize,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) void {
    if (left >= right) return;
    const pivot = arr[right];
    var i = left;
    var j = left;
    while (j < right) : (j += 1) {
        if (cmp(context, arr[j], pivot)) {
            mem.swap(T, &arr[i], &arr[j]);
            i += 1;
        }
    }
    mem.swap(T, &arr[i], &arr[right]);
    quickSortAdvanced(T, arr, left, math.max(i, 1) - 1, context, cmp);
    quickSortAdvanced(T, arr, i + 1, right, context, cmp);
}
