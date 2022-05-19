const std = @import("std");
const zort = @import("main.zig");
const math = std.math;

pub fn insertionSortAdvanced(
    comptime T: type,
    arr: []T,
    left: usize,
    right: usize,
    cmp: zort.CompareFn(T),
) void {
    var i: usize = left + 1;
    while (i <= right) : (i += 1) {
        const x = arr[i];
        var j = i;
        while (j > left and cmp(x, arr[j - 1])) : (j -= 1) {
            arr[j] = arr[j - 1];
        }
        arr[j] = x;
    }
}

pub fn insertionSort(comptime T: type, arr: []T, cmp: zort.CompareFn(T)) void {
    return insertionSortAdvanced(T, arr, 0, math.max(arr.len, 1) - 1, cmp);
}
