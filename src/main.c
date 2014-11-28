/*
 * Copyright (c) 2013 James Deery
 * Released under the MIT license <http://opensource.org/licenses/MIT>.
 * See COPYING for details.
 */

#include "alice/host.h"
#include "albase/script.h"

#include "hamilton/band.h"
#include "hamilton/lib.h"
#include "hamilton/audio.h"
#include "hamilton/midi.h"
#include "hamilton/core_synths.h"
#include "hamilton/cmds.h"

#include "scripts.h"

int main(int argc, char *argv[])
{
	BEGIN()

	AlHost *host = NULL;
	HmBand *band = NULL;

	TRY(al_host_systems_init());
	TRY(al_host_init(&host));

	TRY(hm_band_init(&band));
	TRY(mda_dx10_register(band));
	TRY(hm_midi_init());
	TRY(hm_audio_init(band));

	lua_State *L = al_host_get_lua(host);
	hm_load_cmds(L, band);

	TRY(AL_SCRIPT_RUN(L, icons));
	TRY(AL_SCRIPT_RUN(L, band_state));
	TRY(AL_SCRIPT_RUN(L, play_head));
	TRY(AL_SCRIPT_RUN(L, state_widget));

	TRY(AL_SCRIPT_RUN(L, main));

	hm_audio_start();

	al_host_run(host);

	PASS(
		hm_audio_free();
		hm_midi_free();
		hm_band_free(band);

		al_host_free(host);
		al_host_systems_free();
	)
}
