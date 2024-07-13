(
Pbindef(\klic,
    \instrument, \oddeven,
    \dur, 0.5,
    \amp, 0.03,
    \baseFreq, Pseq([Pn([150, 300], 7), 300], inf) ,
    \atk, 0.1,
    \rls, 0.24,
    \stopFilterOrders,[1.0, 3.1, 2.4, 2.1, 3.4],
    \freqScale, Pwhite(0.01, 0.7, inf),
    \modRange1, 0.1,
    \modRange2, 1.1,
    \freqScale, 1.0,
    \out, 0
);

)
Pbindef(\klic).play(~t, quant: 4)
Pbindef(\klic).stop
Routine(~rf[\klic]).play

(
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

)
Pbindef(\arp1).play(~t, quant: 4)
Pbindef(\arp1).stop

(
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

)
Pbindef(\arp2).play(~t, quant: 4)
Pbindef(\arp2).stop

(
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

)
Pbindef(\arp3).play(~t, quant: 4)
Pbindef(\arp3).stop
Routine(~rf[\arp3]).play

(
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

)
Pbindef(\voc1).play(~t, quant: 4)
Pbindef(\voc1).stop
Routine(~rf[\voc1]).play



