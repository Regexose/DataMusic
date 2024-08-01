
// Vowel Synthesis
SynthDef(\bpfstack, {
    |vow=0, buf=0|
    // für flexible Vokale: https://scsynth.org/t/dictionary-keys-as-synthdef-arguments/5886/4
    var sig, sig2, env, ptr, array,  vowel, baseIndex, freqs, widths, dBs;
    baseIndex = vow * 15; //jeder Vokal hat 15 Werte, Index=0 -> erster Vokal
  /*  "vow = % baseIndex = % ".format(vow, baseIndex).postln;
    "vowel Array  %".format(~vowelArray[15 + (0..4)]).postln;*/
    freqs = Select.kr(baseIndex + (0..4), ~vowelArray);
    widths = Select.kr(baseIndex + (5..9), ~vowelArray);
    dBs = Select.kr(baseIndex + (10..14), ~vowelArray);
    env = Env.perc(\atk.kr(0.01), \rls.kr(0.5)).kr(2);
    ptr = Phasor.ar(0, 1, 0, BufFrames.kr(buf));
    vowel = Vowel.basicNew(freqs, dBs, widths);
    sig = BPFStack.ar(BufRd.ar(1, buf, ptr, loop:1), vowel, \freqMods.kr(0.5), \ampMods.kr(0.5),  \widthMods.kr(1));
    sig = sig * env * \amp.kr(0.4) * \fade.kr(1);
    sig = RLPF.ar(sig, \ffreq.kr(4000));
    sig2 = BufRd.ar(1, buf, ptr) * env;
    Out.ar(\out.kr(0), sig!2);
    Out.ar(\outdry.kr(0), sig2);
}).add;

SynthDef(\vowelklank, {
	|vow=1, freqScale=0.1, decayScale=0.1, buf=0, gate=1|
    var sig, env, vowel, baseIndex, freqs, widths, dBs, phases, exc;
    baseIndex = vow * 15; //jeder Vokal hat 15 Werte, Index=0 -> erster Vokal
    freqs = Select.kr(baseIndex + (0..4), ~vowelArray);
    widths = Select.kr(baseIndex + (5..9), ~vowelArray);
    dBs = Select.kr(baseIndex + (10..14), ~vowelArray);
    vowel = Vowel.basicNew(freqs, dBs, widths);
    phases = \phs.kr(1)!5;
	env = Env.asr(\atk.ir(0.1),1,\rls.ir(1)).kr(2, gate);
    exc = BufRd.ar(1, buf, Phasor.ar(0, 1, 0, BufFrames.ir(buf)));
    //exc = WhiteNoise.ar(0.5);
	sig = DynKlank.ar(
		`[
			freqs * \fScale.kr(1),
			dBs.dbamp.normalizeSum,
			phases
	], exc, freqscale: freqScale,  decayscale: decayScale);
    sig = LPF.ar(sig, \ffreq.kr(500)).poll;
	sig = Pan2.ar(sig, \pan.kr(0));
	sig = sig * env * \amp.kr(0.2) * \fade.kr(0.4);
	Out.ar(\out.kr(0), sig);
    Out.ar(\outdry.kr(2), exc);
}).add;

SynthDef(\oddeven, {
    |baseFreq = 100, vowelIndex|
	var numFreqs = 19;
	//var startFilterOrder = 0.1;
	var startFilterOrders = NamedControl.kr(\startFilterOrders, {exprand(0.1, 3.3)}!5);
	//var stopFilterOrders = [0.8, 0.65, 0.5, 0.35, 0.1];
	var stopFilterOrders = NamedControl.kr(\stopFilterOrders, [2.0, 4.0, 0.25, 0.5, 3.25]);
	var sig, baseIndex, vowel, selectfreqs, selectamps, selectwidths, freqs, evenFreqs, oddFreqs, amps, evenAmps, oddAmps, orders;
	var evenAmpMod = SinOsc.kr(\ampFreq.kr(1)).exprange(\modRange1.kr(0.04), \modRange2.kr(0.6)).sqrt;
	var oddAmpMod = SinOsc.kr(freq: 1, phase: pi).exprange(\modRange1.kr(0.04), \modRange2.kr(0.6)).sqrt;
    var ampEnv = Env.perc(\atk.kr( 0.01),\rls.kr( 0.2), curve: \crv.kr(0)).kr(doneAction: 2);


    baseIndex = vowelIndex * 15; //jeder Vokal hat 15 Werte, Index=0 -> erster Vokal
    selectfreqs = Select.kr(baseIndex + (0..4), ~vowelArray);
    selectwidths = Select.kr(baseIndex + (5..9), ~vowelArray);
    selectamps = Select.kr(baseIndex + (10..14), ~vowelArray);
    vowel = Vowel.basicNew(selectfreqs, selectamps, selectwidths).brightenExp(\bright.kr(1));

	evenFreqs = ((1, 3 .. numFreqs) * baseFreq);
	oddFreqs = ((2, 4 .. numFreqs) * baseFreq);

	// there are 5 formants in each vowel, ergo 5 filter orders may be provided
	orders = stopFilterOrders.collect{|stop, i|
        //"Env % start: % , stop: %  dur: %".format(i, startFilterOrders[i], stopFilterOrders[i],  (2 * i )).postln;
        stop * EnvGen.kr(Env([startFilterOrders[i]/stop, 1.0] , (2 * i), curve: 3), timeScale: \envScale.kr(1));

	};

	evenAmps = vowel.ampAt(evenFreqs, orders ) * evenAmpMod;
    oddAmps = vowel.ampAt(oddFreqs, orders) * oddAmpMod;

	freqs = (evenFreqs ++ oddFreqs);
	amps = evenAmps ++ oddAmps;

	amps = amps.normalizeSum; // tame amplitudes

    sig = DynKlang.ar(`[freqs, amps, nil], \freqScale.kr(0.1) ) * \amp.kr(0.1) * ampEnv ;
    Out.ar(\out.kr(0), sig!2);
}).add;


SynthDef(\dynklank, {
	| freqScale=0.1, decayScale=0.1|
	var freqs = NamedControl.kr(\freqs, 900 !3) + SinOsc.kr([0.2,0.1,0.05]).bipolar(-10, 10);
    var amps = NamedControl.kr(\amps, [0.2, 0.1, 0.4]);
	var rings = NamedControl.kr(\rings, 2 !3) ;
	var sig, exc, env;
	env = Env.asr(\atk.ir(0.1),\sus.ir(1),\rls.ir(1)).kr(2, \gate.kr(1));
    exc = PinkNoise.ar(\punch.kr(0.1)) * Decay2.kr(Impulse.kr(0.5), 0.01, \dec.kr(0.9));
	sig = DynKlank.ar(
		`[
			freqs ,
			amps,
			rings
	], exc, freqscale: freqScale,  decayscale: decayScale);
    sig = BPF.ar(sig, \ffreq.kr(1800), \rq.kr(0.5));
	sig = Pan2.ar(sig, \pan.kr(0), \pLag.kr(0.01));
	sig = sig * env * \amp.kr(0.2) * \fade.kr(1);
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\crisps, {
    var exc, freqs, rings, amps, sig, env, trig, freqMod;
    // env = Env.perc(\atk.kr(0.01), \rls.kr(0.08)).kr(2);
    var freqArray = NamedControl.kr(\freq, [80, 120, 350, 1010]);
    var ampArray = NamedControl.kr(\levels, [0.5, 0.24, 0.14, 0.423]);
    var ringArray = NamedControl.kr(\ring, [0.1, 0.04, 0.04, 0.023]);
    freqs = freqArray.collect({
        |f|
        var area = Array.fill(3, {linrand((f- (f/10)), f+ (f/10))});
        //"freqArea  %".format(area).postln;
        area;

    }).flat;
    amps = ampArray.collect({
        |a|
        var area = Array.fill(3, {linrand((a- (a/10)), a+ (a/10))});
        //"freqArea  %".format(area).postln;
        area;
    }).flat;
    rings = ringArray.collect({
        |r|
        var area = Array.fill(3, {linrand(0.05, 0.6)});
        //"ampArea  %".format(area).postln;
        area;
    }).flat ;
    trig = Dust.kr(\trg.kr(4));
    SendTrig.kr(trig);
    freqMod = TRand.kr( 1, 5, trig)  ;
    exc = WhiteNoise.ar(\punch.kr(0.1)) * Decay2.kr(trig, 0.001, \dec.kr(0.9));
    sig = Klank.ar(`[
        freqs,
        amps,
        rings
    ], exc, \freqScale.kr(0.4) *freqMod);
    sig = Pan2.ar(BPF.ar(sig, \ffreq.kr(1000) * freqMod, \rq.kr(1.0)), \pan.kr(0.0));
    sig = sig * \amp.kr(0.3);
    Out.ar(\out.kr, sig);
}).add;

//https://www.youtube.com/watch?v=xYc7_PbbtuE&t=1579s  ab 30:00
SynthDef(\snare, {
	var sig;
	sig = SinOsc.ar(\freq.kr(200) * (1 + (2* Env.perc(0.001, 0.03).ar)) * [1, 2.3, 3.5, 5.8]); // multichannel
	sig = sig * Env.perc(0, [2, 0.4, 0.2, 0.1]).ar; // multichannel
	sig = sig * [0, -20, -12, -24].dbamp; // multichannel
	sig = sig.sum;
	sig = sig + (SinOsc.ar(XLine.ar(3000, 100, 0.03)) * Env.perc(0.01, 0.03).ar); // klick
	sig = sig + (BPF.ar(Hasher.ar(Sweep.ar), \shapFreq1.kr(2120), 0.3) + Env.perc(0.05, 0.1).ar * \shaper1.kr(0.5)); // different timmbres
	sig = sig + ((sig * 13.dbamp).tanh * -10.dbamp); // paralell distortion
	sig = sig * Env.perc(0.001, \envsus.kr(0.75), curve: -4).ar;
	sig = sig +( GVerb.ar(sig, 16, 2) * -30.dbamp);
	sig = sig * Env.perc(0.001, \envlast.kr(1), curve: -4).ar(Done.freeSelf);
	sig = sig * \amp.kr(-5.dbamp);
	sig = Pan2.ar(sig, \pan.kr(0));
	Out.ar(\out.kr(0), sig);
}).add;


SynthDef(\arrayarg, { |out, amp = 0.1, gate = 1|
	var freqs = NamedControl.kr(\freq, [200, 400]);
    var mods = NamedControl.kr(\mods, [ 0, 0]);
	var env,sines, sines2, sig;
	env = Linen.kr(gate,\atk.kr(0.1), 1, \rls.kr(1), 2) ;
    sines = SinOsc.ar(freqs.varlag(\lg.kr(0.2)) + mods, SinOsc.kr(\phsMod.kr(0.2))).sum;
	sines = Splay.ar(sines, 1)  * \fade.kr(0.6);
	sines =  RLPF.ar(sines, \ffreq.kr(200), \rq.kr(0.5));
    sig = sines * env * amp;
	Out.ar(out, sig );
}).add;

SynthDef(\array_1b, { |out = 0, freq = 440, dampExp = 0,
	atk = 0.01, rls = 0.6, ampA = 0.1, gate = 1, freqLag = 0.02, otLag = 0.02|
	var otAmps = NamedControl.kr(\otAmps, 0.2!8); // shortcut: otAmps = \otAmps.kr(1!n);
	var otFreqs= NamedControl.kr(\otFreqs, Array.fill(8, {[0.5, 0.25, 1, 2, 4].choose})); // shortcut: otAmps = \otAmps.kr(1!n);
	var sig, env, freqs, amps;
	freqs = (freq * otFreqs).lag(freqLag);
	amps = ((otAmps / ((1, 1.5..4) ** dampExp)).normalizeSum * ampA).lag(otLag);
    sig = 3.collect({
        var fmod, ampmod;
        fmod = {ExpRand(0.98, 1.02)};
        ampmod = Dust.kr(50).bipolar(0.03);
        SinOscFB.ar(freqs * fmod, \feedb.kr(pi/4), amps + ampmod);
    }).sum;
	sig = RLPF.ar(sig, \ffreq.kr(200), \rq.kr(0.5));
	env = EnvGen.ar(Env.asr(atk, 1, rls), gate, doneAction: 2);
	Out.ar(out, Splay.ar(sig) * env * \fade.kr(1));
}).add;


// Granular Synth
//https://www.youtube.com/watch?v=C9SeVpiyGmI&t=607s  30:00
SynthDef(\tgrains_live, {
	var sig, sig2, env, mic, pos, ptr, buf=\buf.kr(0);
	env = Env.asr(\atk.ir(1),\sus.ir(1),\rls.ir(1)).kr(2, \gate.kr(1));
	mic = SoundIn.ar(0, \in.kr(1));
	ptr = Phasor.ar(0, 1, 0, BufFrames.kr(buf));
	BufWr.ar(mic, buf, ptr);
	pos = (ptr/SampleRate.ir) -1;
	pos = pos + LFNoise1.kr(100).bipolar(\jitter.kr(0.0));
	sig = TGrains.ar(
		numChannels: 2,
		trigger: Impulse.kr(\dens.kr(40)),
		bufnum: \buf.kr(0),
		rate: \rate.kr(1) * \harm.kr([0, 0]).midiratio,
		centerPos: pos,
		dur: \grainDur.kr(1.5),
		pan: 0,
		amp: \grainAmp.kr(0.3),
		interp: \ip.kr(4)
	);
	sig2 = BufRd.ar(1, buf, ptr) * env;
    sig = sig * \duck.kr(1).varlag(0.5);
	sig = sig * env * \amp.kr(1) * \fade.kr(1.0);
	Out.ar(\out.kr(0), sig);
	Out.ar(\outdry.kr(0), sig2);
}).add;

SynthDef(\tgrains, {
	var sig, sig2, ptr, env, buf;
    buf = \buf.kr(0);
	env = Env.asr(\atk.ir(0.1),\sus.ir(1),\rls.ir(1)).kr(2, \gate.kr(1));
    ptr = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf)-1);
    sig2 = BufRd.ar(1, buf, ptr) * env ;
	sig = TGrains.ar(
		numChannels: 2,
		trigger: Dust.kr(\dens.kr(12)),
		bufnum: buf,
		rate: \rate.kr(1) * (\harm.kr([0, 0]).midiratio),
		centerPos: \pos.kr(0.5),
		dur: \grainDur.kr(1.5),
		pan: \pan.kr(0),
		amp: \grainAmp.kr(0.3),
		interp: 4
	);
    sig = RLPF.ar(sig, \ffreq.kr(200), \rq.kr(0.9));
	sig = sig * env * \amp.kr(1) * \fade.kr(1);
    Out.ar(\out.kr(0), sig);
	Out.ar(\outdry.kr(0), sig2);
}).add;

// Scrubbing GrainSynth von Tgrains2 helpfile
SynthDef(\grainScrub, {
    |buf=0|
    var sig, sig2, tr, trSpec, dur, clk, posSpec, pos, pan, env;
    trSpec =  [8, 60, \lin].asSpec;
    posSpec = [0, BufDur.kr(buf), \lin].asSpec;
    pos = posSpec.map(\pos.kr(0));
    tr = trSpec.map(\tr.kr(0.2));// trigger Rate: wie oft wird ein Grain abgespielt
    dur = (12 / tr); // Grain Länge: bei langer trigger Rate längere Grains
    clk = Impulse.kr(tr); // triggert die Grains, relativ zu ihrer Dauer
    pos = pos + TRand.kr(0, 0.01, clk); // das TRand macht einen "an der POsition stehenbleiben"- Effekt, ohne den wäre die Position zu scharfkantig
    pan = WhiteNoise.kr(\pan.kr(0.5));
    sig = TGrains2.ar(
        numChannels: 2,
        trigger: clk,
        bufnum: buf,
        rate: \rate.kr(1) *  \harm.kr(0).midiratio,
        centerPos: pos,
        dur: dur,
        pan: pan,
        amp: 0.1,
        att: dur * 0.3,
        dec: dur * 0.5);
    env = Env.asr(\atk.ir(0.1),\sus.ir(1),\rls.ir(1)).kr(2, \gate.kr(1));
    sig = sig * \amp.kr(0.3) * \fade.kr(1) * env;
    sig = RLPF.ar(sig, \ffreq.kr(1500), \rq.kr(0.9));
    sig2 = TGrains2.ar(2, clk, buf, 1, pos, dur, pan, 0.1, dur * 0.3, dur * 0.5) * env;
    Out.ar(\out.kr(0), sig);
    Out.ar(\outdry.kr(3), sig2);
}).add;



SynthDef(\br, {
	arg buf=0, rate=1, start=0, end;
	var sig, sig2, ptr, ptr2, env;
	env = Env.asr(\atk.ir(1),\sus.ir(1),\rls.ir(1)).kr(2, \gate.kr(1));
	ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate * \harm.kr(0).midiratio, start, end);
	ptr2 = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf)-1);
    sig2 = BufRd.ar(1, buf, ptr2) * env;
	sig = 2.collect({
		var lag = LFNoise1.kr(\lg1.kr(0)).bipolar(\lg2.kr(0.0));
		lag = lag * s.sampleRate;
		BufRd.ar(1, buf, ptr + lag, \lp.kr(1.0));
	}).sum ;
	sig = RLPF.ar(sig, \ffreq.kr(200), \rq.kr(0.5));
	sig = sig * env * \amp.kr(0.3) * \fade.kr(1);
	Out.ar(\out.kr(0), sig);
	Out.ar(\outdry.kr(0), sig2);
}).add;

SynthDef(\brsaw, {
	arg buf=0, rate=1, start=0, end;
	var sig, sig2, ptr, ptr2, env;
	env = Env.asr(\atk.ir(1),\sus.ir(1),\rls.ir(1)).kr(2, \gate.kr(1));
    // garantiert die Originalgeschwindigkeit, \freq ist speedcontrol
    ptr = LFSaw.ar(BufDur.ir(buf).reciprocal * \freq.kr(1)).range(0, BufFrames.ir(buf));
    sig2 = BufRd.ar(1, buf, ptr) * env;
	sig = BufRd.ar(1, buf, ptr );
	sig = RLPF.ar(sig, \ffreq.kr(4000), \rq.kr(0.5));
	sig = sig * env * \amp.kr(0.3) * \fade.kr(1);
	Out.ar(\out.kr(0), sig);
	Out.ar(\outdry.kr(0), sig2);
}).add;


// record stuff with mic until buffer is full
SynthDef(\recOne, {
	|len=4|
	var input, ptr, buf= \buf.kr(0);
	input = SoundIn.ar(\in.kr(0));
	ptr = Line.ar(0, BufFrames.kr(buf), BufDur.kr(buf));
	SendReply.kr(Impulse.kr(100), '/cursor', ptr);
	BufWr.ar(input, buf, ptr);
}).add;

SynthDef(\routing, {
	var sig = In.ar(\in.kr(0), 2);
	sig = sig * \fade.kr(0.0);
	Out.ar(\out.kr(0), sig);
}).add;


// record stuff with mic
SynthDef(\rec, {
	|len=4|
	var input, ptr, buf= \buf.kr(0);
	input = SoundIn.ar(\in.kr(0));
	ptr = Phasor.ar(0, 1, 0, BufFrames.kr(buf));
	SendReply.kr(Impulse.kr(100), '/cursor', ptr);
	BufWr.ar(input, buf, ptr);
	//RecordBuf.ar(input, \buf.kr(0), recLevel: 1.0, preLevel: 0.5, run: \run.kr(1.0), loop: 0.0, doneAction:2)
}).add;

//playback
SynthDef(\playback, {
	var sig;
	sig = PlayBuf.ar(1, \buf.kr(0));
	FreeSelfWhenDone.kr(sig);
	Out.ar(\out.kr(0), sig!2);
}).add;


// building Effect Instruments
// http://www.dewdrop-world.net/sc3/tutorials/index.php?id=5
//Spec.specs.asSortedArray.do(_.postcs)

Instr(#[\busfx, \ring1], { arg bus, numChan, freq, mod_amp, xfade;
	var sig, new;
	sig = In.ar(bus, numChan);
	new = sig * SinOsc.ar(freq, 0, mod_amp);
	XFade2.ar(sig, new, xfade * 2 - 1)
}, [\audiobus, ObjectSpec(2), \freq, \amp, \amp]
);

Instr(#[\busfx, \chorus], { arg bus, numChan, predelay, speed, depth, ph_diff, xfade;
	var in, sig;
	in = In.ar(bus, numChan);
	in.isKindOf(Collection).if({
		sig = in.collect({ arg ch, i;   // ch is one channel
			DelayL.ar(ch, 0.5, SinOsc.kr(speed, ph_diff * i, depth, predelay));
		});
	}, {
		sig = DelayL.ar(in, 0.5, SinOsc.kr(speed, ph_diff, depth, predelay));
	});
	XFade2.ar(in, sig, xfade * 2 - 1);
	//   xf.value(in, sig, xfade)      // when felix has XOut working, this can be better
}, [\audiobus, ObjectSpec(1), #[0.0001, 0.4, \linear, 0, 0.1],
	#[0.001, 20, \exponential], #[0.0001, 0.25, \exponential], #[0, 2pi], #[0, 1]]
);


Instr(#[\busfx, \companderd], { arg bus, numChannels, thresh, slopeBelow, slopeAbove,
 	clampTime, relaxTime, postGain;
 	var sig;
 	sig = In.ar(bus, numChannels);
 	CompanderD.ar(sig, thresh, slopeBelow, slopeAbove, clampTime, relaxTime, postGain);
 	}, [\audiobus, ObjectSpec(2), #[0, 1, \linear, 0, 0.5], #[0.1, 10, \exponential, 0, 1],
 		#[0.1, 10, \exponential, 0, 1], #[0.001, 5, \exponential], #[0.001, 5, \exponential],
 	#[0.1, 10, \exponential, 0, 1]]
 );

Instr(#[\busfx, \singleDelay], { arg bus, numChan, delayClass, maxTime, time, mul, add;
	delayClass.ar(In.ar(bus, numChan), maxTime, time, mul, add)
}, [\audiobus, ObjectSpec(1), ObjectSpec(DelayL), #[0.25, 20], #[0.0001, 20]]
);

//more a delay than reverb
Instr(#[\busfx, \rvb_allpass], { arg bus, numChan, maxDelay, preDelay, decay,
	numRefl, random;
	var sig, new;
	sig = In.ar(bus, numChan);
	new = sig;
	numRefl.do({
		new = AllpassN.ar(new, maxDelay, Array.fill(numChan, { random.rand }) + preDelay, decay);
	});
	new;
}, [\audiobus, ObjectSpec(2), #[0.25, 2], #[0.4, 1.5, \exponential, 0, 0.05],
	#[0.01, 10, \exponential, 0, 0.25], ObjectSpec(4), #[0.001, 1, \exponential, 0, 0.03]]
);
// specifications are ControlSpecs, which can be defined in a shortcut syntax using an array: [low value, high value, warp style, step size, default]
Instr(#[\busfx, \vrb1], { arg bus, numChan, room, damp, mult;
	var sig, new;
	sig = In.ar(bus, numChan);
	sig = FreeVerb.ar(sig, 1, room, damp, mult);
}, [\audiobus, ObjectSpec(2), #[0.1, 1.0, \linear, 0, 0.85], #[0.1, 1.0, \exponential, 0, 0.5],  #[1, 10, \exponential, 0, 4.5]]
);

Instr(#[\busfx, \limiter], { arg bus, numChannels, level, lookAhead, gain;
	Limiter.ar(In.ar(bus, numChannels), level, lookAhead) * gain;
}, [\mybuf, ObjectSpec(2), #[0, 1, \linear, 0, 1], #[0.001, 0.2],
	#[0.1, 4, \exponential, 0, 1]]
);
