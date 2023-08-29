~rf = (
	\48 : {
		// plays br-Synth with
		var data, normalized, buf, syn;
		data = ~currentData[\48];
		normalized = data.asArray.normalize(80, 3000);
		buf = ~buffers[\test][0];
		syn = Synth(\br, [\buf, buf, \end, buf.numFrames-1,  \lg1, 0.2, \lg2, 0.2]);
		normalized.do({
			|d, i|
			"original data  %   normalized data   %  at   %".format(data[i].trunc(0.0001), d, i).postln;
			syn.set(\ffreq, d);
			0.04.wait;
		});
	},

	\50 : {
		var data, normalized, buf, syn, sec;
		data = ~currentData[\50];
		normalized = data.asArray.normalize(36.0, 60.0);
		buf = ~buffers[\test][0];
		sec = buf.numFrames/s.sampleRate * 50;
		syn = Synth(\tgrains, [\buf, buf, \dens, 12, \grainDur, 1.4, \harm, 0]);
		normalized.do({
			|d, i|
			"original data  %   normalized data   %  at   %".format(data[i].trunc(0.0001), d, i).postln;
			syn.set(\harm, d,  \pan, d.linlin(36, 60, -1, 1), \pos, sec *i);
			0.2.wait;
		})
	},

	\52: {
		var data, normalized, buf, syn, sec;
		data = ~currentData[\52];
		normalized = data.asArray.normalize(13, 114);
		buf = ~buffers[\hugoloris][0];
		sec = buf.numFrames/s.sampleRate * 50;
		syn = Synth(\tgrains, [\buf, buf]);
		normalized.do({
			|d, i|
			"original data  %   normalized data   %  at   %".format(data[i].trunc(0.0001), d, i).postln;
			syn.set(\harm, [d, d-12, d+12], \pos, sec *1);
			0.04.wait;
		})
	},

	\55: {
		//weekly rhythm of uvi
		var syn, data, name, buf, partial;
		data = ~currentData[\55];
		data = Array2D.fromArray(6, 48, data);
		name = ~data.findKeyForValue(data);
		buf = ~liveBuffer;
		partial = 4;
		data.rowsDo({
			|r, i|
			var c;
			"new cycle %".format(i).postln;
			syn = Synth(\br, [\buf, buf, \rate, 1, \ffreq, 220, \atk, 0.1, \sus, 2, \rls,2, \start, 0, \end, buf.numFrames/partial]);
			r.do({
				|uvi|
				uvi.postln;
				syn.set(\ffreq, 400 + (220 * uvi.max(0.1)), \lag1, uvi, \lag2, uvi /2);
				0.05.wait;
			});
			(1/partial).wait;
		})
	},

	\59: {
		//play weekly data in 6 chunks
		var data, dataDays, name;
		data = ~data.uvi;
		name = ~data.findKeyForValue(data);
		dataDays = Array2D.fromArray(6, 48, data);
		dataDays.rowsDo({
			|r, i|
			var clumps = r.clump(3).stutter(3);
			"new cycle % ".format(i).postln;
			clumps.do({
				|clmp|
				"clump %".format(clmp).postln;
				~grainLive.set(\harm, clmp);
				0.1.wait;
			});
			1.wait;
		})
	},

)