const std = @import("std");
const mem = std.mem;
const math = std.math;
const testing = std.testing;
const Allocator = mem.Allocator;

pub fn CompareFn(comptime T: type) type {
    return fn (a: T, b: T) bool;
}

pub fn bubbleSort(comptime T: anytype, arr: []T, cmp: CompareFn(T)) void {
    for (arr) |_, i| {
        var j: usize = 0;
        while (j < arr.len - i - 1) : (j += 1) {
            if (cmp(arr[j + 1], arr[j])) {
                mem.swap(T, &arr[j], &arr[j + 1]);
            }
        }
    }
}

pub fn quickSort(comptime T: anytype, arr: []T, cmp: CompareFn(T)) void {
    return quickSortAdvanced(T, arr, 0, math.max(items.len, 1) - 1, cmp);
}

pub fn quickSortAdvanced(comptime T: anytype, arr: []T, left: usize, right: usize, cmp: CompareFn(T)) void {
    if (left >= right) return;
    const pivot = arr[right];
    var i = left;
    var j = left;
    while (j < right) : (j += 1) {
        if (cmp(arr[j], pivot)) {
            mem.swap(T, &arr[i], &arr[j]);
            i += 1;
        }
    }
    mem.swap(T, &arr[i], &arr[right]);
    quickSortAdvanced(T, arr, left, math.max(i, 1) - 1, cmp);
    quickSortAdvanced(T, arr, i + 1, right, cmp);
}

pub fn insertionSort(comptime T: anytype, arr: []T, cmp: CompareFn(T)) void {
    var i: usize = 1;
    while (i < arr.len) : (i += 1) {
        const x = arr[i];
        var j = i;
        while (j > 0 and cmp(x, arr[j - 1])) : (j -= 1) {
            arr[j] = arr[j - 1];
        }
        arr[j] = x;
    }
}

pub fn selectionSort(comptime T: anytype, arr: []T, cmp: CompareFn(T)) void {
    for (arr) |*item, i| {
        var pos = i;
        var j = i + 1;
        while (j < arr.len) : (j += 1) {
            if (cmp(arr[j], arr[pos])) {
                pos = j;
            }
        }
        mem.swap(T, &arr[pos], item);
    }
}

pub fn combSort(comptime T: anytype, arr: []T, cmp: CompareFn(T)) void {
    if (arr.len == 0) return;
    var gap = arr.len;
    var swapped = true;
    while (gap != 1 or swapped) {
        gap = (gap * 10 / 13) ^ 1;
        swapped = false;
        var i: usize = 0;
        while (i < arr.len - gap) : (i += 1) {
            if (cmp(arr[i + gap], arr[i])) {
                mem.swap(T, &arr[i], &arr[i + gap]);
                swapped = true;
            }
        }
    }
}

pub fn shellSort(comptime T: anytype, arr: []T, cmp: CompareFn(T)) void {
    var gap = arr.len / 2;
    while (gap > 0) : (gap /= 2) {
        var i = gap;
        while (i < arr.len) : (i += 1) {
            const x = arr[i];
            var j = i;
            while (j >= gap and cmp(x, arr[j - gap])) : (j -= gap) {
                arr[j] = arr[j - gap];
            }
            arr[j] = x;
        }
    }
}

fn heapify(comptime T: anytype, arr: []T, n: usize, i: usize, cmp: CompareFn(T)) void {
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

pub fn heapSort(comptime T: anytype, arr: []T, cmp: CompareFn(T)) void {
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

pub fn mergeSort(comptime T: anytype, arr: []T, cmp: CompareFn(T), allocator: Allocator) Allocator.Error!void {
    return mergeSortAdvanced(T, arr, 0, math.max(items.len, 1) - 1, cmp, allocator);
}

pub fn mergeSortAdvanced(comptime T: anytype, arr: []T, left: usize, right: usize, cmp: CompareFn(T), allocator: Allocator) Allocator.Error!void {
    if (left >= right) return;
    const mid = left + (right - left) / 2;
    try mergeSortAdvanced(T, arr, left, mid, cmp, allocator);
    try mergeSortAdvanced(T, arr, mid + 1, right, cmp, allocator);
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

pub fn radixSort(comptime T: anytype, arr: []T, allocator: mem.Allocator) Allocator.Error!void {
    if (arr.len == 0) return;
    var x: T = 1;
    const base: u4 = 10;

    // TODO: fix integer overflow for big inputs
    while (@divFloor(mem.max(T, arr), x) > 0) : (x *= base) {
        var res = try allocator.alloc(T, arr.len);
        defer allocator.free(res);

        var count = [_]usize{0} ** base;
        for (arr) |item| {
            count[@intCast(usize, @mod(@divFloor(item, x), base))] += 1;
        }

        {
            var i: u4 = 1;
            while (i < base) : (i += 1)
                count[i] += count[i - 1];
        }

        for (arr) |_, i| {
            const item = arr[arr.len - i - 1];
            res[count[@intCast(usize, @mod(@divFloor(item, x), base))] - 1] = item;
            count[@intCast(usize, @mod(@divFloor(item, x), base))] -= 1;
        }

        for (arr) |*item, i|
            item.* = res[i];
    }
}

//
// Tests
//

fn asc(a: i32, b: i32) bool {
    return a < b;
}

fn desc(a: i32, b: i32) bool {
    return a > b;
}

const items = [_]i32{ 9, 1, 4, 12, 3, 4 };
const expectedASC = [_]i32{ 1, 3, 4, 4, 9, 12 };
const expectedDESC = [_]i32{ 12, 9, 4, 4, 3, 1 };

const items_neg = [_]i32{ -9, 1, -4, 12, 3, 4 };
const expectedNegASC = [_]i32{ -9, -4, 1, 3, 4, 12 };
const expectedNegDESC = [_]i32{ 12, 4, 3, 1, -4, -9 };

const ItemsT = @TypeOf(items[0]);

test "bubble" {
    {
        {
            var arr = items;
            bubbleSort(ItemsT, &arr, asc);
            try testing.expectEqualSlices(ItemsT, &arr, &expectedASC);
        }
        {
            var arr = items;
            bubbleSort(ItemsT, &arr, desc);
            try testing.expectEqualSlices(ItemsT, &arr, &expectedDESC);
        }
    }
    {
        {
            var arr = items_neg;
            bubbleSort(ItemsT, &arr, asc);
            try testing.expectEqualSlices(ItemsT, &arr, &expectedNegASC);
        }
        {
            var arr = items_neg;
            bubbleSort(ItemsT, &arr, desc);
            try testing.expectEqualSlices(ItemsT, &arr, &expectedNegDESC);
        }
    }
}

test "quick" {
    {
        var arr = items;
        quickSort(ItemsT, &arr, asc);
        try testing.expectEqualSlices(ItemsT, &arr, &expectedASC);
    }
    {
        var arr = items;
        quickSort(ItemsT, &arr, desc);
        try testing.expectEqualSlices(ItemsT, &arr, &expectedDESC);
    }
    {
        {
            var arr = items_neg;
            quickSort(ItemsT, &arr, asc);
            try testing.expectEqualSlices(ItemsT, &arr, &expectedNegASC);
        }
        {
            var arr = items_neg;
            quickSort(ItemsT, &arr, desc);
            try testing.expectEqualSlices(ItemsT, &arr, &expectedNegDESC);
        }
    }
}

test "insertion" {
    {
        var arr = items;
        insertionSort(ItemsT, &arr, asc);
        try testing.expectEqualSlices(ItemsT, &arr, &expectedASC);
    }
    {
        var arr = items;
        insertionSort(ItemsT, &arr, desc);
        try testing.expectEqualSlices(ItemsT, &arr, &expectedDESC);
    }
    {
        {
            var arr = items_neg;
            insertionSort(ItemsT, &arr, asc);
            try testing.expectEqualSlices(ItemsT, &arr, &expectedNegASC);
        }
        {
            var arr = items_neg;
            insertionSort(ItemsT, &arr, desc);
            try testing.expectEqualSlices(ItemsT, &arr, &expectedNegDESC);
        }
    }
}

test "selection" {
    {
        var arr = items;
        selectionSort(ItemsT, &arr, asc);
        try testing.expectEqualSlices(ItemsT, &arr, &expectedASC);
    }
    {
        var arr = items;
        selectionSort(ItemsT, &arr, desc);
        try testing.expectEqualSlices(ItemsT, &arr, &expectedDESC);
    }
    {
        {
            var arr = items_neg;
            selectionSort(ItemsT, &arr, asc);
            try testing.expectEqualSlices(ItemsT, &arr, &expectedNegASC);
        }
        {
            var arr = items_neg;
            selectionSort(ItemsT, &arr, desc);
            try testing.expectEqualSlices(ItemsT, &arr, &expectedNegDESC);
        }
    }
}

test "comb" {
    {
        var arr = items;
        combSort(ItemsT, &arr, asc);
        try testing.expectEqualSlices(ItemsT, &arr, &expectedASC);
    }
    {
        var arr = items;
        combSort(ItemsT, &arr, desc);
        try testing.expectEqualSlices(ItemsT, &arr, &expectedDESC);
    }
    {
        {
            var arr = items_neg;
            combSort(ItemsT, &arr, asc);
            try testing.expectEqualSlices(ItemsT, &arr, &expectedNegASC);
        }
        {
            var arr = items_neg;
            combSort(ItemsT, &arr, desc);
            try testing.expectEqualSlices(ItemsT, &arr, &expectedNegDESC);
        }
    }
}

test "shell" {
    {
        var arr = items;
        shellSort(ItemsT, &arr, asc);
        try testing.expectEqualSlices(ItemsT, &arr, &expectedASC);
    }
    {
        var arr = items;
        shellSort(ItemsT, &arr, desc);
        try testing.expectEqualSlices(ItemsT, &arr, &expectedDESC);
    }
    {
        {
            var arr = items_neg;
            shellSort(ItemsT, &arr, asc);
            try testing.expectEqualSlices(ItemsT, &arr, &expectedNegASC);
        }
        {
            var arr = items_neg;
            shellSort(ItemsT, &arr, desc);
            try testing.expectEqualSlices(ItemsT, &arr, &expectedNegDESC);
        }
    }
}

test "heap" {
    {
        var arr = items;
        heapSort(ItemsT, &arr, asc);
        try testing.expectEqualSlices(ItemsT, &arr, &expectedASC);
    }
    {
        var arr = items;
        heapSort(ItemsT, &arr, desc);
        try testing.expectEqualSlices(ItemsT, &arr, &expectedDESC);
    }
    {
        {
            var arr = items_neg;
            heapSort(ItemsT, &arr, asc);
            try testing.expectEqualSlices(ItemsT, &arr, &expectedNegASC);
        }
        {
            var arr = items_neg;
            heapSort(ItemsT, &arr, desc);
            try testing.expectEqualSlices(ItemsT, &arr, &expectedNegDESC);
        }
    }
}

test "merge" {
    {
        var arr = items;
        try mergeSort(ItemsT, &arr, asc, testing.allocator);
        try testing.expectEqualSlices(ItemsT, &arr, &expectedASC);
    }
    {
        var arr = items;
        try mergeSort(ItemsT, &arr, desc, testing.allocator);
        try testing.expectEqualSlices(ItemsT, &arr, &expectedDESC);
    }
    {
        {
            var arr = items_neg;
            try mergeSort(ItemsT, &arr, asc, testing.allocator);
            try testing.expectEqualSlices(ItemsT, &arr, &expectedNegASC);
        }
        {
            var arr = items_neg;
            try mergeSort(ItemsT, &arr, desc, testing.allocator);
            try testing.expectEqualSlices(ItemsT, &arr, &expectedNegDESC);
        }
    }
}

test "radix" {
    {
        var arr = items;
        try radixSort(ItemsT, &arr, testing.allocator);
        try testing.expectEqualSlices(ItemsT, &arr, &expectedASC);
    }
    // {
    //     {
    //         var arr = items_neg;
    //         try radixSort(ItemsT, &arr, asc, testing.allocator);
    //         try testing.expectEqualSlices(ItemsT, &arr, &expectedNegASC);
    //     }
    //     {
    //         var arr = items_neg;
    //         try radixSort(ItemsT, &arr, desc, testing.allocator);
    //         try testing.expectEqualSlices(ItemsT, &arr, &expectedNegDESC);
    //     }
    // }
}
