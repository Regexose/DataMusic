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
~currentData = (\td:  (\sm1 : 0, \sm2 : 0, \temp1: 0, \temp2 : 0, \humid1: 0, \humid2 : 0));
~activeRoutines = ();

~dataGroups = (
    \cmsm : (//Chicken manure mit WHC 50, 70, 90%
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


