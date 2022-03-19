const std = @import("std");
const zort = @import("main.zig");
const mem = std.mem;

pub fn combSort(comptime T: anytype, arr: []T, cmp: zort.CompareFn(T)) void {
    if (arr.len == 0) return;
    var gap = arr.len;
    var swapped = true;
    while (gap != 1 or swapped) {
        gap = (gap * 10 / 13) ^ 1;
        swapped = false;
        var i: usize = 0;
        while (i < arr.len - gap) : (i += 1) {
            if (cmp(arr[i + gap], arr[i])) {
                mem.swap(T, &arr[i], &arr[i + gap]);
                swapped = true;
            }
        }
    }
}
