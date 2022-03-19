const std = @import("std");
const mem = std.mem;
const math = std.math;
const Allocator = mem.Allocator;

pub usingnamespace @import("bubble.zig");
pub usingnamespace @import("comb.zig");
pub usingnamespace @import("heap.zig");
pub usingnamespace @import("insertion.zig");
pub usingnamespace @import("merge.zig");
pub usingnamespace @import("quick.zig");
pub usingnamespace @import("radix.zig");
pub usingnamespace @import("selection.zig");
pub usingnamespace @import("shell.zig");
pub usingnamespace @import("tim.zig");

pub fn CompareFn(comptime T: type) type {
    return fn (a: T, b: T) bool;
}
