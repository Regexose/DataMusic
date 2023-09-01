~rf = (
	// on Off Play
	\48 : {
		// plays br-Synth with
		var data, normalized, compressed,reduce, buf, syn;
		reduce = 30;
		data = ~currentData[\48].asArray;
		compressed = data.select({|item, i| i%reduce == 0});
		normalized = compressed.normalize(80, 3000);
		buf = ~currentSample[\base];
		syn = Synth(\br, [\amp, 0.8, \buf, buf, \end, buf.numFrames-1,  \lg1, 0.2, \lg2, 0.2, \atk, 0.1, \sus, 0.2, \rls, 1]);
		~activeSynths.put(\48, syn);
		normalized.do({
			|d, i|
			"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
			syn.set(\ffreq, d, \lg2, d.linexp(80, 3000, 0.03, 0.5), \harm, d.linlin(80,3000, 13,48));
			0.04.wait;
			if(i >=( normalized.size-1), {"end of data, releasing synth %".format(syn); syn.release(2)});

		});
	},

	\50 : {
		var data, normalized, compressed, reduce, buf, syn, sec;
		reduce=30;
		data = ~currentData[\50].asArray;
		compressed = data.select({|item, i| i%reduce == 0});
		normalized = compressed.normalize(36.0, 60.0);
		buf = ~currentSample[\base];
		sec = buf.numFrames/s.sampleRate * 50;
		syn = Synth(\tgrains, [\amp, 0.5, \grainAmp, 0.5, \buf, buf, \dens, 12, \grainDur, 1.4, \harm, 0]);
		~activeSynths.put(\50, syn);
		normalized.do({
			|d, i|
			"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            syn.set(\harm,  \pos, sec *i);
			0.03.wait;
			if(i >=( normalized.size-1), {"end of data, releasing synth %".format(syn); syn.release(2)});

		})
	},

	\52: {
		var data, normalized, compressed, reduce, buf, syn, sec, mean, range;
		reduce = 30;
		data = ~currentData[\52].asArray;
		compressed = data.select({|item, i| i%reduce == 0});
		normalized = compressed.normalize(36.0, 60.0);
        mean = normalized.mean;
        range = mean / 10;
		buf = ~currentSample[\base];
		sec = buf.numFrames/s.sampleRate * 50;
		syn = Synth(\tgrains, [\buf, buf, \amp, 0.9, \grainAmp, 0.7]);
		~activeSynths.put(\52, syn);
		normalized.do({
			|d, i|
            var c;
			"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            c = case
            {(d >= (normalized.mean - range)) && (d<= (normalized.mean + range))}{syn.set(\harm, d, \dens, 20, \pos, sec *1, \buf, ~currentSample[\base]);}
            {d < (normalized.mean -range)}{syn.set(\harm, d+12, \pos, sec *1, \dens, 5, \buf, ~currentSample[\tension]);}
            {(d > (normalized.mean + range))}{syn.set(\harm, d-12, \pos, sec *1, \dens, 23, \buf, ~currentSample[\relax]);}
            {true}{"no case".postln};
			0.04.wait;
			if(i >=( normalized.size-1), {"end of data, releasing synth %".format(syn); syn.release(2)});
		})
	},


	// One Shot Play
	\60 : {
        var syn, data, compressed, normalized, reduce;
        reduce=10;
        data = ~currentData[\60].asArray;
        compressed = data.select({|item, i| i%reduce == 0});
        normalized = compressed.normalize(80.0, 3500.0);
        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        syn = Synth(\arrayarg, [\amp, 0.1, \freqs, [48, 60, 72].midicps]);
        ~activeSynths.put(\60, syn);
        normalized.do({
            |d, i|
            "original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            syn.set(\ffreq, d, \mod, d.linlin(80, 3500, 1.0, 5.0), \pm, d.linlin(80, 3500, 0.0, 2pi)) ;
            0.05.wait;
            if (i == (normalized.size-1), {syn.release(3)});
        })
    },

	\62 : {
		var data, normalized, buf, syn, sec;
		data = ~currentData[\62];
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
			if(i >=( normalized.size-1), {"end of data, releasing synth %".format(syn); syn.release(2)});
		})
	},

	\64: {
		var data, normalized, buf, syn, sec;
		data = ~currentData[\64];
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
			if(i >=( normalized.size-1), {"end of data, releasing synth %".format(syn); syn.release(2)});
		})
	},



)
