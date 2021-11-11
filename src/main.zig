const std = @import("std");
const mem = std.mem;
const math = std.math;
const testing = std.testing;

pub const Error = error{ OutOfMemory, AllocatorRequired, NotImplemented };

pub const Algorithm = enum { Bubble, Quick, Insertion, Selection, Comb, Shell, Heap, Merge, Radix };

/// sort and return the result (arr param)
pub fn sortR(comptime T: anytype, arr: []T, desc: bool, algorithm: ?Algorithm, allocator: ?*mem.Allocator) Error![]T {
    try sort(T, arr, desc, algorithm, allocator);
    return arr;
}

/// sort to a owned slice
pub fn sortC(comptime T: anytype, arr: []const T, desc: bool, algorithm: ?Algorithm, allocator: *mem.Allocator) Error![]T {
    return try sortR(T, try allocator.dupe(T, arr), desc, algorithm, allocator);
}

/// sort array by given algorithm. default algorithm is Quick Sort
pub fn sort(comptime T: anytype, arr: []T, desc: bool, algorithm_opt: ?Algorithm, allocator_opt: ?*mem.Allocator) Error!void {
    if (algorithm_opt) |algorithm| {
        switch (algorithm) {
            .Bubble => bubbleSort(T, arr, desc),
            .Quick => quickSort(T, arr, 0, math.max(arr.len, 1) - 1, desc),
            .Insertion => insertionSort(T, arr, desc),
            .Selection => selectionSort(T, arr, desc),
            .Comb => combSort(T, arr, desc),
            .Shell => shellSort(T, arr, desc),
            .Heap => try heapSort(T, arr, desc),
            else => {
                if (allocator_opt) |allocator| {
                    switch (algorithm) {
                        .Merge => try mergeSort(T, arr, 0, math.max(arr.len, 1) - 1, desc, allocator),
                        .Radix => try radixSort(T, arr, desc, allocator),
                        else => {},
                    }
                } else {
                    return error.AllocatorRequired;
                }
            },
        }
    } else {
        quickSort(T, arr, 0, math.max(arr.len, 1) - 1, desc);
    }
}

pub fn bubbleSort(comptime T: anytype, arr: []T, desc: bool) void {
    var i: usize = 0;
    while (i < arr.len - 1) : (i += 1) {
        var j: usize = 0;
        while (j < arr.len - i - 1) : (j += 1) {
            if (flow(arr[j + 1], arr[j], desc)) {
                mem.swap(T, &arr[j], &arr[j + 1]);
            }
        }
    }
}

pub fn quickSort(comptime T: anytype, arr: []T, left: usize, right: usize, desc: bool) void {
    if (left < right) {
        const pivot = arr[right];
        var i = left;
        var j = left;
        while (j < right) : (j += 1) {
            if (flow(arr[j], pivot, desc)) {
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
        while (j > 0 and flow(x, arr[j - 1], desc)) : (j -= 1) {
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
            if (flow(arr[j], arr[pos], desc)) {
                pos = j;
            }
        }
        mem.swap(T, &arr[pos], &arr[i - 1]);
    }
}

pub fn combSort(comptime T: anytype, arr: []T, desc: bool) void {
    var gap = arr.len;
    var f = true;
    while (gap != 1 or f == true) {
        gap = @floatToInt(usize, @intToFloat(f32, gap) / 1.3);
        if (gap < 1) gap = 1;
        f = false;
        var i: usize = 0;
        while (i < arr.len - gap) : (i += 1) {
            if (flow(arr[i + gap], arr[i], desc)) {
                mem.swap(T, &arr[i], &arr[i + gap]);
                f = true;
            }
        }
    }
}

pub fn shellSort(comptime T: anytype, arr: []T, desc: bool) void {
    var gap = arr.len / 2;
    while (gap > 0) : (gap /= 2) {
        var i: usize = gap;
        while (i < arr.len) : (i += 1) {
            const x = arr[i];
            var j = i;
            while (j >= gap and flow(x, arr[j - gap], desc)) : (j -= gap) {
                arr[j] = arr[j - gap];
            }
            arr[j] = x;
        }
    }
}

pub fn mergeSort(comptime T: anytype, arr: []T, left: usize, right: usize, desc: bool, allocator: *mem.Allocator) Error!void {
    if (left >= right) return;
    const mid = left + (right - left) / 2;
    try mergeSort(T, arr, left, mid, desc, allocator);
    try mergeSort(T, arr, mid + 1, right, desc, allocator);
    const n1 = mid - left + 1;
    const n2 = right - mid;
    var L = try allocator.alloc(T, n1);
    var R = try allocator.alloc(T, n1);
    defer {
        allocator.free(L);
        allocator.free(R);
    }
    {
        var i: usize = 0;
        while (i < n1) : (i += 1) {
            L[i] = arr[left + i];
        }
    }
    {
        var j: usize = 0;
        while (j < n2) : (j += 1) {
            R[j] = arr[mid + 1 + j];
        }
    }
    var i: usize = 0;
    var j: usize = 0;
    var k = left;
    while (i < n1 and j < n2) : (k += 1) {
        if (flow(L[i], R[j], desc)) {
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

pub fn radixSort(comptime T: anytype, arr: []T, desc: bool, allocator: *mem.Allocator) !void {
    const m = mem.max(T, arr);
    var x: usize = 1;
    while (m / x > 0) : (x *= 10) {
        var res = try allocator.alloc(T, arr.len);
        defer allocator.free(res);

        var count = [_]usize{0} ** 10;
        for (arr) |item| {
            count[(item / x) % 10] += 1;
        }

        {
            var i: usize = 1;
            while (i < 10) : (i += 1) {
                count[i] += count[i - 1];
            }
        }

        {
            var i = @intCast(isize, arr.len - 1);
            while (i >= 0) : (i -= 1) {
                res[count[(arr[@intCast(usize, i)] / x) % 10] - 1] = arr[@intCast(usize, i)];
                count[(arr[@intCast(usize, i)] / x) % 10] -= 1;
            }
        }

        for (arr) |*item, i|
            item.* = res[i];
    }
    mem.reverse(T, arr);
}

fn heapify(comptime T: anytype, arr: []T, n: usize, i: usize, desc: bool) void {
    // in ASC this should be largest, in desc smallest. so i just named this los = largest or samallest
    var los = i;
    const left = 2 * i + 1;
    const right = 2 * i + 2;

    if (left < n and flow(arr[los], arr[left], desc))
        los = left;

    if (right < n and flow(arr[los], arr[right], desc))
        los = right;

    if (los != i) {
        mem.swap(T, &arr[i], &arr[los]);
        heapify(T, arr, n, los, desc);
    }
}

pub fn heapSort(comptime T: anytype, arr: []T, desc: bool) !void {
    _ = desc;
    {
        var i = @intCast(isize, arr.len / 2 - 1);
        while (i >= 0) : (i -= 1)
            heapify(T, arr, arr.len, @intCast(usize, i), desc);
    }

    var i: usize = arr.len - 1;
    while (i > 0) : (i -= 1) {
        mem.swap(T, &arr[0], &arr[i]);
        heapify(T, arr, i, 0, desc);
    }
}

fn flow(a: anytype, b: @TypeOf(a), desc: bool) bool {
    if (desc)
        return a > b
    else
        return a < b;
}

const items = [_]u8{ 9, 1, 4, 12, 3, 4 };
const expectedASC = [_]u8{ 1, 3, 4, 4, 9, 12 };
const expectedDESC = [_]u8{ 12, 9, 4, 4, 3, 1 };

test "bubble" {
    {
        var arr = items;
        bubbleSort(u8, &arr, false);
        try testing.expect(mem.eql(u8, &arr, &expectedASC));
    }
    {
        var arr = items;
        bubbleSort(u8, &arr, true);
        try testing.expect(mem.eql(u8, &arr, &expectedDESC));
    }
}

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

test "comb" {
    {
        var arr = items;
        combSort(u8, &arr, false);
        try testing.expect(mem.eql(u8, &arr, &expectedASC));
    }
    {
        var arr = items;
        combSort(u8, &arr, true);
        try testing.expect(mem.eql(u8, &arr, &expectedDESC));
    }
}

test "shell" {
    {
        var arr = items;
        shellSort(u8, &arr, false);
        try testing.expect(mem.eql(u8, &arr, &expectedASC));
    }
    {
        var arr = items;
        shellSort(u8, &arr, true);
        try testing.expect(mem.eql(u8, &arr, &expectedDESC));
    }
}

test "heap" {
    {
        var arr = items;
        try heapSort(u8, &arr, false);
        try testing.expect(mem.eql(u8, &arr, &expectedASC));
    }
    {
        var arr = items;
        try heapSort(u8, &arr, true);
        try testing.expect(mem.eql(u8, &arr, &expectedDESC));
    }
}

test "merge" {
    {
        var arr = items;
        try mergeSort(u8, &arr, 0, comptime math.max(arr.len, 1) - 1, false, testing.allocator);
        try testing.expect(mem.eql(u8, &arr, &expectedASC));
    }
    {
        var arr = items;
        try mergeSort(u8, &arr, 0, comptime math.max(arr.len, 1) - 1, true, testing.allocator);
        try testing.expect(mem.eql(u8, &arr, &expectedDESC));
    }
}

test "radix" {
    {
        var arr = items;
        try radixSort(u8, &arr, false, testing.allocator);
        try testing.expect(mem.eql(u8, &arr, &expectedASC));
    }
    {
        var arr = items;
        try radixSort(u8, &arr, false, testing.allocator);
        try testing.expect(mem.eql(u8, &arr, &expectedDESC));
    }
}

test "sort" {
    {
        var arr = items;
        try sort(u8, &arr, false, .Quick, null);
        try testing.expect(mem.eql(u8, &arr, &expectedASC));
    }
    {
        sort(u8, &[_]u8{}, false, .Merge, null) catch |err| {
            try testing.expect(err == Error.AllocatorRequired);
        };
    }
    {
        var arr = items;
        const res = try sortR(u8, &arr, false, null, null);
        try testing.expect(mem.eql(u8, res, &expectedASC));
    }
    {
        var arr = items;
        const res = try sortC(u8, &arr, false, null, testing.allocator);
        defer testing.allocator.free(res);
        try testing.expect(mem.eql(u8, res, &expectedASC));
        try testing.expect(mem.eql(u8, &arr, &items));
    }
}
