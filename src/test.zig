const std = @import("std");
const zort = @import("main.zig");
const testing = std.testing;

pub const ItemsType = i32;
pub const items = [_]i32{ -9, 1, -4, 12, 3, 4 };
pub const expectedASC = [_]i32{ -9, -4, 1, 3, 4, 12 };
pub const expectedDESC = [_]i32{ 12, 4, 3, 1, -4, -9 };

test "bubble" {
    {
        var arr = items;
        zort.bubbleSort(ItemsType, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedASC);
    }
    {
        var arr = items;
        zort.bubbleSort(ItemsType, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedDESC);
    }
}

test "comb" {
    {
        var arr = items;
        zort.combSort(ItemsType, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedASC);
    }
    {
        var arr = items;
        zort.combSort(ItemsType, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedDESC);
    }
}

test "heap" {
    {
        var arr = items;
        zort.heapSort(ItemsType, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedASC);
    }
    {
        var arr = items;
        zort.heapSort(ItemsType, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedDESC);
    }
}

test "insertion" {
    {
        var arr = items;
        zort.insertionSort(ItemsType, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedASC);
    }
    {
        var arr = items;
        zort.insertionSort(ItemsType, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedDESC);
    }
}

test "merge" {
    {
        var arr = items;
        try zort.mergeSort(ItemsType, testing.allocator, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedASC);
    }
    {
        var arr = items;
        try zort.mergeSort(ItemsType, testing.allocator, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedDESC);
    }
}

test "quick" {
    {
        var arr = items;
        zort.quickSort(ItemsType, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedASC);
    }
    {
        var arr = items;
        zort.quickSort(ItemsType, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedDESC);
    }
}

test "radix" {
    return error.SkipZigTest;
    // {
    //     var arr = items;
    //     try zort.radixSort(ItemsType, &arr, testing.allocator);
    //     try testing.expectEqualSlices(ItemsType, &arr, &expectedASC);
    // }
}

test "selection" {
    {
        var arr = items;
        zort.selectionSort(ItemsType, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedASC);
    }
    {
        var arr = items;
        zort.selectionSort(ItemsType, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedDESC);
    }
}

test "shell" {
    {
        var arr = items;
        zort.shellSort(ItemsType, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedASC);
    }
    {
        var arr = items;
        zort.shellSort(ItemsType, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedDESC);
    }
}

test "tim" {
    {
        var arr = items;
        try zort.timSort(ItemsType, testing.allocator, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedASC);
    }
    {
        var arr = items;
        try zort.timSort(ItemsType, testing.allocator, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedDESC);
    }
}

test "tail" {
    {
        var arr = items;
        try zort.tailSort(ItemsType, testing.allocator, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedASC);
    }
    {
        var arr = items;
        try zort.tailSort(ItemsType, testing.allocator, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedDESC);
    }
}

test "twin" {
    {
        var arr = items;
        try zort.twinSort(ItemsType, testing.allocator, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedASC);
    }
    {
        var arr = items;
        try zort.twinSort(ItemsType, testing.allocator, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &arr, &expectedDESC);
    }
}
