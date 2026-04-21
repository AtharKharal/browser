const std = @import("std");
const lp = @import("lightpanda");

const protocol = @import("protocol.zig");
const Server = @import("Server.zig");

pub fn processRequests(server: *Server, reader: *std.io.Reader) !void {
    var arena: std.heap.ArenaAllocator = .init(server.allocator);
    defer arena.deinit();

    while (true) {
        _ = arena.reset(.retain_capacity);
        const aa = arena.allocator();

        const buffered_line = reader.takeDelimiter('\n') catch |err| switch (err) {
            error.StreamTooLong => {
                lp.log.err(.lsp, "Message too long", .{});
                try server.sendError(.null, .InvalidRequest, "Message too long");
                continue;
            },
            else => return err,
        } orelse break;

        const trimmed = std.mem.trim(u8, buffered_line, " \r\t");
        if (trimmed.len > 0) {
            handleMessage(server, aa, trimmed) catch |err| {
                log.err(.lsp, "Failed to handle message", .{ .err = err, .msg = trimmed });
            };
        }
    }
}

const log = lp.log;

const Method = enum {
    initialize,
    shutdown,
    @"exit",
    @"textDocument/didOpen",
    @"textDocument/didChange",
    @"textDocument/completion",
    @"completion/resolve",
    @"textDocument/hover",
    @"textDocument/definition",
    @"textDocument/references",
    @"textDocument/documentSymbol",
    @"workspace/symbol",
    @"workspace/executeCommand",
};

const method_map = std.StaticStringMap(Method).initComptime(.{
    .{ "initialize", .initialize },
    .{ "shutdown", .shutdown },
    .{ "exit", .@"exit" },
    .{ "textDocument/didOpen", .@"textDocument/didOpen" },
    .{ "textDocument/didChange", .@"textDocument/didChange" },
    .{ "textDocument/completion", .@"textDocument/completion" },
    .{ "completion/resolve", .@"completion/resolve" },
    .{ "textDocument/hover", .@"textDocument/hover" },
    .{ "textDocument/definition", .@"textDocument/definition" },
    .{ "textDocument/references", .@"textDocument/references" },
    .{ "textDocument/documentSymbol", .@"textDocument/documentSymbol" },
    .{ "workspace/symbol", .@"workspace/symbol" },
    .{ "workspace/executeCommand", .@"workspace/executeCommand" },
});

pub fn handleMessage(server: *Server, arena: std.mem.Allocator, msg: []const u8) !void {
    const req = std.json.parseFromSliceLeaky(protocol.Request, arena, msg, .{
        .ignore_unknown_fields = true,
    }) catch |err| {
        log.warn(.lsp, "JSON Parse Error", .{ .err = err, .msg = msg });
        try server.sendError(.null, .ParseError, "Parse error");
        return;
    };

    const method = method_map.get(req.method) orelse {
        if (req.id != null) {
            try server.sendError(req.id.?, .MethodNotFound, "Method not found");
        }
        return;
    };

    switch (method) {
        .initialize => try handleInitialize(server, req),
        .shutdown => try handleShutdown(server, req),
        .@"exit" => try handleExit(server, req),
        .@"textDocument/completion" => try handleCompletion(server, arena, req),
        .@"textDocument/hover" => try handleHover(server, arena, req),
        .@"textDocument/definition" => try handleDefinition(server, req),
        .@"textDocument/references" => try handleReferences(server, req),
        .@"textDocument/documentSymbol" => try handleDocumentSymbol(server, req),
        .@"workspace/symbol" => try handleWorkspaceSymbol(server, arena, req),
        .@"textDocument/didOpen",
        .@"textDocument/didChange",
        .@"completion/resolve",
        .@"workspace/executeCommand",
        => {},
    }
}

fn handleInitialize(server: *Server, req: protocol.Request) !void {
    const id = req.id orelse return;

    const result: protocol.InitializeResult = .{
        .capabilities = .{
            .completionProvider = .{
                .resolveProvider = true,
                .triggerCharacters = &.{ &.{ "a", "b", "c" } },
            },
            .hoverProvider = true,
            .definitionProvider = true,
            .referencesProvider = true,
            .documentSymbolProvider = true,
            .workspaceSymbolProvider = true,
        },
        .serverInfo = .{
            .name = "lightpanda",
            .version = "0.1.0",
        },
    };

    server.initialized = true;
    try server.sendResult(id, result);
}

fn handleShutdown(server: *Server, req: protocol.Request) !void {
    const id = req.id orelse return;
    try server.sendResult(id, .{});
}

fn handleExit(server: *Server, req: protocol.Request) !void {
    _ = server;
    _ = req;
}

fn handleCompletion(server: *Server, arena: std.mem.Allocator, req: protocol.Request) !void {
    const id = req.id orelse return;

    const completion_items = getCompletionItems(arena);

    const result: protocol.CompletionList = .{
        .isIncomplete = false,
        .items = completion_items,
    };

    try server.sendResult(id, result);
}

fn handleHover(server: *Server, arena: std.mem.Allocator, req: protocol.Request) !void {
    const id = req.id orelse return;

    const result: protocol.Hover = .{
        .contents = .{ .string = "Lightpanda - The headless browser for AI agents" },
    };

    try server.sendResult(id, result);
}

fn handleDefinition(server: *Server, req: protocol.Request) !void {
    const id = req.id orelse return;
    try server.sendResult(id, .{ .value = null });
}

fn handleReferences(server: *Server, req: protocol.Request) !void {
    const id = req.id orelse return;
    try server.sendResult(id, &.{});
}

fn handleDocumentSymbol(server: *Server, req: protocol.Request) !void {
    const id = req.id orelse return;
    try server.sendResult(id, &.{});
}

fn handleWorkspaceSymbol(server: *Server, arena: std.mem.Allocator, req: protocol.Request) !void {
    const id = req.id orelse return;

    const mcp_tools = getMcpToolSymbols(arena);
    const cdp_domains = getCdpDomainSymbols(arena);

    var symbols: []const protocol.SymbolInformation = &.{};
    symbols = try std.mem.concat(arena, protocol.SymbolInformation, &.{ symbols, mcp_tools });
    symbols = try std.mem.concat(arena, protocol.SymbolInformation, &.{ symbols, cdp_domains });

    try server.sendResult(id, symbols);
}

fn getCompletionItems(arena: std.mem.Allocator) ![]const protocol.CompletionItem {
    const mcp_tools = comptime getMcpToolCompletions();
    const cdp_methods = comptime getCdpMethodCompletions();

    var items: []const protocol.CompletionItem = &.{};
    for (mcp_tools) |tool| {
        items = try std.mem.concat(arena, protocol.CompletionItem, &.{ items, &.{tool} });
    }
    for (cdp_methods) |method| {
        items = try std.mem.concat(arena, protocol.CompletionItem, &.{ items, &.{method} });
    }
    return items;
}

fn getMcpToolSymbols(arena: std.mem.Allocator) ![]const protocol.SymbolInformation {
    _ = arena;
    const tools = comptime getMcpToolCompletions();
    var symbols: []const protocol.SymbolInformation = &.{};
    for (tools) |tool| {
        symbols = try std.mem.concat(arena, protocol.SymbolInformation, &.{ symbols, &.{
            .{
                .name = "mcp." ++ tool.label,
                .kind = 1,
                .location = .{
                    .uri = "lightpanda://mcp/tools",
                    .range = .{ .start = .{ .line = 0, .character = 0 }, .end = .{ .line = 0, .character = 0 } },
                },
            },
        }});
    }
    return symbols;
}

fn getCdpDomainSymbols(arena: std.mem.Allocator) ![]const protocol.SymbolInformation {
    _ = arena;
    const domains = comptime getCdpDomainCompletions();
    var symbols: []const protocol.SymbolInformation = &.{};
    for (domains) |domain| {
        symbols = try std.mem.concat(arena, protocol.SymbolInformation, &.{ symbols, &.{
            .{
                .name = "cdp." ++ domain.label,
                .kind = 3,
                .location = .{
                    .uri = "lightpanda://cdp/domains",
                    .range = .{ .start = .{ .line = 0, .character = 0 }, .end = .{ .line = 0, .character = 0 } },
                },
            },
        }});
    }
    return symbols;
}

fn getMcpToolCompletions() []const protocol.CompletionItem {
    return &.{
        .{ .label = "goto", .kind = 2, .detail = "Navigate to URL", .documentation = "Navigate to a specified URL and load the page in memory." },
        .{ .label = "navigate", .kind = 2, .detail = "Navigate to URL", .documentation = "Alias for goto. Navigate to a specified URL and load the page in memory." },
        .{ .label = "markdown", .kind = 2, .detail = "Get page as markdown", .documentation = "Get the page content in markdown format." },
        .{ .label = "links", .kind = 2, .detail = "Extract all links", .documentation = "Extract all links in the opened page." },
        .{ .label = "evaluate", .kind = 2, .detail = "Evaluate JavaScript", .documentation = "Evaluate JavaScript in the current page context." },
        .{ .label = "eval", .kind = 2, .detail = "Evaluate JavaScript", .documentation = "Alias for evaluate. Evaluate JavaScript in the current page context." },
        .{ .label = "semantic_tree", .kind = 2, .detail = "Get semantic DOM tree", .documentation = "Get the page content as a simplified semantic DOM tree for AI reasoning." },
        .{ .label = "nodeDetails", .kind = 2, .detail = "Get node details", .documentation = "Get detailed information about a specific node by its backend node ID." },
        .{ .label = "interactiveElements", .kind = 2, .detail = "Extract interactive elements", .documentation = "Extract interactive elements from the opened page." },
        .{ .label = "structuredData", .kind = 2, .detail = "Extract structured data", .documentation = "Extract structured data (like JSON-LD, OpenGraph, etc) from the opened page." },
        .{ .label = "detectForms", .kind = 2, .detail = "Detect all forms", .documentation = "Detect all forms on the page and return their structure." },
        .{ .label = "click", .kind = 2, .detail = "Click element", .documentation = "Click on an interactive element." },
        .{ .label = "fill", .kind = 2, .detail = "Fill input element", .documentation = "Fill text into an input element." },
        .{ .label = "scroll", .kind = 2, .detail = "Scroll page or element", .documentation = "Scroll the page or a specific element." },
        .{ .label = "waitForSelector", .kind = 2, .detail = "Wait for element", .documentation = "Wait for an element matching a CSS selector to appear." },
        .{ .label = "hover", .kind = 2, .detail = "Hover over element", .documentation = "Hover over an element, triggering mouseover events." },
        .{ .label = "press", .kind = 2, .detail = "Press keyboard key", .documentation = "Press a keyboard key, dispatching keydown and keyup events." },
        .{ .label = "selectOption", .kind = 2, .detail = "Select dropdown option", .documentation = "Select an option in a <select> dropdown element." },
        .{ .label = "setChecked", .kind = 2, .detail = "Check/uncheck checkbox", .documentation = "Check or uncheck a checkbox or radio button." },
        .{ .label = "findElement", .kind = 2, .detail = "Find element by role/name", .documentation = "Find interactive elements by role and/or accessible name." },
    };
}

fn getCdpMethodCompletions() []const protocol.CompletionItem {
    return &.{
        .{ .label = "Page.navigate", .kind = 2, .detail = "Navigate to URL", .documentation = "Navigate the page to the given URL." },
        .{ .label = "Page.captureScreenshot", .kind = 2, .detail = "Capture screenshot", .documentation = "Captures a screenshot of the page." },
        .{ .label = "Runtime.evaluate", .kind = 2, .detail = "Evaluate JavaScript", .documentation = "Evaluates JavaScript expression in the page context." },
        .{ .label = "DOM.getDocument", .kind = 2, .detail = "Get DOM document", .documentation = "Returns the DOM document node." },
        .{ .label = "DOM.querySelector", .kind = 2, .detail = "Query DOM selector", .documentation = "Executes querySelector in the page context." },
        .{ .label = "Network.requestWillBeSent", .kind = 2, .detail = "Network request", .documentation = "Fired when a network request is about to be sent." },
        .{ .label = "Network.responseReceived", .kind = 2, .detail = "Network response", .documentation = "Fired when a network response was received." },
        .{ .label = "Target.createTarget", .kind = 2, .detail = "Create target", .documentation = "Creates a new target." },
        .{ .label = "Input.dispatchMouseEvent", .kind = 2, .detail = "Dispatch mouse event", .documentation = "Dispatches a mouse event to the page." },
        .{ .label = "Emulation.setDeviceMetricsOverride", .kind = 2, .detail = "Set device metrics", .documentation = "Overrides device metrics." },
    };
}

fn getCdpDomainCompletions() []const protocol.CompletionItem {
    return &.{
        .{ .label = "Page", .kind = 3, .detail = "Page domain", .documentation = "Page manipulation and interaction." },
        .{ .label = "Runtime", .kind = 3, .detail = "Runtime domain", .documentation = "JavaScript runtime inspection." },
        .{ .label = "DOM", .kind = 3, .detail = "DOM domain", .documentation = "Document Object Model inspection." },
        .{ .label = "Network", .kind = 3, .detail = "Network domain", .documentation = "Network request tracking." },
        .{ .label = "Target", .kind = 3, .detail = "Target domain", .documentation = "Target management." },
        .{ .label = "Input", .kind = 3, .detail = "Input domain", .documentation = "Input simulation." },
        .{ .label = "Emulation", .kind = 3, .detail = "Emulation domain", .documentation = "Device emulation." },
        .{ .label = "Fetch", .kind = 3, .detail = "Fetch domain", .documentation = "Network request interception." },
        .{ .label = "Storage", .kind = 3, .detail = "Storage domain", .documentation = "Browser storage management." },
        .{ .label = "Security", .kind = 3, .detail = "Security domain", .documentation = "Security state inspection." },
        .{ .label = "Log", .kind = 3, .detail = "Log domain", .documentation = "Console log access." },
        .{ .label = "Inspector", .kind = 3, .detail = "Inspector domain", .documentation = "Inspector protocol." },
        .{ .label = "Accessibility", .kind = 3, .detail = "Accessibility domain", .documentation = "Accessibility inspection." },
        .{ .label = "CSS", .kind = 3, .detail = "CSS domain", .documentation = "CSS inspection and modification." },
        .{ .label = "Performance", .kind = 3, .detail = "Performance domain", .documentation = "Performance metrics." },
    };
}

const testing = @import("../testing.zig");

test "LSP.router - initialize" {
    defer testing.reset();
    const allocator = testing.allocator;
    const app = testing.test_app;

    var out_alloc: std.io.Writer.Allocating = .init(testing.arena_allocator);
    defer out_alloc.deinit();

    var server = try Server.init(allocator, app, &out_alloc.writer);
    defer server.deinit();

    try handleMessage(server, testing.arena_allocator,
        \\{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}}
    );

    try testing.expectJson(
        \\{ "jsonrpc": "2.0", "id": 1, "result": { "capabilities": { "hoverProvider": true } } }
    , out_alloc.writer.buffered());
}

test "LSP.router - completion" {
    defer testing.reset();
    const allocator = testing.allocator;
    const app = testing.test_app;

    var out_alloc: std.io.Writer.Allocating = .init(testing.arena_allocator);
    defer out_alloc.deinit();

    var server = try Server.init(allocator, app, &out_alloc.writer);
    defer server.deinit();

    try handleMessage(server, testing.arena_allocator,
        \\{"jsonrpc":"2.0","id":2,"method":"textDocument/completion","params":{}}
    );

    try testing.expect(std.mem.indexOf(u8, out_alloc.writer.buffered(), "goto") != null);
}