const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const bench = b.addExecutable(.{
        .name = "bench",
        .root_source_file = .{ .path = "bench/bench.zig" },
        .optimize = optimize,
        .target = target,
    });
    bench.addAnonymousModule("zort", .{ .source_file = .{ .path = "src/main.zig" } });

    const bench_cmd = b.addRunArtifact(bench);
    if (b.args) |args| {
        bench_cmd.addArgs(args);
    }
    const bench_step = b.step("bench", "Run benchmarks");
    bench_step.dependOn(&bench_cmd.step);

    var tests = b.addTest(.{
        .root_source_file = .{ .path = "src/test.zig" },
        .optimize = optimize,
        .target = target,
    });
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&b.addRunArtifact(tests).step);
}
