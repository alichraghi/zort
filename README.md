# Zort

a lot of sorting algorithms in zig

Algorithm | Implemented | ASC | DESC | No Allocation
:------------ | :-------------| :-------------| :-------------
Quick | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:
Insertion | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:
Selection | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:
Bubble | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:
Shell | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:
Comb | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:
Heap | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:
Merge | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :white_check_mark:
Radix | :heavy_check_mark: | :heavy_check_mark: | :white_check_mark: | :white_check_mark:
Tim | :x: | :heavy_minus_sign: | :heavy_minus_sign: | :heavy_minus_sign:
Blcok | :x: | :heavy_minus_sign: | :heavy_minus_sign: | :heavy_minus_sign:
Cube | :x: | :heavy_minus_sign: | :heavy_minus_sign: | :heavy_minus_sign:
Tree | :x: | :heavy_minus_sign: | :heavy_minus_sign: | :heavy_minus_sign:
Patience | :x: | :heavy_minus_sign: | :heavy_minus_sign: | :heavy_check_mark:
Smoothsort | :x: | :heavy_minus_sign: | :heavy_minus_sign: | :heavy_minus_sign:
Tournament | :x: | :heavy_minus_sign: | :heavy_minus_sign: | :heavy_minus_sign:

## Usage:
```zig
const zort = @import("zort");

pub fn main() void {
    var arr = [_]u8{ 9, 1, 4, 12, 3, 4 };
    sort(u8, arr, false, .Quick, null);
}
```