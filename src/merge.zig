const std = @import("std");
const zort = @import("main.zig");
const math = std.math;
const mem = std.mem;

pub fn merge(
    comptime T: anytype,
    allocator: mem.Allocator,
    arr: []T,
    left: usize,
    mid: usize,
    right: usize,
    cmp: zort.CompareFn(T),
) mem.Allocator.Error!void {
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
        if (cmp(L[i], R[j])) {
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
    comptime T: anytype,
    allocator: mem.Allocator,
    arr: []T,
    cmp: zort.CompareFn(T),
    left: usize,
    right: usize,
) mem.Allocator.Error!void {
    if (left < right) {
        var mid = left + (right - left) / 2;

        try mergeSortAdvanced(T, allocator, arr, cmp, left, mid);
        try mergeSortAdvanced(T, allocator, arr, cmp, mid + 1, right);

        try merge(T, allocator, arr, left, mid, right, cmp);
    }
}

pub fn mergeSort(
    comptime T: anytype,
    allocator: mem.Allocator,
    arr: []T,
    cmp: zort.CompareFn(T),
) mem.Allocator.Error!void {
    return mergeSortAdvanced(T, allocator, arr, cmp, 0, math.max(arr.len, 1) - 1);
}
