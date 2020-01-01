#ifndef __ZED_H_
#define __ZED_H_

#if __cplusplus
extern "C" {
#endif

#include "lua.h"
#include <lauxlib.h>
#include <lualib.h>
LUALIB_API int luaopen_zed(lua_State *L);

#if __cplusplus
}
#endif

#endif