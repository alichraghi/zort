const std = @import("std");
const zort = @import("main.zig");
const mem = std.mem;

fn heapify(
    comptime T: type,
    arr: []T,
    n: usize,
    i: usize,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) void {
    // in ASC this should be largest, in desc smallest. so i just named this los = largest or samallest
    var los = i;
    const left = 2 * i + 1;
    const right = 2 * i + 2;

    if (left < n and cmp(context, arr[los], arr[left]))
        los = left;

    if (right < n and cmp(context, arr[los], arr[right]))
        los = right;

    if (los != i) {
        mem.swap(T, &arr[i], &arr[los]);
        heapify(T, arr, n, los, context, cmp);
    }
}

pub fn heapSort(
    comptime T: type,
    arr: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) void {
    if (arr.len == 0) return;

    var i = arr.len / 2;
    while (i > 0) : (i -= 1) {
        heapify(T, arr, arr.len, i - 1, context, cmp);
    }

    i = arr.len - 1;
    while (i > 0) : (i -= 1) {
        mem.swap(T, &arr[0], &arr[i]);
        heapify(T, arr, i, 0, context, cmp);
    }
}
