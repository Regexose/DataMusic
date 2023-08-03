~createData = {
    var flopped;
    ~csvFile = CSVFileReader.read(~dataPath ++ "/zku_noTime.csv");
    flopped = ~csvFile.flop; // Invert rows and columns

    flopped.do({
        |line|
        var key;
        key = line[0].toLower.replace(" ", "_").asSymbol;
        line.removeAt(0); //remove key from data values
        line.do({|e| e = e.asFloat}); //convert Strings to Float
        ~data.add(key -> line); // add to ~data
    });
};


/*~csvFile.do({
	|line, i|
	if (i==0,
		{ line.do({
			|k, idx|
			var header = k.toLower.replace(" ", "_").asSymbol;
			~headers.add(header);
			"the key at index %  is %".format(idx, header).postln;
			~data.add(header -> List.new); // put headers in order of this iteration
		})
		},
		{// rows with values
			line.do({
				|v, idx|
				"the value in data row at key %  is %".format(~headers[idx], v).postln;
				~data[~headers[idx]].add(v.asFloat); //add data element to corresponding key
			})
		};

	);

});*/

MIDIClient.init;
MIDIIn.connectAll;
~midiOut = MIDIOut.new(0);
~midiIn = MIDIIn.new(0);

PathName(~samplesPath).entries.do({
	arg subfolder;
	//subfolder.postln;
	~buffers.add(
		subfolder.folderName.asSymbol ->
		Array.fill(
			subfolder.entries.size,
			{
				arg i;
				Buffer.read(s, subfolder.entries[i].fullPath);
			}
		)
	)
});
