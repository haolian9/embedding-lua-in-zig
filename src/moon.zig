const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

const h = @cImport({
    @cInclude("lua.h");
    @cInclude("lualib.h");
    @cInclude("lauxlib.h");
});

fn mul(L: ?*h.lua_State) callconv(.C) c_int {
    const a = h.luaL_checkinteger(L, 1);
    const b = h.luaL_checkinteger(L, 2);
    const c = a * b;
    h.lua_pushinteger(L, c);
    return 1;
}

const mymod = [_]h.luaL_Reg{
    .{ .name = "mul", .func = mul },
    .{ .name = "mul2", .func = mul },
    .{ .name = "mul3", .func = mul },
    .{ .name = 0, .func = null },
};

pub fn main() void {
    var L = h.luaL_newstate();
    defer h.lua_close(L);

    h.luaL_openlibs(L);

    print("mymode={any}, ptr={any}\n", .{ mymod, &mymod });
    h.luaL_register(L, "my", &mymod);

    {
        const erred = h.luaL_dostring(L, "print(2, my.mul2(7, 8))");
        // const erred = h.luaL_dostring(L, "print(2)");
        print("dostring-erred={any}\n", .{erred});
        if (!erred) h.lua_pop(L, h.lua_gettop(L));
    }
}

export fn luaopen_out_lib_libmoon(L: ?*h.lua_State) c_int {
    h.luaL_register(L, "moon", &mymod);
    return 1;
}
