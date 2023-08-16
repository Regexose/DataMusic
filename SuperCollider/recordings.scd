(
r({
	s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
	wait(0.02);
	x = Synth(\arrayarg, [\which, 2]);
	r({
		~data.temperature.do({
			|t, i|
			t.postln;
			x.set(\freqs, Array.exprand(3, ~data.temperature.mean, t), \temps, Array.fill(3, {[~data.temperature[i-1.max(0)], t, ~data.temperature[i+1.min(~data.temperatures.size)]]}), \amp, 0.03);
			0.05.wait;
			if (i == (~data.temperature.size-1), {x.release(3)});
		});
	}).play
}).play

)

(
// 6 datenreihen, [ solar, yearly, relative, relative_low, relative_high, absolute ]
//die Werte im wahrnehmbaren Frequenzspektrum haben, werden gleichzeitig abgespielt
r({
	s.record(~recordingPath +/+ "frequencies.wav", duration: 40);
	wait(0.02);
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
}).play
)


(
//  8 weniger volatile datenreihen ()temperature moisture) gleichzeitig
r({
		s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/steady.wav", duration: 40);
	wait(0.02);
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

}).play
)

(
// tgrains_live mit exprand
r({
	var syn, data, name, buf, segment;
	s.record(~recordingPath +/+ "tgrains_live.wav", duration: 60);
	wait(0.02);
		data = Array.fill(300, {exprand(0.1, 1.0)});
		buf = ~grainBuffer;
		syn = Synth(\tgrains_live, [\buf, buf, \grainAmp, 0.44, \sus, 5, \dens, 3]);
		segment = (buf.numFrames/data.size)/s.sampleRate;
	data.do({
		|t, i|
		"processing %  %  at   %".format("exprand data ", t, i).postln;
		syn.set(\grainDur, t, \rate,  [-1, 1].choose, \dens, (10 * t).ceil, \pos, segment *i, \harm, [t*8, t*4, t*2],  \grainAmp, [t, t/2, t/4] );
		0.15.wait;
		})
}).play
)

(
// brBF
r({
	var syn, data, name, buf, segment, rec;
	s.record(~recordingPath +/+ "for_back03.wav", duration: 30);
	wait(0.02);
		data = Array.fill(300, {exprand(0.1, 1.0)});
		buf = ~liveBuffer;
		segment = buf.numFrames/40;
		syn = Synth(\brBF, [\buf, buf, \sec, segment, \rate, 1, \dirlag, 0.2, ]);
	data.do({
		|t, i|
		"processing %  %  at   %".format("exprand data ", t, i).postln;
		syn.set(\secIdx, i%data.size, \harm, [t*8, t*4, t*2], \rate, [-1, 1].choose);
		0.1.wait;
		})
}).play
)

(
// brBF + arrayarg
r({
	var syn, syn2, data, name, buf, segment, rec, freqs;
s.record(~recordingPath +/+ "voc_syn.wav", duration: 30);
	wait(0.02);
		data = Array.fill(500, {exprand(0.1, 1.0)});
		buf = ~liveBuffer;
		segment = buf.numFrames/40;
		syn = Synth(\brBF, [\buf, buf, \sec, segment, \rate, 1, \dirlag, 0.2, \amp, 0.9]);
		freqs = data.clump(3).stutter(3);
	    syn2 = Synth(\arrayarg, [\freqs, Array.fill(3, freqs[0] * 35), \amp, 0.001]);
	data.do({
		|t, i|
		"processing %  %  at   %".format("exprand data ", t, i).postln;
		syn.set(\secIdx, i%data.size, \harm, t * freqs[i], \rate, [-1, 1].choose);
		syn2.set(\freqs, freqs[i] * 80, \temps, Array.fill(3, {[data[i-1.max(0)], t, data[i+1.min(data.size)]]}));
		0.1.wait;
		})
}).play
)

{//likes values around 20
		//plays ascending segments of the buffer

	},
)


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
	s.record(~recordingPath +/+ "tgrains01.wav", duration: 60);
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

~baromabs)

~buffers[\boris][4].play
(
var buf = ~buffers[\boris][4];
~test = Routine({
	var thres, syn, old, divider, duration;
		s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/brBF01.wav", duration: 45);
	wait(0.02);
	duration = buf.numFrames /s.sampleRate;
	thres = ~baromabs.mean;
	divider = 20;

	~baromabs.do({
		|b, i|
		[b, i].postln;
		syn = Synth(\brBF, [\buf, buf, \sec, buf.numFrames/divider, \secIdx, i%divider ]);
		if(b >= thres, {
			buf = ~buffers[\boris][4];
			syn.set(\rate, 1, \harm, Array.fill(3, {[0, 12].choose}))},
		{   buf = [~buffers[\boris][8], ~buffers[\boris][8], ~buffers[\boris][9]].choose;
			duration = buf.numFrames/ s.sampleRate;
			syn.set(\buf, buf, \rate, -1, \harm, Array.fill(3, {[0, -12].choose}))});
		(duration/divider).wait;
	})
}).play

)
(
Pbindef(\br,
	\instrument, \brSec,
	\buf, buf,
	\amp, 0.2,
	\sec, buf.numFrames / divider,
	\secIdx, Pseq((1..~temps), inf),
	\dur, 0.1,
).play
)
Pbindef(\br, \dur, 24.0.reciprocal, \rate, 2)

(
var buf = ~buffers[\boris][7], divider = 10;
Pbindef(\bfb,
	\instrument, \brBF,
	\buf, buf,
	\amp, 0.2,
	\sec, buf.numFrames/divider,
	\secIdx, Pseq((1..divider), inf),
	\dur, 0.1,
).play
)
Pbindef(\bfb, \dur, 0.3, \rate, 1, \harm, Pxrand([[9, 24, 21], [1, -5, -12], [12, -12, 24]], inf))
~test.stop
(
var buf = ~buffers[\boris][4];

)


(
var buf = ~buffers[\boris][6];
  x = {
        SmoothReversal.ar(
            bufnum: buf,
            playbackRate: MouseX.kr(0, 2),
            switchDirectionTrigger: Dust.ar(4) > 0.5,
            threshold: -15.dbamp
        )
    }.play;
)