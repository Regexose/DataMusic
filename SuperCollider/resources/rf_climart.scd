~rf = (
	// on Off Play
	\48 : {
		// plays br-Synth with
		var data, normalized, compressed,reduce, buf, syn;
		reduce = 100;
		data = ~currentData[\48].asArray;
		compressed = data.select({|item, i| i%reduce == 0});
		normalized = compressed.normalize(80, 3000);
		buf = ~currentSample[\base];
		syn = Synth(\br, [\amp, 0.3, \buf, buf, \end, buf.numFrames-1,  \lg1, 0.2, \lg2, 0.2]);
		~activeSynths.put(\48, syn);
		normalized.do({
			|d, i|
			"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
			syn.set(\ffreq, d);
			0.04.wait;
			if(i >=( normalized.size-1), {"end of data, releasing synth %".format(syn); syn.release(2)});

		});
	},

	\50 : {
		var data, normalized, compressed, reduce, buf, syn, sec;
		reduce=50;
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
			syn.set(\harm, d,  \pan, d.linlin(36, 60, -1, 1), \pos, sec *i);
			0.03.wait;
			if(i >=( normalized.size-1), {"end of data, releasing synth %".format(syn); syn.release(2)});

		})
	},

	\52: {
		var data, normalized, compressed, reduce, buf, syn, sec;
		reduce = 50;
		data = ~currentData[\52].asArray;
		compressed = data.select({|item, i| i%reduce == 0});
		normalized = compressed.normalize(36.0, 60.0);
		buf = ~currentSample[\base];
		sec = buf.numFrames/s.sampleRate * 50;
		syn = Synth(\tgrains, [\buf, buf, \amp, 0.5, \grainAmp, 0.5]);
		~activeSynths.put(\52, syn);
		normalized.do({
			|d, i|
			"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
			syn.set(\harm, [d, d-12, d+12], \pos, sec *1);
			0.04.wait;
			if(i >=( normalized.size-1), {"end of data, releasing synth %".format(syn); syn.release(2)});
		})
	},


	// One Shot Play
	\60 : {
		// plays br-Synth with
		var data, normalized, buf, syn;
		data = ~currentData[\48];
		normalized = data.asArray.normalize(80, 3000);
		buf = ~currentSample[\base];
		syn = Synth(\br, [\buf, buf, \end, buf.numFrames-1,  \lg1, 0.2, \lg2, 0.2]);
		~activeSynths.put(\60, syn);
		normalized.do({
			|d, i|
			"original data  %   normalized data   %  at   %".format(data[i].trunc(0.0001), d, i).postln;
			syn.set(\ffreq, d);
			0.04.wait;
			if(i >=( normalized.size-1), {"end of data, releasing synth %".format(syn); syn.release(2)});
		});
	},

	\62 : {
		var data, normalized, buf, syn, sec;
		data = ~currentData[\50];
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
		data = ~currentData[\52];
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
