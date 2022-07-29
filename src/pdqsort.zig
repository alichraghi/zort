//! Pattern Defeating QuickSort
//! This code is based on https://github.com/zhangyunhao116/pdqsort

const std = @import("std");
const zort = @import("main.zig");

/// pdqSort is `Pattern Defeating Quicksort`.
pub fn pdqSort(
    comptime T: anytype,
    items: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) void {
    var tmp: T = undefined;

    const limit: usize = @bitSizeOf(usize) - @clz(usize, items.len);

    recurse(T, items, tmp, false, limit, context, cmp);
}

/// recurse sorts `items` recursively.
///
/// If the slice had a predecessor in the original array, it is specified as
/// `orig_pred` (must be the minimum value if exist).
///
/// `orig_limit` is the number of allowed imbalanced partitions before switching to `heapsort`.
/// If zero, this function will immediately switch to heapsort.
fn recurse(
    comptime T: anytype,
    orig_items: []T,
    orig_pred: T,
    orig_pred_exist: bool,
    orig_limit: usize,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) void {
    var limit = orig_limit;
    var items: []T = orig_items;
    var pred = orig_pred;
    var pred_exist = orig_pred_exist;

    // slices of up to this length get sorted using insertion sort.
    const max_insertion = 24;

    // True if the last partitioning was reasonably balanced.
    var was_balanced: bool = true;

    // True if the last partitioning didn't shuffle elements (the slice was already partitioned).
    var was_partitioned: bool = true;

    while (true) {
        // Very short slices get sorted using insertion sort.
        if (items.len <= max_insertion) {
            std.sort.insertionSort(T, items, context, cmp);
            return;
        }

        // If too many bad pivot choices were made, simply fall back to heapsort in order to
        // guarantee `O(n log n)` worst-case.
        if (limit == 0) {
            heapify(T, items, context, cmp);
            return;
        }

        // If the last partitioning was imbalanced, try breaking patterns in the slice by shuffling
        // some elements around. Hopefully we'll choose a better pivot this time.
        if (!was_balanced) {
            breakPatterns(T, items);
            limit -= 1;
        }

        // Choose a pivot and try guessing whether the slice is already sorted.
        var likely_sorted: bool = false;
        const pivot_idx = chosePivot(T, items, &likely_sorted, context, cmp);

        // If the last partitioning was decently balanced and didn't shuffle elements, and if pivot
        // selection predicts the slice is likely already sorted...
        if (was_balanced and was_partitioned and likely_sorted) {
            // Try identifying several out-of-order elements and shifting them to correct
            // positions. If the slice ends up being completely sorted, we're done.
            if (partialInsertionSort(T, items)) return;
        }

        // If the chosen pivot is equal to the predecessor, then it's the smallest element in the
        // slice. Partition the slice into elements equal to and elements greater than the pivot.
        // This case is usually hit when the slice contains many duplicate elements.
        if (pred_exist and pred == items[pivot_idx]) {
            const mid = partitionEqual(T, items, pivot_idx, context, cmp);
            items = items[mid..];
            continue;
        }

        // Partition the slice.
        const mid = partition(T, items, pivot_idx, &was_partitioned, context, cmp);

        const left = items[0..mid];
        const right = items[mid + 1 ..];

        const pivot = items[mid];
        const pivot_exists = true;

        if (left.len < right.len) {
            was_balanced = left.len >= items.len / 8;
            recurse(T, left, pred, pred_exist, limit, context, cmp);
            items = right;
            pred = pivot;
            pred_exist = pivot_exists;
        } else {
            was_balanced = right.len >= items.len / 8;
            recurse(T, right, pivot, pivot_exists, limit, context, cmp);
            items = left;
        }
    }
}

fn heapify(
    comptime T: anytype,
    items: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) void {
    @setCold(true);
    zort.heapSort(T, items, context, cmp);
}

/// partition partitions `items` into elements smaller than `items[pivot_idx]`,
/// followed by elements greater than or equal to `items[pivot_idx]`.
///
/// Returns the new pivot index.
/// Sets was_partitioned to `true` if necessary.
fn partition(
    comptime T: anytype,
    items: []T,
    pivot_idx: usize,
    was_partitioned: *bool,
    context: anytype,
    cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) usize {
    const pivot = items[pivot_idx];

    // move pivot to the first place
    std.mem.swap(T, &items[0], &items[pivot_idx]);

    var i: usize = 1;
    var j: usize = items.len - 1;

    while (i <= j and cmp(context, items[i], pivot)) i += 1;
    while (i <= j and !cmp(context, items[j], pivot)) j -= 1;

    // Check if items are already partitioned (no item to swap)
    if (i > j) {
        // put pivot back to the middle
        std.mem.swap(T, &items[j], &items[0]);
        was_partitioned.* = true;
        return j;
    }

    while (true) : ({
        i += 1;
        j -= 1;
    }) {
        while (i <= j and cmp(context, items[i], pivot)) i += 1;
        while (i <= j and !cmp(context, items[j], pivot)) j -= 1;

        if (i > j) break;

        std.mem.swap(T, &items[i], &items[j]);
    }

    // put pivot back to the middle
    std.mem.swap(T, &items[j], &items[0]);
    was_partitioned.* = false;
    return j;
}

const XorShift = u64;
fn next(r: *XorShift) usize {
    r.* ^= r.* << 13;
    r.* ^= r.* << 17;
    r.* ^= r.* << 5;
    return r.*;
}

fn breakPatterns(comptime T: anytype, items: []T) void {
    @setCold(true);
    if (items.len < 8) return;

    var r: XorShift = @intCast(XorShift, items.len);

    const modulus = std.math.ceilPowerOfTwoAssert(usize, items.len);

    var idxs: [3]usize = undefined;
    idxs[0] = items.len / 4 * 2 - 1;
    idxs[1] = items.len / 4 * 2;
    idxs[2] = items.len / 4 * 2 + 1;

    for (idxs) |idx| {
        var other = next(&r) & (modulus - 1);
        if (other >= items.len) {
            other -= items.len;
        }
        std.mem.swap(T, &items[idx], &items[other]);
    }
}

fn partitionEqual(
    comptime T: anytype,
    items: []T,
    pivot_idx: usize,
    context: anytype,
    cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) usize {
    std.mem.swap(T, &items[0], &items[pivot_idx]);

    const pivot = items[0];

    var i: usize = 1;
    var j: usize = items.len - 1;

    while (true) : ({
        i += 1;
        j -= 1;
    }) {
        while (i <= j and !cmp(context, pivot, items[i])) i += 1;
        while (i <= j and cmp(context, pivot, items[j])) j -= 1;

        if (i > j) break;

        std.mem.swap(T, &items[i], &items[j]);
    }

    return i;
}

// partialInsertionSort partially sorts a slice by shifting several out-of-order elements around.
// Returns `true` if the slice is sorted at the end. This function is `O(n)` worst-case.
fn partialInsertionSort(comptime T: anytype, items: []T) bool {
    @setCold(true);
    // maximum number of adjacent out-of-order pairs that will get shifted
    const max_steps = 5;

    // if the slice is shorter than this, don't shift any elements
    const shortest_shifting = 50;

    var i: usize = 1;
    var k: usize = 0;
    while (k < max_steps) : (k += 1) {
        // Find the next pair of adjacent out-of-order elements.
        while (i < items.len and items[i] >= items[i - 1]) i += 1;

        // Are we done?
        if (i == items.len) return true;

        // Don't shift elements on short arrays, that has a performance cost.
        if (items.len < shortest_shifting) return false;

        // Swap the found pair of elements. This puts them in correct order.
        std.mem.swap(T, &items[i], &items[i - 1]);

        // Shift the smaller element to the left.
        shiftTail(T, items, 0, i);
        // Shift the greater element to the right.
        shiftHead(T, items, i, items.len);
    }

    return false;
}

fn shiftTail(comptime T: anytype, items: []T, a: usize, b: usize) void {
    const l = b - a;
    if (l >= 2) {
        var i: usize = l - 1;
        while (i >= 1) : (i -= 1) {
            if (items[i] >= items[i - 1]) break;
            std.mem.swap(T, &items[i], &items[i - 1]);
        }
    }
}

fn shiftHead(comptime T: anytype, items: []T, a: usize, b: usize) void {
    const l = b - a;
    if (l >= 2) {
        var i: usize = a + 1;
        while (i < l) : (i += 1) {
            if (items[i] >= items[i - 1]) break;
            std.mem.swap(T, &items[i], &items[i - 1]);
        }
    }
}

/// chosePivot choses a pivot in `items`.
/// Swaps likely_sorted when `items` seems to be already sorted.
fn chosePivot(
    comptime T: anytype,
    items: []T,
    likely_sorted: *bool,
    context: anytype,
    cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) usize {
    // minimum length for using the Tukey's ninther method
    const shortest_ninther = 50;

    // max_swaps is the maximum number of swaps allowed in this function
    const max_swaps = 4 * 3;

    var swaps: usize = 0;

    var a = items.len / 4 * 1;
    var b = items.len / 4 * 2;
    var c = items.len / 4 * 3;

    if (items.len >= 8) {
        if (items.len >= shortest_ninther) {
            // Find medians in the neighborhoods of `a`, `b` and `c`
            a = sort3(T, items, a - 1, a, a + 1, &swaps, context, cmp);
            b = sort3(T, items, b - 1, b, b + 1, &swaps, context, cmp);
            c = sort3(T, items, c - 1, c, c + 1, &swaps, context, cmp);
        }

        // Find the median among `a`, `b` and `c`
        b = sort3(T, items, a, b, c, &swaps, context, cmp);
    }

    if (swaps < max_swaps) {
        likely_sorted.* = (swaps == 0);
        return b;
    } else {
        // The maximum number of swaps was performed, so items are likely
        // in reverse order. Reverse it to make sorting faster.
        std.mem.reverse(T, items);

        likely_sorted.* = true;
        return items.len - 1 - b;
    }
}

fn sort3(
    comptime T: anytype,
    items: []T,
    a: usize,
    b: usize,
    c: usize,
    swaps: *usize,
    context: anytype,
    cmp: fn (@TypeOf(context), lhs: T, rhs: T) bool,
) usize {
    if (cmp(context, items[b], items[a])) {
        swaps.* += 1;
        std.mem.swap(T, &items[b], &items[a]);
    }

    if (cmp(context, items[c], items[b])) {
        swaps.* += 1;
        std.mem.swap(T, &items[c], &items[b]);
    }

    if (cmp(context, items[b], items[a])) {
        swaps.* += 1;
        std.mem.swap(T, &items[b], &items[a]);
    }

    return b;
}

test "chosePivot" {
    {
        // less than 8 items...
        var array = [_]usize{ 1, 2, 3, 4, 5, 6, 7 };
        var likely_sorted = false;

        const got = chosePivot(usize, &array, &likely_sorted, {}, comptime std.sort.asc(usize));

        try std.testing.expectEqual(@as(usize, 2), got);
        try std.testing.expectEqual(true, likely_sorted);
    }

    {
        // more than 8 items...
        var array = [_]usize{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 };
        var likely_sorted = false;

        const got = chosePivot(usize, &array, &likely_sorted, {}, std.sort.asc(usize));

        try std.testing.expectEqual(@as(usize, 8), got);
        try std.testing.expectEqual(false, likely_sorted);
    }

    {
        // Tucay's method
        var array = [_]usize{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 100, 90, 80, 70, 60, 50, 40, 30, 20, 10, 11, 22, 33, 44, 55, 66, 77, 88, 99, 1000, 0 };
        var likely_sorted = false;

        const got = chosePivot(usize, &array, &likely_sorted, {}, std.sort.asc(usize));

        try std.testing.expectEqual(@as(usize, 24), got);
        try std.testing.expectEqual(false, likely_sorted);
    }
}

test "partitionEqual" {
    const MAX_TESTS = 1000;

    const rnd = std.rand.DefaultPrng.init(@intCast(u64, std.time.milliTimestamp())).random();

    var tc: usize = 0;
    while (tc < MAX_TESTS) : (tc += 1) {
        const random_length = rnd.uintLessThan(usize, 100);
        if (random_length == 0) return;

        var v1 = try std.ArrayList(usize).initCapacity(std.testing.allocator, random_length);
        defer v1.deinit();

        var j: usize = 0;
        while (j < random_length) : (j += 1) {
            const value = rnd.uintLessThan(usize, random_length / 2 + 1);
            v1.appendAssumeCapacity(value);
        }

        var min_value: usize = v1.items[0];
        var min_idx: usize = 0;
        var min_count: usize = 0;

        for (v1.items) |v, i| {
            if (v < min_value) {
                min_value = v;
                min_idx = i;
            }
        }

        for (v1.items) |v| {
            if (v == min_value) min_count += 1;
        }

        try std.testing.expectEqual(
            min_count,
            partitionEqual(usize, v1.items, min_idx, {}, std.sort.asc(usize)),
        );
    }
}

test "pdqSort" {
    {
        var array = [_]usize{ 1, 4, 6, 4, 3, 2, 6, 7, 8, 9 };
        const exp = [_]usize{ 1, 2, 3, 4, 4, 6, 6, 7, 8, 9 };

        pdqSort(usize, &array, {}, comptime std.sort.asc(usize));

        try std.testing.expectEqualSlices(usize, &exp, &array);
    }

    {
        var array = [_]usize{ 1, 4, 6, 4, 3, 2, 6, 7, 8, 9 };
        const exp = [_]usize{ 9, 8, 7, 6, 6, 4, 4, 3, 2, 1 };

        pdqSort(usize, &array, {}, comptime std.sort.desc(usize));

        try std.testing.expectEqualSlices(usize, &exp, &array);
    }

    {
        // ascending
        const TEST_TYPE = isize;
        const TESTS = 10;
        const ITEMS = 10_000;

        const rnd = std.rand.DefaultPrng.init(@intCast(u64, std.time.milliTimestamp())).random();

        var tc: usize = 0;
        while (tc < TESTS) : (tc += 1) {
            var array = try std.ArrayList(TEST_TYPE).initCapacity(std.testing.allocator, ITEMS);
            defer array.deinit();

            var item: usize = 0;
            while (item < ITEMS) : (item += 1) {
                const value = rnd.int(TEST_TYPE);
                array.appendAssumeCapacity(value);
            }
            var reference = try array.clone();
            defer reference.deinit();

            std.sort.sort(TEST_TYPE, reference.items, {}, comptime std.sort.asc(TEST_TYPE));

            pdqSort(TEST_TYPE, array.items, {}, comptime std.sort.asc(TEST_TYPE));

            try std.testing.expectEqualSlices(TEST_TYPE, reference.items, array.items);
        }
    }

    {
        // descending
        const TEST_TYPE = isize;
        const TESTS = 100;
        const ITEMS = 10_000;

        const rnd = std.rand.DefaultPrng.init(@intCast(u64, std.time.milliTimestamp())).random();

        var tc: usize = 0;
        while (tc < TESTS) : (tc += 1) {
            var array = try std.ArrayList(TEST_TYPE).initCapacity(std.testing.allocator, ITEMS);
            defer array.deinit();

            var item: usize = 0;
            while (item < ITEMS) : (item += 1) {
                const value = rnd.int(TEST_TYPE);
                array.appendAssumeCapacity(value);
            }
            var reference = try array.clone();
            defer reference.deinit();

            std.sort.sort(TEST_TYPE, reference.items, {}, comptime std.sort.desc(TEST_TYPE));

            pdqSort(TEST_TYPE, array.items, {}, comptime std.sort.desc(TEST_TYPE));

            try std.testing.expectEqualSlices(TEST_TYPE, reference.items, array.items);
        }
    }
}
