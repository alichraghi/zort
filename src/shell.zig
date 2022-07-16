const zort = @import("main.zig");

pub fn shellSort(
    comptime T: type,
    arr: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) void {
    var gap = arr.len / 2;
    while (gap > 0) : (gap /= 2) {
        var i = gap;
        while (i < arr.len) : (i += 1) {
            const x = arr[i];
            var j = i;
            while (j >= gap and cmp(context, x, arr[j - gap])) : (j -= gap) {
                arr[j] = arr[j - gap];
            }
            arr[j] = x;
        }
    }
}
