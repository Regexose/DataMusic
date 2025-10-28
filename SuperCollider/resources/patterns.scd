Pbindef(\harmonizer,
    \instrument, \br,
    \dur, 4,
    \amp, 0.11,
    \rate, 1!7,
    \harm, 0!7,
    \buf, ~buffersByName[\boris][\gras].normalize,
    \atk, 0.3,
    \rls, 2.5,
    \ffreq, 2500
);

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
    \out, 5,
);


Pbindef(\arpeggio,
    \instrument, \brLive,
    \buf, ~liveBuffer.normalize,
    //\dur, Pwrand([2, 1, 0.5, 0.25], [0.5, 0.2, 0.01, 0.3].normalizeSum, inf),
    \dur, 2,
    \atk, 0.1,
    \rls, 1,
    \send, 0.5,
    \amp, 0.5,

);

Pbindef(\arp67, \out, 0, \outfx, ~fxGrp);
Pbindef(\arp69, \out, 1, \outfx, ~fxGrp);
Pbindef(\arp71,\out, 2, \outfx, ~fxGrp);
Pbindef(\arp72, \out, 3, \outfx, ~fxGrp);


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
    \out, 0,
);


Pbindef(\arps2,
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
    \out, 0,
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
    \out, 0
);


Pbindef(\arps1,
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
    \out, 0,
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
    \out, 0;

);



