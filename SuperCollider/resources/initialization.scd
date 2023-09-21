
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
~midiOut = MIDIOut.new(0);
~midiIn = MIDIIn.new(0);


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
            "set % to %".format(ch.asString, args[0].linlin(0, 127, 0.0, 1.0)).postln;
            ~activeSynths[ch.asSymbol].set(\fade2, args[0].linlin(0, 127, 0.0, 1.0)) ;
        })
    },
    i+offset,
    1
    );


});



PathName(~samplesPath).entries.do({
    arg subfolder;
    var sampleDict=(), sample;
    ~buffers.add(subfolder.folderName.asSymbol -> sampleDict);
    subfolder.entries.do({
        |entry, i|
        var sampleName = entry.fileNameWithoutExtension.asSymbol;
        ~buffers[subfolder.folderName.asSymbol].put(sampleName, Buffer.read(s, entry.fullPath))
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
		dataPlot = ~data[k].asArray.plot(bounds: Rect(0, 0, 800, 400));
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

//initialize currentData and currentSample
~initCurrent = {

	~rf.keys.asArray.sort.do({
		|k, i|
		~currentData.add(k.asSymbol -> Dictionary.with(\reduce -> 10, \data -> ~data.temp, \image ->   ~dataImages.temp));
	});

	[\base, \tension, \relax].do({
		|k|
		~currentSample.add(k -> ~buffers[\voris][k])
	})
};



