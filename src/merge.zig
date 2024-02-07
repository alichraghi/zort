const std = @import("std");
const zort = @import("main.zig");

pub fn merge(
    comptime T: type,
    allocator: std.mem.Allocator,
    arr: []T,
    left: usize,
    mid: usize,
    right: usize,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) std.mem.Allocator.Error!void {
    const n1 = mid - left + 1;
    const n2 = right - mid;

    var L = try allocator.alloc(T, n1);
    var R = try allocator.alloc(T, n2);
    defer {
        allocator.free(L);
        allocator.free(R);
    }

    var i: usize = 0;
    var j: usize = 0;

    while (i < n1) : (i += 1) {
        L[i] = arr[left + i];
    }

    i = 0;
    while (i < n2) : (i += 1) {
        R[i] = arr[mid + 1 + i];
    }

    i = 0;
    var k = left;
    while (i < n1 and j < n2) : (k += 1) {
        if (cmp(context, L[i], R[j])) {
            arr[k] = L[i];
            i += 1;
        } else {
            arr[k] = R[j];
            j += 1;
        }
    }

    while (i < n1) {
        arr[k] = L[i];
        i += 1;
        k += 1;
    }

    while (j < n2) {
        arr[k] = R[j];
        j += 1;
        k += 1;
    }
}

pub fn mergeSortAdvanced(
    comptime T: type,
    allocator: std.mem.Allocator,
    arr: []T,
    left: usize,
    right: usize,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) std.mem.Allocator.Error!void {
    if (left < right) {
        const mid = left + (right - left) / 2;

        try mergeSortAdvanced(T, allocator, arr, left, mid, context, cmp);
        try mergeSortAdvanced(T, allocator, arr, mid + 1, right, context, cmp);

        try merge(T, allocator, arr, left, mid, right, context, cmp);
    }
}

pub fn mergeSort(
    comptime T: type,
    allocator: std.mem.Allocator,
    arr: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) std.mem.Allocator.Error!void {
    return mergeSortAdvanced(T, allocator, arr, 0, @max(arr.len, 1) - 1, context, cmp);
}
