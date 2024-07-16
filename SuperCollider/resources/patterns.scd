Pbindef(\klic,
    \instrument, \dynklank,
    \freqs, 1200 !5,
    \rings, 5!5,
    \amps, [1.2, 0.5, 0.7, 0.4, 1.2],
    \dur, 2,
    \amp, 0.61,
    \freqScale, 0.5,
    \decayScale, 0.35,
    \atk, 0.04,
    \rls, Pkey(\decayScale),
    \ffreq, Pwhite(1000, 5000, inf),
    \pan, Pwhite(-0.6, 0.6, inf),
    \pLag, 0.26,
    \out, ~perc.inbus,
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
    \out, 0
);

Pbindef(\blab,
    \instrument, \bpfstack,
    \vow, Pseq((0..24), inf),
    \buf, Pfunc({~currentSample[\base].normalize}),
    \dur, 0.5,
    \atk, 0.04,
    \rls, 0.19,
    \freqMods, Pwhite(0.1, 1, inf),
    \ampMods, 0.5,
    \widthMods, Pwhite(0.06, 0.6, inf),
    \amp, 0.7,
    \out, 0,
    \outdry, 2
);

Pbindef(\arp1,
    \instrument, \vowelklank,
    \dur, 4,
    \amp, 0.1,
    \vow, Pseq([0, 0, 0, 10], inf),
    \rls, 0.1,
    \sus, 0.3,
    \buf, ~currentSample[\relax],
    \decayScale, 0.1,
    \freqScale, 1,
    \fScale, Array.fill(5, {1.rand}),
    \dbScale, 0.04,
    \out, 0,
    \outdry, 2
);

Pbindef(\array01,
    \instrument, \arrayarg,
    \dur, 4,
    \freqs, [250, 400, 600] * Pwhite(0.8, 1.3, inf),
    \temps, [pi/2, pi/2, pi/2] * Prand([1.0, 1.0, 1.0], inf),
    \lag, 2,
    \modf, 0.3,
    \mod, 0.3,
    \modf2, 0.2,
    \mod2, 0.5,
    \pm, pi,
    \fade, 0.1,
    \fade2, 0.1,
    \atk, 0.4,
    \rls, 3,
    \amp, 0.05,
    \ffreq, 4900,
    \rq, 0.1,
    \out, 0
);

Pbindef(\array02,
    \instrument, \array_1b,
    \dur, 1,
    \freq, 100,
    \otFreqs, Array.fill(8, {rrand(1,5)}),
    \freqLag, Pwhite(0.02, 0.9, inf),
    \otAmps, Array.fill(8, {0.9.rand}),
    \otLag, 0.2,
    \dampExp, 0.002,
    \fade, 0.3,
    \atk, 0.04,
    \rls, 0.4,
    \amp, 0.05,
    \ffreq, 4900,
    \out, 0,
);

Pbindef(\arp1,
    \instrument, \vowelklank,
    \dur, 4,
    \amp, 0.1,
    \vow, Pseq([0, 0, 0, 10], inf),
    \rls, 0.1,
    \sus, 0.3,
    \buf, ~currentSample[\relax],
    \decayScale, 0.1,
    \freqScale, 1,
    \fScale, Array.fill(5, {1.rand}),
    \dbScale, 0.04,
    \out, 0,
    \outdry, 2
);

Pbindef(\arp2,
    \instrument, \bpfstack,
    \vow, Pseq([0, 0, 0, 10], inf),
    \dur, 1,
    \buf, ~currentSample[\base],
    \amp, 1,
    \freqMods, Pwhite(0.2, 1.5, inf),
    \ampMods, 2,
    \rls, 1,
    \out, 0,
    \outdry, 2
);


Pbindef(\voc1,
    \instrument, \vowelklank,
    \vow, 10,
    \buf, Pfunc({~currentSample[\base].normalize}),
    \dur, 4,
    \amp, 0.1,
    \phs, pi,
    \fScale, 1,
    \ffreq, 400,
    \freqScale, 0.4,
    \decayScale, 0.09,
    \rls, 1,
    \out, 0,
    \outdry, 2
);


