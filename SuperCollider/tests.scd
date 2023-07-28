(
~test = Routine({
		var syn = Synth( \arrayarg, [\amp, 0.03]);
	~barotemps.clump(3).do({
		|bt|
		if (bt.isArray, {
			bt.postln;
			syn.setn(\freqs, bt[0], \temps, bt[1] );
		} );
		1.wait;
	})
}).play;
)
// wavetable
(
//sc_230727_201826_stereo
~test = Routine({
	var syn;
	~barotemps.do({
		|bt|
		~makeWaveTable.(4096, ~temps, \temps);
		~makeWaveTable.(4096, ~baromabs, \baro);
		syn = Synth(\oscfm, [\buf1, ~buffers[\baro], \buf2, ~buffers[\temps], \atk, 0.2, \rls, 1, \modamp, bt[0]/2, \modfreq, bt[0], \freq, bt[1]]);
		0.6.wait;
	})
}).play;
)

(
// with voice samples
~test = Routine({
	var syn;
	s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/tgrains01.wav", duration: 60);
	wait(0.02);

	~temps.do({
		|t, i|
		var c;
		c = case
		{i%18==0}{syn = Synth(\tgrains, [\buf, ~buffers[\boris][i], \sus, 30, \grainAmp, 0.2, \dens, 1])}
		{i%5==0} {syn.set(\harm, Array.fill(4, {|idx| idx / t }), \pos, i/t, \dens, i/3, \grainDur, i/t)}
		{true}{("cases test done" ++ i).postln};
		0.5.wait;
		})
	}).play;

)

(
// grains slowly moving forward
~test = Routine({
	var syn;
	s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/tgrains02.wav", duration: 35);
	wait(0.02);

	~temps.do({
		|t, i|
		var c, buf, segment;
		buf = ~buffers[\boris][10];
		segment = buf.numFrames/(~temps.size * s.sampleRate);
		syn = Synth(\tgrains, [\buf, buf, \pos, segment * i, \sus, 0.1, \atk, 0.001, \rls, 0.6, \grainAmp, 0.34, \grainDur, 0.14,  \dens, 3]);
		c = case
		{i%5==0}{syn.set(\harm, Array.fill(4, {|idx| idx / t }), \rate, 1 + t.reciprocal)}
		{i%25==0}{syn.set(\buf, ~buffers[\boris][i%~buffers[\boris].size] )}
		{true}{("cases test done" ++ i).postln};
		0.1.wait;
		})
	}).play;

)

(
// grains slowly moving forward
~test = Routine({
	var syn;
	s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/tgrains03.wav", duration: 25);
	wait(0.02);

	~temps.do({
		|t, i|
		var c, buf, maxInd, segment;
		buf = ~buffers[\boris][7];
		segment = buf.numFrames/(~temps.size * s.sampleRate);

		syn = Synth(\tgrains, [\buf, buf, \pos, segment * i, \sus, 0.1, \atk, 0.001, \rls, 0.8, \grainAmp, 0.34, \grainDur, 0.2,  \dens, 3]);
		c = case
		{i%5==0}{syn.set(\harm, Array.fill(4, {|idx| idx / t }))}
		{i%25==0}{syn.set(\buf, ~buffers[\boris][i%~buffers[\boris].size] )}
		{true}{("cases test done" ++ i).postln};
		0.08.wait;
		})
	}).play;

)
~test.stop
s.makeWindow
s.recSampleFormat = "int16"
s.recHeaderFormat = "wav"

(
//sc_230727_164424_stereo
~test = Routine({
	~barotemps.clump(3).do({
		|bt|
		var syn = Synth(\dynklank, [\amp, 0.2, \pan, rrand(-0.1, 0.1), \pLag, 0.3]);
		if (bt.isArray, {
			bt.postln;
			syn.set(\freqs, bt[0], \rings, bt[1], \freqScale, bt[1][1], \decayScale, bt[1][0]);
		} );
		1.wait;
	})
}).play;
)
s.makeWindow

(
p = Pmono(\arrayarg,
	\amp, 0.01,
	\pan, Pwhite(-0.9, 0.9, inf),
	\pLag, 0.1,
	\freqIndex, Pseq((0..(~baromabs.clump(3).size -1)), inf).trace,
	\freqs, Pfunc({|ev| ~baromabs.clump(3)[ev.freqIndex]}).trace,
).play
)
~test.stop