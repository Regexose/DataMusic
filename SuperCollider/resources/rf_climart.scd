~rf = (
	// on Off Play
	\48 : {
		/* plays br-Synth with fitler frequency manipulation \ffreq
        \harmonic manipulation
        \lag : playhead springt hin und her
        */
		var data, normalized, compressed, reduce, buf, syn;
	/* s.record(~recordingPath ++ "/jan_solar.wav", duration: 60);
        wait(0.02);*/
		reduce = ~currentData[\48][\reduce];
		data = ~currentData[\48][\data].asArray;
		compressed = data.select({|item, i| i%reduce == 0});
		normalized = compressed.normalize(80, 3000);
		buf = ~currentSample[\base].normalize;
		s.sync;
		syn = Synth(\br, [\amp, 0.45, \buf, buf, \end, buf.numFrames-1,  \lg1, 0.1, \lg2, 0.2, \outdry, ~dryBus]);
		~activeSynths.put(\48, syn);
		normalized.do({
			|d, i|
			//"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
			syn.set(\ffreq, d, \lg2, d.linexp(80, 3000, 0.03, 0.1), \harm, d.linlin(80,3000, -12,12));
			0.04.wait;
			defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh}; // Update GUI
		});
		syn.release(2);
	},

	\50 : {
        /*

        */
		var data, normalized, compressed, reduce, buf, syn, syn2, dry, synGroup, sec;
	 /*  s.record(~recordingPath ++ "/karlwhct_50_soilmoisture.wav", duration: 60);
        wait(0.02);*/
		reduce= ~currentData[\50][\reduce];
		data = ~currentData[\50][\data].asArray;
		compressed = data.select({|item, i| i%reduce == 0});
		normalized = compressed.normalize(300, 2000);
		buf = ~currentSample[\base].normalize;
		s.sync;
		sec = buf.numFrames/(s.sampleRate * 100);
		synGroup = Group.new;
		syn = Synth(\tgrains, [\amp, 0.4, \grainAmp, 0.65, \buf, buf, \dens, 10, \grainDur, sec, \rq, 0.5, \outdry, ~dryBus], synGroup, \addToHead);
		syn2 = Synth(\dynklank, [\freqs, 500!3, \rings, 0.2!3, \decayScale, 0.001, \amp, 0.6, \punch, 0.2, \dec, 0.2], synGroup, \addToHead);
		s.sync;
		~activeSynths.put(\50, synGroup);
		normalized.do({
			|d, i|
			//"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            syn.set(\ffreq, d.linexp(300, 2000, 100, 3500), \rate, d.linlin(300,2000, 0.3, 1.0), \pos, sec * i);
			syn2.set(\rings, d.linlin(300, 2000, 0.1, 3.0) !3, \imp, d.linlin(300, 2000, 1, 30), \freqScale, d.linlin(300, 2000, 0.1, 2.0), \decayScale, d.linlin(300, 2000, 0.0001, 0.1));
			0.03.wait;
		    defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh;};
		});
		synGroup.release(2);

	},

	\52: {
		var data, normalized, compressed, reduce, buf1, buf2, buf3, syn, sec, mean, range;
	  /*  s.record(~recordingPath ++ "/jan_52_temp.wav", duration: 60);
        wait(0.02);*/
		reduce = ~currentData[\52][\reduce];
		data = ~currentData[\52][\data].asArray;
		compressed = data.select({|item, i| i%reduce == 0});
		normalized = compressed.normalize(36.0, 60.0);
        mean = normalized.mean;
        range = mean / 30;
		buf1 = ~currentSample[\base].normalize;
		buf2 = ~currentSample[\tension].normalize;
		buf3 = ~currentSample[\relax].normalize;
		s.sync;
		sec = buf1.numFrames/s.sampleRate * 50;
		syn = Synth(\tgrains, [\amp, 0.4, \grainAmp, 0.5, \dens, 10, \pos, sec * 20, \outdry, ~dryBus]);
		s.sync;
		~activeSynths.put(\52, syn);
		normalized.do({
			|d, i|
            var c;
			//"original data  %  normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            c = case
            {(d >= (normalized.mean - range)) && (d<= (normalized.mean + range))}{
				syn.set(\ffreq, d.linlin(36, 60, 250, 2500), \harm, d.linlin(36, 60, -12, 12)!2, \buf, buf1);
			}
            {d < (normalized.mean -range)}{
				syn.set(\ffreq, d.linlin(36, 60, 250, 2500), \harm, d.linlin(36, 60, -15, 15)!2, \buf, buf2);
			}
            {(d > (normalized.mean + range))}{
				syn.set(\ffreq, d.linlin(36, 60, 250, 2500), \harm, d.linlin(36, 60, -5, 5)!2, \buf, buf3)
		     }
            {true}{"no case".postln};
			0.04.wait;
			defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh;};
		});
		syn.release(2);
	},


	\60 : {
        var syn, data, compressed, normalized, reduce;
        reduce= ~currentData[\60][\reduce];
        data = ~currentData[\60][\data].asArray;
        compressed = data.select({|item, i| i%reduce == 0});
        normalized = compressed.normalize(80.0, 3500.0);
        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        syn = Synth(\arrayarg, [\amp, 0.2, \freqs, [ 48, 72, 84].midicps]);
        ~activeSynths.put(\60, syn);
        normalized.do({
            |d, i|
            "original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            syn.set(\ffreq, d, \mod, d.linlin(80, 3500, 1.0, 5.0), \pm, d.linlin(80, 3500, 0.0, 2pi)) ;
            0.05.wait;
			defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh;};

        });
		syn.release(2);
    },

	\62 : {
		var data, normalized, compressed, buf, syn, sec, reduce;
		reduce = ~currentData[\62][\reduce];
		data = ~currentData[\62][\data].asArray;
		compressed = data.select({|item, i| i%reduce == 0});
		normalized = compressed.normalize(12.0, 24.0);
		buf = ~liveBuffer;
		s.sync;
		sec = buf.numFrames/s.sampleRate * 50;
		syn = Synth(\tgrains_live, [\buf, buf, \dens, 12, \grainDur, 1.4, \grainAmp, 0.5, \harm, [0,0]]);
		~activeSynths.put(\62, syn);

		normalized.do({
			|d, i|
			"original data  %   normalized data   %  at   %".format(data[i].trunc(0.0001), d, i).postln;
			syn.set(\harm, d.linlin(12, 24, - 12, 12) !2, \pan, d.linlin(12, 24, -1, 1), \jitter,  d.linlin(12, 24, 0.0001, 1.0));
			0.04.wait;
			defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh;};

		});
		syn.release(2);
	},

	\64: {
		var data, compressed, normalized, buf, syn, sec, reduce;
		reduce = ~currentData[\64][\reduce];
		data = ~currentData[\64][\data].asArray;
		compressed = data.select({|item, i| i%reduce == 0});
		normalized = compressed.normalize(300, 2000);
		buf = ~currentSample[\base];
		sec = buf.numFrames/s.sampleRate * 50;
		syn = Synth(\dynklank, [\amp, 0.4, \freqs, 300!3, \rings, 0.2!3, \decayScale, 0.001, \amp, 0.6,  \dec, 0.3]);
		~activeSynths.put(\64, syn);
		normalized.do({
			|d, i|
			"original data  %   normalized data   %  at   %".format(data[i].trunc(0.0001), d, i).postln;
			syn.set(\rings, d.linlin(300, 2000, 0.2, 10) !3, \imp, d.linlin(300, 2000, 1, 20), \freqScale, d.linlin(300, 2000, -2.0, 2.0), \decayScale, d.linlin(300, 2000, 0.0001, 0.09), \punch, d.linlin(300, 2000, 0.22, 0.15));
			0.04.wait;
			defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh;};

		});
		syn.release(2);
	},



)
