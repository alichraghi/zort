const std = @import("std");
const zort = @import("main.zig");
const mem = std.mem;

fn heapify(comptime T: anytype, arr: []T, n: usize, i: usize, cmp: zort.CompareFn(T)) void {
    // in ASC this should be largest, in desc smallest. so i just named this los = largest or samallest
    var los = i;
    const left = 2 * i + 1;
    const right = 2 * i + 2;

    if (left < n and cmp(arr[los], arr[left]))
        los = left;

    if (right < n and cmp(arr[los], arr[right]))
        los = right;

    if (los != i) {
        mem.swap(T, &arr[i], &arr[los]);
        heapify(T, arr, n, los, cmp);
    }
}

pub fn heapSort(comptime T: anytype, arr: []T, cmp: zort.CompareFn(T)) void {
    if (arr.len == 0) return;

    var i = arr.len / 2;
    while (i > 0) : (i -= 1) {
        heapify(T, arr, arr.len, i - 1, cmp);
    }

    i = arr.len - 1;
    while (i > 0) : (i -= 1) {
        mem.swap(T, &arr[0], &arr[i]);
        heapify(T, arr, i, 0, cmp);
    }
}
