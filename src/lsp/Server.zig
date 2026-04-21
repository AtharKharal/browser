const std = @import("std");
const lp = @import("lightpanda");

const protocol = @import("protocol.zig");
const router = @import("router.zig");
const CDPNode = lp.CDPNode;

const Self = @This();

allocator: std.mem.Allocator,
app: *App,
node_registry: CDPNode.Registry,

initialized: bool = false,
writer: *std.io.Writer,
mutex: std.Thread.Mutex = .{},
aw: std.io.Writer.Allocating,

pub fn init(allocator: std.mem.Allocator, app: *App, writer: *std.io.Writer) !*Self {
    const self = try allocator.create(Self);
    errdefer allocator.destroy(self);

    self.* = .{
        .allocator = allocator,
        .app = app,
        .writer = writer,
        .node_registry = CDPNode.Registry.init(allocator),
    };

    return self;
}

pub fn deinit(self: *Self) void {
    self.node_registry.deinit();
    self.aw.deinit();
    self.allocator.destroy(self);
}

pub fn sendResponse(self: *Self, response: anytype) !void {
    self.mutex.lock();
    defer self.mutex.unlock();

    self.aw.clearRetainingCapacity();
    try std.json.Stringify.value(response, .{ .emit_null_optional_fields = false }, &self.aw.writer);
    try self.aw.writer.writeByte('\n');
    try self.writer.writeAll(self.aw.writer.buffered());
    try self.writer.flush();
}

pub fn sendResult(self: *Self, id: std.json.Value, result: anytype) !void {
    const GenericResponse = struct {
        jsonrpc: []const u8 = "2.0",
        id: std.json.Value,
        result: @TypeOf(result),
    };
    try self.sendResponse(GenericResponse{
        .id = id,
        .result = result,
    });
}

pub fn sendError(self: *Self, id: std.json.Value, code: protocol.ErrorCode, message: []const u8) !void {
    try self.sendResponse(protocol.Response{
        .id = id,
        .@"error" = protocol.Error{
            .code = @intFromEnum(code),
            .message = message,
        },
    });
}

pub fn sendNotification(self: *Self, method: []const u8, params: anytype) !void {
    const GenericNotification = struct {
        jsonrpc: []const u8 = "2.0",
        method: []const u8,
        params: @TypeOf(params),
    };
    try self.sendResponse(GenericNotification{
        .method = method,
        .params = params,
    });
}
