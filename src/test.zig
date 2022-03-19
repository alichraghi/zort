const std = @import("std");
const zort = @import("main.zig");
const testing = std.testing;

pub const items_t = i32;
pub const items = [_]i32{ -9, 1, -4, 12, 3, 4 };
pub const expectedASC = [_]i32{ -9, -4, 1, 3, 4, 12 };
pub const expectedDESC = [_]i32{ 12, 4, 3, 1, -4, -9 };

fn asc(a: i32, b: i32) bool {
    return a < b;
}

fn desc(a: i32, b: i32) bool {
    return a > b;
}

test "bubble" {
    {
        var arr = items;
        zort.bubbleSort(items_t, &arr, asc);
        try testing.expectEqualSlices(items_t, &arr, &expectedASC);
    }
    {
        var arr = items;
        zort.bubbleSort(items_t, &arr, desc);
        try testing.expectEqualSlices(items_t, &arr, &expectedDESC);
    }
}

test "comb" {
    {
        var arr = items;
        zort.combSort(items_t, &arr, asc);
        try testing.expectEqualSlices(items_t, &arr, &expectedASC);
    }
    {
        var arr = items;
        zort.combSort(items_t, &arr, desc);
        try testing.expectEqualSlices(items_t, &arr, &expectedDESC);
    }
}

test "heap" {
    {
        var arr = items;
        zort.heapSort(items_t, &arr, asc);
        try testing.expectEqualSlices(items_t, &arr, &expectedASC);
    }
    {
        var arr = items;
        zort.heapSort(items_t, &arr, desc);
        try testing.expectEqualSlices(items_t, &arr, &expectedDESC);
    }
}

test "insertion" {
    {
        var arr = items;
        zort.insertionSort(items_t, &arr, asc);
        try testing.expectEqualSlices(items_t, &arr, &expectedASC);
    }
    {
        var arr = items;
        zort.insertionSort(items_t, &arr, desc);
        try testing.expectEqualSlices(items_t, &arr, &expectedDESC);
    }
}

test "merge" {
    {
        var arr = items;
        try zort.mergeSort(items_t, &arr, asc, testing.allocator);
        try testing.expectEqualSlices(items_t, &arr, &expectedASC);
    }
    {
        var arr = items;
        try zort.mergeSort(items_t, &arr, desc, testing.allocator);
        try testing.expectEqualSlices(items_t, &arr, &expectedDESC);
    }
}

test "quick" {
    {
        var arr = items;
        zort.quickSort(items_t, &arr, asc);
        try testing.expectEqualSlices(items_t, &arr, &expectedASC);
    }
    {
        var arr = items;
        zort.quickSort(items_t, &arr, desc);
        try testing.expectEqualSlices(items_t, &arr, &expectedDESC);
    }
}

test "radix" {
    return error.SkipZigTest;
    // {
    //     var arr = items;
    //     try zort.radixSort(items_t, &arr, testing.allocator);
    //     try testing.expectEqualSlices(items_t, &arr, &expectedASC);
    // }
}

test "selection" {
    {
        var arr = items;
        zort.selectionSort(items_t, &arr, asc);
        try testing.expectEqualSlices(items_t, &arr, &expectedASC);
    }
    {
        var arr = items;
        zort.selectionSort(items_t, &arr, desc);
        try testing.expectEqualSlices(items_t, &arr, &expectedDESC);
    }
}

test "shell" {
    {
        var arr = items;
        zort.shellSort(items_t, &arr, asc);
        try testing.expectEqualSlices(items_t, &arr, &expectedASC);
    }
    {
        var arr = items;
        zort.shellSort(items_t, &arr, desc);
        try testing.expectEqualSlices(items_t, &arr, &expectedDESC);
    }
}
