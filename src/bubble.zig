const mem = @import("std").mem;

pub fn bubbleSort(
    comptime T: type,
    arr: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) void {
    for (0..arr.len) |i| {
        for (0..arr.len - i - 1) |j| {
            if (cmp(context, arr[j + 1], arr[j])) {
                mem.swap(T, &arr[j], &arr[j + 1]);
            }
        }
    }
}
