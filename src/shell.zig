const zort = @import("main.zig");

pub fn shellSort(comptime T: type, arr: []T, cmp: zort.CompareFn(T)) void {
    var gap = arr.len / 2;
    while (gap > 0) : (gap /= 2) {
        var i = gap;
        while (i < arr.len) : (i += 1) {
            const x = arr[i];
            var j = i;
            while (j >= gap and cmp(x, arr[j - gap])) : (j -= gap) {
                arr[j] = arr[j - gap];
            }
            arr[j] = x;
        }
    }
}
