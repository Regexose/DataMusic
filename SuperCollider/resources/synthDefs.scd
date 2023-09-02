SynthDef(\dynklank, {
	|freqRatio=1, modInd=1, freqScale=1, decayScale=1|
	var freqs = NamedControl.kr(\freqs, 900 !3);
	var rings = NamedControl.kr(\rings, 20 !3) * 0.1;
	var sig, exc, env;
	env = Env.asr(\atk.ir(1),\sus.ir(1),\rls.ir(1)).kr(2, \gate.kr(1));
	exc = PinkNoise.ar(0.1) * Decay2.kr(Impulse.kr(\imp.kr(0.5)), 0.01, \dec.kr(0.9));
	sig = DynKlank.ar(
		`[
			freqs * rings,
			nil,
			rings
	], exc, freqscale: freqScale * 0.1,  decayscale: decayScale * 0.1);
	sig = Pan2.ar(sig, \pan.kr(0), \pLag.kr(0));
	sig = sig * env * \amp.kr(0.2) * \fade.kr(1);
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\arrayarg, { |out, amp = 0.1, gate = 1|
	var freqs = NamedControl.kr(\freqs, [300, 600, 1200]);
	var temps = NamedControl.kr(\temps, (pi/2)!3);
	var env,sines, sines2, sig;
	env = Linen.kr(gate,\atk.kr(0.1), \sus.kr(0.5), \rls.kr(1), 2) * amp;
	sines =  PMOsc.ar(freqs.varlag(\lag.kr(0.5)), freqs * \mod.kr(1), LFNoise2.kr(1) * \pm.kr(0.0));
	sines2 =  PMOsc.ar(freqs.varlag(0.5), freqs * 1);
	sines = Splay.ar(sines)  * \fade.kr(0.6);
	sines2 = Splay.ar(sines2) * \fade2.kr(0.1);
	sines =  RLPF.ar(sines, \ffreq.kr(200), \rq.kr(0.5));
    sig = Mix.ar([sines, sines2]) * env;
	Out.ar(out, sig );
}).add;

SynthDef(\array_1b, { |out = 0, freq = 440, dampExp = 0,
	atk = 0.01, rls = 0.6, amp = 0.1, gate = 1, freqLag = 0.02, otLag = 0.02|
	var otAmps = NamedControl.kr(\otAmps, 1!8); // shortcut: otAmps = \otAmps.kr(1!n);
	var otFreqs= NamedControl.kr(\otFreqs, 200!8); // shortcut: otAmps = \otAmps.kr(1!n);
	var sig, env, freqs, amps;
	freqs = (freq * otFreqs).lag(freqLag);
	amps = ((otAmps / ((1..8) ** dampExp)).normalizeSum * amp).lag(otLag);
	sig = SinOsc.ar(freqs, 0, amps);
	sig = RLPF.ar(sig, \ffreq.kr(200), \rq.kr(0.5));
	env = EnvGen.ar(Env.asr(atk, 1, rls), gate, doneAction: 2);
	Out.ar(out, Splay.ar(sig) * env * \fade.kr(1));
}).add;


// Granular Synth

SynthDef(\tgrains, {
	var sig, sig2, ptr, env, buf;
    buf = \buf.kr(0);
	env = Env.asr(\atk.ir(0.1),\sus.ir(1),\rls.ir(1)).kr(2, \gate.kr(1));
    ptr = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf)-1);
    sig2 = BufRd.ar(1, buf, ptr);
	sig = TGrains.ar(
		numChannels: 2,
		trigger: Dust.kr(\dens.kr(12)),
		bufnum: buf,
		rate: \rate.kr(1) * (\harm.kr([-7, -4, 0]).midiratio),
		centerPos: \pos.kr(0.5),
		dur: \grainDur.kr(1.5),
		pan: \pan.kr(0),
		amp: \grainAmp.kr(0.3),
		interp: 4
	);
    sig2 = sig2 * env * \fade2.kr(0.1);
    sig = RLPF.ar(sig, \ffreq.kr(200), \rq.kr(0.9));
	sig = sig * env * \amp.kr(1) * \fade.kr(1);
    Out.ar(\out.kr(0), Mix.ar([sig, sig2]));
}).add;

//https://www.youtube.com/watch?v=C9SeVpiyGmI&t=607s  30:00
SynthDef(\tgrains_live, {
	var sig, env, mic, pos, ptr, buf=\buf.kr(0);
	env = Env.asr(\atk.ir(1),\sus.ir(1),\rls.ir(1)).kr(2, \gate.kr(1));
	mic = SoundIn.ar(0, \in.kr(1));
	ptr = Phasor.ar(0, 1, 0, BufFrames.kr(buf));
	BufWr.ar(mic, buf, ptr);

	pos = (ptr/SampleRate.ir) -1;
	pos = pos + LFNoise1.kr(100).bipolar(0.0);

	sig = TGrains.ar(
		numChannels: 2,
		trigger: Dust.kr(\dens.kr(40)),
		bufnum: \buf.kr(0),
		rate: \rate.kr(1) * \harm.kr(0).midiratio,
		centerPos: pos,
		dur: \grainDur.kr(1.5),
		pan: 0,
		amp: \grainAmp.kr(0.3),
		interp: \ip.kr(4)
	);
	sig = sig * env * \amp.kr(1) * \fade.kr(1);
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\br, {
	arg buf=0, rate=1, start=0, end;
	var sig, sig2, ptr, ptr2, env;
	ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate * \harm.kr(0).midiratio, start, end);
	ptr2 = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf)-1);
    sig2 = BufRd.ar(1, buf, ptr2);
	env = Env.asr(\atk.ir(1),\sus.ir(1),\rls.ir(1)).kr(2, \gate.kr(1));
	sig = 2.collect({
		var lag = LFNoise1.kr(\lg1.kr(0)).bipolar(\lg2.kr(0.0));
		lag = lag * s.sampleRate;
		BufRd.ar(1, buf, ptr + lag, \lp.kr(1.0));
	}).sum ;
	sig = RLPF.ar(sig, \ffreq.kr(200), \rq.kr(0.5));
    sig2 = sig2 * env * \fade2.kr(0.1);
	sig = sig * env * \amp.kr(0.3) * \fade.kr(1);
    sig = Mix.ar([sig, sig2]);
	Out.ar(\out.kr(0), sig);
}).add;


// record stuff with mic untif buffer is full
SynthDef(\recOne, {
	|len=4|
	var input, ptr, buf= \buf.kr(0);
	input = SoundIn.ar(\in.kr(0));
	ptr = Line.ar(0, BufFrames.kr(buf), BufDur.kr(buf));
	SendReply.kr(Impulse.kr(100), '/cursor', ptr);
	BufWr.ar(input, buf, ptr);
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
