~dataPath = PathName(~projectRoot).parentPath ++ "data";
~dataFileName = "zku_OpenHausData_noTime.csv";
~recordingPath = PathName(~projectRoot).parentPath ++ "recordings";
~samplesPath = PathName(~projectRoot).parentPath ++ "samples";
~t = TempoClock(103/60, 8).permanent_(true);
~buffersByName = Dictionary.new;
~buffersByCat = Dictionary.with(*[\base -> List.new, \tension -> List.new, \relax -> List.new]);
~liveBuffer = Buffer.alloc(s, 4 * s.sampleRate, 1);
~grainBuffer = Buffer.alloc(s, 4 * s.sampleRate, 1);
~userSound = Buffer.alloc(s, 4 * s.sampleRate, 1);
~currentSample = Dictionary.new;
~vowelDict = Dictionary.new;
~vowelIndex = 0;
~scales = List.new;

~patternOn = (\1: false, \2: false, \3: false, \4: false);
~patternVals = (\67: (\on: false, \harm: 0, \ffreq: 3000, \send: 0), \69: (\on: false, \harm: 0, \ffreq: 3000, \send: 0),
    \71: (\on: false, \harm: 0, \ffreq: 3000, \send: 0), \72: (\on: false, \harm: 0, \ffreq: 3000, \send: 0));

~activeSynths = ();
~currentData = (\td:  (\sm1 : 0, \temp1 : 0, \sm2 : 0, \temp2 : 0, \sm3 : 0, \temp3 : 0, \sm4 : 0),
    \fade : ()
);
~activeRoutines = ();
// für spectral delay
~size = 128;
~fftSize = 2 * ~size;




