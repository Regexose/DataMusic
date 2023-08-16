~rf = (
	\48 : {
		// Synth plays sections
		// Buffer for Synth is exchanged if data goes belaw the mean and plays backward
		// likes values around 500 -1000
		var buf, thres, syn, old, divider, duration, data, name;
		data = ~currentData[\48];
		name = ~data.findKeyForValue(data);
		buf = ~liveBuffer;
		duration = buf.numFrames /s.sampleRate;
		thres = data.mean;
		divider = data.size/10;
		syn = Synth(\brBF, [\buf, buf, \sec, buf.numFrames/divider, \amp, 0.8, ]);
		~activeSynths.put(\48, syn);
		data.do({
			|b, i|
		"processing %  %".format(name.asString, b).postln;
			if(b >= thres, {
				"set synth".postln;
				syn.set(\buf, ~liveBuffer, \rate, 1, \devF, 1 + b.max(0.01).reciprocal, \harm, Array.fill(3, {[0,12].choose}),
					\sec, b.max(0.001) * 4, \secIdx, i, \cent, b.linlin(0.0, 1000, -1, 1))
			},
			{
				"new buffer".postln;
				buf = ~buffers[\boris][3];
				//duration = buf.numFrames/ s.sampleRate;
				syn.set(\buf, buf, \sec, b.max(0.001) * 4,  \rate, -1, \secIdx, i, \devB, 5, \harm, Array.fill(3, {([0, -12].choose)}), \cent, b.explin(0.0, 1000, -1, 1))
			});
			(duration/divider).wait;
			if (i>=(data.size-1), {"freeing synth 48".postln; syn.set(\gate, 0); ~activeSynths.removeAt(\48)})
		})
	},

	\50 : {
		/*
		likes data 0-5
		plays segments in varying rates
		*/
		var syn, data, name, buf, segment;
		data = ~currentData[\50];
		name = ~data.findKeyForValue(data);
		buf = ~liveBuffer;
		segment = (buf.numFrames/data.size)/s.sampleRate;
		syn = Synth(\tgrains, [\buf, buf, \rls, 2, \sus, 3,  \grainAmp, 0.8, \grainDur, segment*6,  \dens, 3]);
		~activeSynths.put(\50, syn);
		data.do({
			|t, i|
			var c;
			"processing %  % at %".format(name.asString, t, i).postln;
			c = case
			{(i < (data.size-1)) && (i%5==0)}{ syn.set(\harm, Array.fill(4, {|idx| idx / t.max(0.01) }), \rate, 1 + t.reciprocal.min(1000))}
			{(i < (data.size-1)) && (i%26==0)}{ syn.set(\rls, 0.1, \grainDur, segment*5, \rate, 1 - t.reciprocal.min(1000))}
			{(i < (data.size-1))}{ syn.set( \pos, segment * i)}
			{true}{"freeing synth 50".postln; syn.set(\gate, 0); ~activeSynths.removeAt(\50)};
			0.1.wait;
		})
	},

	\52: {//likes values around 20
		//plays ascending segments of the buffer
	var syn, data, name, buf, segment;
		data = ~currentData[\52];
		name = ~data.findKeyForValue(data);
		buf = ~liveBuffer;
		syn = Synth(\tgrains, [\buf, ~liveBuffer, \grainAmp, 0.44, \sus, 10, \dens, 3]);
		~activeSynths.put(\52, syn);
		segment = (buf.numFrames/data.size)/s.sampleRate;
	data.do({
		|t, i|
		var c, maxInd;
		"processing %  %  at   %".format(name.asString, t, i).postln;
		c = case
		{i < (data.size-1)}{syn.set(\pos, segment * i, \grainDur, t/30, \rate, 1.0 + (t/100));}
		{(i < (data.size-1)) && (i%5==0)}{syn.set(\harm, Array.fill(4, {|idx| idx / t.max(0.01) }))}
		{true}{"freeing synth 52".postln; syn.set(\gate, 0); ~activeSynths.removeAt(\52)};
		0.08.wait;
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