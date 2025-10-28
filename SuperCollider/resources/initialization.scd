~data = ~createData.(~dataPath, "zku_OpenHausData_noTime.csv" );
~sm50 = ~createData.(~dataPath, "SM_50.csv");
~sm70 = ~createData.(~dataPath, "SM_70.csv");
~sm90 = ~createData.(~dataPath, "SM_90.csv");
~mbsdata = (\panbus: 0);

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

~scales = [Scale.new(#[0, 4, 7, 10], name: "eins"), Scale.new(#[0, 7, 2, 11], name: "zwei"), Scale.minor,  Scale.new(#[0, 2, 6, 10], name: "vier"), Scale.new(#[0, 1, 3, 7], name: "fünf")];

MIDIClient.init;
MIDIIn.connectAll;

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

 ~activeRoutines.put(\td, ());

 