const std = @import("std");
const zort = @import("main.zig");

pub fn quickSort(
    comptime T: type,
    arr: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) void {
    return quickSortAdvanced(T, arr, 0, std.math.max(arr.len, 1) - 1, context, cmp);
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
    const pivot = getPivot(T, arr, left, right, context, cmp);
    var i = left;
    var j = left;
    while (j < right) : (j += 1) {
        if (cmp(context, arr[j], pivot)) {
            std.mem.swap(T, &arr[i], &arr[j]);
            i += 1;
        }
    }
    std.mem.swap(T, &arr[i], &arr[right]);
    quickSortAdvanced(T, arr, left, std.math.max(i, 1) - 1, context, cmp);
    quickSortAdvanced(T, arr, i + 1, right, context, cmp);
}

fn getPivot(
    comptime T: type,
    arr: []T,
    left: usize,
    right: usize,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) T {
    const mid = (left + right) / 2;
    if (cmp(context, arr[mid], arr[left])) std.mem.swap(T, &arr[mid], &arr[left]);
    if (cmp(context, arr[right], arr[left])) std.mem.swap(T, &arr[right], &arr[left]);
    if (cmp(context, arr[mid], arr[right])) std.mem.swap(T, &arr[mid], &arr[right]);
    return arr[right];
}
