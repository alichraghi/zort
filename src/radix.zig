const std = @import("std");
const mem = std.mem;

const SortOrder = enum {
    ascending,
    descending,
};

const SortOptions = struct {
    order: SortOrder = .ascending,
    _byte_order: SortOrder = .ascending,
    key_field: ?@Type(.EnumLiteral) = null,
    fn canonicalize(comptime self: SortOptions) SortOptions {
        return .{
            .order = self.order,
            ._byte_order = self.order,
            .key_field = self.key_field,
        };
    }
    fn reversed(comptime self: SortOptions) SortOptions {
        return .{
            .order = self.order,
            ._byte_order = switch (self.order) {
                .ascending => .descending,
                .descending => .ascending,
            },
            .key_field = self.key_field,
        };
    }
};

const INSSORT_CUTOFF = 55;

inline fn lt(comptime T: type, comptime options: SortOptions, a: T, b: T) bool {
    if (options.key_field) |key_field| {
        const a_key = @field(a, @tagName(key_field));
        const b_key = @field(b, @tagName(key_field));
        return switch (options.order) {
            .ascending => a_key < b_key,
            .descending => b_key < a_key,
        };
    }
    return switch (options.order) {
        .ascending => a < b,
        .descending => b < a,
    };
}

inline fn insSort(comptime T: type, comptime options: SortOptions, noalias array: [*]T, len: usize) void {
    var i: usize = 1;
    while (i < len) : (i += 1) {
        const tmp = array[i];
        var j: usize = i;
        while (j > 0) : (j -= 1) {
            if (lt(T, options, array[j - 1], tmp)) {
                break;
            }
            array[j] = array[j - 1];
        }
        array[j] = tmp;
    }
}

inline fn insSortIntoOtherArray(comptime T: type, comptime options: SortOptions, noalias src: [*]T, noalias dst: [*]T, len: usize) void {
    var i: usize = 1;
    dst[0] = src[0];
    while (i < len) : (i += 1) {
        const tmp = src[i];
        var j: usize = i;
        while (j > 0) : (j -= 1) {
            if (lt(T, options, dst[j - 1], tmp)) {
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

inline fn readOneByte(comptime T: type, comptime options: SortOptions, comptime idx: usize, x: T) u8 {
    if (options.key_field) |key_field| {
        const key = @field(x, @tagName(key_field));
        return readOneByte(FieldType(T, key_field), .{}, idx, key);
    }
    if (T == f32) {
        return readOneByte(u32, .{}, idx, @bitCast(u32, x));
    }
    if (T == f64) {
        return readOneByte(u64, .{}, idx, @bitCast(u64, x));
    }
    const U = comptime std.meta.Int(.unsigned, std.meta.bitCount(T));
    const shift = comptime (@sizeOf(T) - 1 - idx) * 8;
    if (idx == 0) {
        return truncate(u8, (@bitCast(U, @as(T, std.math.minInt(T))) ^ @bitCast(U, x)) >> shift);
    }
    return truncate(u8, @bitCast(U, x) >> shift);
}

inline fn readTwoBytes(comptime T: type, comptime options: SortOptions, comptime idx: usize, x: T) u16 {
    if (options.key_field) |key_field| {
        const key = @field(x, @tagName(key_field));
        return readTwoBytes(FieldType(T, key_field), .{}, idx, key);
    }
    if (T == f32) {
        return readTwoBytes(u32, .{}, idx, @bitCast(u32, x));
    }
    if (T == f64) {
        return readTwoBytes(u64, .{}, idx, @bitCast(u64, x));
    }
    const U = comptime std.meta.Int(.unsigned, std.meta.bitCount(T));
    const shift = comptime (@sizeOf(T) - 2 - idx) * 8;
    if (idx == 0) {
        return truncate(u16, (@bitCast(U, @as(T, std.math.minInt(T))) ^ @bitCast(U, x)) >> shift);
    }
    return truncate(u16, @bitCast(U, x) >> shift);
}

fn FieldType(comptime T: type, comptime field: @Type(.EnumLiteral)) type {
    return std.meta.fieldInfo(T, field).field_type;
}

fn SortKeyType(comptime T: type, comptime options: SortOptions) type {
    if (options.key_field) |key_field| {
        return FieldType(T, key_field);
    }
    return T;
}

fn radixSortByBytesAdaptive(
    comptime T: type,
    comptime options: SortOptions,
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
    const Key = SortKeyType(T, options);
    const is_first_byte_of_float_key = comptime if (Key == f32 or Key == f64) idx == 0 else false;

    const readBucket = comptime if (BYTES_PER_LEVEL == 2) readTwoBytes else readOneByte;

    i = 0;
    while (i < buckets_len) : (i += 1) {
        bucketsize[i] = 0;
    }

    i = 0;
    while (i < arr_len) : (i += 1) {
        const bucket = readBucket(T, options, idx, array[i]);
        bucketsize[bucket] += 1;
    }

    if (!is_first_byte_of_float_key) {
        switch (options._byte_order) {
            .ascending => {
                bucketindex[0] = 0;
                i = 1;
                while (i < buckets_len) : (i += 1) {
                    bucketindex[i] = bucketindex[i - 1] + bucketsize[i - 1];
                }
            },
            .descending => {
                bucketindex[buckets_len - 1] = 0;
                i = buckets_len - 1;
                while (i > 0) : (i -= 1) {
                    bucketindex[i - 1] = bucketindex[i] + bucketsize[i];
                }
            },
        }
    } else {
        switch (options._byte_order) {
            .ascending => {
                bucketindex[buckets_len - 1] = 0;
                i = buckets_len - 1;
                while (i > buckets_len / 2) : (i -= 1) {
                    bucketindex[i - 1] = bucketindex[i] + bucketsize[i];
                }
                bucketindex[0] = bucketindex[buckets_len / 2] + bucketsize[buckets_len / 2];
                i = 1;
                while (i < buckets_len / 2) : (i += 1) {
                    bucketindex[i] = bucketindex[i - 1] + bucketsize[i - 1];
                }
            },
            .descending => {
                bucketindex[buckets_len / 2 - 1] = 0;
                i = buckets_len / 2 - 1;
                while (i > 0) : (i -= 1) {
                    bucketindex[i - 1] = bucketindex[i] + bucketsize[i];
                }
                bucketindex[buckets_len / 2] = bucketindex[0] + bucketsize[0];
                i = buckets_len / 2 + 1;
                while (i < buckets_len) : (i += 1) {
                    bucketindex[i] = bucketindex[i - 1] + bucketsize[i - 1];
                }
            },
        }
    }

    i = 0;
    while (i < arr_len) : (i += 1) {
        const bucket = readBucket(T, options, idx, array[i]);
        scratch[bucketindex[bucket]] = array[i];
        bucketindex[bucket] += 1;
    }

    const next_idx = comptime idx + BYTES_PER_LEVEL;
    if (next_idx >= @sizeOf(Key)) {
        if (array_is_final_destination) {
            i = 0;
            while (i < arr_len) : (i += 1) {
                array[i] = scratch[i];
            }
        }
        return;
    }

    if (!is_first_byte_of_float_key) {
        switch (options._byte_order) {
            .ascending => {
                i = 0;
                while (i < buckets_len) : (i += 1) {
                    const len = bucketsize[i];
                    const hi = lo + len;
                    recurse(T, options, Ubucket, idx, array_is_final_destination, BYTES_PER_LEVEL, array, scratch, buckets, lo, len);
                    lo = hi;
                }
            },
            .descending => {
                i = buckets_len;
                while (i > 0) {
                    i -= 1;
                    const len = bucketsize[i];
                    const hi = lo + len;
                    recurse(T, options, Ubucket, idx, array_is_final_destination, BYTES_PER_LEVEL, array, scratch, buckets, lo, len);
                    lo = hi;
                }
            },
        }
    } else {
        const reversed_options = comptime options.reversed();
        switch (options._byte_order) {
            .ascending => {
                i = buckets_len;
                while (i > buckets_len / 2) {
                    i -= 1;
                    const len = bucketsize[i];
                    const hi = lo + len;
                    recurse(T, reversed_options, Ubucket, idx, array_is_final_destination, BYTES_PER_LEVEL, array, scratch, buckets, lo, len);
                    lo = hi;
                }
                i = 0;
                while (i < buckets_len / 2) : (i += 1) {
                    const len = bucketsize[i];
                    const hi = lo + len;
                    recurse(T, options, Ubucket, idx, array_is_final_destination, BYTES_PER_LEVEL, array, scratch, buckets, lo, len);
                    lo = hi;
                }
            },
            .descending => {
                i = buckets_len / 2;
                while (i > 0) {
                    i -= 1;
                    const len = bucketsize[i];
                    const hi = lo + len;
                    recurse(T, options, Ubucket, idx, array_is_final_destination, BYTES_PER_LEVEL, array, scratch, buckets, lo, len);
                    lo = hi;
                }
                i = buckets_len / 2;
                while (i < buckets_len) : (i += 1) {
                    const len = bucketsize[i];
                    const hi = lo + len;
                    recurse(T, reversed_options, Ubucket, idx, array_is_final_destination, BYTES_PER_LEVEL, array, scratch, buckets, lo, len);
                    lo = hi;
                }
            },
        }
    }
}

inline fn recurse(
    comptime T: type,
    comptime options: SortOptions,
    comptime Ubucket: type,
    comptime idx: usize,
    comptime array_is_final_destination: bool,
    comptime BYTES_PER_LEVEL: usize,
    noalias array: [*]T,
    noalias scratch: [*]T,
    noalias buckets: [*]Ubucket,
    lo: usize,
    len: usize,
) void {
    const next_idx = comptime idx + BYTES_PER_LEVEL;
    const buckets_len = comptime if (BYTES_PER_LEVEL == 2) 0x10000 else 0x100;
    const bucketindex = buckets + buckets_len;
    if (BYTES_PER_LEVEL == 2 and next_idx + 1 < @sizeOf(T) and len >= 0x10000) {
        radixSortByBytesAdaptive(
            T,
            options,
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
            options,
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
            insSortIntoOtherArray(T, options, scratch + lo, array + lo, len);
        } else {
            insSort(T, options, scratch + lo, len);
        }
    } else if (len == 1 and array_is_final_destination) {
        array[lo] = scratch[lo];
    }
}

pub fn radixSort(
    comptime T: type,
    comptime _options: SortOptions,
    allocator: mem.Allocator,
    arr: []T,
) mem.Allocator.Error!void {
    const options = comptime _options.canonicalize();
    const Key = SortKeyType(T, options);
    // the max number of buckets needed is for the case where we consume
    // 2 bytes at a time the whole way through.
    // In that case, we'll need 0x10000 * (n_levels+1) buckets.
    const max_buckets = (((std.meta.bitCount(Key) + 15) / 16) + 1) * 0x10000;

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
                options,
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
                options,
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
                options,
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
                options,
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
