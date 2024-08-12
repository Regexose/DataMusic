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
~dry = Synth(\dry, [in: ~dryBus, fade: 0.0, out:0], addAction: \addToHead);

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
        "key % ".format(key).postln;
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
~midiOut = MIDIOut.new(0);
~midiIn = MIDIIn.new(0);

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
\bak: [\amp, 0.2, \punch, 0.02, \trg, 5, \dec, 0.071, \out, ~perc.inbus, \freq, [420, 810, 1010, 2800] *0.7, \levels, [0.2, 0.24, 0.14, 0.223] *2, \ring, [0.1, 0.06, 0.04, 0.023] * 25, \ffreq, exprand(300,350), \rq, 0.1],
\pilz:  [\amp, 0.2, \punch, 0.04, \trg, 5, \dec, 0.071, \out, ~perc.inbus, \freq, [1220, 2510, 3010, 3800], \levels, [0.12, 0.14, 0.14, 0.223] *2, \ring, [0.1, 0.06, 0.04, 0.023] * 5, \ffreq, exprand(900,1150), \rq, 0.1],
// Bodentiere Wimperntiere
\wimper: [\amp, 0.2, \punch, 0.03, \trg, 5,  \out, ~perc.inbus, \freq, [90, 110, 310, 800], \levels, [0.2, 0.24, 0.14, 0.223], \ring, [0.1, 0.6, 0.4, 0.23] * 4, \rq, 0.1, \ffreq, 350, \dec, 0.01, \punch, 0.5, \freqScale, 1.9, \freqOffset, 200, \decayScale, 0.01],
\nematode: [\amp, 0.2,  \trg, 5, \out, ~perc.inbus, \freq, [90, 110, 310, 800], \levels, [0.2, 0.24, 0.14, 0.223], \ring, [0.1, 0.6, 0.4, 0.23] * 4,  \ffreq, 250, \rq, 0.4, \dec, 0.01, \punch, 0.5, \freqScale, 0.9, \freqOffset, 280, \decayScale, 0.011],
 //Bakterien
\rhizobak: [\amp, 0.2,  \trg, 5, \out, ~perc.inbus, \freq, [420, 810, 1010, 2800] *0.7, \levels, [0.2, 0.24, 0.14, 0.223] *2, \ring, [0.1, 0.06, 0.04, 0.023] * 25, \ffreq, 1640, \rq, 0.1, \dec, 0.01, \punch, 0.5, \freqScale, 0.6, \freqOffset, 750, \decayScale, 0.04],

\cyanobak: [\amp, 0.2,  \trg, 5, \out, ~perc.inbus, \freq, [420, 810, 1010, 2800] *0.7, \levels, [0.2, 0.24, 0.14, 0.223] *2, \ring, [0.1, 0.06, 0.04, 0.023] * 25, \ffreq, 2000, \rq, 0.3, \dec, 0.01, \punch, 0.5, \freqScale, 0.4, \freqOffset, 900, \decayScale, 0.04],
// Pilze
\mycorrhiz: [\amp, 0.2,  \trg, 5, \out, ~perc.inbus, \freq, [1220, 2510, 3010, 3800], \levels, [0.12, 0.14, 0.14, 0.223] *2, \ring, [0.1, 0.06, 0.04, 0.023] * 5, \ffreq, 1800, \rq, 0.4, \dec, 0.04, \punch, 0.2, \freqScale, 2, \freqOffset, 800, \decayScale, 0.05],

\basidio:  [\amp, 0.2,  \trg, 5, \out, ~perc.inbus, \freq, [1220, 2510, 3010, 3800], \levels, [0.12, 0.14, 0.14, 0.223] *2, \ring, [0.1, 0.06, 0.04, 0.023] * 5,\ffreq, 850, \rq, 0.7, \dec, 0.04, \punch, 0.3, \freqScale, 1.6, \freqOffset, 1100, \decayScale, 0.13],

);

// make background images for dataView GUI

/*
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
            //~dataImages.add(k -> image);
            0.05.wait;
            image.write(path.standardizePath);
            0.05.wait;
            image.free;
        });
    }).play(AppClock);
};
*/
