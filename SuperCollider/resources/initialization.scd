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
(~resourcePath ++ "synthDefs.scd").load;
s.sync;


~dry = Synth(\routing, [in: ~dryBus, fade: 0.0, out:0], addAction: \addToHead);

~createData = {
    var flopped, headers;
    headers = List.new;
    ~csvFile = CSVFileReader.read(~dataPath +/+ ~dataFileName);
    flopped = ~csvFile.flop; // Invert rows and columns

    flopped.do({
        |line, i|
        var key, values;
        values = List.new;
        key = line[0].toLower.replace(" ", "_");
        key = key.replace(".", "_").asSymbol;
        //"key % ".format(key).postln;
        headers.add(key);
        ~data.add(key -> values); // add to ~data
        line.removeAt(0); //remove key from data values
        line.do({
            |e, idx|
            //"element % in % at ind %".format(e, key, idx).postln;
            if (key == \index, {
                values.add(e)
            },
            {
                values.add(e.asFloat);//convert Strings to Float
            })

        });
        ~data.put(key, values);
    });
};


MIDIClient.init;
MIDIIn.connectAll;
/*~midiOut = MIDIOut.new(0);
~midiIn = MIDIIn.new(0);*/

~routines = ();
//Aktivieren von Fadern für die Lautstärke Regelung der midikeys
~rf.keys.asArray.sort.do({
    |ch, i|
    var slider, knobs, slideName, knobName, offset=89;
    slideName = ("slide" ++ ch).asSymbol;
    knobName = ("knob" ++ ch).asSymbol;
    //"chan   %    and i   %  ".format(channel, i).postln;
    slider = MIDIdef.cc(slideName, {
        arg ...args;
        args[..2].postln;
        if (i < 8, {
            "set % to %".format(ch.asString, args[0].linlin(0, 127, 0.0, 1.0)).postln;
            ~activeSynths[ch.asSymbol].set(\fade, args[0].linlin(0, 127, 0.0, 1.0)) ;
        })
    },
    i,
    1
    );
    knobs = MIDIdef.cc(knobName, {
        arg ...args;
        args[..2].postln;
        if (i < 8, {
            "set % to %".format("dry", args[0].linlin(0, 127, 0.0, 1.0)).postln;
            //~activeSynths[ch.asSymbol].set(\fade2, args[0].linlin(0, 127, 0.0, 1.0)) ;
            ~dry.set(\fade, args[0].linlin(0, 127, 0.0, 1.0)) ;

        })
    },
    i+offset,
    1
    );
    ~routines[ch] = Routine(~rf[ch]);

});

~patFuncs.keys.asArray.sort.do({
    |ch, i|
    ~routines[ch] = Routine(~patFuncs[ch]);
});

PathName(~samplesPath).entries.do({
    arg subfolder;
    var sampleDict=(), sample;
    ~buffersByName.add(subfolder.folderName.asSymbol -> sampleDict);
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
    });
});


// make background images for dataView GUI


~makeDataImages = {
    r({
        var dataPlot, image;
        ~data.keys.remove(\index).do({
            |k, i|
            var path;
            "background image for % ".format(k).postln;
            path =  "~/Desktop/" ++ k.asString ++ ".png";
            dataPlot = ~data[k].asArray.plot(bounds: Rect(0, 0, 900, 450));
            0.05.wait;
            image = Image.fromWindow(dataPlot.parent, dataPlot.interactionView.bounds); // get image from the view
            ~dataImages.add(k -> image);
            0.05.wait;
            image.write(path.standardizePath);
            0.05.wait;
            image.free;
        });
    }).play(AppClock);
};



