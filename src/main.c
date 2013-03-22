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

int mda_dx10_register(void);

static volatile bool finished = false;

static int midi_thread(void *_)
{
	while (!finished) {
		uint8_t status, data1, data2;
		while (hm_midi_read(&status, &data1, &data2) > 0) {
			uint8_t type = status >> 4;
			uint8_t channel = status & 0x0F;

			switch (type) {
				case 0x8:
					hm_band_send_note(0, channel, false, data1, data2 / 127.0);
					break;

				case 0x9:
					hm_band_send_note(0, channel, true, data1, data2 / 127.0);
					break;

				case 0xB:
					hm_band_send_cc(0, channel, data1, data2 / 127.0);
					break;

				case 0xC:
					hm_band_send_patch(0, channel, data1);
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

	TRY(al_host_systems_init());
	TRY(al_host_init(&host));

	TRY(hm_band_init());
	TRY(mda_dx10_register());
	int n;
	const HmSynthType *synths = hm_lib_get_synths(&n);
	TRY(hm_band_set_channel_synth(0, &synths[0]));

	TRY(hm_midi_init());
	TRY(hm_audio_init());

	hm_audio_start();

	SDL_Thread *thread = SDL_CreateThread(midi_thread, NULL);
	if (!thread)
		THROW(AL_ERROR_GENERIC);

	TRY(al_host_run_script(host, "main.lua"));

	al_host_run(host);

	finished = true;
	SDL_WaitThread(thread, NULL);

	PASS(
		 hm_audio_free();
		 hm_midi_free();
		 hm_band_free();

		 al_host_free(host);
		al_host_systems_free();
	)
}
