~data = ~createData.(~dataPath, "zku_OpenHausData_noTime.csv" );
~sm50 = ~createData.(~dataPath, "SM_50.csv");
~sm70 = ~createData.(~dataPath, "SM_70.csv");
~sm90 = ~createData.(~dataPath, "SM_90.csv");
s.sync;

//  vowelArrays machen um, in der SynthDef die Werte abrufen zu können
~vowelValues = { |vowel = \a, register = \alto|
    var v = Vowel(vowel, register);
    //[v.freqs, v.widths, v.dBs].postln;
    [v.freqs, v.widths, v.dBs]
};

// make vowelArray

~vowelArray = [\a, \e, \i, \o, \u].collect({
    |vowel, i|
    [\bass, \counterTenor, \soprano, \alto, \tenor].collect({
        |reg|
        //[~vowelIndex, vowel, reg].postln;
        ~vowelDict.add(~vowelIndex -> [vowel, reg]);
        ~vowelIndex = ~vowelIndex + 1;
        ~vowelValues.value(vowel, reg);
    });
});

~vowelArray = ~vowelArray.flat;

s.sync;
//dieses Setup nimmt konstant material über den Mic Eingang auf und schreibt es in den grainBuffer
~micGrp = Group.new;
~ptrGrp = Group.after(~micGrp);
~recGrp = Group.after(~ptrGrp);
~grainGrp = Group.after(~recGrp);
Synth(\routing, [in: 0, fade: 0.85, out: ~micBus], ~micGrp);
Synth(\pointer, [\buf, ~grainBuffer, \out, ~ptrBus], ~ptrGrp);
Synth(\rec, [\ptrIn, ~ptrBus, \micIn, ~micBus, \buf, ~grainBuffer], ~recGrp);


MIDIClient.init;
MIDIIn.connectAll;


~routines = (
    \live: ~live.keys.asArray.sort.collect({|k| Routine(~live[k])}),
    \midi: ~midi.keys.asArray.sort.collect({|k| Routine(~midi[k])})
   // \patFunc: ~patFunc.keys.asArray.sort.do({|k| Routine(~patFunc[k])})

);

PathName(~samplesPath).entries.do({
    arg subfolder;
    var sampleDict=(), sample;
    ~buffersByName.add(subfolder.folderName.asSymbol -> sampleDict);
    ~buffersByCat.add(subfolder.folderName.asSymbol -> sampleDict);
    subfolder.entries.do({
        |entry, i|
        var sampleName = entry.fileNameWithoutExtension.asSymbol;
        var c;
        sample = Buffer.read(s, entry.fullPath);
        ~buffersByName[subfolder.folderName.asSymbol].put(sampleName, sample);
        //"foldername % samplename % is %".format(subfolder.folderName, sampleName, sampleName.asString == "base").postln;
        c = case
        {sampleName.asString == "base"}{~buffersByCat[\base].add(sample.normalize)}
        {sampleName.asString == "tension"}{~buffersByCat[\tension].add(sample.normalize)}
        {sampleName.asString == "relax"}{~buffersByCat[\relax].add(sample.normalize)}
        {true}{"no samplename".postln};

        //"foldername % samplename % is %".format(subfolder.folderName, sampleName, sampleName.asString == "base").postln;

    });
});

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

