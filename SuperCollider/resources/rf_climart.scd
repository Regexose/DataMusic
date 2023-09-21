~rf = (
	// on Off Play
	\48 : {
		// plays br-Synth with
		var data, normalized, compressed, reduce, buf, syn;
	/*	s.record(~recordingPath ++ "/karlwhct_temp02.wav", duration: 60);
        wait(0.02);*/
		reduce = ~currentData[\48][\reduce];
		data = ~currentData[\48][\data].asArray;
		compressed = data.select({|item, i| i%reduce == 0});
		normalized = compressed.normalize(80, 3000);
		buf = ~currentSample[\base].normalize;
		s.sync;
		syn = Synth(\br, [\amp, 0.8, \buf, buf, \end, buf.numFrames-1,  \lg1, 0.2, \lg2, 0.2, \atk, 0.1, \sus, 0.2, \rls, 1]);
		~activeSynths.put(\48, syn);
		normalized.do({
			|d, i|
			//"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
			syn.set(\ffreq, d, \lg2, d.linexp(80, 3000, 0.03, 0.5), \harm, d.linlin(80,3000, 12,30));
			0.04.wait;
			defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh}; // Update GUI
		});
		syn.release(2);
	},

	\50 : {
		var data, normalized, compressed, reduce, buf, syn, syn2, synGroup, sec;
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
		syn = Synth(\tgrains, [\amp, 0.4, \grainAmp, 0.5, \buf, buf, \dens, 2, \grainDur, sec], synGroup, \addToHead);
		syn2 = Synth(\dynklank, [\freqs, 300!3, \rings, 0.2!3, \decayScale, 0.001, \amp, 0.6, \punch, 0.2, \dec, 0.1], synGroup, \addToHead);
		s.sync;
		~activeSynths.put(\50, synGroup);
		normalized.do({
			|d, i|
			"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            syn.set(\ffreq, d, \pos, sec * i);
			syn2.set(\rings, d.linlin(300, 2000, 1, 4) !3, \imp, d.linlin(300, 2000, 1, 20), \freqScale, d.linlin(300, 2000, -2.0, 2.0), \decayScale, d.linlin(300, 2000, 0.0001, 0.03));
			0.03.wait;
		    defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh;};
		});
		syn.release(2);
		syn2.release(2);
	},

	\52: {
		var data, normalized, compressed, reduce, buf, syn, sec, mean, range;
	 /*   s.record(~recordingPath ++ "/karlwhct_52_temp01.wav", duration: 60);
        wait(0.02);*/
		reduce = ~currentData[\52][\reduce];
		data = ~currentData[\52][\data].asArray;
		compressed = data.select({|item, i| i%reduce == 0});
		normalized = compressed.normalize(36.0, 60.0);
        mean = normalized.mean;
        range = mean / 10;
		buf = ~currentSample[\base].normalize;
		s.sync;
		sec = buf.numFrames/s.sampleRate * 50;
		syn = Synth(\tgrains, [\buf, buf, \amp, 0.4, \grainAmp, 0.5, \dens, 10, \pos, sec * 20]);
		s.sync;
		~activeSynths.put(\52, syn);
		normalized.do({
			|d, i|
            var c;
			"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            c = case
            {(d >= (normalized.mean - range)) && (d<= (normalized.mean + range))}{
				syn.set(\ffreq, d.linlin(36, 60, 250, 2500), \harm, d, \buf, ~currentSample[\base]);
			}
            {d < (normalized.mean -range)}{
				syn.set(\ffreq, d.linlin(36, 60, 250, 2500), \harm, d+12, \pos, sec *1,  \buf, ~currentSample[\tension]);
			}
            {(d > (normalized.mean + range))}{
				syn.set(\ffreq, d.linlin(36, 60, 250, 2500), \harm, d-12, \pos, sec *1, \buf, ~currentSample[\relax])
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
		normalized = compressed.normalize(36.0, 48.0);
		buf = ~liveBuffer;
		s.sync;
		sec = buf.numFrames/s.sampleRate * 50;
		syn = Synth(\tgrains_live, [\buf, buf, \dens, 12, \grainDur, 1.4, \grainAmp, 0.5, \harm, [0,0]]);
		~activeSynths.put(\62, syn);

		normalized.do({
			|d, i|
			"original data  %   normalized data   %  at   %".format(data[i].trunc(0.0001), d, i).postln;
			syn.set(\harm, [d-12, d-24], \pan, d.linlin(36, 48, -1, 1), \jitter,  d.linlin(36, 48, 0.0001, 1.0));
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
		syn = Synth(\dynklank, [\freqs, 300!3, \rings, 0.2!3, \decayScale, 0.001, \amp, 0.6, \punch, 0.2, \dec, 0.3]);
		~activeSynths.put(\64, syn);
		normalized.do({
			|d, i|
			"original data  %   normalized data   %  at   %".format(data[i].trunc(0.0001), d, i).postln;
			syn.set(\rings, d.linlin(300, 2000, 0.2, 10) !3, \imp, d.linlin(300, 2000, 1, 20), \freqScale, d.linlin(300, 2000, -2.0, 2.0), \decayScale, d.linlin(300, 2000, 0.0001, 0.09), \punch, d.linlin(300, 2000, 0.25, 0.1));
			0.04.wait;
			defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh;};

		});
		syn.release(2);
	},



)
