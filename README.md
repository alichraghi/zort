# Zort

a lot of sorting algorithms in zig

- [x] Quick
- [x] Insertion
- [x] Selection
- [x] Bubble
- [x] Merge
- [x] Shell
- [x] Comb
- [ ] Counting (requires allocator)
- [ ] Radix (requires allocator)
- [ ] Bucket (requires allocator)

## Usage:
```zig
const zort = @import("zort");

pub fn main() void {
    var arr = [_]u8{ 9, 1, 4, 12, 3, 4 };
    sort(u8, .Quick, &arr, false);
}
```