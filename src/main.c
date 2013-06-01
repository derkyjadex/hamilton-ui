/*
 * Copyright (c) 2013 James Deery
 * Released under the MIT license <http://opensource.org/licenses/MIT>.
 * See COPYING for details.
 */

#include <SDL/SDL.h>

#include "alice/host.h"
#include "albase/script.h"

#include "hamilton/band.h"
#include "hamilton/lib.h"
#include "hamilton/audio.h"
#include "hamilton/midi.h"
#include "hamilton/core_synths.h"

#include "cmds.h"

static volatile bool finished = false;

static int midi_thread(void *data)
{
	HmBand *band = (HmBand *)data;

	while (!finished) {
		uint8_t status, data1, data2;
		while (hm_midi_read(&status, &data1, &data2) > 0) {
			uint32_t time = SDL_GetTicks();
			uint8_t type = status >> 4;
			uint8_t channel = status & 0x0F;

			switch (type) {
				case 0x8:
					hm_band_send_note(band, time, channel, false, data1, data2 / 127.0);
					break;

				case 0x9:
					hm_band_send_note(band, time, channel, true, data1, data2 / 127.0);
					break;

				case 0xB:
					hm_band_send_cc(band, time, channel, data1, data2 / 127.0);
					break;

				case 0xC:
					hm_band_send_patch(band, time, channel, data1);
					break;
			}
		}

		SDL_Delay(4);
	}

	return 0;
}

int main(int argc, char *argv[])
{
	BEGIN()

	AlHost *host = NULL;
	SDL_Thread *midiThread = NULL;
	HmBand *band = NULL;

	TRY(al_host_systems_init());
	TRY(al_host_init(&host));

	TRY(hm_band_init(&band));
	TRY(mda_dx10_register(band));
	TRY(hm_midi_init());
	TRY(hm_audio_init(band));

	lua_State *L = al_host_get_lua(host);
	lua_pushlightuserdata(L, &bandKey);
	lua_pushlightuserdata(L, band);
	lua_settable(L, LUA_REGISTRYINDEX);
	luaL_requiref(L, "hamilton", luaopen_hamilton, false);

	TRY(al_host_run_script(host, "main.lua"));

	hm_audio_start();
	hm_band_reset_time(band, SDL_GetTicks());

	midiThread = SDL_CreateThread(midi_thread, band);
	if (!midiThread)
		THROW(AL_ERROR_GENERIC);

	al_host_run(host);

	finished = true;
	SDL_WaitThread(midiThread, NULL);

	PASS(
		hm_audio_free();
		hm_midi_free();
		hm_band_free(band);

		al_host_free(host);
		al_host_systems_free();
	)
}
