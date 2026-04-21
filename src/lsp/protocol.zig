const std = @import("std");

pub const JSONRPC_VERSION = "2.0";

pub const Request = struct {
    jsonrpc: []const u8 = JSONRPC_VERSION,
    id: ?std.json.Value = null,
    method: []const u8,
    params: ?std.json.Value = null,
};

pub const Response = struct {
    jsonrpc: []const u8 = JSONRPC_VERSION,
    id: std.json.Value,
    result: ?std.json.Value = null,
    @"error": ?Error = null,
};

pub const Error = struct {
    code: i64,
    message: []const u8,
    data: ?std.json.Value = null,
};

pub const ErrorCode = enum(i64) {
    ParseError = -32700,
    InvalidRequest = -32600,
    MethodNotFound = -32601,
    InvalidParams = -32602,
    InternalError = -32603,
    ServerNotInitialized = -32002,
};

pub const Notification = struct {
    jsonrpc: []const u8 = JSONRPC_VERSION,
    method: []const u8,
    params: ?std.json.Value = null,
};

pub const InitializeParams = struct {
    processId: ?i64 = null,
    rootUri: ?[]const u8 = null,
    rootPath: ?[]const u8 = null,
    capabilities: ClientCapabilities,
    workspaceFolders: ?[]WorkspaceFolder = null,
};

pub const ClientCapabilities = struct {
    textDocument: ?TextDocumentClientCapabilities = null,
    workspace: ?WorkspaceClientCapabilities = null,
};

pub const TextDocumentClientCapabilities = struct {
    completion: ?CompletionCapabilities = null,
    hover: ?HoverCapabilities = null,
    definition: ?DefinitionCapabilities = null,
    references: ?ReferencesCapabilities = null,
    documentSymbol: ?DocumentSymbolCapabilities = null,
};

pub const WorkspaceClientCapabilities = struct {
    workspaceFolders: ?bool = null,
    applyEdit: ?bool = null,
};

pub const CompletionCapabilities = struct {
    dynamicRegistration: ?bool = null,
    completionItem: ?CompletionItemCapabilities = null,
};

pub const HoverCapabilities = struct {
    dynamicRegistration: ?bool = null,
};

pub const DefinitionCapabilities = struct {
    dynamicRegistration: ?bool = null,
};

pub const ReferencesCapabilities = struct {
    dynamicRegistration: ?bool = null,
};

pub const DocumentSymbolCapabilities = struct {
    dynamicRegistration: ?bool = null,
};

pub const CompletionItemCapabilities = struct {
    snippetSupport: ?bool = null,
    documentationFormat: ?[][]const u8 = null,
};

pub const ServerCapabilities = struct {
    textDocumentSync: ?TextDocumentSyncOptions = null,
    completionProvider: ?CompletionOptions = null,
    hoverProvider: ?bool = null,
    definitionProvider: ?bool = null,
    referencesProvider: ?bool = null,
    documentSymbolProvider: ?bool = null,
    workspaceSymbolProvider: ?bool = null,
};

pub const TextDocumentSyncOptions = struct {
    openClose: ?bool = null,
    change: ?i64 = null,
};

pub const CompletionOptions = struct {
    resolveProvider: ?bool = null,
    triggerCharacters: ?[][]const u8 = null,
};

pub const WorkspaceFolder = struct {
    uri: []const u8,
    name: []const u8,
};

pub const InitializeResult = struct {
    capabilities: ServerCapabilities,
    serverInfo: ServerInfo,
};

pub const ServerInfo = struct {
    name: []const u8,
    version: []const u8,
};

pub const TextDocumentPositionParams = struct {
    textDocument: TextDocumentIdentifier,
    position: Position,
};

pub const TextDocumentIdentifier = struct {
    uri: []const u8,
};

pub const Position = struct {
    line: i64,
    character: i64,
};

pub const Range = struct {
    start: Position,
    end: Position,
};

pub const Location = struct {
    uri: []const u8,
    range: Range,
};

pub const CompletionItem = struct {
    label: []const u8,
    kind: ?i64 = null,
    detail: ?[]const u8 = null,
    documentation: ?[]const u8 = null,
    insertText: ?[]const u8 = null,
    insertTextFormat: ?i64 = null,
};

pub const CompletionList = struct {
    isIncomplete: bool,
    items: []const CompletionItem,
};

pub const Hover = struct {
    contents: HoverContents,
    range: ?Range = null,
};

pub const HoverContents = union(enum) {
    string: []const u8,
    markedStrings: []const MarkedString,
    markupContent: MarkupContent,
};

pub const MarkedString = struct {
    language: []const u8,
    value: []const u8,
};

pub const MarkupContent = struct {
    kind: []const u8,
    value: []const u8,
};

pub const DocumentSymbol = struct {
    name: []const u8,
    kind: i64,
    range: Range,
    children: ?[]const DocumentSymbol = null,
};

pub const SymbolInformation = struct {
    name: []const u8,
    kind: i64,
    location: Location,
};

pub const WorkspaceSymbolParams = struct {
    query: []const u8,
};

const testing = @import("../testing.zig");

test "LSP.protocol - request parsing" {
    defer testing.reset();
    const raw_json =
        \\{
        \\  "jsonrpc": "2.0",
        \\  "id": 1,
        \\  "method": "initialize",
        \\  "params": {
        \\    "processId": 1234,
        \\    "capabilities": {}
        \\  }
        \\}
    ;

    const parsed = try std.json.parseFromSlice(Request, testing.arena_allocator, raw_json, .{ .ignore_unknown_fields = true });
    defer parsed.deinit();

    const req = parsed.value;
    try testing.expectString("2.0", req.jsonrpc);
    try testing.expectString("initialize", req.method);
    try testing.expect(req.id.? == .integer);
    try testing.expectEqual(@as(i64, 1), req.id.?.integer);
    try testing.expect(req.params != null);
}
