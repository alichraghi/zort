const std = @import("std");
const mem = std.mem;
const math = std.math;
const Allocator = mem.Allocator;

pub usingnamespace @import("bubble.zig");
pub usingnamespace @import("comb.zig");
pub usingnamespace @import("heap.zig");
pub usingnamespace @import("insertion.zig");
pub usingnamespace @import("merge.zig");
pub usingnamespace @import("quick.zig");
pub usingnamespace @import("radix.zig");
pub usingnamespace @import("selection.zig");
pub usingnamespace @import("shell.zig");

pub fn CompareFn(comptime T: type) type {
    return fn (a: T, b: T) bool;
}

// pub fn timSort(comptime T: anytype, arr: []T, cmp: CompareFn(T), allocator: mem.Allocator) Allocator.Error!void {
//     const RUN = 32;
//     // Sort individual subarrays of size RUN
//     {
//         var i: usize = 0;

//         while (i < arr.len) : (i += RUN) {
//             insertionSort(T, arr[i..math.min(i + RUN - 1, n - 1)], cmp);
//         }
//     }

//     var i: usize = RUN;

//     while (i < arr.len) : (i = 2 * i) {
//         var left: usize = 0;
//         while (left < arr.len) : (left += 2 * i) {

//             // find ending point of
//             // left sub array
//             // mid+1 is starting point
//             // of right sub array
//             var mid = left + i - 1;
//             var right = math.min((left + 2 * i - 1), (n - 1));

//             // merge sub array arr[left.....mid] &
//             // arr[mid+1....right]
//             if (mid < right)
//                 merge(arr, left, mid, right);
//         }
//     }
// }
