// Zig port of tail sort by VÖRÖSKŐI András <voroskoi@gmail.com>

const std = @import("std");
const zort = @import("main.zig");

pub fn tailSort(
    comptime T: type,
    allocator: std.mem.Allocator,
    arr: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) !void {
    if (arr.len < 2) return;

    try tailMerge(T, allocator, arr, context, cmp, 1);
}

/// Bottom up merge sort. It copies the right block to swap, next merges
/// starting at the tail ends of the two sorted blocks.
/// Can be used stand alone. Uses at most arr.len / 2 swap memory.
pub fn tailMerge(
    comptime T: type,
    allocator: std.mem.Allocator,
    arr: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
    b: u2,
) !void {
    var c: isize = undefined;
    var c_max: isize = undefined;
    var d: isize = undefined;
    var d_max: isize = undefined;
    var e: isize = undefined;

    var block: isize = b;

    var swap = try allocator.alloc(T, arr.len / 2);
    defer allocator.free(swap);

    while (block < arr.len) {
        var offset: isize = 0;
        while (offset + block < arr.len) : (offset += block * 2) {
            e = offset + block - 1;

            if (!cmp(context, arr[@intCast(usize, e) + 1], arr[@intCast(usize, e)])) continue;

            if (offset + block * 2 < arr.len) {
                c_max = 0 + block;
                d_max = offset + block * 2;
            } else {
                c_max = 0 + @intCast(isize, arr.len) - (offset + block);
                d_max = 0 + @intCast(isize, arr.len);
            }

            d = d_max - 1;

            while (!cmp(context, arr[@intCast(usize, d)], arr[@intCast(usize, e)])) {
                d_max -= 1;
                d -= 1;
                c_max -= 1;
            }

            c = 0;
            d = offset + block;

            while (c < c_max) {
                swap[@intCast(usize, c)] = arr[@intCast(usize, d)];
                c += 1;
                d += 1;
            }

            c -= 1;

            d = offset + block - 1;
            e = d_max - 1;

            if (!cmp(context, arr[@intCast(usize, offset + block)], arr[@intCast(usize, offset)])) {
                arr[@intCast(usize, e)] = arr[@intCast(usize, d)];
                e -= 1;
                d -= 1;
                while (c >= 0) {
                    while (cmp(context, swap[@intCast(usize, c)], arr[@intCast(usize, d)])) {
                        arr[@intCast(usize, e)] = arr[@intCast(usize, d)];
                        e -= 1;
                        d -= 1;
                    }
                    arr[@intCast(usize, e)] = swap[@intCast(usize, c)];
                    e -= 1;
                    c -= 1;
                }
            } else {
                arr[@intCast(usize, e)] = arr[@intCast(usize, d)];
                e -= 1;
                d -= 1;
                while (d >= offset) {
                    while (!cmp(context, swap[@intCast(usize, c)], arr[@intCast(usize, d)])) {
                        arr[@intCast(usize, e)] = swap[@intCast(usize, c)];
                        e -= 1;
                        c -= 1;
                    }
                    arr[@intCast(usize, e)] = arr[@intCast(usize, d)];
                    e -= 1;
                    d -= 1;
                }
                while (c >= 0) {
                    arr[@intCast(usize, e)] = swap[@intCast(usize, c)];
                    e -= 1;
                    c -= 1;
                }
            }
        }
        block *= 2;
    }
}
