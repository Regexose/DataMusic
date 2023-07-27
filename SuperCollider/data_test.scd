(
//ServerOptions.devices
//~audioInterface = "MacBook Pro-Lautsprecher";
~audioInterface = "Fireface 400 (BEF)";
Server.default.options.numInputBusChannels_(0);
Server.default.options.outDevice_(~audioInterface);
//Server.default.options.inDevice_(~audioInterface);
s.newBusAllocators;
ServerTree.removeAll; // löscht alle funktionen
~projectRoot = PathName(thisProcess.nowExecutingPath).parentPath;
~dataPath = PathName(~projectRoot).parentPath ++ "data";
~baromabs= List.new;
~temps = List.new;
~barotemps = List.new;
~buffers = Dictionary.new;

~csvFile = CSVFileReader.read(~dataPath ++ "/test_data.csv", true);
~csvFile.do({
	|row, i|
	var c;
	c = case
	{(i != 0) && row[1].isString}{
		row[1] = row[1].asFloat;
		row[2] = row[2].asFloat;
		~baromabs.add(row[1]);
		~temps.add(row[2]);
		~barotemps.add([row[1], row[2]]);
	}
	{true}{"end csv.postln"}
});

s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	Pbindef.all.do(_.clear);
	s.sync;
	MIDIClient.init;
	MIDIIn.connectAll;
	~midiOut = MIDIOut.new(0);
	~midiIn = MIDIIn.new(0);

	~makeWaveTable = {
	|size=4096, external, name|
	var sig, wt, buf ;
	//external = external.wrapExtend(size.asInteger).asArray.normalize;
	r{
		buf = Buffer.alloc(s, size*2);
		s.sync;
		buf.sine3(
			({external.choose} !16).sort,
			({exprand(0.05, 0.9)} !16).sort,
			{rrand(0, 2pi)} !16,
			asWavetable: true
		);
		//buf.plot;
		s.sync;
		~buffers.put(name, buf);
		//~buffers[name].postln;

	}.play(AppClock);
};

	SynthDef(\baro, {
		|gate=1, freqRatio=1, modInd=1|
		var freqs = NamedControl.kr(\freqs, 800 !3);
		var temps = NamedControl.kr(\temps, 20 !3);
		var sig, mod, env;
		env = EnvGen.kr(Env([0, 1, 0], [\atk.kr(1.0), \rls.kr(1)], \crv.kr(3)), gate, doneAction:2);
		//mod = SinOsc.ar([freq, freq1, freq2] * freqRatio, mul: freq * freqRatio * modInd);
		sig = DynKlang.ar(
			`[
				// {ExpRand(freq, freq*tempFactor)}!3,
				(freqs +.t temps).poll,
				temps/100,
				{ExpRand(0.1, 0.5)}!3
			], 1, 0
		);
		//sig = PMOsc.ar(freq, freq * freqRatio, modInd);
		sig = Pan2.ar(sig, \pan.kr(0), \pLag.kr(0));
		sig = sig * env * \amp.kr(0.2);
		Out.ar(\out.kr(0), sig);
	}).add;

	SynthDef(\dynklank, {
		|gate=1, freqRatio=1, modInd=1, freqScale=1, decayScale=1|
		var freqs = NamedControl.kr(\freqs, 900 !3);
		var rings = NamedControl.kr(\rings, 20 !3) * 0.1;
		var sig, exc, env;
		env = EnvGen.kr(Env([0, 1, 0], [\atk.kr(0.01), \rls.kr(1)], \crv.kr(3)), gate, doneAction:2);
		exc = PinkNoise.ar(0.005) * Decay2.kr(Impulse.kr(0.01), 0.01, 0.5);
		sig = DynKlank.ar(
			`[
				freqs * rings,
				nil,
				rings
			], exc, freqscale: freqScale * 0.1,  decayscale: decayScale * 0.1);
		//sig = PMOsc.ar(freq, freq * freqRatio, modInd);
		sig = Pan2.ar(sig, \pan.kr(0), \pLag.kr(0));
		sig = sig * env * \amp.kr(0.2);
		Out.ar(\out.kr(0), sig);
	}).add;

	SynthDef(\arrayarg, { |out, amp = 0.1, gate = 1|
		var freqs = NamedControl.kr(\freqs, [300, 400, 500]);
		var temps = NamedControl.kr(\temps, 20 !3);
		var env, sines;
		env = Linen.kr(gate, 0.1, 1, 1, 2) * amp;
		sines = LFSaw.ar(freqs  +.t temps *2).cubed.sum; // A mix of 4 oscillators
		Out.ar(out, sines * env);
	}, [0, 0.1, 0]).add;

	SynthDef(\array_1b, { |out = 0, freq = 440, dampExp = 0,
		atk = 0.01, rls = 0.6, amp = 0.1, gate = 1, freqLag = 0.02, otLag = 0.02|
		var otAmps = NamedControl.kr(\otAmps, 1!8); // shortcut: otAmps = \otAmps.kr(1!n);
		var otFreqs= NamedControl.kr(\otFreqs, 200!8); // shortcut: otAmps = \otAmps.kr(1!n);
		var sig, env, freqs, amps;
		freqs = (freq * otFreqs).lag(freqLag);
		amps = ((otAmps / ((1..8) ** dampExp)).normalizeSum * amp).lag(otLag);
		sig = SinOsc.ar(freqs, 0, amps);
		env = EnvGen.ar(Env.asr(atk, 1, rls), gate, doneAction: 2);
		Out.ar(out, Splay.ar(sig) * env)
	}).add;

	SynthDef.new(\oscfm, {
	var sig, mod, env;
	//modulator
	mod = Osc.ar(\buf2.ir(0), \modfreq.kr(1000), mul:\modamp.kr(100));
	//a chorus of 5 slightly detuned voices
	sig = 2.collect({
		Osc.ar(\buf1.ir(0), \freq.kr(200) + mod);
	}).sum;
	env = Env(
		[0,1,0],
		[\atk.ir(0.02), \rls.ir(0.5)],
		[\atkcrv.ir(1), \rlscrv.ir(-3)]
	).ar(2);
	sig = Pan2.ar(sig, \pan.ir(0), \amp.kr(0.2) * \fade.kr(0.5));
	sig = sig * env;
	Out.ar(\out.ir(0), sig);
}).add;

	"done".postln;
})

)
(#[300, 400, 500, 600] +.t [0,0.5]).cubed.sum
[ 998.7137378093677, 998.7137378093677, 998.7137378093677 ] *0.001
1.0 / 998.7137378093677
(4096 / 282).floor
282 * 14 + 148
~baromabs.sort


(


)
~buffers[\wt].free
~makeWaveTable.(4096, ~baromabs, \baro)
Synth(\oscfm, [\atk, 1, \rls, 3])
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
)


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
