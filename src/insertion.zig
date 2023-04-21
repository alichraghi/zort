const std = @import("std");
const zort = @import("main.zig");

pub fn insertionSortAdvanced(
    comptime T: type,
    arr: []T,
    left: usize,
    right: usize,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) void {
    for (left..right) |i| {
        const x = arr[i + 1];
        var j = i + 1;
        while (j > left and cmp(context, x, arr[j - 1])) : (j -= 1) {
            arr[j] = arr[j - 1];
        }
        arr[j] = x;
    }
}

pub fn insertionSort(
    comptime T: type,
    arr: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) void {
    return insertionSortAdvanced(T, arr, 0, std.math.max(arr.len, 1) - 1, context, cmp);
}
