const std = @import("std");
const mem = std.mem;
const math = std.math;
const testing = std.testing;

pub const Error = error{ OutOfMemory, AllocatorRequired };

pub const Algorithm = enum { Bubble, Quick, Insertion, Selection, Comb, Shell, Heap, Merge, Radix };

/// sort and return the result
pub fn sortR(comptime T: anytype, arr: []T, desc: bool, algorithm: ?Algorithm, allocator: ?*mem.Allocator) Error![]T {
    try sort(T, arr, desc, algorithm, allocator);
    return arr;
}

/// sort to an owned slice. don't forgot to free
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
                if (allocator_opt) |allocator|
                    switch (algorithm) {
                        .Merge => try mergeSort(T, arr, 0, math.max(arr.len, 1) - 1, desc, allocator),
                        .Radix => try radixSort(T, arr, desc, allocator),
                        else => {},
                    }
                else {
                    return error.AllocatorRequired;
                }
            },
        }
    } else {
        quickSort(T, arr, 0, math.max(arr.len, 1) - 1, desc);
    }
}

pub fn bubbleSort(comptime T: anytype, arr: []T, desc: bool) void {
    for (arr) |_, i| {
        var j: usize = 0;
        while (j < arr.len - i - 1) : (j += 1) {
            if (flow(arr[j + 1], arr[j], desc)) {
                mem.swap(T, &arr[j], &arr[j + 1]);
            }
        }
    }
}

pub fn quickSort(comptime T: anytype, arr: []T, left: usize, right: usize, desc: bool) void {
    if (left >= right) return;
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
    for (arr) |*item, i| {
        var pos = i;
        var j = i + 1;
        while (j < arr.len) : (j += 1) {
            if (flow(arr[j], arr[pos], desc)) {
                pos = j;
            }
        }
        mem.swap(T, &arr[pos], item);
    }
}

pub fn combSort(comptime T: anytype, arr: []T, desc: bool) void {
    if (arr.len == 0) return;
    var gap = arr.len;
    var swapped = true;
    while (gap != 1 or swapped) {
        gap = (gap * 10 / 13) ^ 1;
        swapped = false;
        var i: usize = 0;
        while (i < arr.len - gap) : (i += 1) {
            if (flow(arr[i + gap], arr[i], desc)) {
                mem.swap(T, &arr[i], &arr[i + gap]);
                swapped = true;
            }
        }
    }
}

pub fn shellSort(comptime T: anytype, arr: []T, desc: bool) void {
    var gap = arr.len / 2;
    while (gap > 0) : (gap /= 2) {
        var i = gap;
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
    if (arr.len == 0) return;
    {
        var i = arr.len / 2 - 1;
        while (i > 0) : (i -= 1) {
            heapify(T, arr, arr.len, i - 1, desc);
        }
    }
    var i: usize = arr.len - 1;
    while (i > 0) : (i -= 1) {
        mem.swap(T, &arr[0], &arr[i]);
        heapify(T, arr, i, 0, desc);
    }
}

pub fn mergeSort(comptime T: anytype, arr: []T, left: usize, right: usize, desc: bool, allocator: *mem.Allocator) Error!void {
    if (left >= right) return;
    const mid = left + (right - left) / 2;
    try mergeSort(T, arr, left, mid, desc, allocator);
    try mergeSort(T, arr, mid + 1, right, desc, allocator);
    const n1 = mid - left + 1;
    const n2 = right - mid;
    var L = allocator.alloc(T, n1) catch return Error.OutOfMemory;
    var R = allocator.alloc(T, n1) catch return Error.OutOfMemory;
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
        var i: usize = 0;
        while (i < n2) : (i += 1) {
            R[i] = arr[mid + 1 + i];
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

pub fn radixSort(comptime T: anytype, arr: []T, desc: bool, allocator: *mem.Allocator) Error!void {
    if (arr.len == 0) return;
    var x: T = 1;
    while (@divFloor(mem.max(T, arr), x )> 0) : (x *= 10) {
        var res = allocator.alloc(T, arr.len) catch return Error.OutOfMemory;
        defer allocator.free(res);

        var count = [_]usize{0} ** 10;
        for (arr) |item|
            count[@intCast(usize, @mod(@divFloor(item, x), 10))] += 1;

        var j: usize = 1;
        while (j < 10) : (j += 1) {
            count[j] += count[j - 1];
        }

        for (arr) |_, i| {
            const item = arr[arr.len - i - 1];
            res[count[@intCast(usize, @mod(@divFloor(item, x), 10))] - 1] = item;
            count[@intCast(usize, @mod(@divFloor(item, x), 10))] -= 1;
        }

        for (arr) |*item, i|
            item.* = res[i];
    }
    if (desc)
        mem.reverse(T, arr);
}

fn flow(a: anytype, b: @TypeOf(a), desc: bool) bool {
    if (desc)
        return a > b
    else
        return a < b;
}

// const items = [_]i32{ 9, 1, 4, 12, 3, 4 };
// const expectedASC = [_]i32{ 1, 3, 4, 4, 9, 12 };
// const expectedDESC = [_]i32{ 12, 9, 4, 4, 3, 1 };
const items = [_]i32{ -1, -2 };
const expectedASC = [_]i32{ -2, -1 };
const expectedDESC = [_]i32{ -1, -2 };

test "bubble" {
    {
        var arr = items;
        bubbleSort(@TypeOf(items[0]), &arr, false);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedASC));
    }
    {
        var arr = items;
        bubbleSort(@TypeOf(items[0]), &arr, true);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedDESC));
    }
}

test "quick" {
    {
        var arr = items;
        quickSort(@TypeOf(items[0]), &arr, 0, math.max(arr.len, 1) - 1, false);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedASC));
    }
    {
        var arr = items;
        quickSort(@TypeOf(items[0]), &arr, 0, math.max(arr.len, 1) - 1, true);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedDESC));
    }
}

test "insertion" {
    {
        var arr = items;
        insertionSort(@TypeOf(items[0]), &arr, false);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedASC));
    }
    {
        var arr = items;
        insertionSort(@TypeOf(items[0]), &arr, true);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedDESC));
    }
}

test "selection" {
    {
        var arr = items;
        selectionSort(@TypeOf(items[0]), &arr, false);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedASC));
    }
    {
        var arr = items;
        selectionSort(@TypeOf(items[0]), &arr, true);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedDESC));
    }
}

test "comb" {
    {
        var arr = items;
        combSort(@TypeOf(items[0]), &arr, false);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedASC));
    }
    {
        var arr = items;
        combSort(@TypeOf(items[0]), &arr, true);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedDESC));
    }
}

test "shell" {
    {
        var arr = items;
        shellSort(@TypeOf(items[0]), &arr, false);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedASC));
    }
    {
        var arr = items;
        shellSort(@TypeOf(items[0]), &arr, true);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedDESC));
    }
}

test "heap" {
    {
        var arr = items;
        try heapSort(@TypeOf(items[0]), &arr, false);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedASC));
    }
    {
        var arr = items;
        try heapSort(@TypeOf(items[0]), &arr, true);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedDESC));
    }
}

test "merge" {
    {
        var arr = items;
        try mergeSort(@TypeOf(items[0]), &arr, 0, comptime math.max(arr.len, 1) - 1, false, testing.allocator);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedASC));
    }
    {
        var arr = items;
        try mergeSort(@TypeOf(items[0]), &arr, 0, comptime math.max(arr.len, 1) - 1, true, testing.allocator);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedDESC));
    }
}

test "radix" {
    {
        var arr = items;
        try radixSort(@TypeOf(items[0]), &arr, false, testing.allocator);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedASC));
    }
    {
        var arr = items;
        try radixSort(@TypeOf(items[0]), &arr, true, testing.allocator);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedDESC));
    }
}

test "sort" {
    {
        var arr = items;
        try sort(@TypeOf(items[0]), &arr, false, .Quick, null);
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &expectedASC));
    }
    {
        sort(@TypeOf(items[0]), &[_]@TypeOf(items[0]){}, false, .Merge, null) catch |err| {
            try testing.expect(err == Error.AllocatorRequired);
        };
    }
    {
        var arr = items;
        const res = try sortR(@TypeOf(items[0]), &arr, false, null, null);
        try testing.expect(mem.eql(@TypeOf(items[0]), res, &expectedASC));
    }
    {
        var arr = items;
        const res = try sortC(@TypeOf(items[0]), &arr, false, null, testing.allocator);
        defer testing.allocator.free(res);
        try testing.expect(mem.eql(@TypeOf(items[0]), res, &expectedASC));
        try testing.expect(mem.eql(@TypeOf(items[0]), &arr, &items));
    }
}
