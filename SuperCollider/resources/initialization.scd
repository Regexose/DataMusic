
~createData = {
    var flopped, headers;
	headers = List.new;
    ~csvFile = CSVFileReader.read(~dataPath +/+ ~fileName);
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

/*~csvFile.do({
	|line, i|

	if (i==0,
		{ line.do({
			|k, idx|
			var header = k.toLower.replace(" ", "_");
			header = header.replace(".", "_").asSymbol;
			~headers.add(header);
			//"the key at index %  is %".format(idx, header).postln;
			~data.add(header -> List.new); // put headers in order of this iteration
		})
		},
		{// rows with values
			line.do({
				|v, idx|
				//"the value in data row at key %  is %".format(~headers[idx], v).postln;
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

