pub const import = @cImport({
    @cDefine("GLAD_GL_IMPLEMENTATION", "1");
    @cInclude("glad/gl.h");
    @cDefine("GLFW_INCLUDE_NONE", "1");
    @cInclude("glfw3.h");
});
