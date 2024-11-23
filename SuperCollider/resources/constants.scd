~dataPath = PathName(~projectRoot).parentPath ++ "data";
~dataFileName = "zku_OpenHausData_noTime.csv";
~recordingPath = PathName(~projectRoot).parentPath ++ "recordings";
~samplesPath = PathName(~projectRoot).parentPath ++ "samples";
~t = TempoClock(120/60).permanent_(true);
~buffersByName = Dictionary.new;
~buffersByCat = Dictionary.with(*[\base -> List.new, \tension -> List.new, \relax -> List.new]);
~liveBuffer = Buffer.alloc(s, 4 * s.sampleRate, 1);
~grainBuffer = Buffer.alloc(s, 4 * s.sampleRate, 1);
~userSound = Buffer.alloc(s, 4 * s.sampleRate, 1);
~currentSample = Dictionary.new;
~vowelDict = Dictionary.new;
~vowelIndex = 0;
~posX = 0; //position of the cursor in ~dataView, manipulated by ~moveCursor

~activeSynths = ();
~currentData = ();
~activeRoutines = ();

~dataGroups = (
    \cmsm : (//Cchicken manure mit WHC 50, 70, 90%
        \50 : [22.3, 32.8, 30.7, 35.3, 36.7],
        \70 : [26.0, 30.7, 28.8, 41.2, 41.3],
        \90 : [26.1, 25.0, 37.8, 40.2, 44.3]
    ),
    \apsm : (//AP (Pflanzenreste)  WHC 50, 70, 90%
        \50 : [15.3, 25.5, 30.4, 34.8, 41.1],
        \70 : [15.9, 22.4, 29.5, 40.0, 44.0],
        \90 : [14.0, 20.6, 30.9, 40.7, 45.9]
    ),

    \cmapsm : (//ausgehend von 66% AP (Pflanzenreste) und 34% CM (Tierkot etc). WHC 50, 70, 90%
        \50 : ([0.0, 22.3, 32.8, 30.7, 35.3, 36.7] * 0.34).collect({|n, i| var ap = ([0.0, 5.3, 25.5, 30.4, 34.8, 41.1] * 0.66); n + ap[i] }) ,
        \70 : ([0.0, 26.0, 30.7, 28.8, 41.2, 41.3]* 0.34).collect({|n, i| var ap = ([0.0, 5.9, 22.4, 29.5, 40.0, 44.0] * 0.66); n + ap[i] }),
        \90 : ([0.0, 26.1, 25.0, 37.8, 40.2, 44.3] * 0.34).collect({|n, i| var ap = ([0.0, 14.0, 20.6, 30.9, 40.7, 45.9] * 0.66); n + ap[i] })
    ),
);

~synthArgs = (
\bak: [\amp, 0.4, \punch, 0.08, \trg, 5, \dec, 0.071, \out, ~perc.inbus, \freq, [420, 810, 1010, 2800] *0.7, \levels, [0.2, 0.24, 0.14, 0.223] *2, \ring, [0.1, 0.06, 0.04, 0.023] * 25, \ffreq, exprand(300,350), \rq, 0.1],
\pilz:  [\amp, 0.2, \punch, 0.04, \trg, 5, \dec, 0.071, \out, ~perc.inbus, \freq, [1220, 2510, 3010, 3800], \levels, [0.12, 0.14, 0.14, 0.223] *2, \ring, [0.1, 0.06, 0.04, 0.023] * 5, \ffreq, exprand(900,1150), \rq, 0.1],
// Bodentiere Wimperntiere
\wimper: [\amp, 0.4, \trg, 5,  \out, ~perc.inbus, \freq, [90, 110, 310, 800], \levels, [0.2, 0.24, 0.14, 0.223], \ring, [0.1, 0.6, 0.4, 0.23] * 4, \rq, 0.1, \ffreq, 350, \dec, 0.01, \punch, 0.5, \freqScale, 1.9, \freqOffset, 200, \decayScale, 0.01],
\nematode: [\amp, 0.4,  \trg, 5, \out, ~perc.inbus, \freq, [90, 110, 310, 800], \levels, [0.2, 0.24, 0.14, 0.223], \ring, [0.1, 0.6, 0.4, 0.23] * 4,  \ffreq, 250, \rq, 0.4, \dec, 0.01, \punch, 0.5, \freqScale, 0.9, \freqOffset, 280, \decayScale, 0.011],
 //Bakterien
\rhizobak: [\amp, 0.2,  \trg, 5, \out, ~perc.inbus, \freq, [420, 810, 1010, 2800] *0.7, \levels, [0.2, 0.24, 0.14, 0.223] *2, \ring, [0.1, 0.06, 0.04, 0.023] * 25, \ffreq, 1640, \rq, 0.1, \dec, 0.01, \punch, 0.5, \freqScale, 0.6, \freqOffset, 750, \decayScale, 0.04],

\cyanobak: [\amp, 0.2,  \trg, 5, \out, ~perc.inbus, \freq, [420, 810, 1010, 2800] *0.7, \levels, [0.2, 0.24, 0.14, 0.223] *2, \ring, [0.1, 0.06, 0.04, 0.023] * 25, \ffreq, 2000, \rq, 0.3, \dec, 0.01, \punch, 0.5, \freqScale, 0.4, \freqOffset, 900, \decayScale, 0.04],
// Pilze
\mycorrhiz: [\amp, 0.4,  \trg, 5, \out, ~perc.inbus, \freq, [1220, 2510, 3010, 3800], \levels, [0.12, 0.14, 0.14, 0.223] *2, \ring, [0.1, 0.06, 0.04, 0.023] * 5, \ffreq, 1800, \rq, 0.4, \dec, 0.04, \punch, 0.2, \freqScale, 2, \freqOffset, 800, \decayScale, 0.05],

\basidio:  [\amp, 0.2,  \trg, 5, \out, ~perc.inbus, \freq, [1220, 2510, 3010, 3800], \levels, [0.12, 0.14, 0.14, 0.223] *2, \ring, [0.1, 0.06, 0.04, 0.023] * 5,\ffreq, 850, \rq, 0.7, \dec, 0.04, \punch, 0.3, \freqScale, 1.6, \freqOffset, 1100, \decayScale, 0.13],

);