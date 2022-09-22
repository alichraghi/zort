const std = @import("std");
const mem = std.mem;

const INSSORT_CUTOFF = 55;

inline fn insSort(comptime T: type, noalias array: [*]T, len: usize) void {
    var i: usize = 1;
    while (i < len) : (i += 1) {
        const tmp = array[i];
        var j: usize = i;
        while (j > 0) : (j -= 1) {
            if (array[j - 1] < tmp) {
                break;
            }
            array[j] = array[j - 1];
        }
        array[j] = tmp;
    }
}

inline fn insSortIntoOtherArray(comptime T: type, noalias src: [*]T, noalias dst: [*]T, len: usize) void {
    var i: usize = 1;
    dst[0] = src[0];
    while (i < len) : (i += 1) {
        const tmp = src[i];
        var j: usize = i;
        while (j > 0) : (j -= 1) {
            if (dst[j - 1] < tmp) {
                break;
            }
            dst[j] = dst[j - 1];
        }
        dst[j] = tmp;
    }
}

inline fn truncate(comptime U: type, x: anytype) U {
    const T = @TypeOf(x);
    if (std.meta.bitCount(T) >= std.meta.bitCount(U)) {
        return @truncate(U, x);
    }
    return x;
}

inline fn readOneByte(comptime T: type, comptime idx: usize, x: T) u8 {
    const U = comptime std.meta.Int(.unsigned, std.meta.bitCount(T));
    const shift = comptime (@sizeOf(T) - 1 - idx) * 8;
    if (idx == 0) {
        return truncate(u8, (@bitCast(U, @as(T, std.math.minInt(T))) ^ @bitCast(U, x)) >> shift);
    }
    return truncate(u8, @bitCast(U, x) >> shift);
}

inline fn readTwoBytes(comptime T: type, comptime idx: usize, x: T) u16 {
    const U = comptime std.meta.Int(.unsigned, std.meta.bitCount(T));
    const shift = comptime (@sizeOf(T) - 2 - idx) * 8;
    if (idx == 0) {
        return truncate(u16, (@bitCast(U, @as(T, std.math.minInt(T))) ^ @bitCast(U, x)) >> shift);
    }
    return truncate(u16, @bitCast(U, x) >> shift);
}

fn radixSortByBytesAdaptive(
    comptime T: type,
    comptime Ubucket: type,
    comptime idx: usize,
    comptime array_is_final_destination: bool,
    comptime BYTES_PER_LEVEL: usize,
    noalias array: [*]T,
    noalias scratch: [*]T,
    arr_len: usize,
    noalias buckets: [*]Ubucket,
) void {
    comptime {
        std.debug.assert(BYTES_PER_LEVEL == 1 or BYTES_PER_LEVEL == 2);
    }

    var i: usize = 0;
    var lo: usize = 0;
    const buckets_len = comptime if (BYTES_PER_LEVEL == 2) 0x10000 else 0x100;
    const bucketsize = buckets;
    const bucketindex = buckets + buckets_len;

    const readBucket = comptime if (BYTES_PER_LEVEL == 2) readTwoBytes else readOneByte;

    i = 0;
    while (i < buckets_len) : (i += 1) {
        bucketsize[i] = 0;
    }

    i = 0;
    while (i < arr_len) : (i += 1) {
        const bucket = readBucket(T, idx, array[i]);
        bucketsize[bucket] += 1;
    }

    bucketindex[0] = 0;
    i = 1;
    while (i < buckets_len) : (i += 1) {
        bucketindex[i] = bucketindex[i - 1] + bucketsize[i - 1];
    }

    i = 0;
    while (i < arr_len) : (i += 1) {
        const bucket = readBucket(T, idx, array[i]);
        scratch[bucketindex[bucket]] = array[i];
        bucketindex[bucket] += 1;
    }

    const next_idx = comptime idx + BYTES_PER_LEVEL;
    if (next_idx >= @sizeOf(T)) {
        if (array_is_final_destination) {
            i = 0;
            while (i < arr_len) : (i += 1) {
                array[i] = scratch[i];
            }
        }
        return;
    }

    i = 0;
    while (i < buckets_len) : (i += 1) {
        const len = bucketsize[i];
        const hi = lo + len;
        if (BYTES_PER_LEVEL == 2 and next_idx + 1 < @sizeOf(T) and len >= 0x10000) {
            radixSortByBytesAdaptive(
                T,
                Ubucket,
                next_idx,
                !array_is_final_destination,
                2,
                scratch + lo,
                array + lo,
                len,
                bucketindex,
            );
        } else if (len > INSSORT_CUTOFF) {
            radixSortByBytesAdaptive(
                T,
                Ubucket,
                next_idx,
                !array_is_final_destination,
                1,
                scratch + lo,
                array + lo,
                len,
                bucketindex,
            );
        } else if (len > 1) {
            if (array_is_final_destination) {
                insSortIntoOtherArray(T, scratch + lo, array + lo, len);
            } else {
                insSort(T, scratch + lo, len);
            }
        } else if (len == 1 and array_is_final_destination) {
            array[lo] = scratch[lo];
        }
        lo = hi;
    }
}

pub fn radixSort(comptime T: type, allocator: mem.Allocator, arr: []T) mem.Allocator.Error!void {
    // the max number of buckets needed is for the case where we consume
    // 2 bytes at a time the whole way through.
    // In that case, we'll need 0x10000 * (n_levels+1) buckets.
    const max_buckets = (((std.meta.bitCount(T) + 15) / 16) + 1) * 0x10000;

    // using usize for buckets is pretty wasteful - most arrays have <2^32 elements.
    // this has a quite real performance cost because fewer buckets fit in cache.
    // so let's have a u32 version?
    const scratch = try allocator.alloc(T, arr.len);
    defer allocator.free(scratch);
    if (arr.len <= std.math.maxInt(u32) and std.meta.bitCount(usize) > 32) {
        const buckets = try allocator.alloc(u32, max_buckets);
        defer allocator.free(buckets);
        if (@sizeOf(T) > 1 and arr.len >= 0x10000) {
            radixSortByBytesAdaptive(
                T,
                u32,
                0,
                true,
                2,
                arr.ptr,
                scratch.ptr,
                arr.len,
                buckets.ptr,
            );
        } else {
            radixSortByBytesAdaptive(
                T,
                u32,
                0,
                true,
                1,
                arr.ptr,
                scratch.ptr,
                arr.len,
                buckets.ptr,
            );
        }
    } else {
        const buckets = try allocator.alloc(usize, max_buckets);
        defer allocator.free(buckets);
        if (@sizeOf(T) > 1 and arr.len >= 0x10000) {
            radixSortByBytesAdaptive(
                T,
                usize,
                0,
                true,
                2,
                arr.ptr,
                scratch.ptr,
                arr.len,
                buckets.ptr,
            );
        } else {
            radixSortByBytesAdaptive(
                T,
                usize,
                0,
                true,
                1,
                arr.ptr,
                scratch.ptr,
                arr.len,
                buckets.ptr,
            );
        }
    }
}
