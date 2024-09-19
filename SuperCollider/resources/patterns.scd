Pbindef(\klic,
    \instrument, \dynklank,
    \freqs, 2200!3,
    \rings, 1!3,
    \amps, [1.2, 0.5, 0.7],
    \dur, 1,
    \amp, Pseq([0.2, \, 0.2, 0.03, 0.2, \, 0.2, \], inf) * 1.75,
    \punch, 0.5,
    \dec, 0.3,
    \freqScale, 1,
    \decayScale, 0.1,
    \atk, 0.02,
    \rls, 0.1,
    \ffreq, 5000,
    \pan, 0,
    \pLag, 0.26,
    \out, ~perc.inbus,
);


Pbindef(\klank,
    \instrument, \dynklank,
    \freqs, Prand([2000!3, 900!3, 1500!3, 3500!3], inf),
    \rings, 0.001!3,
    \amps, Pfunc({Array.rand(3, 0.06, 0.74)}) * Pwhite(0.01, 0.03, inf),
    \dur, Pwhite(0.01, 0.61, inf),
    \amp, 0.1,
    \punch, Pwhite(0.1, 0.5, inf),
    \dec, Pkey(\punch) * 0.3,
    \freqScale, Pwhite(0.8, 1.5, inf),
    \decayScale, Pwhite(0.04, 0.1, inf),
    \atk, 0.02,
    \rls, 0.1,
    \ffreq, Pwhite(100, 1200, inf),
    \rq, 0.9,
    \pan, Pwhite(-0.8, 0.8, inf),
    \pLag, Pwhite(0.1, 1.7, inf),
    \out, ~perc.inbus,
);

Pbindef(\snare,
    \instrument, \snare,
    \dur, Pwhite(0.17, 1.61, inf),
     \amp, 0.4,
   \freq, Pwhite(90, 140, inf),
  \envsus, Pkey(\dur),
    \envlast, 1,
    \pan, Pwhite(-0.8, 0.8, inf),
    \out, ~perc.inbus
);

Pbindef(\percvowel,
    \instrument, \bpfstack,
    \vow, Pseq([Pn(0, 8), Pn(Prand([5,7, 8]), 3), Pn(Prand([15,17, 12]), 13) ],inf),
    \buf, Prand(~buffersByCat[\base], inf),
    \dur, 1,
    \atk, 0.01,
    \rls, 0.19,
    \freqMods, Pseq([Pn(2.5, 32), Pwhite(0.9, 1.2, 16), Pn(1.8, 8), Pn(2.8, 8)], inf),
    \ampMods, 5,
    \widthMods, pi/16,
    \ffreq, Pseq((800, 1800 .. 5800),inf),
    \amp, 0.7,
    \out, ~ch1.inbus,
    \outdry, ~dryBus
);


Pbindef(\snarl,
    \instrument, \oddeven,
    \dur, 1,
    \amp, 0.05,
    \baseFreq, Pseq([Pn([60, 63, 68], 7), [72, 75, 80]], inf).midicps,
    \atk, 0.08,
    \rls, 1.5,
    \modRange1, 0.01,
    \modRange2, 4.1,
    \freqScale, 1,
    \out, ~ch2.inbus
);




Pbindef(\arp2,
    \instrument, \vowelklank,
    \dur, 0.5,
    \amp, 0.4,
    \fade, 0.2,
    \vow, Pseq([0, 5, 10, 15], inf),
    \rls, 0.1,
    \buf,  Pfunc({~currentSample[\relax].normalize}),
    \phs, Prand([pi, pi/2, pi/4, pi/5, (3*pi)/2], inf),
    \decayScale, Pwhite(0.1, 0.9, inf),
    \freqScale, 1.5,
    \fScale,  Pwhite(0.1, 1, inf),
    \ffreq, 4000,
    \out, ~ch3.inbus,
    \outdry, ~dryBus
);

Pbindef(\arp3,
    \instrument, \bpfstack,
    \vow, Pseq([0, 20, 15, 10], inf),
    \dur, 0.5,
    \buf, Pfunc({~currentSample[\base].normalize}),
    \amp, 1,
    \freqMods, Pseq([Pn(0.5, 32), Pwhite(0.9, 1.2, 16), Pn(0.8, 8), Pn(2.8, 8)], inf),
    \ampMods, Pwhite(1, 4, inf),
    \widthMods, pi/18,
    \atk, 0.03,
    \rls, 0.2,
    \ffreq, Pwhite(1600, 4000, inf),
    \out, ~ch3.inbus,
    \outdry, ~dryBus
);

Pbindef(\array01,
    \instrument, \arrayarg,
    \dur, 4,
    \freq, [65, 71].midicps,
    \mods, [0, 0],
    \lg, 2,
    \pm, pi,
    \fade, 0.22,
    \atk, 0.4,
    \rls, 3,
    \amp, 0.2,
    \ffreq, 4900,
    \rq, 0.1,
    \out, ~ch2.inbus
);


Pbindef(\arp1,
    \instrument, \array_1b,
    \dur, 0.25,
    \freq, Pseq([Pn(200, 7), Prand([800, 400, 600, 795, 402, 596], 1)], inf) * Pxrand([0.99, 1.01, 2.99, 3.01], inf),
    \otFreqs, Pfunc({Array.fill(8, {exprand(1,5)})}),
    \freqLag, Pwhite(0.02, 2.9, inf),
    \otAmps, Pfunc({Array.fill(8, {0.6.rand})}),
    \feedb, Pxrand([0, 1/8, 1/4, 1/2, 1/3], inf) * pi,
    \otLag, 0.1,
    \dampExp, 2.04,
    \ampA, 2,
    \fade, 0.1,
    \atk, Pwhite(0.01, 0.05, inf),
    \rls, 0.06,
    \amp, 0.05,
    \ffreq, Pkey(\freq) * Prand([3, 4, 5], inf),
    \out, ~ch3.inbus,
);

Pbindef(\quirkator,
    \instrument, \array_1b,
    \otLag, 0.3, \dampExp, 0.2,
    \otAmps, Pfunc({rrand(0.01, 0.2)}!4),
    \otFreqs, Pfunc({rrand(0.1, 3.6)}!4),

    \ampA, Prand([0.4, 0.6, 0.77], inf),   \amp, Pwhite(0.7, 1.5, inf),
    \freq, Pseq([60, 63, 68, Prand([ 72, 75], 1)].midicps, inf) * Pxrand([ 0.95, 1.05, 0.99, 1.01], inf),
    \freqLag, 0.3,
    \feedb, pi *1/8,
    \atk, Prand([0.01, 0.04, 0.08], inf), \rls, Prand([0.041, 0.15, 0.3], inf), \sustain, Pkey(\rls),
    \dur, Pseq([Pn(0.25, 45), Pn(0.125, 16)], inf),
    \ffreq, Pwhite(300, 3000, inf), \rq, Prand([0.1, 0.13, 0.5], inf),
    \out, ~ch1.inbus
);

Pbindef(\dark,
    \instrument, \array_1b,
    \otLag, 4,
    \dampExp, 0.2,
    \otAmps, 0.5!8,
    \amp, Pwhite(1.75, 4.33, inf),
    \freq, Pseq([Pn(24, 7), Prand([24, 36, 48, 60, 72].midicps, 1)], inf) * Pxrand([2.99, 3.01, 3.99, 4.01], inf),
    \freqLag, 3.2, \feedb, pi *3/8,
    \dur, 4,
   \rls, 2, \atk, 0.5,
    \out, ~ch1.inbus;

);


Pbindef(\voc2,
    \instrument, \vowelklank,
    \vow, 10,
    \buf, Pfunc({~currentSample[\base].normalize}),
    \dur, 1,
    \amp, 0.05,
    \phs, pi,
    \fScale, Pwhite(0.1, 1, inf),
    \ffreq, 400,
    \freqScale, Pseq([Pn(1, 15), 0.6], inf),
    \decayScale, 0.09,
    \rls, 1,
    \out, ~voc.inbus,
    \outdry, ~dryBus
);

Pbindef(\voc1,
    \instrument, \vowelklank,
    \dur, 2,
    \amp, 0.15,
    \rls, 0.2,
    \buf, Pfunc({~currentSample[\relax].normalize}),
    //\phs, Prand([pi, pi/2, pi/4, pi/5, (3*pi)/2], inf),
    \freqScale, 1,
    \decayScale, 0.11,
    \fScale, 1,
    \ffreq, 6600,
    \out, ~voc.inbus,
    \outdry, ~dryBus

);


