
(
w = Window.new("I catch keystrokes");
w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
	var c;
	[char, keycode].postln;
	c = case
	{keycode == 18} {"active replacePlay".postln; ~replacePlay.()}
	//{keycode == 19} {"empty replacePlay".postln; [\rplOn, \rplOff].do({|n| MIDIdef(n).free})}
	{keycode == 19} {"empty replacePlay".postln; {~replacePlay = {}}}
	{true}{};
};
w.front;
)

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
