~rf = (
	\48 : {
		// wind_gust
		var buf, thres, syn, old, divider, duration, data, name;
		data = ~data.wind_gust;
		name = ~data.findKeyForValue(data);
		buf = ~liveBuffer;
		duration = buf.numFrames /s.sampleRate;
		thres = data.mean;
		divider = data.size/2;

		~data.wind_gust.do({
			|b, i|
		"processing %  %".format(name.asString, t).postln;
			syn = Synth(\brBF, [\buf, buf, \sec, buf.numFrames/divider, \secIdx, i%divider ]);
			if(b >= thres, {
				buf = ~liveBuffer;
				"set synth".postln;
				syn.set(\rate, 1, \harm, Array.fill(3, {[0, 12].choose}))},
			{"new buffer".postln;  buf = [~buffers[\boris][4], ~liveBuffer].choose;
				duration = buf.numFrames/ s.sampleRate;
				syn.set(\buf, buf, \rate, -1, \harm, Array.fill(3, {[0, -12].choose}))});
			(duration/divider).wait;
		})
	},
	\50 : {
		var syn;
		var data = ~data.wind_direction;
		var name = ~data.findKeyForValue(data);
		data.do({
			|t, i|
			var c, buf, segment;
			"processing %  %".format(name.asString, t).postln;
			buf = ~liveBuffer;
			//segment = buf.numFrames/(data.size * s.sampleRate);
			segment = buf.numFrames/data.size;
			syn = Synth(\tgrains, [\buf, buf, \pos, segment * i, \sus, 0.1, \atk, 0.001, \rls, 0.6, \grainAmp, 0.34, \grainDur, 0.14,  \dens, 3]);
			c = case
			{i%5==0}{syn.set(\harm, Array.fill(4, {|idx| idx / t }), \rate, 1 + t.reciprocal)}
			{i%25==0}{syn.set(\rls, 0.1, \grainDur, 0.09)}
			{true}{true};
			0.1.wait;
		})
	},
	\52: {
	var syn, data, name;
		data = ~data.humidity;
		name = ~data.findKeyForValue(data);
	data.do({
		|t, i|
		var c, buf, maxInd, segment;
		"processing %  %".format(name.asString, t).postln;
		buf = ~liveBuffer;
		segment = buf.numFrames/data.size;
		syn = Synth(\tgrains, [\buf, buf, \pos, segment * i, \sus, 0.1, \atk, 0.001, \rls, 0.8, \grainAmp, 0.34, \grainDur, t/100,  \dens, 3, \rate, 0.4 + (t/100)]);
		c = case
		{i%5==0}{syn.set(\harm, Array.fill(4, {|idx| idx / t }))}
		{true}{true};
		0.08.wait;
		})
	},

	\55: {
		//weekly rhythm of uvi
		var syn, data, name, buf, partial;
		data = Array2D.fromArray(6, 48, ~data.uvi);
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

/*	\59: {
		var data, dataDays, name, syn;
		syn =  Synth(\tgrains_live, [\buf, ~grainBuffer]);
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
				syn.class.postln;
				syn.set(\harm, clmp);
				0.1.wait;
			});
			1.wait;
		})
	},*/
	//
	 \59: {
	 	|id|
	 	var data, dataDays, name, syn;
		"calling funktion mit %".format(id).postln;
	 	data = ~data.uvi;
	 	name = ~data.findKeyForValue(data);
	 	dataDays = Array2D.fromArray(6, 48, data);
	 	dataDays.rowsDo({
	 		|r, i|
	 		var clumps = r.clump(3).stutter(3);
	 		"new cycle % ".format(i).postln;
	 		clumps.do({
	 			|clmp|
	 			//"clump %".format(clmp).postln;
				//s.sendMsg(\n_set, id, \harm, clmp);
				~syn.set(\harm, clmp *2, \grainAmp, [1.0, 1.1, 1.3] );
				"set %".format(clmp).postln;
	 			0.5.wait;
			});
	 		1.wait;
	 	})
	 },
)