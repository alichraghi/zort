const std = @import("std");
const zort = @import("main.zig");
const testing = std.testing;

pub const ItemsType = i32;
pub const items = [_]i32{ -9, 1, -4, 12, 3, 4 };
pub const expectedASC = [_]i32{ -9, -4, 1, 3, 4, 12 };
pub const expectedDESC = [_]i32{ 12, 4, 3, 1, -4, -9 };

test "temp" {
    return error.SkipZigTest;
}

test "bubble" {
    {
        var arr = items;
        zort.bubbleSort(ItemsType, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedASC, &arr);
    }
    {
        var arr = items;
        zort.bubbleSort(ItemsType, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedDESC, &arr);
    }
}

test "comb" {
    {
        var arr = items;
        zort.combSort(ItemsType, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedASC, &arr);
    }
    {
        var arr = items;
        zort.combSort(ItemsType, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedDESC, &arr);
    }
}

test "heap" {
    {
        var arr = items;
        zort.heapSort(ItemsType, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedASC, &arr);
    }
    {
        var arr = items;
        zort.heapSort(ItemsType, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedDESC, &arr);
    }
}

test "insertion" {
    {
        var arr = items;
        zort.insertionSort(ItemsType, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedASC, &arr);
    }
    {
        var arr = items;
        zort.insertionSort(ItemsType, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedDESC, &arr);
    }
}

test "merge" {
    {
        var arr = items;
        try zort.mergeSort(ItemsType, testing.allocator, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedASC, &arr);
    }
    {
        var arr = items;
        try zort.mergeSort(ItemsType, testing.allocator, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedDESC, &arr);
    }
}

test "quick" {
    {
        var arr = items;
        zort.quickSort(ItemsType, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedASC, &arr);
    }
    {
        var arr = items;
        zort.quickSort(ItemsType, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedDESC, &arr);
    }
}

test "radix" {
    {
        var arr = items;
        try zort.radixSort(ItemsType, .{}, testing.allocator, &arr);
        try testing.expectEqualSlices(ItemsType, &expectedASC, &arr);
    }
}

test "selection" {
    {
        var arr = items;
        zort.selectionSort(ItemsType, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedASC, &arr);
    }
    {
        var arr = items;
        zort.selectionSort(ItemsType, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedDESC, &arr);
    }
}

test "shell" {
    {
        var arr = items;
        zort.shellSort(ItemsType, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedASC, &arr);
    }
    {
        var arr = items;
        zort.shellSort(ItemsType, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedDESC, &arr);
    }
}

test "tim" {
    {
        var arr = items;
        try zort.timSort(ItemsType, testing.allocator, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedASC, &arr);
    }
    {
        var arr = items;
        try zort.timSort(ItemsType, testing.allocator, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedDESC, &arr);
    }
}

test "tail" {
    {
        var arr = items;
        try zort.tailSort(ItemsType, testing.allocator, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedASC, &arr);
    }
    {
        var arr = items;
        try zort.tailSort(ItemsType, testing.allocator, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedDESC, &arr);
    }
}

test "twin" {
    {
        var arr = items;
        try zort.twinSort(ItemsType, testing.allocator, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedASC, &arr);
    }
    {
        var arr = items;
        try zort.twinSort(ItemsType, testing.allocator, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedDESC, &arr);
    }
}

test "pdq" {
    {
        var arr = items;
        zort.pdqSort(ItemsType, &arr, {}, comptime std.sort.asc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedASC, &arr);
    }
    {
        var arr = items;
        zort.pdqSort(ItemsType, &arr, {}, comptime std.sort.desc(i32));
        try testing.expectEqualSlices(ItemsType, &expectedDESC, &arr);
    }
}
