const std = @import("std");
const mem = std.mem;

pub fn radixSort(comptime T: anytype, arr: []T, allocator: mem.Allocator) mem.Allocator.Error!void {
    if (arr.len == 0) return;
    var x: T = 1;
    const base: u4 = 10;

    // TODO: fix integer overflow for big inputs
    while (@divFloor(mem.max(T, arr), x) > 0) : (x *= base) {
        var res = try allocator.alloc(T, arr.len);
        defer allocator.free(res);

        var count = [_]usize{0} ** base;
        for (arr) |item| {
            count[@intCast(usize, @mod(@divFloor(item, x), base))] += 1;
        }

        {
            var i: u4 = 1;
            while (i < base) : (i += 1)
                count[i] += count[i - 1];
        }

        for (arr) |_, i| {
            const item = arr[arr.len - i - 1];
            res[count[@intCast(usize, @mod(@divFloor(item, x), base))] - 1] = item;
            count[@intCast(usize, @mod(@divFloor(item, x), base))] -= 1;
        }

        for (arr) |*item, i|
            item.* = res[i];
    }
}
