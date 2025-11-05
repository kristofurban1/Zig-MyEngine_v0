const Shader = @import("Shaders.zig").Shader;
const ShaderUniformInterface = @import("ShaderUniforms.zig").ShaderUniformInterface;
const ObjectChain = @import("../Utils/ObjectChain.zig");

pub const ShaderUniformUnion = union(enum) { shader: Shader, uniform: ShaderUniformInterface };

pub fn ShaderBuilderChain(comptime LENGTH: u32) type {
    return struct {
        objectChain: ObjectChain.ObjChain(ShaderUniformUnion, LENGTH),

        pub fn chain(self: @This(), object: anytype) ShaderBuilderChain(ShaderUniformUnion, LENGTH + 1) {
            if (@TypeOf(object) == Shader) {
                return .{
                    .objectChain = self.objectChain.chain(ShaderUniformUnion{ .shader = object }),
                };
            } else if (@TypeOf(object) == ShaderUniformInterface) {
                return .{
                    .objectChain = self.objectChain.chain(ShaderUniformUnion{ .uniform = object }),
                };
            } else @compileError("ShaderBuilderChain :: Invalid type given to .chain");
        }

        pub fn reset(self: *@This()) void {
            self.*.objectChain.reset();
        }

        pub fn next(self: *@This()) ?usize {
            return self.*.objectChain.next();
        }

        pub fn next_obj(self: *@This()) ?ShaderUniformUnion {
            return self.*.objectChain.next_obj();
        }
        pub fn next_ref(self: *@This()) ?*ShaderUniformUnion {
            return self.*.objectChain.next_ref();
        }
    };
}

pub fn CreateShaderBuilderChain() ShaderBuilderChain(0) {
    return .{
        .objectChain = ObjectChain.CreateChain(ShaderUniformUnion),
    };
}

pub fn EnforceShaderBuilderChain(comptime chain_type: type) comptime_int {
    if (!@hasDecl(chain_type, "objectChain")) {
        @compileError("ShaderBuilderChain :: Given type is not ShaderBuilderChain Chain!");
    }
    if (!@hasDecl(chain_type.objectChain, "__signature__object_chain__")) {
        @compileError("OBJECT_CHAIN :: Given type is not Object Chain!");
    }

    const T = chain_type.objectChain.T;
    if (ShaderUniformUnion) |_type| {
        if (T != _type) @compileError("ShaderBuilderChain :: Given ObjectChain's type is not the requested type!");
    }
    return chain_type.objectChain.LENGTH;
}
