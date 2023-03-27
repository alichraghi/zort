// Zig port of twinsort by VÖRÖSKŐI András <voroskoi@gmail.com>

const std = @import("std");
const zort = @import("main.zig");

pub fn twinSort(
    comptime T: type,
    allocator: std.mem.Allocator,
    arr: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) !void {
    if (twinSwap(T, arr, context, cmp) == 0) {
        try zort.tailMerge(T, allocator, arr, context, cmp, 2);
    }
}

/// Turn the array into sorted blocks of 2 elements.
/// Detect and sort reverse order runs. So `6 5 4 3 2 1` becomes `1 2 3 4 5 6`
/// rather than `5 6 3 4 1 2`.
fn twinSwap(
    comptime T: type,
    arr: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) usize {
    var index: usize = 0;
    var start: usize = undefined;
    var end: usize = arr.len - 2;
    while (index <= end) {
        if (cmp(context, arr[index], arr[index + 1])) {
            index += 2;
            continue;
        }

        start = index;
        index += 2;
        while (true) {
            if (index > end) {
                if (start == 0) {
                    if (arr.len % 2 == 0 or arr[index - 1] > arr[index]) {
                        // the entire slice was reversed
                        end = arr.len - 1;
                        while (start < end) {
                            std.mem.swap(T, &arr[start], &arr[end]);
                            start += 1;
                            end -= 1;
                        }
                        return 1;
                    }
                }
                break;
            }

            if (cmp(context, arr[index + 1], arr[index])) {
                if (cmp(context, arr[index], arr[index - 1])) {
                    index += 2;
                    continue;
                }
                std.mem.swap(T, &arr[index], &arr[index + 1]);
            }
            break;
        }

        end = index - 1;
        while (start < end) {
            std.mem.swap(T, &arr[start], &arr[end]);
            start += 1;
            end -= 1;
        }

        end = arr.len - 2;
        index += 2;
    }

    return 0;
}
