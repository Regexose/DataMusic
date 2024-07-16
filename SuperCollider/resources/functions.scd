~makeWaveTable = {
    |size=4096, external, name|
    var sig, wt, buf;
    external = external.sort.reverse.asArray;
    external = external.normalize(external.last, external[0]/2);
    external[0..15].postln;
    r{
        buf = Buffer.alloc(s, size*2);
        s.sync;
        buf.sine1(external[0..15], asWavetable:true);
        //buf.plot;
        s.sync;
        ~buffers.add(name.asSymbol -> buf);
        "made buffer  %".format(~buffers[name]).postln;

    }.play(AppClock);
};

~selectorAction = {
    |menu|
    var key, selected, imgPath, image;
    selected = menu.item.asSymbol;
    key = menu.name;
    imgPath = ~imagePath +/+ selected.asString ++ ".png";
    image = Image.open(imgPath).setSize(900, 450, \keepAspectRatio );
    ~currentData[key.asSymbol][\data] = ~data[selected];
    ~databg.setBackgroundImage(image);
    ~dataView.refresh;
    "set % with %".format(key, selected).postln;
};

~bufferSelectorAction = {
    |menu|
    var key, selected, filePath, buf;
    selected = menu.item.asSymbol;
    key = menu.name;
    filePath = PathName(~samplesPath +/+ selected +/+ key ++ ".wav");
    buf = Buffer.read(s, filePath.fullPath);
    ~currentSample.add(key.asSymbol -> buf);
    "set % with %".format(key, selected).postln;
};

~reduceAction = {
    |knob|
    var keyKnob, knobVal;
    keyKnob = knob.name.asSymbol;
    knobVal = knob.value.linlin(0.0, 1.0, 1, 50).asInteger;
    ~currentData[keyKnob][\reduce] = knobVal;
    "set keyKnob % to  %".format(keyKnob, knobVal).postln;
};


~recordUser = {
    |username, typename|
    var rec, filePath, file, progress=0;
    //make Gui for record progress
    rec = Synth(\recOne, [\buf, ~userSound]);
    o = OSCdef(\listener, { |msg|
        {progress = msg[3]}.defer; if(msg[3] >= (~userSound.numFrames -100), {
            "record done".postln;
            rec.free;
            File.mkdir(~samplesPath +/+ username);
            ~userSound.write(~samplesPath +/+ username +/+ typename ++ ".wav", "WAV", "int16");
            /*if (~buffers[username.asSymbol].includesKey(typename.asSymbol),
            {"remove key".postln; ~buffers[username.asSymbol].removeAt(typename.asSymbol)});*/
            filePath = PathName(~samplesPath +/+ username +/+ typename ++ ".wav");
            ~buffers[username.asSymbol].add(typename.asSymbol -> Buffer.read(s, filePath.fullPath));
    })}, '/cursor');

};

~moveCursor = {
    |pos|
    ~posX = pos;
    ~cursor.refresh;
};

~runFx = {

    ~fx = (
        \rev: ~reverb.playfx(FxPatch(#[ \busfx, \vrb1 ], ~patches[\reverb2])),
        \ring : ~ringmod.playfx(FxPatch(#[\busfx, \ring1], ~patches[\ring])),
        \chor : ~chorus.playfx(FxPatch(#[\busfx, \chorus], ~patches[\chorus])),
        \mst_lim : ~master.playfx(FxPatch(#[\busfx, \limiter], ~patches[\limiter])),
        \ch1_cmp : ~ch1.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])),
        \ch2_cmp : ~ch2.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])),
        \ch3_cmp : ~ch3.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])),
        \ch4_cmp :~ch4.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])),
        \ch5_cmp : ~ch5.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])), //dieser macht den *** ERROR: SynthDef companderd#7HVwu not found
        \utt_cmp : ~utt.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])),
        \perc_cmp : ~perc.playfx(FxPatch(#[\busfx, \companderd], ~patches[\companderd_beat])),
        \bass_cmp : ~bass.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander_bass]))
    )
};

~bypass = {
    |key, on|
    if (on, {~fx[key].synth.run(false)}, {~fx[key].synth.run(true);})
};


////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////    PLAY FUNCTIONS   ///////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////





//restarts play if new MIDI key is pressed with User Sounds
~onOffUser = {
    |act|
    var rout;
    if (act == 1,
        {
            MIDIdef.noteOn(\onoffUserOn, {
                |vel, num|
                if ((rout.notNil && rout.isPlaying), {"stopping rout".postln; rout.stop});
                if (~rf.keys.includes(num.asSymbol),{
                    rout = Routine(~rf[num.asSymbol]).play
                });
                "on off playing/restart routine %".format(num.asSymbol).postln;
            });
            MIDIdef.noteOff(\onoffUserOff, {
                |vel, num|
                if (~rf.keys.includes(num.asSymbol),{
                    rout.stop;
                    ~activeSynths[num.asSymbol].free;
                    "stopped routine %  released  %".format(num, ~activeSynths[num.asSymbol]).postln;
                });
            });
        },{
            "freeing MIDIdefs".postln;
            [\onoffUserOn, \onoffUserOff].do{|n| MIDIdef(n).free};

        }
    )

};
//restarts play if new MIDI key is pressed with User Sounds
~onOffUserMouse = {
    |pressed, rout, num|
    [pressed, rout, num].postln;
    if (pressed, {
       "reset rout".postln;  rout.reset;
        rout.play;
        //"playing/restart routine %".format(num.asSymbol).postln;
        "playing/restart routine".postln;
    },{
        rout.stop;
         ~activeSynths[num.asSymbol].release(3);
            //"stopped routine %  released Synth %".format(~rout.isPlaying,~activeSynths[num.asSymbol]).postln;
        "stopped routine   released Synth ".postln;
        });

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



//always plays the complete data array with User Sounds
~oneShotUser = {
    |act|
    var rout;
    if (act == 1,
        {
            MIDIdef.noteOn(\osUserOn, {
                |vel, num|
                if ((rout.notNil || rout.isPlaying), {
                    rout.stop;
                    "stopping rout: %".format(num).postln;
                    ~activeSynths[num.asSymbol].free;
                });

            });
            MIDIdef.noteOff(\osUserOff, {
                |vel, num|
                if (~rf.keys.includes(num.asSymbol),{
                    rout = Routine(~rf[num.asSymbol]).play
                });
                "playing oneShot %".format(num.asSymbol).postln;

            });
        },{

            "freeing MIDIdefs".postln;
            [\osUserOn, \osUserOff].do{|n| MIDIdef(n).free};
        }
    )
};

