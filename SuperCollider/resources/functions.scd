~makeNodes = {
    s.newBusAllocators;
    ~soundIn = Bus.audio(s, 1);
    ~userPtr = Bus.audio(s, 1);
    ~micBus = Bus.audio(s, 1);
    ~ptrBus = Bus.audio(s, 1);
    ~dryBus = Bus.audio(s, 2);
    ~fxBus = Bus.audio(s, 2);
    s.bind {
        //dieses Setup nimmt konstant material über den Mic Eingang auf und schreibt es in den grainBuffer
        var fftSize, size;
        size = 128;
        fftSize = size * 2;
        ~micGrp = Group.new;
        ~ptrGrp = Group.after(~micGrp);
        ~recGrp = Group.after(~ptrGrp);
        ~grainGrp = Group.after(~recGrp);
        Synth(\routing, [in: 0, fade: 0.85, out: ~micBus], ~micGrp);
        Synth(\pointer, [\buf, ~grainBuffer, \out, ~ptrBus], ~ptrGrp);
        Synth(\rec, [\ptrIn, ~ptrBus, \micIn, ~micBus, \buf, ~grainBuffer ], ~recGrp);
        ~sourceGrp = Group.after(~grainGrp);
        ~fxGrp = Group.after(~sourceGrp);
    };
};

~recordUser = {
    |username, typename|
    var ptr, rec, filePath, file, progress=0;
    //make Gui for record progress
    "recording % %".format(username, typename).postln;
    rec = Synth(\userrec, [\buf, ~userSound, \ptrIn, ~userPtr, \micIn, 0]);
    o = OSCdef(\listener, { |msg|
        var tdmsg = ["Done", typename];
        msg[3].postln;
        if(msg[3] > (~userSound.numFrames-1920), {
            "record done  msg %".format(msg[3]).postln;
            ~tdOSC.sendMsg('/recdone', *tdmsg);
            msg.postln;
            ptr.free;
            rec.free;
            File.mkdir(~samplesPath +/+ username);
            ~userSound.write(~samplesPath +/+ username +/+ typename ++ ".wav", "WAV", "int16");
            /*if (~buffersByName[username.asSymbol].includesKey(typename.asSymbol),
            {"remove key".postln; ~buffersByName[username.asSymbol].removeAt(typename.asSymbol)});*/
            filePath = PathName(~samplesPath +/+ username +/+ typename ++ ".wav");
            ~buffersByName[username.asSymbol].add(typename.asSymbol -> Buffer.read(s, filePath.fullPath));
    })}, '/cursor');

};

~moveCursor = {
    |pos|
    ~posX = pos;
    ~cursor.refresh;
};




//initialize currentData and currentSample
~initCurrent = {
    var reduce = 10;
   /* ~midi.keys.asArray.sort.do({
        |k, i|
        ~currentData.add(k.asSymbol ->
            Dictionary.with(\reduce -> reduce, \data -> ~data.soilmoisture1.select({|item, i| i%reduce == 0}), \datakey -> \soilmoisture1, \in -> 0, \out -> (~data.soilmoisture1.size-1), \position -> 0, \originalSize -> ~data.soilmoisture1.size)
        );
    });
    ~patFuncs.keys.asArray.sort.do({
        |k, i|
        ~currentData.add(k.asSymbol ->
            Dictionary.with(\reduce -> reduce, \data -> ~data.soilmoisture1.select({|item, i| i%reduce == 0}), \datakey -> \soilmoisture1, \in -> 0, \out -> (~data.soilmoisture1.size-1), \position -> 0, \originalSize -> ~data.soilmoisture1.size)
        );
    });

    ~live.keys.asArray.sort.do({
        |k, i|
        ~currentData.add(k.asSymbol ->
            Dictionary.with(\reduce -> reduce, \data -> ~data.soilmoisture1.select({|item, i| i%reduce == 0}), \datakey -> \soilmoisture1, \in -> 0, \out -> (~data.soilmoisture1.size-1), \position -> 0, \originalSize -> ~data.soilmoisture1.size)
        );
    });
    ~keySelector.do({|n| n.valueAction = 3});
    ~bufSelector.do({|n| n.valueAction = 8});
    */
    ~currentData.add(\globalPos -> 0);//For synchronous data playback
    ~currentData.add(\globalKey -> \48);
    ~currentSample.add(\base -> ~buffersByCat[\base][2]);
    ~currentSample.add(\relax -> ~buffersByCat[\relax][2]);

};






////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////    PLAY FUNCTIONS   ///////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////


~play = {
    //~runFx.();
    ~patFuncs.keys.do({
        |k|
        Pbindef(k).play(~t, quant:4)
    })
};


~startPattern = {
    |pressed, name|
        if (pressed == 1, {
       "value % start pattern %".format(pressed, name).postln;
        Pbindef(name.asSymbol).play(~t, quant:4);
        //"playing/restart routine %".format(num.asSymbol).postln;
    },{
         Pbindef(name.asSymbol).stop;
    })
};
~stopPattern = {
          |pressed, name|
        if (pressed ==0, {
      "value % stop pattern %".format(pressed, name).postln;
        //Pbindef(name.asSymbol).stop;
        //"playing/restart routine %".format(num.asSymbol).postln;

    })

};





