# Zort

implemention of 9 sorting algorithm in Zig

| Algorithm           | Custom Comparison | Zero Allocation |
| ------------------- | ----------------- | --------------- |
| Quick               | ✅                | ✅              |
| Insertion           | ✅                | ✅              |
| Selection           | ✅                | ✅              |
| Bubble              | ✅                | ✅              |
| Shell               | ✅                | ✅              |
| Comb                | ✅                | ✅              |
| Heap                | ✅                | ✅              |
| Merge               | ✅                | ❌              |
| Radix (no negative) | ❌                | ❌              |

benchmark results:
![exec_time.png](/benchmark/image/exec_time.png)

## Usage:

```zig
const zort = @import("zort");

pub fn main() !void {
    var arr = [_]u8{ 9, 1, 4, 12, 3, 4 };
    try zort.sort(u8, &arr, false, .Quick, null);
}
```

## TODO

- [ ] move algorithms into sepereate files and organize tests
- [ ] pdq sort
- [ ] quad sort?
