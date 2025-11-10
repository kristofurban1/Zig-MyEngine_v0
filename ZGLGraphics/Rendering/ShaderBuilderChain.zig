const Shader = @import("Shaders.zig").Shader;
const ShaderUniform = @import("ShaderUniforms.zig").ShaderUniform;
const ObjectChain = @import("../Utils/ObjectChain.zig");

pub const ShaderUniformUnion = union(enum) { shader: Shader, uniform: ShaderUniform };

pub fn ShaderBuilderChain(comptime LENGTH: u32) type {
    return struct {
        pub const ObjectChainType = ObjectChain.ObjChain(ShaderUniformUnion, LENGTH);
        objectChain: ObjectChainType,

        pub fn chain(self: @This(), object: anytype) ShaderBuilderChain(LENGTH + 1) {
            if (@TypeOf(object) == Shader) {
                return .{
                    .objectChain = self.objectChain.chain(ShaderUniformUnion{ .shader = object }),
                };
            } else if (@TypeOf(object) == ShaderUniform) {
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
    if (!@hasDecl(chain_type, "ObjectChainType")) {
        @compileError("ShaderBuilderChain :: Given type is not ShaderBuilderChain Chain!");
    }
    if (!@hasDecl(chain_type.ObjectChainType, "__signature__object_chain__")) {
        @compileError("OBJECT_CHAIN :: Given type is not Object Chain!");
    }

    const T = chain_type.ObjectChainType.T;
    if (T != ShaderUniformUnion) @compileError("ShaderBuilderChain :: Given ObjectChain's type is not ShaderUniformUnion!");
    return chain_type.ObjectChainType.LENGTH;
}
