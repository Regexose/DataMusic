(
r = Routine({
	100.do({
		|i|
		i.postln;
		0.5.wait;
		"ding".yield;
	})
})
)
r.play

MIDIFunc.trace(false);
~recOnOff.()
~liveBuffer.plot
(

~demos = List.new;
// with voice samples
~lambs = Routine({
	var syn = Synth(\tgrains, [\buf, ~liveBuffer, \sus, 2, \grainAmp, 0.2, \dens, 1]);
	~temps.do({
		|t, i|
		var c;
		c = case
		{i%18==0}{syn.set(\sus, 4, \grainAmp, 0.2, \dens, 4)}
		{i%5==0} {syn.set(\harm, Array.fill(4, {|idx| idx / t }), \pos, i/t, \dens, i/3, \grainDur, i/t)}
		{true}{("cases test done" ++ i).postln};
		0.15.wait;
		})
	});

~demos.add(~lambs);

// grains slowly moving forward
~stutter = Routine({
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
	});
~demos.add(~stutter);
)
