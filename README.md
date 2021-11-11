# Zort

a lot of sorting algorithms in zig

| Algorithm | Implemented | ASC | DESC | Zero Allocation |
| ------------ | ------------- | ------------- | ------------- | ------------- |
| Quick | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Insertion | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Selection | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Bubble | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Shell | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Comb | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Heap | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Merge | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :x: |
| Radix | :heavy_check_mark: | :heavy_check_mark: | :white_check_mark: (`mem.reverse`) | :x: |

## Usage:
```zig
const zort = @import("zort");

pub fn main() void {
    var arr = [_]u8{ 9, 1, 4, 12, 3, 4 };
    sort(u8, arr, false, .Quick, null);
}
```