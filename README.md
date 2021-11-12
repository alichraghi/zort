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
    1.18 ± 0.21 times faster than 'std_block'
    1.06 ± 0.20 times faster than 'radix'
    1.24 ± 0.21 times faster than 'comb'
    1.33 ± 0.22 times faster than 'shell'
    1.44 ± 0.26 times faster than 'heap'
  106.11 ± 13.74 times faster than 'merge'
  153.15 ± 19.84 times faster than 'std_insertion'
  165.51 ± 22.83 times faster than 'insertion'
  243.00 ± 31.52 times faster than 'selection'
  477.22 ± 62.45 times faster than 'bubble'
```

## Usage:
```zig
const zort = @import("zort");

pub fn main() !void {
    var arr = [_]u8{ 9, 1, 4, 12, 3, 4 };
    try zort.sort(u8, &arr, false, .Quick, null);
}
```

thx from @der-teufel-programming for answering my questions