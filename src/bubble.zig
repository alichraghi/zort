const std = @import("std");
const zort = @import("main.zig");
const mem = std.mem;

pub fn bubbleSort(
    comptime T: type,
    arr: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) void {
    for (arr) |_, i| {
        var j: usize = 0;
        while (j < arr.len - i - 1) : (j += 1) {
            if (cmp({}, arr[j + 1], arr[j])) {
                mem.swap(T, &arr[j], &arr[j + 1]);
            }
        }
    }
}
