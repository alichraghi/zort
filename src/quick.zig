const std = @import("std");
const zort = @import("main.zig");
const math = std.math;
const mem = std.mem;

pub fn quickSort(comptime T: anytype, arr: []T, cmp: zort.CompareFn(T)) void {
    return quickSortAdvanced(T, arr, 0, math.max(arr.len, 1) - 1, cmp);
}

pub fn quickSortAdvanced(
    comptime T: anytype,
    arr: []T,
    left: usize,
    right: usize,
    cmp: zort.CompareFn(T),
) void {
    if (left >= right) return;
    const pivot = arr[right];
    var i = left;
    var j = left;
    while (j < right) : (j += 1) {
        if (cmp(arr[j], pivot)) {
            mem.swap(T, &arr[i], &arr[j]);
            i += 1;
        }
    }
    mem.swap(T, &arr[i], &arr[right]);
    quickSortAdvanced(T, arr, left, math.max(i, 1) - 1, cmp);
    quickSortAdvanced(T, arr, i + 1, right, cmp);
}
