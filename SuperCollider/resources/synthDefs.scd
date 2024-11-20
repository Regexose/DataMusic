
// Vowel Synthesis
SynthDef(\bpfstack, {
    |vow=0, buf=0|
    // für flexible Vokale: https://scsynth.org/t/dictionary-keys-as-synthdef-arguments/5886/4
    var sig, dry, env, ptr, array,  vowel, baseIndex, freqs, widths, dBs;
    baseIndex = vow * 15; //jeder Vokal hat 15 Werte, Index=0 -> erster Vokal
  /*  "vow = % baseIndex = % ".format(vow, baseIndex).postln;
    "vowel Array  %".format(~vowelArray[15 + (0..4)]).postln;*/
    freqs = Select.kr(baseIndex + (0..4), ~vowelArray);
    widths = Select.kr(baseIndex + (5..9), ~vowelArray);
    dBs = Select.kr(baseIndex + (10..14), ~vowelArray);
    //env = EnvGen.kr(Env([0, 1, 0],[\atk.kr(0.5), \rls.kr(0.5)]), doneAction:0); //mit Env endet der Synth vorzeitig
    ptr = Phasor.ar(0, 1, 0, BufFrames.kr(buf));
    vowel = Vowel.basicNew(freqs, dBs, widths);
    sig = BPFStack.ar(BufRd.ar(1, buf, ptr, loop:1), vowel, \freqMods.kr(0.5), \ampMods.kr(0.5),  \widthMods.kr(1));
    sig = sig * \amp.kr(0.4) * \fade.kr(1); // * env;
    sig = RLPF.ar(sig, \ffreq.kr(4000));
    dry = BufRd.ar(1, buf, ptr); // * env;
    sig = (sig * (1.0 - \drywet.kr(0))) + (dry * \drywet.kr(0));
    Out.ar(\out.kr(0), sig!2);
    Out.ar(\outdry.kr(0), dry);
}).add;

SynthDef(\vowelklank, {
	|vow=1, freqScale=0.1, decayScale=0.1, buf=0, gate=1|
    var sig, dry, ptr, env, vowel, baseIndex, freqs, widths, dBs, phases, exc;
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
			freqs,
			dBs.dbamp.normalizeSum,
			phases
	], exc, freqscale: freqScale,  decayscale: decayScale);

    sig = RLPF.ar(sig, \ffreq.kr(500).varlag(0.2), \rq.kr(0.5));
	sig = Pan2.ar(sig, \pan.kr(0)) * env;
    ptr = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf)-1);
    dry = BufRd.ar(1, buf, ptr);
    sig = (dry * (1.0 - \drywet.kr(0).varlag(0.3))) + (sig * \drywet.kr(0).varlag(0.3));
	sig = sig * \amp.kr(0.2) * \fade.kr(0.4);
	Out.ar(\out.kr(0), sig);
    //Out.ar(\outdry.kr(2), exc);
}).add;

SynthDef(\voweltrig, {
	|vow=1, freqScale=0.1, decayScale=0.1, buf=0, gate=1|
    var sig, env, vowel, baseIndex, freqs, widths, dBs, phases, exc, trig;
    baseIndex = vow * 15; //jeder Vokal hat 15 Werte, Index=0 -> erster Vokal
    freqs = Select.kr(baseIndex + (0..4), ~vowelArray);
    widths = Select.kr(baseIndex + (5..9), ~vowelArray);
    dBs = Select.kr(baseIndex + (10..14), ~vowelArray);
    vowel = Vowel.basicNew(freqs, dBs, widths);
    phases = \phs.kr(1!5);
	env = Env.asr(\atk.ir(0.1),1,\rls.ir(1)).kr(2, gate);
    trig = Dust.kr(\trg.kr(4));
    exc = BufRd.ar(1, buf, Phasor.ar(0, 1, 0, BufFrames.ir(buf))) * Decay2.kr(trig, \att.kr(0.001), \dec.kr(0.9));
	sig = DynKlank.ar(
		`[
			freqs * \fScale.kr(1),
			dBs.dbamp.normalizeSum,
			phases
	], exc, freqscale: freqScale,  decayscale: decayScale);

    sig = BPF.ar(sig, \ffreq.kr(500), \rq.kr(0.3));
	sig = Pan2.ar(sig, \pan.kr(0));
	sig = sig * env * \amp.kr(0.2) * \fade.kr(0.4);
	Out.ar(\out.kr(0), sig);
    Out.ar(\outdry.kr(2), exc);
}).add;

SynthDef(\oddeven, {
    |buf=0, baseFreq = 100, vowelIndex, modRange1=0.04, modRange2=0.6|
    var numFreqs = 19;
    var startFilterOrders = NamedControl.kr(\startFilterOrders, {exprand(0.1, 3.3)}!5);
    var stopFilterOrders = NamedControl.kr(\stopFilterOrders, [2.0, 4.0, 0.25, 0.5, 3.25]);
    var sig, exc, baseIndex, vowel, selectfreqs, selectamps, selectwidths, freqs, evenFreqs, oddFreqs, amps, evenAmps, oddAmps, orders;
    var evenAmpMod = SinOsc.kr(\ampFreq.kr(1)).exprange(modRange1, modRange2).sqrt;
    var oddAmpMod = SinOsc.kr(freq: 1, phase: pi).exprange(modRange1, modRange2).sqrt;
    var dry, ptr;
    var env = EnvGen.kr( Env.asr(\atk.kr( 0.01), 1, \rls.kr( 0.7), \crv.kr(0)), \gate.kr(1), doneAction:2);

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
     exc = BufRd.ar(1, buf, Phasor.ar(0, 1, 0, BufFrames.ir(buf)));
    sig = DynKlank.ar(`[freqs, amps, nil], exc, \freqScale.kr(0.1) );

    ptr = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf)-1);
    dry = BufRd.ar(1, buf, ptr);
    sig = (dry * (1.0 - \drywet.kr(0).varlag(0.3))) + (sig * \drywet.kr(0).varlag(0.3));
    sig = sig * \amp.kr(0.2) * \fade.kr(0.4) * env;
    Out.ar(\out.kr(0), sig!2);
}).add;


SynthDef(\dynklank, {
	| freqScale=0.1, decayScale=0.1|
	var freqs = NamedControl.kr(\freqs, 900 !3) ;
    var amps = NamedControl.kr(\amps, [0.2, 0.1, 0.4]);
	var rings = NamedControl.kr(\rings, 2 !3) ;
	var sig, exc, env;
	env = Env.asr(\atk.ir(0.1),\sus.ir(1),\rls.ir(1)).kr(2, \gate.kr(1));
    exc = PinkNoise.ar(\punch.kr(0.1)) * Decay2.kr(Impulse.kr(0.5), 0.01, \dec.kr(0.9));
    freqs = freqs + SinOsc.kr([0.2,0.1,0.05]).bipolar(-10, 10);
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
    var freqArray = NamedControl.kr(\freq, [80, 120, 350, 1010]);
    var ampArray = NamedControl.kr(\levels, [0.5, 0.24, 0.14, 0.423]);
    var ringArray = NamedControl.kr(\ring, [0.1, 0.04, 0.04, 0.023]);
    //env = Env.perc(\atk.kr(0.01), \rls.kr(0.08), curve: \crv.kr(-4.0)).kr(2);
    freqs = freqArray.collect({
        |f, i|
        [(f- (f/10)), f,  f+ (f/10)];
    }).flat;
    amps = ampArray.collect({
        |a|
        [(a- (a/10)), a,  a+ (a/10)]
    }).flat;
    rings = ringArray.collect({
        |r|
        [(r- (r/10)), r,  r+ (r/10)]
    }).flat;
    trig = Dust.kr(\trg.kr(4));
    SendTrig.kr(trig);
    freqMod = TRand.kr( 1, 5, trig)  ;
    exc = WhiteNoise.ar(\punch.kr(0.1)) * Decay2.kr(trig, 0.001, \dec.kr(0.9));
    sig = DynKlank.ar(`[
        freqs ,
        amps.ampdb.normalizeSum,
         rings
    ], exc, \freqScale.kr(1), \freqOffset.kr(0), \decayScale.kr(0.1));
    sig = sig * \amp.kr(0.3) ;
    sig = Pan2.ar(BPF.ar(sig, \ffreq.kr(1000), \rq.kr(1.0)), \pan.kr(0.0));
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
	var env,sines, sines2, sig, lagF, lagM;
	env = Linen.kr(gate,\atk.kr(0.1), 1, \rls.kr(1), 2) ;
    lagF = ExpRand(\flg1.kr(0.2), \flg2.kr(0.4));
    lagM = ExpRand(\mlg1.kr(0.2), \mlg2.kr(0.4));
    sines = SinOsc.ar(freqs.varlag(lagF) + mods.varlag(lagM), SinOsc.kr(\phsMod.kr(0.2))).sum;
	sines = Splay.ar(sines, 1) ;
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
	sig = BPF.ar(sig, \ffreq.kr(200), \rq.kr(0.5));
	env = EnvGen.ar(Env.asr(atk, 1, rls), gate, doneAction: 2);
	Out.ar(out, Splay.ar(sig) * env * \fade.kr(1));
}).add;

// Granular Synth
//https://www.youtube.com/watch?v=C9SeVpiyGmI&t=607s  30:00
SynthDef(\tgrains_live, {
	var sig, dry, fm, env, mic, pos, ptr, buf=\buf.kr(0);
	env = Env.asr(\atk.ir(1),\sus.ir(1),\rls.ir(1)).kr(2, \gate.kr(1));
	mic = SoundIn.ar(0, \in.kr(0));
	ptr = Phasor.ar(0, 1, 0, BufFrames.kr(buf));
	BufWr.ar(mic, buf, ptr);
	pos = (ptr/SampleRate.ir) -1;
	pos = pos + LFNoise1.kr(100).bipolar(\jitter.kr(0.0));
	sig = TGrains.ar(
		numChannels: 2,
		trigger: Impulse.kr(\dens.kr(40)),
		bufnum: buf,
		rate: \rate.kr(1) * \harm.kr([0, 0]).midiratio,
		centerPos: pos, // Sekunden
		dur: \grainDur.kr(1.5),
		pan: 0,
		amp: \grainAmp.kr(0.3),
		interp: \ip.kr(4)
	);
	fm = FMGrain.ar(Blip.kr(\fmdens.kr(1), \numharm.kr(2).varlag(\lg.kr(0.0))), \fmDur.kr(0.5),
        \carfreq.kr(400), \modfreq.kr(10), \index.kr(1), //release Phase Nitrifikation
        \fmAmp.kr(0.5)
    );
    fm = BPF.ar(fm, \fmffreq.kr(2000), 0.5);
    sig = RLPF.ar(sig, \ffreq.kr(200), \rq.kr(0.9), 0.25);
    sig = Splay.ar([sig, fm]);
	sig = sig * env * \amp.kr(1) * \fade.kr(1);
    dry = BufRd.ar(1, buf, ptr) * env ;
    sig = (dry * (1.0 - \drywet.kr(0).varlag(0.3))) + (sig * \drywet.kr(0).varlag(0.3));
	Out.ar(\out.kr(0), sig);

}).add;

SynthDef(\tgrains, {
	var sig, dry, fm, ptr, env, buf;
    buf = \buf.kr(0);
	env = Env.asr(\atk.ir(0.1),\sus.ir(1),\rls.ir(1)).kr(2, \gate.kr(1));
    ptr = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf)-1);
    dry = BufRd.ar(1, buf, ptr) * env ;
	sig = TGrains2.ar(
		numChannels: 2,
		trigger: Dust.kr(\dens.kr(12)),
		bufnum: buf,
		rate: \rate.kr(1) * (\harm.kr([0, 0]).midiratio),
		centerPos: \pos.kr(0.5),
		dur: \grainDur.kr(1.5),
		pan: \pan.kr(0),
		amp: \grainAmp.kr(0.7),
		att: \grainDur.kr(1.5) * 0.3,
        dec: \grainDur.kr(1.5) * 0.5;
	);
    	fm = FMGrain.ar(Blip.kr(\fmdens.kr(1), \numharm.kr(2).varlag(\lg.kr(0.0))), \fmDur.kr(0.5),
        \carfreq.kr(400).varlag(\lg.kr(0.0)), \modfreq.kr(10), LFNoise1.kr(\iMod.kr(1).range(1,\index.kr(1))), //release Phase Nitrifikation
        \fmAmp.kr(0.5)
    );
    fm = BPF.ar(fm, \fmffreq.kr(2000), 0.5);
    sig = Splay.ar([sig, fm]);
    sig = RLPF.ar(sig, \ffreq.kr(200), \rq.kr(0.9), 0.25) * env;
    sig = (dry * (1.0 - \drywet.kr(0).varlag(0.3))) + (sig * \drywet.kr(0).varlag(0.3));
	sig = sig  * \amp.kr(0.4) * \fade.kr(1);
    Out.ar(\out.kr(0), sig);
}).add;


// Scrubbing GrainSynth von Tgrains2 helpfile
SynthDef(\grainScrub, {
    |buf=0|
    var sig, dry, tr, trSpec, dur, clk, posSpec, pos, pan, env;
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
    sig = RLPF.ar(sig, \ffreq.kr(1500), \rq.kr(0.9)) * env;
    dry = TGrains2.ar(2, clk, buf, 1, pos, dur, pan, 0.1, dur * 0.3, dur * 0.5);
    sig = (dry * (1.0 - \drywet.kr(0).varlag(0.3))) + (sig * \drywet.kr(0).varlag(0.3));
    sig = sig * \amp.kr(0.3) * \fade.kr(1);
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\livegran, {
    |buf=0, durRand=1, rateRand=1, panRand=0, dens=40, ptrBus=0, ptrSampleDelay=20000,
    ptrRandSamples= 3000, minPtrDelay=1000, maxGrainDur, grainEnv = (-1)|
    var sig, dry, env, densCtrl, durCtrl, rateCtrl, panCtrl, ptr, ptrRand, totalDelay;

    env = EnvGen.kr(Env.asr(\atk.kr(1), 1, \rls.kr(1)), \gate.kr(1), doneAction:2);
    densCtrl = Select.ar(\sync.kr(1), [Dust.ar(dens), Impulse.ar(dens)]);
    durCtrl = \baseDur.kr(0.05) * LFNoise1.ar(100).exprange(1/durRand, durRand);
    rateCtrl = \rate.kr(1) * LFNoise1.ar(100).exprange(1/rateRand, rateRand) * \harm.kr(0).midiratio;
    panCtrl = \pan.kr(0) * LFNoise1.ar(100).bipolar(panRand);
    ptrRand = LFNoise1.ar(100).bipolar(ptrRandSamples); // zitter effekt
    totalDelay =  max(ptrSampleDelay - ptrRand, minPtrDelay);//gesamt Zahl Delay samples
    ptr = In.ar(ptrBus, 1);
    ptr = ptr - totalDelay; // pointer immer hinter dem ptrBus
    ptr = ptr/BufFrames.kr(buf); //normalisierter Pointer
    maxGrainDur = (totalDelay/rateCtrl) / SampleRate.ir; // Wie lang darf ein Grain sein, ohne über die Schreiblücke zu springen?
    durCtrl = min(durCtrl, maxGrainDur);
    sig = GrainBuf.ar(
        2,
        densCtrl,
        durCtrl,
        buf,
        rateCtrl,
        ptr,
        2,
        panCtrl,
        grainEnv
    );
    sig = RLPF.ar( sig, \ffreq.kr(4000), \rq.kr(0.5)) * env ;
    ptr = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf)-1);
    dry = BufRd.ar(1, buf, ptr);
    sig = (dry * (1.0 - \drywet.kr(0).varlag(0.3))) + (sig * \drywet.kr(0).varlag(0.3));
    sig = sig * \amp.kr(0.5) * \fade.kr(1);
    Out.ar(\out.kr(0), sig);
    Out.ar(\outfx.kr(0), sig * \send.kr(0));
}).add;

SynthDef(\br, {
	arg buf=0, rate=1, start=0, end;
	var sig, dry, ptr, ptr2, env;
	env = Env.asr(\atk.ir(1),\sus.ir(1),\rls.ir(1)).kr(2, \gate.kr(1));
	ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate * \harm.kr(0).midiratio, start, end);
	ptr2 = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf)-1);
    dry = BufRd.ar(1, buf, ptr2) * env;
	sig = 2.collect({
		var lag = LFNoise1.kr(\lg1.kr(0)).bipolar(\lg2.kr(0.0));
		lag = lag * s.sampleRate;
		BufRd.ar(1, buf, ptr + lag, \lp.kr(1.0));
	}).sum ;
	sig = RLPF.ar(sig, \ffreq.kr(200), \rq.kr(0.5));
	sig = sig * env * \amp.kr(0.3) * \fade.kr(1);
    sig = (dry * (1.0 - \drywet.kr(0).varlag(0.3))) + (sig * \drywet.kr(0).varlag(0.3));
	Out.ar(\out.kr(0), sig);
	Out.ar(\outdry.kr(0), dry);
}).add;

SynthDef(\brsaw, {
	arg buf=0, rate=1, start=0, end;
	var sig, dry, ptr, ptr2, env;
	env = Env.asr(\atk.ir(1),\sus.ir(1),\rls.ir(1)).kr(2, \gate.kr(1));
    // garantiert die Originalgeschwindigkeit, \freq ist speedcontrol
    ptr = LFSaw.ar(BufDur.ir(buf).reciprocal * \freq.kr(1)).range(0, BufFrames.ir(buf));
    dry = BufRd.ar(1, buf, ptr) * env;
	sig = BufRd.ar(1, buf, ptr );
	sig = RLPF.ar(sig, \ffreq.kr(4000).varlag(\lg.kr(0)), \rq.kr(0.1));
    sig = Pan2.ar(sig, \pan.kr(0)) * env;
    sig = (dry * (1.0 - \drywet.kr(0).varlag(0.3))) + (sig * \drywet.kr(0).varlag(0.3));
    sig = sig * \amp.kr(0.3) * \fade.kr(1);
	Out.ar(\out.kr(0), sig);
	Out.ar(\outdry.kr(0), dry);
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

// Live granulation https://www.youtube.com/watch?v=MnD8stNB5tE&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=27
// ab 8:00

SynthDef(\routing, {
	var sig = SoundIn.ar(\in.kr(0));
	sig = sig * \fade.kr(0.0);
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\pointer, {
    |out=0, buf=0|
    var sig;
    sig = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
    Out.ar(out, sig);
}).add;

// record stuff with mic
SynthDef(\rec, {
	|len=4, ptrIn=0, micIn=0, buf=0|
	var ptr, sig;
	ptr = In.ar(ptrIn, 1);
	sig = In.ar(micIn, 1);
	SendReply.kr(Impulse.kr(100), '/cursor', ptr);
	BufWr.ar(sig, buf, ptr);
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
}, [\audiobus, ObjectSpec(2), \freq, #[0.01, 2.0], \amp]
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

Instr(#[\busfx, \singleDelay], { arg bus, numChan, maxTime, time, decay, mul, add;
    CombL.ar(In.ar(bus, numChan), maxTime, time, decay, mul, add)
}, [\audiobus, ObjectSpec(1),  #[0.1, 20], #[0.0001, 20], #[0.0001, 20], #[0.0001, 2.0], #[0.0001, 4.0]]);


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

