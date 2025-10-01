const ObjectChain = @import("ObjectChain.zig");

pub fn NamedTypeCodeStore(comptime T: type, comptime LENGTH: u32) type {
    return struct {
        pub const NamedTypeCode = struct {
            identifyer: T,
            code: u32,
            name: []const u8,
        };

        objectChain: ObjectChain.ObjChain(NamedTypeCode, LENGTH),

        pub fn chain(self: @This(), named_type_code: NamedTypeCode) NamedTypeCodeStore(T, LENGTH + 1) {
            return .{
                .objectChain = self.objectChain.chain(named_type_code),
            };
        }

        pub fn get(self: @This(), identifyer: T) ?NamedTypeCode {
            var object_chain = self.objectChain;
            object_chain.reset();
            while (object_chain.next_obj()) |obj| {
                if (obj.identifyer == identifyer) return obj;
            }
            return null;
        }
    };
}

pub fn CreateNamedTypeCodeStore(comptime T: type) NamedTypeCodeStore(T, 0) {
    return .{
        .objectChain = ObjectChain.CreateChain(NamedTypeCodeStore(T, 0).NamedTypeCode),
    };
}
