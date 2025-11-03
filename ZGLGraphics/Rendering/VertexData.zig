/// Create Buffer, Bind Buffer
/// Create Vertex Array, Bind Vertex Array
/// Specify Draw type and array length, insert data. Needs both objects.
/// AttribPointers:
///     - Create pointer: glVertexAttribPointer
///         Index,
///         size: components per vertex, [1,4]
///         Type(GL_FLOAT, GL_SHORT etc),
///         Normalized: if integer, puts it in a [0 - 1] (-1 - 1 for signed) range, where 1 represents INT_MAX
///         Stride: Byte offset from one vertex's data to the next ones data
///         Pointer: points to the first component.
///     - Enable Pointer: glEnableVertexAttribArray(index)
const std = @import("std");
const ZGL = @import("../ZGL.zig");

const _g = ZGL.OPENGL;
const Reporter = ZGL.Reporter;
const NamedTypeCode = ZGL.NamedTypeCode;

const DrawUsageTypes = enum { STATIC_DRAW, DYNAMIC_DRAW, STREAM_DRAW };
const DrawUsages = NamedTypeCode.CreateNamedTypeCodeStore(DrawUsageTypes)
    .chain(.{ .identifyer = .STATIC_DRAW, .code = _g.GL_STATIC_DRAW, .name = "STATIC_DRAW" })
    .chain(.{ .identifyer = .DYNAMIC_DRAW, .code = _g.GL_DYNAMIC_DRAW, .name = "DYNAMIC_DRAW" })
    .chain(.{ .identifyer = .STREAM_DRAW, .code = _g.GL_STREAM_DRAW, .name = "STREAM_DRAW" });

const DataTypes = enum {
    BYTE,
    UNSIGNED_BYTE,
    SHORT,
    UNSIGNED_SHORT,
    INT,
    UNSIGNED,
    HALF_FLOAT,
    FLOAT,
    DOUBLE,
    FIXED,
    PackedReversed_I2_3xI10, // INT_2_10_10_10_REV
    PackedReversed_U2_3xU10, // UNSIGNED_INT_2_10_10_10_REV
    PackedReversed_F10_2xF11, // UNSIGNED_INT_10F_11F_11F_REV
};
const DataTypeCodes = NamedTypeCode.CreateNamedTypeCodeStore(DataTypes)
    .chain(.{ .identifyer = .BYTE, .code = _g.GL_BYTE, .name = "GL_BYTE" })
    .chain(.{ .identifyer = .UNSIGNED_BYTE, .code = _g.GL_UNSIGNED_BYTE, .name = "GL_UNSIGNED_BYTE" })
    .chain(.{ .identifyer = .SHORT, .code = _g.GL_SHORT, .name = "GL_SHORT" })
    .chain(.{ .identifyer = .UNSIGNED_SHORT, .code = _g.GL_UNSIGNED_SHORT, .name = "GL_UNSIGNED_SHORT" })
    .chain(.{ .identifyer = .INT, .code = _g.GL_INT, .name = "GL_INT" })
    .chain(.{ .identifyer = .UNSIGNED, .code = _g.GL_UNSIGNED, .name = "GL_UNSIGNED" })
    .chain(.{ .identifyer = .HALF_FLOAT, .code = _g.GL_HALF_FLOAT, .name = "GL_HALF_FLOAT" })
    .chain(.{ .identifyer = .FLOAT, .code = _g.GL_FLOAT, .name = "GL_FLOAT" })
    .chain(.{ .identifyer = .DOUBLE, .code = _g.GL_DOUBLE, .name = "GL_DOUBLE" })
    .chain(.{ .identifyer = .FIXED, .code = _g.GL_FIXED, .name = "GL_FIXED" })
    .chain(.{ .identifyer = .PackedReversed_I2_3xI10, .code = _g.GL_INT_2_10_10_10_REV, .name = "PackedReversed_I2_3xI10 (GL_INT_2_10_10_10_REV)" })
    .chain(.{ .identifyer = .PackedReversed_U2_3xU10, .code = _g.GL_UNSIGNED_INT_2_10_10_10_REV, .name = "PackedReversed_U2_3xU10 (GL_UNSIGNED_INT_2_10_10_10_REV)" })
    .chain(.{ .identifyer = .PackedReversed_F10_2xF11, .code = _g.GL_UNSIGNED_INT_10F_11F_11F_REV, .name = "PackedReversed_F10_2xF11 (GL_UNSIGNED_INT_10F_11F_11F_REV)" });

pub const VertexArray = struct {
    VBO: u32, // Vertex Buffer Object   ; Stores raw data
    VAO: u32, // Vertex Array Object    ; Describes stored data
};
