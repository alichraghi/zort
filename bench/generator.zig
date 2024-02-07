const std = @import("std");

/// Generate `limit` number or random items
pub fn random(comptime T: type, allocator: std.mem.Allocator, limit: usize) std.mem.Allocator.Error![]T {
    var rnd = std.rand.DefaultPrng.init(@intCast(std.time.milliTimestamp()));

    var array = try std.ArrayList(T).initCapacity(allocator, limit);

    switch (@typeInfo(T)) {
        .Int => {
            var i: usize = 0;
            while (i < limit) : (i += 1) {
                const item: T = rnd.random()
                    .intRangeAtMostBiased(T, std.math.minInt(T), @as(T, @intCast(limit)));
                array.appendAssumeCapacity(item);
            }
        },
        else => unreachable,
    }

    return array.toOwnedSlice();
}

pub fn sorted(comptime T: type, allocator: std.mem.Allocator, limit: usize) std.mem.Allocator.Error![]T {
    const ret = try random(T, allocator, limit);

    std.mem.sort(T, ret, {}, comptime std.sort.asc(T));

    return ret;
}

pub fn reverse(comptime T: type, allocator: std.mem.Allocator, limit: usize) std.mem.Allocator.Error![]T {
    const ret = try random(T, allocator, limit);

    std.mem.sort(T, ret, {}, comptime std.sort.desc(T));

    return ret;
}

pub fn ascSaw(comptime T: type, allocator: std.mem.Allocator, limit: usize) std.mem.Allocator.Error![]T {
    const TEETH = 10;
    var ret = try random(T, allocator, limit);

    var offset: usize = 0;
    while (offset < TEETH) : (offset += 1) {
        const start = ret.len / TEETH * offset;
        std.mem.sort(T, ret[start .. start + ret.len / TEETH], {}, comptime std.sort.asc(T));
    }

    return ret;
}

pub fn descSaw(comptime T: type, allocator: std.mem.Allocator, limit: usize) std.mem.Allocator.Error![]T {
    const TEETH = 10;
    var ret = try random(T, allocator, limit);

    var offset: usize = 0;
    while (offset < TEETH) : (offset += 1) {
        const start = ret.len / TEETH * offset;
        std.mem.sort(T, ret[start .. start + ret.len / TEETH], {}, comptime std.sort.desc(T));
    }

    return ret;
}
