const std = @import("std");
const zort = @import("main.zig");

pub fn insertionSort(comptime T: anytype, arr: []T, cmp: zort.CompareFn(T)) void {
    var i: usize = 1;
    while (i < arr.len) : (i += 1) {
        const x = arr[i];
        var j = i;
        while (j > 0 and cmp(x, arr[j - 1])) : (j -= 1) {
            arr[j] = arr[j - 1];
        }
        arr[j] = x;
    }
}
