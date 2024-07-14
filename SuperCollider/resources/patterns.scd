
Pbindef(\klic,
    \instrument, \oddeven,
    \dur, 2,
    \amp, 0.1,
    \baseFreq, Pseq([Pn([150, 300], 7), 300], inf) ,
    \atk, 0.18,
    \rls, 0.14,
    \crv, 0,
    \stopFilterOrders,[1.0, 3.1, 2.4, 2.1, 3.4],
    \freqScale, Pwhite(0.01, 0.7, inf),
    \modRange1, 0.1,
    \modRange2, 1.1,
    \freqScale, 2.0,
    \out, 0
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

Pbindef(\arp3,
    \instrument, \dynklank,
    \freqs, Array.fill(5, {exprand(800, 1000)}),
    \rings, 5.rand !5,
    \amps, [1.2, 0.5, 0.7],
    \dur, 0.5,
    \amp, 1,
    \freqScale, Pwhite(0.1, 0.9, inf),
    \decayScale, 0.1,
    \rls, 1,
    \out, 0,
);

Pbindef(\voc1,
    \instrument, \vowelklank,
    \vow, 1,
    \buf, ~currentSample[\base],
    \dur, 16,
    \amp, 0.35,
    \freqScale, Pwhite(0.1,0.9, inf),
    \decayScale, 0.1,
    \rls, 1,
    \out, 0,
    \outdry, 2
);


