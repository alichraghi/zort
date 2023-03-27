const std = @import("std");
const zort = @import("main.zig");
const mem = std.mem;

pub fn combSort(
    comptime T: type,
    arr: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) void {
    if (arr.len == 0) return;
    var gap = arr.len;
    var swapped = true;
    while (gap != 1 or swapped) {
        gap = (gap * 10 / 13) ^ 1;
        swapped = false;
        for (0..arr.len - gap) |i| {
            if (cmp(context, arr[i + gap], arr[i])) {
                mem.swap(T, &arr[i], &arr[i + gap]);
                swapped = true;
            }
        }
    }
}
