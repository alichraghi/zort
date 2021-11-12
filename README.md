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
```rs
'quick' ran
  1.21 ± 0.57 times faster than 'shell'
  1.22 ± 0.59 times faster than 'radix'
  1.22 ± 0.59 times faster than 'heap'
  1.23 ± 0.81 times faster than 'std_quick'
  1.23 ± 0.62 times faster than 'merge'
  1.54 ± 0.71 times faster than 'comb'
 88.44 ± 33.60 times faster than 'std_insertion'
 92.76 ± 35.22 times faster than 'insertion'
136.53 ± 51.69 times faster than 'selection'
273.05 ± 103.60 times faster than 'bubble'
```

## Usage:
```zig
const zort = @import("zort");

pub fn main() !void {
    var arr = [_]u8{ 9, 1, 4, 12, 3, 4 };
    try zort.sort(u8, &arr, false, .Quick, null);
}
```