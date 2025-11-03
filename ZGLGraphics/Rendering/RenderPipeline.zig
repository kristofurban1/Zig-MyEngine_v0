const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const ZGL = @import("../ZGL.zig");
const ShaderProgram = ZGL.Shaders.ShaderProgram;
const VertexArray = ZGL.VertexData.VertexArray;

pub const RenderObject = struct {
    shader: ShaderProgram,
    vertexArray: VertexArray,
};

pub const RenderPipeline = struct {
    objects: ArrayList(RenderObject) = undefined,

    pub fn init() @This() {}
};
