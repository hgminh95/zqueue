const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("zqueue", .{
        .root_source_file = b.path("src/zqueue.zig"),
        .target = b.graph.host,
        .optimize = optimize,
    });

    // Benchmark
    const bench = b.addExecutable(.{
        .name = "bench",
        .root_source_file = b.path("bench/main.zig"),
        .target = b.graph.host,
        .optimize = optimize,
    });
    bench.root_module.addImport("zqueue", module);

    const run_exe = b.addRunArtifact(bench);

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
