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

	\53: {
		var syn, data, name;
		data = ~data.solar;
		name = ~data.findKeyForValue(data);
	/*	~makeWaveTable.(4096, data, name);
		~makeWaveTable.(4096, ~data.rain_rate, \rainrate);*/
		data.do({
			|bt|
			syn = Synth(\oscfm, [\buf1, ~buffers[\solar], \buf2, ~buffers[\rainrate], \atk, 0.2, \rls, 1, \modamp, bt/2, \modfreq, bt, \freq, bt]);
			0.6.wait;
		})
	}
)