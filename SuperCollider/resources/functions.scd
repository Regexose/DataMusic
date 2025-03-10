~makeNodes = {
    s.bind {
        // Mixer Channels, you have to install dewdrop_lib and ddwMixerChannel with Quarks.gui
        ~master = MixerChannel(\master, s, 2, 2);
        ~ch1 = MixerChannel(\ch1, s, 2, 2, outbus:  ~master);
        ~ch2 = MixerChannel(\ch2, s, 2, 2, outbus:  ~master);
        ~ch3 = MixerChannel(\ch3, s, 2, 2, outbus:  ~master);
        ~ch4 = MixerChannel(\ch4, s, 2, 2, outbus:  ~master);
        ~ch5 = MixerChannel(\ch5, s, 2, 2, outbus:  ~master);
        ~ch6 = MixerChannel(\ch6, s, 2, 2, outbus:  ~master);
        ~ch7 = MixerChannel(\ch7, s, 2, 2, outbus:  ~master);
        ~ch8 = MixerChannel(\ch8, s, 2, 2, outbus:  ~master);
        ~voc = MixerChannel(\voc, s, 2, 2,  outbus:  ~master);
        ~perc = MixerChannel(\perc, s, 2, 2, outbus:  ~master);
        ~bass = MixerChannel(\bass, s, 2, 2, outbus:  ~master);
        ~grainGrp = MixerChannel(\grain, s, 2, 2, outbus: ~master);
        ~ringmod = MixerChannel(\ring, s, 2, 2, outbus: ~master);
        ~delay = MixerChannel(\delay, s, 2, 2, outbus: ~master);
        ~reverb = MixerChannel(\vrb1, s, 2, 2, outbus: ~master);
    };
};

~fxOnOff = {
    |on|
    if (on==true, {
            ~fx = (
    \rev: ~reverb.playfx(FxPatch(#[\busfx, \vrb1 ], ~patches[\reverb2])),
    //\allpass: ~reverb.playfx(FxPatch(#[\busfx, \rvb_allpass ], [29, 2])),
    \ring : ~ringmod.playfx(FxPatch(#[\busfx, \ring1], ~patches[\ring])),
    \delay : ~delay.playfx(FxPatch(#[\busfx, \rvb_allpass], ~patches[\allpass])),
    \mst_lim : ~master.playfx(FxPatch(#[\busfx, \limiter], ~patches[\limiter])),
    \ch1_cmp : ~ch1.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander_01])),
    \ch2_cmp : ~ch2.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander_01])),
    \ch3_cmp : ~ch3.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander_01])),
    \ch4_cmp : ~ch4.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander_01])),
    \ch5_cmp : ~ch5.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander_01])),
    \ch6_cmp : ~ch6.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander_01])),
    \ch7_cmp : ~ch7.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander_01])),
    \ch8_cmp : ~ch8.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander_01])),
    \voc_cmp : ~voc.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])),
    \perc_cmp : ~perc.playfx(FxPatch(#[\busfx, \companderd], ~patches[\companderd_beat])),
    \bass_cmp : ~bass.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander_bass]))
)
    }, {
        ~fx.keys.do({
            |k|
            ~toggleFx.(k, true)
        })
    })
};

~toggleFx = {
    |key, on|
    if (on, {~fx[key].synth.run(false)}, {~fx[key].synth.run(true);})
};

// Allgemeine Funktion zum Zuweisen von Slidern und Knobs
~makeCC = {
    |funcDict, chanDict|
    "chandict %".format(chanDict).postln;
    funcDict.keys.asArray.sort.do({
        |key, idx|
        (\fade: 0, \pan: 57, \drywet: 89).keysValuesDo({
            |cName, off|
            var control, defName;
            defName = (cName.asString ++ "_" + key).asSymbol;
            control = MIDIdef.cc(defName, {
                arg ...args;
                args[..2].postln;
                if (idx <= 8, {
                    "set % to %".format((cName ++ key).asString, args[0].linlin(0, 127, 0.0, 1.0)).postln;
                    ~activeSynths[key.asSymbol].set(cName, args[0].linlin(0, 127, 0.0, 1.0)) ;
                })
            },
            idx + off,
            1
            );
        });
    });

    chanDict.keys.asArray.sort.do({
        |key, idx|
        var chan, send;
        chan = chanDict[key][0];
        send = chanDict[key][1];
        (\send: 97, \pan: 57).keysValuesDo({
            |cName, offset|
            var control, defName, sendName;
            defName = ( cName ++ "_" ++ key).asSymbol;
            sendName = (key ++ send).asSymbol;
            "defname % sendname % ".format(defName, sendName).postln;
            control = MIDIdef.cc(defName, {
                arg ...args;
                args[..2].postln;
                "set send of % to %".format(sendName, args[0].linlin(0, 127, 0.0, 1.0)).postln;
                ~sends[sendName].level = args[0].linlin(0, 127, 0.0, 1.0);
            },
            idx + offset,
            1
            )
        });
    })
};

~createData = {
    |dataPath, fileName|
    var data, csvFile, flopped, headers;
    data = ();
    headers = List.new;
    csvFile = CSVFileReader.read(dataPath +/+ fileName);
    flopped = csvFile.flop; // Invert rows and columns
    flopped.removeAt(0); //erste Zeile mit Indices löschen
    flopped.do({
        |line, i|
        var key, values;
        values = List.new;
        key = line[0].toLower.replace(" ", "_");
        key = key.replace(".", "_").asSymbol;
        //"key % ".format(key ++ "  " ++ fileName).postln;
        headers.add(key);
        data.add(key -> values);
        line.removeAt(0); //remove key from data values
        //
        block{
            |break|
            line.do({
                |e, idx|
                if (e == "", { break.value(idx+1)});
                values.add(e.asFloat);
            })
        };
        //"values of % are % long".format(key, values.size).postln;
        data.put(key, values);
    });

    data;
};

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
        ~buffersByName.add(name.asSymbol -> buf);
        "made buffer  %".format(~buffersByName[name]).postln;

    }.play(AppClock);
};


~alignData = {
    |keyCurrent, refDataPointer|
    var compareData = ~currentData[keyCurrent][\data];
    var in = ~currentData[keyCurrent][\in], out = ~currentData[keyCurrent][\out], reduce = ~currentData[keyCurrent][\reduce];
    var divisor = ~currentData[keyCurrent][\originalSize] / ~currentData[keyCurrent][\data].size; // maximale Datenpunkte / aktuelle Datenpunkte
    var maxMinutes = max(~currentData[keyCurrent][\originalSize], (60 * 24 * 7 * 4)); // maximale Datenmenge, die ersten 4 Wochen
    var refData = currentEnvironment[refDataPointer][\minutes][0..maxMinutes]; // die ersten 4 Wochen
    var refReduced = refData.select({|n, i| i%reduce==0}); // reduziert
    //welche Auflösung braucht refData ?
    refData = refReduced[in..out]; // entspricht der Verkleinerung durch die ~rangeSlider
    "refData from in % to out % ... size %".format(in, out, refData.size).postln;
    refData;
};

~selectorAction = {
    |menu|
    var key, selected, res, imgPath, image, reduce;
    selected = menu.item.asSymbol;
    key = menu.name.asSymbol;
    res = ~currentData[key][\reduce];
    "selected % key % selector reduce %".format(selected, key, res).postln;
    ~currentData[key][\data] = ~data[selected].select({|n, i| i%res==0});
    ~currentData[key][\datakey] = selected;
    ~dataView.close;
    ~dataView = ~buildDataView.(selected, res );
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
    "set buffer % with %".format(key, selected).postln;
};

~wetdry = {
    |k, val|
    "drywet %   val % ".format(k, val).postln;
    ~activeSynths[k].set(\drywet, val);
};

~senddelay = {
    |k, val|
    var sendName = (k.name.asString ++ "_snd_dela").asSymbol;
    "sends %   val % ".format(sendName, val).postln;
    ~sends[sendName].level = val;
    //~activeSynths[k].set(\drywet, val);
};

~reduceAction = {
    |menu|
    var midikey, datakey, res;
    midikey = menu.name.asSymbol;
    datakey = ~currentData[midikey][\datakey];
    res = menu.item.asInteger;
    ~currentData[midikey][\reduce] = res;
    ~currentData[midikey][\data] = ~data[datakey].select({|n, i| i%res==0});
    ~dataView.close;
    ~dataView = ~buildDataView.(datakey, res );
    "set key % to  %".format(datakey, res).postln;
};


~recordUser = {
    |username, typename|
    var rec, filePath, file, progress=0;
    //make Gui for record progress
    rec = Synth(\rec, [\buf, ~userSound, \ptrIn, ~ptrBus, \micIn, ~micBus]);
    o = OSCdef(\listener, { |msg|
        {progress = msg[3]}.defer; if(msg[3] >= (~userSound.numFrames -100), {
            "record done".postln;
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
    ~midi.keys.asArray.sort.do({
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
    ~currentData.add(\globalPos -> 0);//For synchronous data playback
    ~currentData.add(\globalKey -> \48);

    ~keySelector.do({|n| n.valueAction = 3});
    ~bufSelector.do({|n| n.valueAction = 8});

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



//restarts play if new MIDI key is pressed with User Sounds
~holdNote = { // oder auf holdNote..
    |act, dictName |
    var dictVar, dictChan;
    case
    {dictName == "midi"}{dictVar = ~midi; dictChan = ~midiChannels; ~activeRoutines.put(dictName.asSymbol, ())}
    {dictName == "patFuncs"}{dictVar = ~patFuncs; dictChan = ~patternChannels;}
    {dictName == "live"}{dictVar = ~live; dictChan = ~liveChannels; ~activeRoutines.put(dictName.asSymbol, ())}
    {true}{nil};
    dictName = dictName.asSymbol;
    if (act == 1,
        {
            ~makeCC.(dictVar, dictChan);
            MIDIdef.noteOn(\holdNoteOn, {
                |vel, num|
                var rout = ~activeRoutines[dictName][num.asSymbol] ;
                if ((rout.notNil && rout.isPlaying), {"stopping rout".postln; rout.stop});
                if (dictVar.keys.includes(num.asSymbol),{
                    ~activeRoutines[dictName].put(num.asSymbol, Routine(dictVar[num.asSymbol]));
                    " ~activeRoutines % ".format(~activeRoutines).postln;
                  ~activeRoutines[dictName][num.asSymbol].play;
                });
                "on off % playing/restart routine %".format(dictName, num).postln;
            });
            MIDIdef.noteOff(\holdNoteOff, {
                |vel, num|
                var rout = ~activeRoutines[dictName][num.asSymbol];
                if (dictVar.keys.includes(num.asSymbol),{
                    rout.stop;
                    ~activeSynths[num.asSymbol].free;
                    "% stopped routine %  released  %".format(dictName, num, ~activeSynths[num.asSymbol]).postln;
                });
            });
        }
      ,{
            "freeing MIDIdefs".postln;
           MIDIdef.freeAll;
        }
    )

};


//always plays the complete data array with User Sounds
~oneShot = {
    /*Bei NoteOn wird das One Shot entweder an oder ausgeschaltet*/
    |act, dictName |
    var dictVar, dictChan;
    case
    {dictName == "midi"}{dictVar = ~midi; dictChan = ~midiChannels; ~activeRoutines.put(dictName.asSymbol, ())}
    {dictName == "patFuncs"}{dictVar = ~patFuncs; dictChan = ~patternChannels;}
    {dictName == "live"}{dictVar = ~live; dictChan = ~liveChannels; ~activeRoutines.put(dictName.asSymbol, ())}
    {true}{nil};
    dictName = dictName.asSymbol;
    if (act == 1,
        {
            ~makeCC.(dictVar, dictChan);
            MIDIdef.noteOn(\oneShotOn, {
                |vel, num|
                var rout = ~activeRoutines[dictName][num.asSymbol];
                if ( rout.isPlaying, {
                    rout.stop;
                    "stopping rout: % rout exists? %".format(num, rout.class).postln;
                    ~activeSynths[num.asSymbol].free;
                },{
                    if (dictVar.keys.includes(num.asSymbol),{
                        ~activeRoutines[dictName].put(num.asSymbol, Routine(dictVar[num.asSymbol]));
                        " ~activeRoutines % ".format(~activeRoutines).postln;
                        ~activeRoutines[dictName][num.asSymbol].play;
                    });
                    "on off % playing/restart routine %".format(dictName, num).postln;

                });


            });
            MIDIdef.noteOff(\oneShotOff, {
                |vel, num|
                "oneShot  NoteOff %".format(num.asSymbol).postln;

            });
        },{

            "freeing MIDIdefs and routine".postln;
            [\oneShotOn, \oneShotOff].do{|n| MIDIdef(n).free};
        }
    )
};



//restarts play if new MIDI key is pressed with User Sounds
~onOffButton = {
    |pressed, k, i, dictName|
    var rout, dictVar;
    case
    {dictName == "midi"}{dictVar = ~midi}
    {dictName == "patFuncs"}{dictVar = ~patFuncs}
    {dictName == "live"}{dictVar = ~live}
    {true}{nil};
    rout = ~routines[dictName.asSymbol][i];
    if (pressed==1, {
       "reset rout % %".format(rout, k).postln;  rout.reset;
        rout.play;
        "% playing/restart routine % % ".format(dictName, i, rout.isPlaying).postln;
    },{
        "stopping routine %  % releasing %".format(i, ~activeSynths[k.asSymbol]).postln;
       rout.stop;
         ~activeSynths[k.asSymbol].release(2);
            "stopped routine %  released Synth %".format(~activeSynths[k.asSymbol]).postln;
        });

};
//toggles between play and pause of the routine, remembers last position
~pausButton = {
    |btn, rout, num, dictName|
    var dictVar;
     case
    {dictName == "midi"}{dictVar = ~midi}
    {dictName == "patFuncs"}{dictVar = ~patFuncs}
    {dictName == "live"}{dictVar = ~live}
    {true}{nil};
    [btn, rout, num].postln;
    if (btn==1, {
       "resume rout at %".format(~currentData[num][\position]).postln;  rout.reset;
        rout.play;
        //"playing/restart routine %".format(num.asSymbol).postln;
        "playing/restart routine".postln;
    },{
        rout.stop;
         ~activeSynths[num.asSymbol].release(3);
            //"stopped routine %  released Synth %".format(~rout.isPlaying,~activeSynths[num.asSymbol]).postln;
        "paused routine at position % released Synth ".format(~currentData[num][\position]).postln;
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





