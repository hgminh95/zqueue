const std = @import("std");
const Atomic = std.atomic.Value;


pub fn Queue(comptime T: type, len: comptime_int) type {
    return struct {
        const cache_line = std.atomic.cache_line;

        elems: [len]T = undefined,

        writer_idx: Atomic(u32) align(cache_line) = .{ .raw = 0 },
        reader_idx: Atomic(u32) align(cache_line) = .{ .raw = 0 },

        const Self = @This();

        pub fn push(self: *Self, value: T) bool {
            const writer_idx = self.writer_idx.load(.monotonic);
            const reader_idx = self.reader_idx.load(.monotonic);
            if (writer_idx != (reader_idx + len - 1) % len) {
                self.elems[writer_idx] = value;
                self.writer_idx.store((writer_idx + 1) % len, .release);
                return true;
            }
            return false;
        }

        pub fn pop(self: *Self) ?T {
            const writer_idx = self.writer_idx.load(.monotonic);
            const reader_idx = self.reader_idx.load(.monotonic);
            if (writer_idx != reader_idx) {
                self.reader_idx.store((reader_idx + 1) % len, .release);
                return self.elems[reader_idx];
            } else {
                return null;
            }
        }
    };
}

test "simple pushing and poping" {
    var q = Queue(u8, 32){};
    try std.testing.expect(q.push(5));
    try std.testing.expect(q.push(8));
    try std.testing.expect(q.pop() == 5);
    try std.testing.expect(q.pop() == 8);
}
