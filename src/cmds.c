/*
 * Copyright (c) 2013 James Deery
 * Released under the MIT license <http://opensource.org/licenses/MIT>.
 * See COPYING for details.
 */

#include "hamilton/lib.h"
#include "hamilton/band.h"
#include "cmds.h"

AlLuaKey bandKey;

static int cmd_get_synths(lua_State *L)
{
	HmBand *band = lua_touserdata(L, lua_upvalueindex(1));
	HmLib *lib = hm_band_get_lib(band);
	int n;
	const HmSynthType *synths = hm_lib_get_synths(lib, &n);

	for (int i = 0; i < n; i++) {
		lua_pushstring(L, synths[i].name);
	}

	return n;
}

static int cmd_set_synth(lua_State *L)
{
	HmBand *band = lua_touserdata(L, lua_upvalueindex(1));
	HmLib *lib = hm_band_get_lib(band);
	int channel =luaL_checkint(L, 1);
	const char *name = luaL_checkstring(L, 2);

	const HmSynthType *synth = hm_lib_get_synth(lib, name);
	if (!synth)
		return luaL_error(L, "no such synth: %s", name);

	int error = hm_band_set_channel_synth(band, channel, synth);
	if (error)
		return luaL_error(L, "error setting synth: %d", error);

	return 0;
}

static int cmd_send_cc(lua_State *L)
{
	HmBand *band = lua_touserdata(L, lua_upvalueindex(1));
	int channel = (int)luaL_checkinteger(L, 1);
	int control = (int)luaL_checkinteger(L, 2);
	float value = luaL_checknumber(L, 3);

	hm_band_send_cc(band, 0, channel, control, value);

	return 0;
}

static const luaL_Reg lib[] = {
	{"get_synths", cmd_get_synths},
	{"set_synth", cmd_set_synth},
	{"send_cc", cmd_send_cc},
	{NULL, NULL}
};

int luaopen_hamilton(lua_State *L)
{
	luaL_newlibtable(L, lib);
	lua_pushlightuserdata(L, &bandKey);
	lua_gettable(L, LUA_REGISTRYINDEX);
	luaL_setfuncs(L, lib, 1);

	return 1;
}
