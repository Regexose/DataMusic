(
~dataGroups.freq.do({
	|frq, i|
	var synName, data, keyName;
	data = ~data[frq];
	keyName = ~data.findKeyForValue(data);
	synName = "syn_" ++keyName;
	synName = Synth(\array_1b, [\freq, data.mean, \amp, 0.2]);
	r({
		data.do({
			|t, i|
			[t, i].postln;
			synName.set(\freq, t /1000, \otFreqs, Array.exprand(4, data.mean, t), \otAmps, Array.fill(4, {exprand(0.8, 1.0)}), \freqLag, 0.9);
			0.1.wait;
			if (i == (data.size-1), {synName.release(3)});
		});

	}).play
})
)

(
~dataGroups.steady.do({
	|frq, i|
	var synName, data, keyName, freqs;
	data = ~data[frq];
	keyName = ~data.findKeyForValue(data);
	synName = "syn_" ++keyName;
	freqs = data.clump(3).stutter(3);
	synName = Synth(\arrayarg, [\freqs, Array.fill(3, freqs[0] + 35), \amp, 0.01]);
	r({
		data.do({
		|t, i|
			[t,i].postln;
		synName.set(\freqs, freqs[i] +35, \temps, Array.fill(3, {[data[i-1.max(0)], t, data[i+1.min(data.size)]]}));
		0.1.wait;
			if (i == (data.size-1), {synName.release(3)});
	});
	}).play
})
)

(
y = Synth(\array_1b, [\freq, ~data.temperature.mean]);
r({
	~data.temperature.do({
		|t, i|
		t.postln;
		y.set(\freq, t/100, \otFreqs, Array.exprand(8, ~data.temperature.mean, t), \otAmps, Array.fill(8, {exprand(0.8, 1.0)}), \freqLag, 0.9);
		0.1.wait;
		if (i == (~data.temperature.size-1), {y.release(3)});
	});

}).play
)
(
x = Synth(\arrayarg, [\which, 2]);
r({
	~data.temperature.do({
		|t, i|
		t.postln;
		x.set(\freqs, Array.exprand(3, ~data.temperature.mean, t), \temps, Array.fill(3, {[~data.temperature[i-1.max(0)], t, ~data.temperature[i+1.min(~data.temperatures.size)]]}), \amp, 0.03);
		0.2.wait;
		if (i == (~data.temperature.size-1), {x.release(3)});
	});

}).play
)
a = Array.linrand(9, 20, 80)
a.clump(3).stutter(3)

(

~demos = List.new;
// with voice samples
~lambs = {
	var buf, thres, syn, old, divider, duration;
	buf = ~liveBuffer;
	duration = buf.numFrames /s.sampleRate;
	thres = ~baromabs.mean;
	divider = 20;

	~baromabs.do({
		|b, i|
		[b, i].postln;
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
};
~demos.add(~lambs);

// grains slowly moving forward
~stutter = {
	var syn;
	~temps.do({
		|t, i|
		var c, buf, segment;
		buf = ~liveBuffer;
		segment = buf.numFrames/(~temps.size * s.sampleRate);
		syn = Synth(\tgrains, [\buf, buf, \pos, segment * i, \sus, 0.1, \atk, 0.001, \rls, 0.6, \grainAmp, 0.34, \grainDur, 0.14,  \dens, 3]);
		c = case
		{i%5==0}{syn.set(\harm, Array.fill(4, {|idx| idx / t }), \rate, 1 + t.reciprocal)}
		{i%25==0}{syn.set(\rls, 0.1, \grainDur, 0.09)}
		{true}{("cases test done" ++ i).postln};
		0.1.wait;
	})
};
~demos.add(~stutter);
)
