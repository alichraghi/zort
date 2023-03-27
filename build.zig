const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const benchmark = b.addExecutable(.{
        .name = "bench",
        .root_source_file = .{ .path = "benchmark/bench.zig" },
        .optimize = optimize,
        .target = target,
    });
    benchmark.addAnonymousModule("zort", .{ .source_file = .{ .path = "src/main.zig" } });

    const benchmark_cmd = benchmark.run();
    if (b.args) |args| {
        benchmark_cmd.addArgs(args);
    }
    const benchmark_step = b.step("bench", "Run benchmarks");
    benchmark_step.dependOn(&benchmark_cmd.step);

    var tests = b.addTest(.{
        .name = "zort-tests",
        .root_source_file = .{ .path = "src/test.zig" },
        .optimize = optimize,
        .target = target,
    });
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&tests.run().step);
}
