const std = @import("std");
const zort = @import("main.zig");
const mem = std.mem;

pub fn selectionSort(comptime T: type, arr: []T, cmp: zort.CompareFn(T)) void {
    for (arr) |*item, i| {
        var pos = i;
        var j = i + 1;
        while (j < arr.len) : (j += 1) {
            if (cmp(arr[j], arr[pos])) {
                pos = j;
            }
        }
        mem.swap(T, &arr[pos], item);
    }
}
