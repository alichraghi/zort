# Zort

a lot of sorting algorithms in zig

- [x] Quick
- [x] Insertion
- [x] Selection
- [x] Bubble
- [x] Merge
- [x] Shell
- [x] Comb
- [x] Heap
- [x] Radix (ASC Only)
- [ ] Tim
- [ ] Blcok
- [ ] Cube
- [ ] Tree
- [ ] Patience
- [ ] Smoothsort
- [ ] Tournament

## Usage:
```zig
const zort = @import("zort");

pub fn main() void {
    var arr = [_]u8{ 9, 1, 4, 12, 3, 4 };
    sort(u8, arr, false, .Quick, null);
}
```