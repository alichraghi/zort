//! By VÖRÖSKŐI András <voroskoi@gmail.com>
//! This implementation is based on the go version found here:
//! https://github.com/psilva261/timsort
//! I have also read the java version found here:
//! https://github.com/openjdk/jdk/blob/master/src/java.base/share/classes/java/util/TimSort.java

const std = @import("std");

/// This is the minimum sized sequence that will be merged. Shorter
/// sequences will be lengthened by calling `binarySort()`.  If the entire
/// array is less than this length, no merges will be performed.
///
/// This variable is also used by `minRunLength()` function to determine
/// minimal run length used in `binarySort()`.
///
/// This constant should be a power of two!
const MIN_MERGE = 32;

/// Runs-to-be-merged stack size (which cannot be expanded).
const STACK_LENGTH = 85;

/// Maximum initial size of tmp array, which is used for merging.  The array
/// can grow to accommodate demand.

// Unlike Tim's original C version, we do not allocate this much storage
// when sorting smaller arrays.
const TMP_SIZE = 256;

/// When we get into galloping mode, we stay there until both runs win less
/// often than MIN_GALLOP consecutive times.
const MIN_GALLOP = 7;

pub fn timSort(
    comptime T: type,
    allocator: std.mem.Allocator,
    items: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) anyerror!void {
    // already sorted
    if (items.len < 2) return;

    // If the slice is small do a binarySort.
    if (items.len < MIN_MERGE) {
        const init_run_len = countRun(T, items, context, cmp);

        binarySort(T, items, init_run_len, context, cmp);
        return;
    }

    // Real TimSort starts here
    var ts = try TimSort(T, context, cmp).init(allocator, items);
    defer ts.deinit();

    const min_run = ts.minRunLength();
    var lo: usize = 0;
    var remain: usize = items.len;

    while (true) {
        var run_len: usize = countRun(T, items[lo..], context, cmp);

        // If run is short extend to min(min_run, remain).
        if (run_len < min_run) {
            const force = if (remain <= min_run) remain else min_run;

            binarySort(T, items[lo .. lo + force], run_len, context, cmp);
            run_len = force;
        }

        // Push run into pending-run stack, any maybe merge
        ts.pushRun(lo, run_len);
        try ts.mergeCollapse();

        // Advance to find next run
        lo += run_len;
        remain -= run_len;
        if (remain == 0) break;
    }

    try ts.mergeForceCollapse();
}

fn countRun(
    comptime T: type,
    items: []T,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) usize {
    var run_hi: usize = 1;

    if (run_hi == items.len) return 1;

    // Find end of run and reverse range if descending.
    if (cmp(context, items[run_hi], items[0])) {
        // descending
        run_hi += 1;

        while (run_hi < items.len and cmp(context, items[run_hi], items[run_hi - 1])) run_hi += 1;

        std.mem.reverse(T, items[0..run_hi]);
    } else {
        // ascending
        while (run_hi < items.len and !cmp(context, items[run_hi], items[run_hi - 1])) run_hi += 1;
    }

    return run_hi;
}

fn binarySort(
    comptime T: type,
    items: []T,
    orig_start: usize,
    context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) void {
    var start: usize = orig_start;
    if (start == 0) start += 1;

    while (start < items.len) : (start += 1) {
        const pivot = items[start];

        // Set left and right to the index where items[start] (pivot) belongs.
        var left: usize = 0;
        var right: usize = start;

        // Invariants:
        //   pivot >= all in [0, left)
        //   pivot < all in [right, start)
        while (left < right) {
            // https://ai.googleblog.com/2006/06/extra-extra-read-all-about-it-nearly.html
            const mid = (left +| right) >> 1;

            if (cmp(context, pivot, items[mid])) right = mid else left = mid + 1;
        }

        // The invariants still hold: pivot >= all in [lo, left) and
        // pivot < all in [left, start), so pivot belongs at left.  Note
        // that if there are elements equal to pivot, left points to the
        // first slot after them -- that's why this sort is stable.
        // Slide elements over to make room to make room for pivot.

        const n = start - left; // the number of elements to move

        std.debug.assert(left + 1 > left);
        std.mem.copyBackwards(T, items[left + 1 ..], items[left .. left + n]);

        items[left] = pivot;
    }
}

fn TimSort(
    comptime T: type,
    comptime context: anytype,
    comptime cmp: fn (context: @TypeOf(context), lhs: T, rhs: T) bool,
) type {
    return struct {
        allocator: std.mem.Allocator,
        items: []T,
        min_gallop: usize = MIN_GALLOP,

        // Timsort temporary stacks
        tmp: []T,
        run_base: []usize,
        run_len: []usize,
        pending: usize = 0,

        // Comparing information
        context: @TypeOf(context) = context,
        cmp: *const fn (@TypeOf(context), T, T) bool = cmp,

        fn init(allocator: std.mem.Allocator, items: []T) !@This() {
            // Adjust tmp_size
            var tmp_size: usize = TMP_SIZE;
            if (items.len < 2 * tmp_size) tmp_size = items.len / 2;
            return @This(){
                .tmp = try allocator.alloc(T, tmp_size),
                .run_base = try allocator.alloc(usize, STACK_LENGTH),
                .run_len = try allocator.alloc(usize, STACK_LENGTH),
                .allocator = allocator,
                .items = items,
            };
        }

        fn deinit(self: @This()) void {
            self.allocator.free(self.tmp);
            self.allocator.free(self.run_base);
            self.allocator.free(self.run_len);
        }

        /// Returns the minimum acceptable run length for an array of the specified
        /// length. Natural runs shorter than this will be extended with binarySort.
        ///
        /// Roughly speaking, the computation is:
        ///  If n < MIN_MERGE, return n (it's too small to bother with fancy stuff).
        ///  Else if n is an exact power of 2, return MIN_MERGE/2.
        ///  Else return an int k, MIN_MERGE/2 <= k <= MIN_MERGE, such that n/k
        ///  is close to, but strictly less than, an exact power of 2.
        fn minRunLength(self: @This()) usize {
            var n: usize = self.items.len;
            var r: usize = 0;
            while (n >= MIN_MERGE) {
                r |= (n & 1);
                n >>= 1;
            }

            return n + r;
        }

        /// Pushes the specified run onto the pending-run stack.
        fn pushRun(self: *@This(), run_base: usize, run_len: usize) void {
            self.run_base[self.pending] = run_base;
            self.run_len[self.pending] = run_len;
            self.pending += 1;
        }

        /// Examines the stack of runs waiting to be merged and merges adjacent runs
        /// until the stack invariants are reestablished:
        ///
        ///     1. runLen[i - 3] > runLen[i - 2] + runLen[i - 1]
        ///     2. runLen[i - 2] > runLen[i - 1]
        ///
        /// This method is called each time a new run is pushed onto the stack,
        /// so the invariants are guaranteed to hold for i < stackSize upon
        /// entry to the method.
        fn mergeCollapse(self: *@This()) !void {
            while (self.pending > 1) {
                var n: usize = self.pending - 2;
                if ((n > 0 and self.run_len[n - 1] <= self.run_len[n] + self.run_len[n + 1]) or
                    (n > 1 and self.run_len[n - 2] <= self.run_len[n - 1] + self.run_len[n]))
                {
                    if (self.run_len[n - 1] < self.run_len[n + 1]) n -= 1;
                    try self.mergeAt(n);
                } else if (self.run_len[n] <= self.run_len[n + 1]) {
                    try self.mergeAt(n);
                } else break; // invariant is established
            }
        }

        /// Merges all runs on the stack until only one remains.  This method is
        /// called once, to complete the sort.
        fn mergeForceCollapse(self: *@This()) !void {
            while (self.pending > 1) {
                var n: usize = self.pending - 2;
                if (n > 0 and self.run_len[n - 1] < self.run_len[n + 1]) n -= 1;
                try self.mergeAt(n);
            }
        }

        /// Merges the two runs at stack indices `i` and `i+1`.  Run i must be
        /// the penultimate or antepenultimate run on the pending stack.  In other words,
        /// `i` must be equal to self.pending-2 or self.pending-3.
        fn mergeAt(self: *@This(), i: usize) !void {
            var base1: usize = self.run_base[i];
            var len1: usize = self.run_len[i];
            var base2: usize = self.run_base[i + 1];
            var len2: usize = self.run_len[i + 1];

            // Record the length of the combined runs; if `i` is the 3rd-last
            // run now, also slide over the last run (which isn't involved
            // in this merge).  The current run (`i+1`) goes away in any case.
            self.run_len[i] = len1 + len2;
            if (i == @intCast(isize, self.pending) - 3) {
                self.run_base[i + 1] = self.run_base[i + 2];
                self.run_len[i + 1] = self.run_len[i + 2];
            }
            self.pending -= 1;

            // Find where the first element of run2 goes in run1. Prior elements
            // in run1 can be ignored (because they're already in place).
            const k = self.gallopRight(self.items[base2], self.items, base1, len1, 0);
            base1 += k;
            len1 -= k;
            if (len1 == 0) return;

            // Find where the last element of run1 goes in run2. Subsequent elements
            // in run2 can be ignored (because they're already in place).
            len2 = self.gallopLeft(self.items[base1 + len1 - 1], self.items, base2, len2, len2 - 1);
            if (len2 == 0) return;

            // Merge remaining runs, using tmp array with min(len1, len2) elements
            if (len1 <= len2)
                try self.mergeLo(base1, len1, base2, len2)
            else
                try self.mergeHi(base1, len1, base2, len2);
        }

        /// Merges two adjacent runs in place, in a stable fashion.  The first
        /// element of the first run must be greater than the first element of the
        /// second run (items[base1] > items[base2]), and the last element of the first run
        /// (items[base1 + len1-1]) must be greater than all elements of the second run.
        ///
        /// For performance, this method should be called only when len1 <= len2;
        /// its twin, mergeHi should be called if len1 >= len2.  (Either method
        /// may be called if len1 == len2.)
        fn mergeLo(
            self: *@This(),
            base1: usize,
            orig_len1: usize,
            base2: usize,
            orig_len2: usize,
        ) !void {
            var len1: usize = orig_len1;
            var len2: usize = orig_len2;

            const tmp = try self.ensureCapacity(len1);

            std.mem.copy(T, tmp, self.items[base1 .. base1 + len1]);

            var cursor1: usize = 0;
            var cursor2: usize = base2;
            var dest: usize = base1;

            // Move first element of second run and deal with degenerate cases.
            self.items[dest] = self.items[cursor2];
            dest += 1;
            cursor2 += 1;
            len2 -= 1;

            if (len2 == 0) {
                std.mem.copy(T, self.items[dest .. dest + len1], tmp[0..len1]);
                return;
            }

            if (len1 == 1) {
                std.debug.assert(dest <= cursor2);
                std.mem.copy(T, self.items[dest .. dest + len2], self.items[cursor2 .. cursor2 + len2]);
                self.items[dest + len2] = tmp[cursor1];
                return;
            }

            var min_gallop: usize = self.min_gallop;

            outer: while (true) {
                var count1: usize = 0;
                var count2: usize = 0;

                // Do the straightforward thing until (if ever) one run starts
                // winning consistently.
                while (true) {
                    if (self.cmp(self.context, self.items[cursor2], tmp[cursor1])) {
                        self.items[dest] = self.items[cursor2];
                        dest += 1;
                        cursor2 += 1;
                        count2 += 1;
                        count1 = 0;
                        len2 -= 1;
                        if (len2 == 0) break :outer;
                    } else {
                        self.items[dest] = tmp[cursor1];
                        dest += 1;
                        cursor1 += 1;
                        count1 += 1;
                        count2 = 0;
                        len1 -= 1;
                        if (len1 == 1) break :outer;
                    }

                    if ((count1 | count2) >= min_gallop) break;
                }

                // One run is winning so consistently that galloping may be a
                // huge win. So try that, and continue galloping until (if ever)
                // neither run appears to be winning consistently anymore.
                while (true) {
                    // gallopRight
                    count1 = self.gallopRight(self.items[cursor2], tmp, cursor1, len1, 0);

                    if (count1 != 0) {
                        std.mem.copy(T, self.items[dest .. dest + count1], tmp[cursor1 .. cursor1 + count1]);
                        dest += count1;
                        cursor1 += count1;
                        len1 -= count1;
                        if (len1 <= 1) break :outer;
                    }

                    self.items[dest] = self.items[cursor2];
                    dest += 1;
                    cursor2 += 1;
                    len2 -= 1;
                    if (len2 == 0) break :outer;

                    // gallopLeft
                    count2 = self.gallopLeft(tmp[cursor1], self.items, cursor2, len2, 0);

                    if (count2 != 0) {
                        std.debug.assert(dest <= cursor2);
                        std.mem.copy(T, self.items[dest .. dest + count2], self.items[cursor2 .. cursor2 + count2]);
                        dest += count2;
                        cursor2 += count2;
                        len2 -= count2;
                        if (len2 == 0) break :outer;
                    }

                    self.items[dest] = tmp[cursor1];
                    dest += 1;
                    cursor1 += 1;
                    len1 -= 1;
                    if (len1 == 1) break :outer;

                    min_gallop -|= 1;

                    if (count1 < min_gallop and count2 < min_gallop) break;
                }

                min_gallop += 2; // penalize for leaving gallop mode

            } // end of `outer` loop

            if (min_gallop < 1) min_gallop = 1;

            self.min_gallop = min_gallop;

            if (len1 == 1) {
                std.debug.assert(dest <= cursor2);
                std.mem.copy(T, self.items[dest .. dest + len2], self.items[cursor2 .. cursor2 + len2]);
                self.items[dest + len2] = tmp[cursor1];
            } else {
                std.mem.copy(T, self.items[dest .. dest + len1], tmp[cursor1 .. cursor1 + len1]);
            }
        }

        /// Like mergeLo, except that this method should be called only if
        /// len1 >= len2; mergeLo should be called if len1 <= len2.  (Either method
        /// may be called if len1 == len2.)
        fn mergeHi(
            self: *@This(),
            base1: usize,
            orig_len1: usize,
            base2: usize,
            orig_len2: usize,
        ) !void {
            var len1: usize = orig_len1;
            var len2: usize = orig_len2;

            const tmp = try self.ensureCapacity(len2);

            std.mem.copy(T, tmp, self.items[base2 .. base2 + len2]);

            var cursor1: usize = base1 + len1;
            var cursor2: usize = len2 - 1;
            var dest: usize = base2 + len2 - 1;

            // Move first element of second run and deal with degenerate cases.
            self.items[dest] = self.items[cursor1 - 1];
            dest -= 1;
            cursor1 -= 1;
            len1 -= 1;

            if (len1 == 0) {
                dest -= len2 - 1;
                std.mem.copy(T, self.items[dest .. dest + len2], tmp);
                return;
            }

            if (len2 == 1) {
                dest -= len1 - 1;
                cursor1 -= len1 - 1;
                std.debug.assert(dest > cursor1 - 1);
                std.mem.copyBackwards(T, self.items[dest .. dest + len1], self.items[cursor1 - 1 .. cursor1 - 1 + len1]);
                self.items[dest - 1] = tmp[cursor2];
                return;
            }

            var min_gallop: usize = self.min_gallop;

            outer: while (true) {
                var count1: usize = 0;
                var count2: usize = 0;

                // Do the straightforward thing until (if ever) one run starts
                // winning consistently.
                while (true) {
                    if (self.cmp(self.context, tmp[cursor2], self.items[cursor1 - 1])) {
                        self.items[dest] = self.items[cursor1 - 1];
                        dest -= 1;
                        cursor1 -= 1;
                        count1 += 1;
                        count2 = 0;
                        len1 -= 1;
                        if (len1 == 0) break :outer;
                    } else {
                        self.items[dest] = tmp[cursor2];
                        dest -= 1;
                        cursor2 -= 1;
                        count2 += 1;
                        count1 = 0;
                        len2 -= 1;
                        if (len2 == 1) break :outer;
                    }

                    if ((count1 | count2) >= min_gallop) break;
                }

                // One run is winning so consistently that galloping may be a
                // huge win. So try that, and continue galloping until (if ever)
                // neither run appears to be winning consistently anymore.
                while (true) {
                    // gallopRight
                    const gr = self.gallopRight(tmp[cursor2], self.items, base1, len1, len1 - 1);
                    count1 = len1 - gr;

                    if (count1 != 0) {
                        dest -= count1;
                        cursor1 -= count1;
                        len1 -= count1;
                        std.debug.assert(dest + 1 > cursor1);
                        std.mem.copyBackwards(T, self.items[dest + 1 .. dest + 1 + count1], self.items[cursor1 .. cursor1 + count1]);
                        if (len1 == 0) break :outer;
                    }

                    self.items[dest] = tmp[cursor2];
                    dest -= 1;
                    cursor2 -= 1;
                    len2 -= 1;
                    if (len2 == 1) break :outer;

                    // gallopLeft
                    const gl = self.gallopLeft(self.items[cursor1 - 1], tmp, 0, len2, len2 - 1);
                    count2 = len2 - gl;

                    if (count2 != 0) {
                        dest -= count2;
                        cursor2 -= count2;
                        len2 -= count2;
                        std.mem.copy(T, self.items[dest + 1 .. dest + 1 + count2], tmp[cursor2 + 1 .. cursor2 + 1 + count2]);
                        if (len2 <= 1) break :outer;
                    }

                    self.items[dest] = self.items[cursor1 - 1];
                    dest -= 1;
                    cursor1 -= 1;
                    len1 -= 1;
                    if (len1 == 0) break :outer;

                    min_gallop -|= 1;

                    if (count1 < min_gallop and count2 < min_gallop) break;
                }

                min_gallop += 2; // penalize for leaving gallop mode

            } // end of `outer` loop

            if (min_gallop < 1) min_gallop = 1;

            self.min_gallop = min_gallop;

            if (len2 == 1) {
                dest -= len1;
                cursor1 -= len1;

                std.debug.assert(dest + 1 > cursor1);
                std.mem.copyBackwards(T, self.items[dest + 1 .. dest + 1 + len1], self.items[cursor1 .. cursor1 + len1]);
                self.items[dest] = tmp[cursor2];
            } else {
                std.mem.copy(T, self.items[dest + 1 - len2 .. dest + 1], tmp[0..len2]);
            }
        }

        /// Ensures that the external array tmp has at least the specified
        /// number of elements, increasing its size if necessary.  The size
        /// increases exponentially to ensure amortized linear time complexity.
        fn ensureCapacity(self: *@This(), min_cap: usize) ![]T {
            if (self.tmp.len < min_cap) {
                const new_size = try std.math.ceilPowerOfTwo(usize, min_cap);
                self.tmp = try self.allocator.realloc(self.tmp, new_size);
            }

            return self.tmp;
        }

        /// Locates the position at which to insert the specified key into the
        /// specified sorted range; if the range contains an element equal to key,
        /// returns the index of the leftmost equal element.
        fn gallopLeft(
            self: @This(),
            key: T,
            items: []T,
            base: usize,
            len: usize,
            hint: usize,
        ) usize {
            var last_offset: usize = 0;
            var offset: usize = 1;

            if (cmp(context, items[base + hint], key)) {
                // Gallop right until items[base+hint+last_offset] < key <= items[base+hint+offset]
                const max_offset = len - hint;

                while (offset < max_offset and self.cmp(context, items[base + hint + offset], key)) {
                    last_offset = offset;
                    var res: usize = undefined;
                    const ov = @shlWithOverflow(offset, @intCast(u6, 1));
                    if (ov[1] == 1) {
                        offset = max_offset;
                    } else {
                        offset = res +| 1;
                    }
                }

                if (offset > max_offset) offset = max_offset;

                // Make offsets relative to base
                last_offset += hint + 1;
                offset += hint;
            } else { // key <= items[base + hint]
                // Gallop left until items[base+hint-offset] < key <= items[base+hint-last_offset]
                const max_offset = hint + 1;
                while (offset < max_offset and !self.cmp(context, items[base + hint - offset], key)) {
                    last_offset = offset;
                    var res: usize = undefined;
                    const ov = @shlWithOverflow(offset, @intCast(u6, 1));
                    if (ov[1] == 1) {
                        offset = max_offset;
                    } else {
                        offset = res +| 1;
                    }
                }

                if (offset > max_offset) offset = max_offset;

                // Make offsets relative to base
                const tmp = last_offset;
                last_offset = hint + 1 - offset;
                offset = hint - tmp;
            }

            // Now items[base+last_offset] < key <= items[base+offset], so key belongs somewhere
            // to the right of lastoffset but no farther right than offset.  Do a binary
            // search, with invariant items[base + last_offset - 1] < key <= items[base + offset].

            while (last_offset < offset) {
                const m = last_offset + (offset - last_offset) / 2;

                if (self.cmp(context, items[base + m], key))
                    last_offset = m + 1
                else
                    offset = m;
            }

            return offset;
        }

        /// Like gallopLeft, except that if the range contains an element equal to
        /// key, gallopRight returns the index after the rightmost equal element.
        fn gallopRight(
            self: @This(),
            key: T,
            items: []T,
            base: usize,
            len: usize,
            hint: usize,
        ) usize {
            var last_offset: usize = 0;
            var offset: usize = 1;

            if (self.cmp(context, key, items[base + hint])) {
                // Gallop left until items[base+hint-offset] <= key < items[base+hint-last_offset]
                const max_offset = hint + 1;

                while (offset < max_offset and self.cmp(context, key, items[base + hint - offset])) {
                    last_offset = offset;
                    var res: usize = undefined;
                    const ov = @shlWithOverflow(offset, @intCast(u6, 1));
                    if (ov[1] == 1) {
                        offset = max_offset;
                    } else {
                        offset = res +| 1;
                    }
                }

                if (offset > max_offset) offset = max_offset;

                // Make offsets relative to base
                const tmp = last_offset;
                last_offset = hint + 1 - offset;
                offset = hint - tmp;
            } else { // items[base + hint] <= key
                // Gallop right until items[base+hint+last_offset] <= key < items[base+hint+offset]
                const max_offset = len - hint;
                while (offset < max_offset and !self.cmp(context, key, items[base + hint + offset])) {
                    last_offset = offset;
                    var res: usize = undefined;
                    const ov = @shlWithOverflow(offset, @intCast(u6, 1));
                    if (ov[1] == 1) {
                        offset = max_offset;
                    } else {
                        offset = res +| 1;
                    }
                }

                if (offset > max_offset) offset = max_offset;

                // Make offsets relative to base
                last_offset += hint + 1;
                offset += hint;
            }

            // Now items[base+last_offset] <= key < items[base+offset], so key belongs somewhere
            // to the right of lastoffset but no farther right than offset.  Do a binary
            // search, with invariant items[base+last_offset-1] <= key < items[base+offset].

            while (last_offset < offset) {
                const m = last_offset + (offset - last_offset) / 2;

                if (cmp(context, key, items[base + m]))
                    offset = m
                else
                    last_offset = m + 1;
            }

            return offset;
        }
    };
}

test "timSort" {
    {
        var array = [_]usize{ 6, 4, 1, 4, 3, 2, 6, 7, 8, 9 };
        const exp = [_]usize{ 1, 2, 3, 4, 4, 6, 6, 7, 8, 9 };

        try timSort(usize, std.testing.allocator, &array, {}, comptime std.sort.asc(usize));

        try std.testing.expectEqualSlices(usize, &exp, &array);
    }

    {
        var array = [_]usize{ 6, 4, 1, 4, 3, 2, 6, 7, 8, 9, 0 };
        const exp = [_]usize{ 0, 1, 2, 3, 4, 4, 6, 6, 7, 8, 9 };

        try timSort(usize, std.testing.allocator, &array, {}, comptime std.sort.asc(usize));

        try std.testing.expectEqualSlices(usize, &exp, &array);
    }

    {
        var array = [_]usize{ 1, 4, 6, 4, 3, 2, 6, 7, 8, 9 };
        const exp = [_]usize{ 9, 8, 7, 6, 6, 4, 4, 3, 2, 1 };

        try timSort(usize, std.testing.allocator, &array, {}, comptime std.sort.desc(usize));

        try std.testing.expectEqualSlices(usize, &exp, &array);
    }

    {
        var array = [_]usize{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 100, 90, 80, 70, 60, 50, 40, 30, 20, 10, 11, 22, 33, 44, 55, 66, 77, 88, 99, 1000, 0, 500 };
        const exp = [_]usize{ 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 10, 10, 11, 20, 20, 22, 30, 30, 33, 40, 40, 44, 50, 50, 55, 60, 60, 66, 70, 70, 77, 80, 80, 88, 90, 90, 99, 100, 100, 500, 1000 };

        try timSort(usize, std.testing.allocator, &array, {}, comptime std.sort.asc(usize));

        try std.testing.expectEqualSlices(usize, &exp, &array);
    }

    {
        // ascending
        const TEST_TYPE = isize;
        const TESTS = 10;
        const ITEMS = 10_000;

        var rnd = std.rand.DefaultPrng.init(@intCast(u64, std.time.milliTimestamp()));

        var tc: usize = 0;
        while (tc < TESTS) : (tc += 1) {
            var array = try std.ArrayList(TEST_TYPE).initCapacity(std.testing.allocator, ITEMS);
            defer array.deinit();

            var item: usize = 0;
            while (item < ITEMS) : (item += 1) {
                const value = rnd.random().int(TEST_TYPE);
                array.appendAssumeCapacity(value);
            }
            var reference = try array.clone();
            defer reference.deinit();

            std.sort.sort(TEST_TYPE, reference.items, {}, comptime std.sort.asc(TEST_TYPE));

            try timSort(TEST_TYPE, std.testing.allocator, array.items, {}, comptime std.sort.asc(TEST_TYPE));

            try std.testing.expectEqualSlices(TEST_TYPE, reference.items, array.items);
        }
    }

    {
        // descending
        const TEST_TYPE = isize;
        const TESTS = 10;
        const ITEMS = 10_000;

        var rnd = std.rand.DefaultPrng.init(@intCast(u64, std.time.milliTimestamp()));

        var tc: usize = 0;
        while (tc < TESTS) : (tc += 1) {
            var array = try std.ArrayList(TEST_TYPE).initCapacity(std.testing.allocator, ITEMS);
            defer array.deinit();

            var item: usize = 0;
            while (item < ITEMS) : (item += 1) {
                const value = rnd.random().int(TEST_TYPE);
                array.appendAssumeCapacity(value);
            }
            var reference = try array.clone();
            defer reference.deinit();

            std.sort.sort(TEST_TYPE, reference.items, {}, comptime std.sort.desc(TEST_TYPE));

            try timSort(TEST_TYPE, std.testing.allocator, array.items, {}, comptime std.sort.desc(TEST_TYPE));

            try std.testing.expectEqualSlices(TEST_TYPE, reference.items, array.items);
        }
    }
}
