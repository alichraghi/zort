# Zort

implemention of 9 sorting algorithm in Zig

| Algorithm | ASC | DESC | Zero Allocation |
| ------------ | ------------- | ------------- | ------------- |
| Quick | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Insertion | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Selection | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Bubble | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Shell | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Comb | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Heap | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Merge | :heavy_check_mark: | :heavy_check_mark: | :x: |
| Radix (positive number) | :heavy_check_mark: | :white_check_mark: (`mem.reverse`) | :x: |

benchmark result:
```js
  'quick' ran
    1.18 ± 0.20 times faster than 'std_quick'
    1.25 ± 0.21 times faster than 'comb'
    1.34 ± 0.22 times faster than 'merge'
    1.35 ± 0.22 times faster than 'heap'
    1.36 ± 0.25 times faster than 'radix'
    1.39 ± 0.29 times faster than 'shell'
  149.39 ± 19.69 times faster than 'std_insertion'
  157.82 ± 21.27 times faster than 'insertion'
  232.40 ± 30.83 times faster than 'selection'
  454.14 ± 59.74 times faster than 'bubble'
```

## Usage:
```zig
const zort = @import("zort");

pub fn main() !void {
    var arr = [_]u8{ 9, 1, 4, 12, 3, 4 };
    try zort.sort(u8, &arr, false, .Quick, null);
}
```