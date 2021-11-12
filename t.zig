const zort = @import("zort.zig");

pub fn main() !void {
    var arr = [_]u8{ 9, 1, 4, 12, 3, 4 };
    try zort.sort(u8, &arr, false, .Quick, null);
}