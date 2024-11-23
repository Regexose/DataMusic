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



