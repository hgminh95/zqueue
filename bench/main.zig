const std = @import("std");
const zbench = @import("zbench");
const zqueue = @import("zqueue");

fn benchSpsc(_: std.mem.Allocator) void {
    var queue = zqueue.Spsc.Queue(u32, 128){};
    for (0..1000) |_| {
        _ = queue.push(100);
        _ = queue.pop();
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.add("SPSC", benchSpsc, .{});

    try stdout.writeAll("\n");
    try bench.run(stdout);
}
