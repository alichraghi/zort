const std = @import("std");
const zort = @import("main.zig");

pub fn selectionSort(
    comptime T: type,
    arr: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) void {
    for (arr, 0..) |*item, i| {
        var pos = i;
        var j = i + 1;
        while (j < arr.len) : (j += 1) {
            if (cmp(context, arr[j], arr[pos])) {
                pos = j;
            }
        }
        std.mem.swap(T, &arr[pos], item);
    }
}
