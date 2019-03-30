/*
# Copyright 2019 BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
*/

#include "DMRLookup.hpp"
#include <assert.h>

using namespace std;

#ifdef __cplusplus
  #include "lua.hpp"
#else
  #include "lua.h"
  #include "lualib.h"
  #include "lauxlib.h"
#endif

static CDMRLookup* m_lookup = NULL;

std::string findByCallsign(std::string callsign) {
    assert(m_lookup != NULL);
    return m_lookup->findByCallsign(callsign).c_str();
}

void load(std::string dmrid_file) {
    if(m_lookup == NULL) {
        m_lookup = new CDMRLookup(dmrid_file);
        m_lookup->read();
    }
}

// int main()
// {
//     cout << findByCallsign("BD7MQB") << endl;
//     return 0;
// }

//so that name mangling doesn't mess up function names
#ifdef __cplusplus
extern "C"{
#endif

static int init (lua_State *L) {
    const char *dmrid_file;
    dmrid_file = luaL_checkstring(L, 1);
    load(std::string(dmrid_file));

    return 0;
}

static int get_dmrid_by_callsign (lua_State *L) {
    const char *callsign;
    callsign = luaL_checkstring(L, 1);
    lua_pushstring(L, findByCallsign(std::string(callsign)).c_str());

    return 1;
}

//library to be registered
static const struct luaL_Reg mylib [] = {
        {"get_dmrid_by_callsign", get_dmrid_by_callsign},
        {"init", init},
        {NULL, NULL}  /* sentinel */
};

int luaopen_mmdvm(lua_State *L) {
#ifdef OPENWRT
    // Lua 5.1 style
    luaL_register(L, "mmdvm", mylib);
#else
    // Lua 5.3 style
    luaL_newlib(L, mylib);
#endif
	return 1;
}

#ifdef __cplusplus
}
#endif
