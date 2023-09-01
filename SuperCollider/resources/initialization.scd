
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

//initialize currentData
~initCurrentData = {(48 .. 72).do({
	|i|
	~currentData.put(i.asSymbol , ~data.temperature)
})
};

MIDIClient.init;
MIDIIn.connectAll;
~midiOut = MIDIOut.new(0);
~midiIn = MIDIIn.new(0);


//Aktivieren von Fadern für die Lautstärke Regelung der midikeys
~rf.keys.asArray.sort.do({
	|ch, i|
	var value, defName, offset=0;
	[ch, i].postln;
	defName = ("ch" ++ ch).asSymbol;
	//"chan   %    and i   %  ".format(channel, i).postln;
	value = MIDIdef.cc(defName, {
		arg ...args;
		args[..2].postln;
		if (i < 8, {
			"set % to ".format(ch.asString, args[0].linlin(0, 127, 0.0, 1.0)).postln;
			~activeSynths[ch.asSymbol].set(\fade, args[0].linlin(0, 127, 0.0, 1.0)) ;
		}, {
			"activate other  % ".format(ch.asString).postln;
			~activeSynths[ch.asSymbol].set(\fade, args[0].linlin(0, 127, 0.0, 1.0));
		})
	},
	i,
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

