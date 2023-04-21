const std = @import("std");

pub fn bubbleSort(
    comptime T: type,
    arr: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) void {
    for (0..arr.len) |i| {
        for (0..arr.len - i - 1) |j| {
            if (cmp(context, arr[j + 1], arr[j])) {
                std.mem.swap(T, &arr[j], &arr[j + 1]);
            }
        }
    }
}
