pub fn ObjChain(comptime T: type, comptime LENGTH: u32) type {
    return struct {
        pub const __signature__object_chain__ = true;
        current: usize = 0,
        array: [LENGTH]T,

        pub fn chain(self: @This(), obj: T) ObjChain(T, LENGTH + 1) {
            var array: [LENGTH + 1]T = undefined;
            for (0..self.array.len) |i| {
                array[i] = self.array[i];
            }
            array[LENGTH] = obj;
            return .{
                .current = 0,
                .array = array,
            };
        }

        pub fn reset(self: *@This()) void {
            self.*.current = 0;
        }

        pub fn next(self: *@This()) ?usize {
            if (self.*.current == LENGTH) return null;
            defer self.*.current += 1;
            return self.*.current;
        }

        pub fn next_obj(self: *@This()) ?T {
            const next_idx = next(self);
            if (next_idx) |idx| {
                return self.*.array[idx];
            }
            return null;
        }
        pub fn next_ref(self: *@This()) ?*T {
            const next_idx = next(self);
            if (next_idx) |idx| {
                return &(self.*.array[idx]);
            }
            return null;
        }
    };
}

pub fn CreateChain(comptime T: type) ObjChain(T, 0) {
    return .{
        .current = 0,
        .array = undefined,
    };
}

pub fn ResolveObjectChain(comptime obj_chain: anytype, _T: ?type) type {
    const ObjectChain = @TypeOf(obj_chain);
    if (!@hasDecl(ObjectChain, "__signature__object_chain__")) {
        @compileError("OBJECT_CHAIN :: Given type is not Object Chain!");
    }

    const T = ObjectChain.T;
    if (_T) |_type| {
        if (T != _type) @compileError("OBJECT_CHAIN :: Given ObjectChain's type is not the requested type!");
    }
    const LENGTH = ObjectChain.LENGTH;
    return ObjChain(if (_T) _T.? else T, LENGTH);
}
