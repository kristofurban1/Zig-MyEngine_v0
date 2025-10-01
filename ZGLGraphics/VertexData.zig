const std = @import("std");
const ZGL = @import("ZGL.zig");

const _g = @import("_glfw_glad_.zig").import;
const Reporter = ZGL.Reporter;
const NamedTypeCode = ZGL.NamedTypeCode;

const DrawUsageTypes = enum { STATIC_DRAW, DYNAMIC_DRAW, STREAM_DRAW };
const DrawUsages = NamedTypeCode.CreateNamedTypeCodeStore(DrawUsageTypes)
    .chain(.{ .identifyer = .STATIC_DRAW, .code = _g.GL_STATIC_DRAW, .name = "STATIC_DRAW" })
    .chain(.{ .identifyer = .DYNAMIC_DRAW, .code = _g.GL_DYNAMIC_DRAW, .name = "DYNAMIC_DRAW" })
    .chain(.{ .identifyer = .STREAM_DRAW, .code = _g.GL_STREAM_DRAW, .name = "STREAM_DRAW" });

pub const VertexArray = struct {
    VBO: u32, // Vertex Buffer Object   ; Stores raw data
    VAO: u32, // Vertex Array Object    ; Describes stored data
};
