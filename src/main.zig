const std = @import("std");
const mem = std.mem;
const math = std.math;
const testing = std.testing;

pub const Algorithm = enum { Quick, Insertion, Selection };

/// sort and return the result (arr param)
pub fn sortR(comptime T: anytype, algorithm: ?Algorithm, arr: []T, desc: bool) []T {
    sort(T, algorithm, arr, desc);
    return arr;
}

/// sort to a owned slice
pub fn sortC(comptime T: anytype, algorithm: ?Algorithm, arr: []const T, desc: bool, allocator: *mem.Allocator) ![]T {
    var result = try allocator.alloc(T, arr.len);
    mem.copy(T, result, arr);
    return sortR(T, algorithm, result, desc);
}

/// sort array by given algorithm. default algorithm is Quick Sort
pub fn sort(comptime T: anytype, algorithm: ?Algorithm, arr: []T, desc: bool) void {
    if (algorithm == null) {
        quickSort(T, arr, 0, math.max(arr.len, 1) - 1, desc);
    } else {
        switch (algorithm.?) {
            .Quick => quickSort(T, arr, 0, math.max(arr.len, 1) - 1, desc),
            .Insertion => insertionSort(T, arr, desc),
            .Selection => selectionSort(T, arr, desc),
        }
    }
}

pub fn quickSort(comptime T: anytype, arr: []T, left: usize, right: usize, desc: bool) void {
    if (left < right) {
        const pivot = arr[right];
        var i = left;
        var j = left;
        while (j < right) : (j += 1) {
            if (flow(T, arr[j], pivot, desc)) {
                mem.swap(T, &arr[i], &arr[j]);
                i += 1;
            }
        }
        mem.swap(T, &arr[i], &arr[right]);
        quickSort(T, arr, left, math.max(i, 1) - 1, desc);
        quickSort(T, arr, i + 1, right, desc);
    }
}

pub fn insertionSort(comptime T: anytype, arr: []T, desc: bool) void {
    var i: usize = 1;
    while (i < arr.len) : (i += 1) {
        const x = arr[i];
        var j: usize = i;
        while (j > 0 and flow(T, x, arr[j - 1], desc)) : (j -= 1) {
            arr[j] = arr[j - 1];
        }
        arr[j] = x;
    }
}

pub fn selectionSort(comptime T: anytype, arr: []T, desc: bool) void {
    var i: usize = 1;
    while (i < arr.len) : (i += 1) {
        var pos = i - 1;
        var j = i;
        while (j < arr.len) : (j += 1) {
            if (flow(T, arr[j], arr[pos], desc)) {
                pos = j;
            }
        }
        mem.swap(T, &arr[pos], &arr[i - 1]);
    }
}

fn flow(comptime T: type, a: T, b: T, desc: bool) bool {
    if (desc)
        return a > b
    else
        return a < b;
}

const items = [_]u8{ 9, 1, 4, 12, 3, 4 };
const expectedASC = [_]u8{ 1, 3, 4, 4, 9, 12 };
const expectedDESC = [_]u8{ 12, 9, 4, 4, 3, 1 };

test "quick" {
    {
        var arr = items;
        quickSort(u8, &arr, 0, math.max(arr.len, 1) - 1, false);
        try testing.expect(mem.eql(u8, &arr, &expectedASC));
    }
    {
        var arr = items;
        quickSort(u8, &arr, 0, math.max(arr.len, 1) - 1, true);
        try testing.expect(mem.eql(u8, &arr, &expectedDESC));
    }
}

test "insertion" {
    {
        var arr = items;
        insertionSort(u8, &arr, false);
        try testing.expect(mem.eql(u8, &arr, &expectedASC));
    }
    {
        var arr = items;
        insertionSort(u8, &arr, true);
        try testing.expect(mem.eql(u8, &arr, &expectedDESC));
    }
}

test "selection" {
    {
        var arr = items;
        selectionSort(u8, &arr, false);
        try testing.expect(mem.eql(u8, &arr, &expectedASC));
    }
    {
        var arr = items;
        selectionSort(u8, &arr, true);
        try testing.expect(mem.eql(u8, &arr, &expectedDESC));
    }
}

test "sort" {
    {
        var arr = items;
        sort(u8, null, &arr, false);
        try testing.expect(mem.eql(u8, &arr, &expectedASC));
    }
    {
        var arr = items;
        try testing.expect(mem.eql(u8, sortR(u8, null, &arr, false), &expectedASC));
    }
    {
        var arr = items;
        const c = try sortC(u8, null, &arr, false, std.testing.allocator);
        defer std.testing.allocator.free(c);
        try testing.expect(mem.eql(u8, c, &expectedASC));
        try testing.expect(mem.eql(u8, &arr, &items));
    }
}
