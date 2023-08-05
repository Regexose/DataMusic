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

	// Granular Synth

SynthDef(\tgrains, {
	var sig, env;
	env = Env([0,1,1,0], [\atk.ir(1),\sus.ir(4),\rls.ir(1)], [1,0,-1]).kr(2);
	sig = TGrains.ar(
		numChannels: 2,
		trigger: Dust.kr(\dens.kr(40)),
		bufnum: \buf.kr(0),
		rate: \rate.kr(1) * \harm.kr([-9, -7, -4, 0]).midiratio,
		centerPos: \pos.kr(0.5),
		dur: \grainDur.kr(1.5),
		pan: 0,
		amp: \grainAmp.kr(0.3),
		interp: \ip.kr(4)
	);
	sig = sig * env * \amp.kr(1);
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\br, {
    arg buf, rate=1, start, end;
    var sig, ptr, ptr2, env;
	ptr = Select.ar(\which.kr(0),
		[
		SinOsc.ar(\sin.kr(0.2)),
		LFNoise1.ar(\sin.kr(0.2)),
		LFTri.ar(\sin.kr(0.2)),
		]) * BufFrames.kr(buf);
	ptr2 = Phasor.ar(0, BufRateScale.kr(buf)* rate, start, end, 0.0);
    env = Env([0,1,1,0], [\atk.ir(1),\sus.ir(4),\rls.ir(1)], [1,0,-1]).kr(2);
    sig = 2.collect({
		var lag = LFNoise1.kr(\lg1.kr(0)).bipolar(\lg2.kr(0.0));
		lag = lag * s.sampleRate;
		BufRd.ar(1, buf, ptr2, \lp.kr(1.0));
	}).sum ;
    sig = sig * env * \amp.kr(0.3);
    Out.ar(\out.kr(0), sig!2);
}).add;

SynthDef(\brSec, {
	// plays Section according to indices
    arg buf, rate=1;
    var sig, secStart, secEnd, ptr, fadeIn, sus, fadeOut, env;
	secStart = \sec.kr(1) * \secIdx.kr(1);
	secEnd = secStart + \sec.kr(1);
	ptr = Phasor.ar(0.0, BufRateScale.kr(buf)* rate, secStart, secEnd, 0.0);
	sus = \sec.kr(1) / s.sampleRate;
	fadeIn = sus/10;
	fadeOut = sus/5;
	sus = sus - fadeIn - fadeOut;
    env = Env([0,1,1,0], [fadeIn, sus, fadeOut], [1,0,-1]).kr(2);
	sig = BufRd.ar(1, buf, ptr, \lp.kr(1.0));
	sig = Pan2.ar( sig, \pan.kr(0));
	sig = sig * env * \amp.kr(0.3);
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\brBF, {
	// backward and forward in sections
    arg buf;
    var sig, secStart, secEnd, dirRate, trigForw, trigBack, tracker, phsF, phsB, back, forw, env, fadeIn, sus, fadeOut;
	dirRate = \rate.kr(1);
	trigForw = Trig.kr(dirRate > 0);
	trigBack = Trig.kr(dirRate < 0);
	secStart = \sec.kr(1) * \secIdx.kr(1);
	secEnd = secStart + \sec.kr(1);
	tracker = Phasor.ar(0, dirRate,  0, BufFrames.kr(buf));
	phsF = Phasor.ar(trigForw, BufRateScale.kr(buf) * dirRate * \harm.kr([9, 3, 0]).midiratio, secStart, secEnd, tracker);
	phsB = Phasor.ar(trigForw, BufRateScale.kr(buf) * dirRate * \harm.kr([9, 3, 0]).midiratio, secStart, secEnd, tracker);
	forw = BufRd.ar(1, buf, phsF, 1);
	back = BufRd.ar(1, buf, phsB, 1);
	sus = (\sec.kr(1) / s.sampleRate);
	fadeIn = sus/10;
	fadeOut = sus/5;
	sus = sus - fadeIn - fadeOut;
    env = Env([0,1,1,0], [fadeIn, sus, fadeOut], [1,0,-1]).kr(2);
	sig = XFade2.ar(back, forw, dirRate.lag(\dirlag.kr(0.2)));
    sig = sig * env * \amp.kr(0.3);
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\samp, {
	var buf = \buf.kr();
	var rate = \rate.kr(1);
	var trigForw = Trig.kr(rate > 0);
	var trigBack = Trig.kr(rate < 0);
	var tracker = Phasor.ar(0, rate, 0, BufFrames.kr(buf));
	var phaseForw = Phasor.ar(trigForw, BufRateScale.kr(buf)* rate, 0, BufFrames.kr(buf), tracker);
	var phaseBack = Phasor.ar(trigBack, BufRateScale.kr(buf)* rate, 0, BufFrames.kr(buf), tracker);

	var back = BufRd.ar(1, buf, phaseBack)!2;
	var forw = BufRd.ar(1, buf, phaseForw)!2;

	Out.ar(\bus.kr(0), XFade2.ar(back, forw, rate.lag(\lt.kr(0.2)), level: \amp.kr(0.3)))
}).add;

// record stuff with mic
SynthDef(\rec, {
	var sig;
	sig = In.ar(\in.kr(2));
	Out.ar(0, sig!2 * \amp.kr(0.5));
}).add;