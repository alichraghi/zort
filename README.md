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

fn asc(a: u8, b: u8) bool {
    return a < b;
}

pub fn main() !void {
    var arr = [_]u8{ 9, 1, 4, 12, 3, 4 };
    try zort.quickSort(u8, &arr, asc);
}
```

## TODO

- [ ] move algorithms into sepereate files and organize tests
