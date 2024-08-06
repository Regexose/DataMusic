~rf = (
    // on Off Play
    \48 : {
        /* spielt brsaw-Synth mit filter frequency manipulation \ffreq
        */
        var data, normalized, compressed, reduce, buf, syn;
        /* s.record(~recordingPath ++ "/gunter_soilmoist.wav", duration: 60);
        wait(0.02);*/
        reduce = ~currentData[\48][\reduce];
        data = ~currentData[\48][\data].asArray;
        compressed = data.select({|item, i| i%reduce == 0});
        normalized = compressed.normalize(80, 3000);
        buf = ~currentSample[\base].normalize;
        s.sync;
        syn = Synth(\brsaw, [\amp, 0.45, \buf, buf, \outdry, ~dryBus]);
        ~activeSynths.put(\48, syn);
        normalized.do({
            |d, i|
            //"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            syn.set(\ffreq, d);
            0.05.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh}; // Update GUI
        });
        syn.release(2);

    },

    \50 :{
        /* spielt liveSynth-Synth mit filter frequency manipulation \ffreq
        und harmonischer verstimmung
        */
        var data, normalized, compressed, reduce, buf, syn, mn, mx;
      /* s.record(~recordingPath ++ "/proto01.wav", duration: 60);
        wait(0.02);*/
        reduce = ~currentData[\50][\reduce];
        data = ~currentData[\50][\data].asArray;
        compressed = data.select({|item, i| i%reduce == 0});
        # mn, mx = [0.0, 100]; // Bodenfeuchte WHC Water Holding Capacity
        normalized = compressed.normalize(mn, mx);
        buf = ~liveBuffer;
        s.sync;
        "pre Syn".postln;
        syn = Synth(\tgrains_live, [\in, 16, \amp, 0.45, \buf, buf, \dens, 2, \grainDur, 1.4, \grainAmp, 0.9, \out, ~ch1.inbus, \outdry, ~dryBus]);
        ~activeSynths.put(\50, syn);
        normalized.do({
            |d, i|
            //"original data  %   normalized data   %  at  %".format(normalized[i].trunc(0.001), d, i).postln;

            syn.set(\rate, d.linlin(mn, mx, 0.75, 1.25), \harm, d.linlin(mn, mx , [-12.0, -6.0, -0.5], [12.0, 6.0, 0.5]));
           ~t.beatDur.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh}; // Update GUI
        });
        syn.release(2);
    },



    \52: {
        // 3 mean options
        var data, normalized, compressed, reduce, buf1, buf2, buf3, syn, sec, mean, range;
        /*  s.record(~recordingPath ++ "/ana_52_humid.wav", duration: 45);
        wait(0.02);*/
        reduce = ~currentData[\52][\reduce];
        data = ~currentData[\52][\data].asArray;
        compressed = data.select({|item, i| i%reduce == 0});
        normalized = compressed.normalize(36.0, 60.0);
        mean = normalized.mean;
        range = mean / 30;
        buf1 = ~currentSample[\base].normalize;
        buf2 = ~currentSample[\tension].normalize;
        buf3 = ~currentSample[\relax].normalize;
        s.sync;
        sec = buf1.numFrames/s.sampleRate * 50;
        syn = Synth(\tgrains, [\amp, 0.4, \grainAmp, 0.5, \dens, 10, \pos, sec * 20, \outdry, ~dryBus]);
        s.sync;
        ~activeSynths.put(\52, syn);
        normalized.do({
            |d, i|
            var c;
            //"original data  %  normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            c = case
            {(d >= (normalized.mean - range)) && (d<= (normalized.mean + range))}{
                syn.set(\ffreq, d.linlin(36, 60, 250, 2500), \harm, d.linlin(36, 60, -12, 12)!2, \buf, buf1);
            }
            {d < (normalized.mean -range)}{
                syn.set(\ffreq, d.linlin(36, 60, 250, 2500), \harm, d.linlin(36, 60, -15, 15)!2, \buf, buf2);
            }
            {(d > (normalized.mean + range))}{
                syn.set(\ffreq, d.linlin(36, 60, 250, 2500), \harm, d.linlin(36, 60, -5, 5)!2, \buf, buf3)
            }
            {true}{"no case".postln};
            0.04.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh;};
        });
        syn.release(2);
    },

    \53: {
        // 3 mean options ohne pitch
        // versuchen, die buffer in quasi-Realtime zu loopen (ist das nicht einfach PlayBuf?)
        var data, normalized, compressed, reduce, buf1, buf2, buf3, syn1, mean, range, speed;
        /*  s.record(~recordingPath ++ "/ana_52_humid.wav", duration: 45);
        wait(0.02);*/
        reduce = ~currentData[\53][\reduce];
        data = ~currentData[\53][\data].asArray;
        compressed = data.select({|item, i| i%reduce == 0});
        normalized = compressed.normalize(300, 3000);
        mean = normalized.mean;
        mean.postln;
        range = mean / 10;
        buf1 = ~currentSample[\base].normalize;
        buf2 = ~currentSample[\tension].normalize;
        buf3 = ~currentSample[\relax].normalize;
        s.sync;
        syn1 = Synth(\grainScrub, [\buf, buf2, \amp, 0.4, \ffreq, 3000, \tr, 0.8, \outdry, ~dryBus]);
        s.sync;
        ~activeSynths.put(\53, syn1);
        normalized.do({
            |d, i|
            var c;
            //"original data  %  normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            "position %  i  %".format(i.linlin(0, normalized.size, 0.0, 1.0 ), i).postln;
            c = case
            {(d >= (normalized.mean - range)) && (d<= (normalized.mean + range))}{
                syn1.set(\buf, buf1, \pos, i.linlin(0, normalized.size, 0.0, 1.0 ));

            }
            {d < (normalized.mean - range)}{
                syn1.set(\buf, buf2, \pos, i.linlin(0, normalized.size, 0.0, 1.0 ));

            }
            {(d > (normalized.mean + range))}{
                syn1.set(\buf, buf3, \pos, i.linlin(0, normalized.size, 0.0, 1.0 ));

            }
            {true}{"no case".postln};
            0.04.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh;};
        });
        syn1.release(2);

    },

    \55: {
        // sample switch mit LFSaw als Pointer (simuliert Normalgeschwindigkeit)
        var data, normalized, compressed, reduce, buf1, buf2, buf3, syn1, mean, range, speed;
        /*  s.record(~recordingPath ++ "/ana_52_humid.wav", duration: 45);
        wait(0.02);*/
        reduce = ~currentData[\55][\reduce];
        data = ~currentData[\55][\data].asArray;
        compressed = data.select({|item, i| i%reduce == 0});
        normalized = compressed.normalize(300, 3000);
        mean = normalized.mean;
        range = mean / 6;
        [  mean, range].postln;
        buf1 = ~currentSample[\base].normalize;
        buf2 = ~currentSample[\tension].normalize;
        buf3 = ~currentSample[\relax].normalize;
        s.sync;
        syn1 = Synth(\brsaw, [\buf, buf1, \amp, 0.4, \ffreq, 3000, \outdry, ~dryBus]);
        s.sync;
        ~activeSynths.put(\55, syn1);
        normalized.do({
            |d, i|
            var c;
            //"original data  %  normalized data   %  at  %".format(compressed[i].trunc(0.0001), d, i).postln;
            c = case
            {(d >= (normalized.mean - range)) && (d<= (normalized.mean + range))}{
                syn1.set(\buf, buf1, \ffreq, d);
                "mean".postln;

            }
            {d < (normalized.mean - range)}{
                syn1.set(\buf, buf2, \ffreq, d.linlin(300, 3000, 800, 4000));
                "tension".postln;

            }
            {(d > (normalized.mean + range))}{
                syn1.set(\buf, buf3, \ffreq, d.linlin(300, 3000, 800, 4000));
                "relax".postln;


            }
            {true}{"no case".postln};
            0.04.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh;};
        });
        syn1.release(2);

    },

    \57 : {// für Vowel Synthesis
        var syn, data, compressed, normalized, reduce, dbs, buf;
        reduce= ~currentData[\57][\reduce];
        data = ~currentData[\57][\data].asArray;
        compressed = data.select({|item, i| i%reduce == 0});
        normalized = compressed.normalize(0.02, 0.09);
        buf = ~currentSample[\base].normalize;
        syn = Synth(\bpfstack, [\buf, buf, \amp, 0.7, \outdry, ~dryBus]);
        s.sync;
        ~activeSynths.put(\57, syn);
        normalized.do({
            |d, i|
            // welche Werte werden für Vowels benutzt?
            var key = d.linlin(0.05, 0.18, 1, 24).asInteger;
            dbs =  Vowel.formLib.at(~vowelDict[key][0], ~vowelDict[key][1], \db);
            "key % dbs %  sum % ".format(key, dbs, dbs[0..2].sum).postln;
            if (dbs[0..2].sum > -16, {
                syn.set(\vow, key, \fade, 0.9)
            },{
                syn.set(\vow, key, \fade, 1.5);
            }
            );
            d.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh;};
        });
        syn.release(2);

    },

   \58 : {// für Vowel Synthesis
        var syn, data, compressed, normalized, reduce, buf1, buf2, buf3, mean, range;
        reduce= ~currentData[\58][\reduce];
        data = ~currentData[\58][\data].asArray;
        compressed = data.select({|item, i| i%reduce == 0});
        normalized = compressed.normalize(1, 100);
        mean = normalized.mean;
        range = mean / 30;
        buf1 = ~currentSample[\base].normalize;
        buf2 = ~currentSample[\tension].normalize;
        buf3 = ~currentSample[\relax].normalize;
        syn = Synth(\vowelklank2, [\buf, buf1, \amp, 0.1, \outdry, ~dryBus]);
        s.sync;
        ~activeSynths.put(\58, syn);
        normalized.do({
            |d, i|
            // Vowels werden mit key geändert
            var c, key = d.linlin(1, 100, 0, 20).asInteger;
            c = case
            {(d >= (normalized.mean - range)) && (d<= (normalized.mean + range))}{
                syn.set(\vow, 0, \stp, d.linlin(1, 100, 0.1, 2.1), \buf, buf1, \freqScale, d.linlin(1, 100, 0.1, 0.6));
            }
            {d < (normalized.mean -range)}{
                syn.set(\vow, 5, \stp, d.linlin(1, 100, 0.1, 2.1), \buf, buf1,\freqScale, d.linlin(1, 100, 0.1, 0.6));
            }
            {(d > (normalized.mean + range))}{
                syn.set(\vow, 10, \stp, d.linlin(1, 100, 0.1, 2.1), \buf, buf1,\freqScale, d.linlin(1, 100, 0.1, 0.6))
            }
            {true}{"no case".postln};
            //"i % key % dbs %  sum % ".format(i, key, dbs, dbs[0..2].sum).postln;
           0.03.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh};
        });
        syn.release(2);

    },

    \60 : {
        //MikrobenAktivität && Temperatur
        var syn, data, compressed, normalized, reduce, lastPos, mn, mx, avg, ranges;
        reduce= ~currentData[\60][\reduce];
        data = ~currentData[\60][\data][~dataIn.asInteger .. ~dataOut.asInteger].asArray;
        lastPos =  ~currentData[\60][\position];
        compressed = data.select({|item, i| i%reduce == 0});
        #mn, mx = [-5, 50];
        normalized = compressed.normalize(mn, mx);
        avg = normalized.mean;
        ranges = [0.1, 0.25, 0.5, 0.75] * avg;
        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        syn = Synth(\crisps, ~synthArgs.wimper);
        ~activeSynths.put(\60, syn);
        normalized.do({
            |d, i|
            var c;
                c = case
            {d > 35}{"over max".postln; syn.set(\trg, d.linlin(35, mx, 75, 125), \dec, 0.01)}
                {(d >= 25) && (d <= 35)}{"max".postln; syn.set(\trg, d.linlin(25, 35, 30, 75), \dec, 0.01)}
            {(d >= 18 ) && (d <= 24)}{"hoch".postln;syn.set(\trg, d.linlin(18, 24, 20, 30), \dec, 0.06)}
            {(d >= 8) && (d <= 17)}{"mittel".postln;syn.set(\trg, d.linlin(8, 17, 8, 20), \dec, 0.09)}
            {(d >= 0 ) && (d <= 7)}{"niedrig".postln;syn.set(\trg, d.linlin(8, 17, 1, 8), \dec, 0.126)}
            {d < 0}{"keine Aktivität".postln; syn.set(\trg, 0.001, \dec, 0.136)}
            {true}{"d outside range".postln};
            /*"original data  %   normalized data   %  at   %".format(compressed[i].round(0.01), d, i).postln;*/
            syn.set(\ffreq, d.linlin(mn, mx, 120, 2300), \rq, d.linlin(mn, mx, 0.1, 0.5)) ;
            ~currentData[\60][\position] = i + lastPos;
            ~t.beatDur.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh;};

        });
        syn.release(2);
        ~currentData[\60][\position] = 0;
    },

    \62 : {
        // C-N Akkord
        var syn, data, compressed, normalized, reduce, oldSize, lastPos, mn, mx;
        reduce= ~currentData[\62][\reduce];
        data = ~currentData[\62][\data].asArray;
        lastPos =  ~currentData[\60][\position];
        compressed = data.select({|item, i| i%reduce == 0});
          oldSize = compressed.size; //logic for pause/resume
        #mn, mx = [-25.0, 25.0];
        if (~currentData[\globalPos] == 0, {normalized = compressed.normalize(mn, mx)[lastPos..oldSize-1]},{normalized = compressed.normalize(mn, mx)[~currentData[\globalPos]..oldSize-1]});


        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        syn = Synth(\arrayarg, [\amp, 0.1, \freq, [65, 71, 73].midicps -24, \mods, [2.0, -12.0, -3.0], \lg, 0.4, \rq, 0.2, \phsMod, 0.5, \out, ~ch1.inbus]);
        ~activeSynths.put(\62, syn);
        normalized.do({
            |d, i|
            //"original data  % freqs %  mods % at   %".format(compressed[i].trunc(0.0001), [d *2, d *2.5], Array.fill(3,  {|n| d.linlin(mn, mx, -100*(n+1), 100*(n+1))}),  i).postln;
            syn.setn(\mods, Array.fill(3,  {|n| d * (n+1)}),
                \freq, [53, 49, 51].midicps * [[0.8, 1.2], [0.5, 1.9], [0.95, 1.05] ].collect({|r| {d.linlin(mn, mx, r[0], r[1])}}));
            ~currentData[\62][\position] = i + lastPos;
            ~t.beatDur.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh;};

        });
        syn.release(2);
        ~currentData[\62][\position] = 0;
    },


);

~patFuncs = (
      \klic : {
        // ist der Master, der die globale Position vorgibt
        var data, compressed, normalized, reduce, lastPos, oldSize, mn, mx;
        reduce= ~currentData[\klic][\reduce];
        data = ~currentData[\klic][\data].asArray;
        lastPos =  ~currentData[\klic][\position];
        compressed = data.select({|item, i| i%reduce == 0});
        oldSize = compressed.size; //logic for pause/resume
        #mn, mx = [0.05, 0.9];
        //
        normalized = compressed.normalize(mn, mx)[lastPos..oldSize-1];

        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        normalized.do({
            |d, i|
            //"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i + lastPos).postln;
            Pbindef(\klic,
                \freqScale, d,
                \decayScale, d,
            );
            ~sends.perc_snd_vrb1.level= d.explin(0.05, 1.0, 0.001, 0.04);
            ~currentData[\klic][\position] = i + lastPos;
           ~currentData[\globalPos] = i + ~currentData[\globalPos];

           ~t.beatDur.wait;
            defer{~posX = (i+lastPos).linlin(0, normalized.size-1, 14, 900); ~cursor.refresh};
        });
        Pbindef(\klic).stop;
         ~currentData[\klic][\position] = 0;
    },

    \snarl : {
        var data, compressed, normalized, reduce, lastPos, oldSize;
        reduce= ~currentData[\snarl][\reduce];
        data = ~currentData[\snarl][\data].asArray;
        lastPos =  ~currentData[\snarl][\position];
        compressed = data.select({|item, i| i%reduce == 0});
        oldSize = compressed.size; //logic for pause/resume
        normalized = compressed.normalize(0.05, 0.9)[lastPos..oldSize-1];
        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        normalized.do({
            |d, i|
            //"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i + lastPos).postln;
            Pbindef(\snarl,
                \vowelIndex, d.linlin(0.05, 0.9, 0, 5).asInteger * 4,
                \freqScale, d,
            );
              ~currentData[\snarl][\position] = i + lastPos;
         ~t.beatDur.wait;
            defer{~posX = (i+lastPos).linlin(0, normalized.size-1, 14, 900); ~cursor.refresh};
        });
        Pbindef(\snarl).stop;
         ~currentData[\snarl][\position] = 0;
    },

    \voc1 : {
        var data, compressed, normalized, reduce, lastPos, oldSize, mn, mx, avg, ranges;
        reduce= ~currentData[\voc1][\reduce];
        data = ~currentData[\voc1][\data].asArray;
        lastPos =  ~currentData[\voc1][\position];
        compressed = data.select({|item, i| i%reduce == 0});
        oldSize = compressed.size; //logic for pause/resume
        #mn, mx = [0.05, 0.9];
        normalized = compressed.normalize(mn, mx)[lastPos..oldSize-1];
        avg = normalized.mean;
        ranges = [0.1, 0.25, 0.5, 0.75] * avg;
        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        normalized.do({
            |d, i|
            var c;
            //"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i + lastPos).postln;
            c = case
            {(d >= (avg - ranges[0])) && (d <= (avg + ranges[0]))}{"range 0".postln; Pbindef(\voc1, \vow, 1)}
            {(d >= (avg - ranges[1])) && (d <= (avg + ranges[1]))}{"range 1".postln;Pbindef(\voc1, \vow, 6)}
            {(d >=  (avg - ranges[2])) && (d <= (avg + ranges[2]))}{"range 2".postln;Pbindef(\voc1, \vow, 11)}
            {(d >= (avg - ranges[3])) && (d <= (avg + ranges[3]))}{"range 3".postln;Pbindef(\voc1, \vow, 16)}
            {(d >= 0) && (d <= mx)}{"range 4".postln; Pbindef(\voc1, \vow, 21)}
            {true}{"d outside range".postln};
            Pbindef(\voc1, \fScale, d, \ffreq, d * 10000);
            ~currentData[\voc1][\position] = i+lastPos;
             ~t.beatDur.wait;
            defer{~posX = (i+lastPos).linlin(0, normalized.size-1, 14, 900); ~cursor.refresh};
        });
        Pbindef(\voc1).stop;
           ~currentData[\voc1][\position] = 0;
    },


)
