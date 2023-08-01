~dataPath = PathName(~projectRoot).parentPath ++ "data";
~samplesPath = PathName(~projectRoot).parentPath ++ "samples";
~baromabs= List.new;
~temps = List.new;
~barotemps = List.new;
~buffers = Dictionary.new;
~liveBuffer = Buffer.alloc(s, 10 * s.sampleRate, 1);
