/*
 * Copyright (c) 2013 James Deery
 * Released under the MIT license <http://opensource.org/licenses/MIT>.
 * See COPYING for details.
 */

#include "hamilton/lib.h"
#include "hamilton/band.h"
#include "albase/commands.h"
#include "cmds.h"

static int cmd_get_synths(lua_State *L)
{
	int n;
	const HmSynthType *synths = hm_lib_get_synths(&n);

	for (int i = 0; i < n; i++) {
		lua_pushstring(L, synths[i].name);
	}

	return n;
}

static int cmd_set_synth(lua_State *L)
{
	int channel =luaL_checkint(L, 1);
	const char *name = luaL_checkstring(L, 2);

	const HmSynthType *synth = hm_lib_get_synth(name);
	if (!synth)
		return luaL_error(L, "no such synth: %s", name);

	int error = hm_band_set_channel_synth(channel, synth);
	if (error)
		return luaL_error(L, "error setting synth: %d", error);

	return 0;
}

AlError hm_commands_init(AlCommands *commands)
{
	BEGIN()

	al_commands_register(commands, "get_synths", cmd_get_synths, NULL);
	al_commands_register(commands, "set_synth", cmd_set_synth, NULL);

	PASS()
}
