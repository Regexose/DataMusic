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
			"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
			syn.set(\ffreq, d, \lg2, d.linexp(80, 3000, 0.03, 0.5), \harm, d.linlin(80,3000, 12,30));
			0.04.wait;
		});
		syn.release(2);
	},

	\50 : {
		var data, normalized, compressed, reduce, buf, syn, sec;
	 /*  s.record(~recordingPath ++ "/karlwhct_50_soilmoisture.wav", duration: 60);
        wait(0.02);*/
		reduce= ~currentData[\50][\reduce];
		data = ~currentData[\50][\data].asArray;
		compressed = data.select({|item, i| i%reduce == 0});
		normalized = compressed.normalize(24.0, 48.0);
		buf = ~currentSample[\base].normalize;
		s.sync;
		sec = buf.numFrames/s.sampleRate * 10;
		syn = Synth(\tgrains, [\amp, 0.4, \grainAmp, 0.6, \buf, buf, \dens, 12, \grainDur, 0.3]);
		~activeSynths.put(\50, syn);
		normalized.do({
			|d, i|
			"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            syn.set(\ffreq, d.linlin(24, 48, 500, 2000), \harm, [d, d/2], \pos, sec * i);
			0.03.wait;
		});
		syn.release(2);
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
		syn = Synth(\tgrains, [\buf, buf, \amp, 0.4, \grainAmp, 0.67, \dens, 10]);
		~activeSynths.put(\52, syn);
		normalized.do({
			|d, i|
            var c;
			"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            c = case
            {(d >= (normalized.mean - range)) && (d<= (normalized.mean + range))}{
				syn.set(\ffreq, d.linlin(36, 60, 250, 2500), \harm, d, \pos, sec *1, \buf, ~currentSample[\base]);
			}
            {d < (normalized.mean -range)}{
				syn.set(\ffreq, d.linlin(36, 60, 250, 2500), \harm, d+12, \pos, sec *1,  \buf, ~currentSample[\tension]);
			}
            {(d > (normalized.mean + range))}{
				syn.set(\ffreq, d.linlin(36, 60, 250, 2500), \harm, d-12, \pos, sec *1, \buf, ~currentSample[\relax])
		     }
            {true}{"no case".postln};
			0.04.wait;
		});
		syn.release(2);
	},


	// One Shot Play
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
        });
		syn.release(2);
    },

	\62 : {
		var data, normalized, buf, syn, sec, reduce;
		reduce = ~currentData[\62][\reduce];
		data = ~currentData[\62][\data];
		normalized = data.asArray.normalize(36.0, 60.0);
		buf = ~currentSample[\base];
		sec = buf.numFrames/s.sampleRate * 50;
		syn = Synth(\tgrains, [\buf, buf, \dens, 12, \grainDur, 1.4, \harm, 0]);
		~activeSynths.put(\62, syn);
		normalized.do({
			|d, i|
			"original data  %   normalized data   %  at   %".format(data[i].trunc(0.0001), d, i).postln;
			syn.set(\harm, d,  \pan, d.linlin(36, 60, -1, 1), \pos, sec *i);
			0.03.wait;
		});
		syn.release(2);
	},

	\64: {
		var data, normalized, buf, syn, sec, reduce;
		reduce = ~currentData[\64][\reduce];
		data = ~currentData[\64][\data];
		normalized = data.asArray.normalize(13, 114);
		buf = ~currentSample[\base];
		sec = buf.numFrames/s.sampleRate * 50;
		syn = Synth(\tgrains, [\buf, buf]);
		~activeSynths.put(\64, syn);
		normalized.do({
			|d, i|
			"original data  %   normalized data   %  at   %".format(data[i].trunc(0.0001), d, i).postln;
			syn.set(\harm, [d, d-12, d+12], \pos, sec *1);
			0.04.wait;
		});
		syn.release(2);
	},



)
