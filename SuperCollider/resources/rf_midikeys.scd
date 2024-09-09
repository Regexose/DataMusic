~midi = (
    // on Off Play
    \48 : {
        /* spielt brsaw-Synth mit filter frequency manipulation \ffreq
        */
        var data, normalized, compressed, reduce, buf, syn;
        /* s.record(~recordingPath ++ "/gunter_soilmoist.wav", duration: 60);
        wait(0.02);*/
        //reduce = ~currentData[\48][\reduce];
        data = ~currentData[\48][\data].asArray;
        ~currentData.globalKey = \48; // für handling des RangeSliders
        //compressed = data.select({|item, i| i%reduce == 0});
        normalized = data.normalize(80, 5000);
        buf = ~currentSample[\base].normalize;
        s.sync;
        syn = Synth(\brsaw, [\amp, 0.45, \buf, buf, \rq, 0.44, \out, ~ch1.inbus, \outdry, ~dryBus]);
        ~activeSynths.put(\48, syn);
        normalized.do({
            |d, i|
            //"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            syn.set(\ffreq, d);
            0.05.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh}; // Update GUI
        });
        syn.release(2);

    },

    \50 : {
        /* Nitrifikation
        */
        var data, normalized, buf, syn;
        /* s.record(~recordingPath ++ "/gunter_soilmoist.wav", duration: 60);
        wait(0.02);*/
        //reduce = ~currentData[\48][\reduce];
        data = ~currentData[\50][\data].asArray;
        ~currentData.globalKey = \50; // für handling des RangeSliders
        normalized = data.normalize(80, 5000);
        buf = ~currentSample[\base].normalize;
        s.sync;
        syn = Synth(\vowelklank, [\amp, 0.35, \buf, buf, \rq, 0.44, \out, ~voc.inbus, \outdry, ~dryBus]);
        ~activeSynths.put(\50, syn);
        normalized.do({
            |d, i|
            //"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            syn.set(\ffreq, d);
            0.05.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh}; // Update GUI
        });
        syn.release(2);

    },


    \52: {
        // 3 mean options
        var data, normalized, compressed, reduce, buf1, buf2, buf3, syn, sec, mean, range, mn, mx;
        /*  s.record(~recordingPath ++ "/ana_52_humid.wav", duration: 45);
        wait(0.02);*/
        //reduce = ~currentData[\52][\reduce];
        data = ~currentData[\52][\data].asArray;
          ~currentData.globalKey = \52;
        //compressed = data.select({|item, i| i%reduce == 0});
        #mn, mx = [36.0, 60.0];
        normalized = data.normalize(mn, mx);
        mean = normalized.mean;
         range = mean / 30;
        buf1 = ~currentSample[\base].normalize;
        buf2 = ~currentSample[\tension].normalize;
        buf3 = ~currentSample[\relax].normalize;
        s.sync;
        sec = buf1.numFrames/s.sampleRate * 50;
        syn = Synth(\tgrains, [\amp, 0.4, \grainAmp, 0.5, \dens, 10, \lg, 0.7, \pos, sec * 20, \outdry, ~dryBus]);
        s.sync;
        ~activeSynths.put(\52, syn);
        normalized.do({
            |d, i|
            var c;
            //"original data  %  normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            c = case
            {(d >= (normalized.mean - range)) && (d<= (normalized.mean + range))}{
                syn.set(\ffreq, d.linlin(mn, mx, 250, 2500), \harm, d.linlin(mn, mx, -12, 12)!2, \buf, buf1);
            }
            {d < (normalized.mean -range)}{
                syn.set(\ffreq, d.linlin(mn, mx, 250, 2500), \harm, d.linlin(mn, mx, -15, 15)!2, \buf, buf2);
            }
            {(d > (normalized.mean + range))}{
                syn.set(\ffreq, d.linlin(mn, mx, 250, 2500), \harm, d.linlin(mn, mx, -5, 5)!2, \buf, buf3)
            }
            {true}{"no case".postln};

            0.04.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh;};
        });
        syn.release(2);
    },

    \53: {
        // 3 mean options ohne pitch
        // versuchen, die buffer in quasi-Realtime zu loopen (ist das nicht einfach PlayBuf?)
        var data, normalized, compressed, reduce, buf1, buf2, buf3, syn1, mean, range, mn, mx;
        /*  s.record(~recordingPath ++ "/ana_52_humid.wav", duration: 45);
        wait(0.02);*/
        reduce = ~currentData[\53][\reduce];
        data = ~currentData[\53][\data].asArray;
        ~currentData.globalKey = \53;
        //compressed = data.select({|item, i| i%reduce == 0});
        #mn, mx = [300, 3000];
        normalized = data.normalize(mn, mx);
        mean = normalized.mean;
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
            //"position %  i  %".format(i.linlin(0, normalized.size, 0.0, 1.0 ), i).postln;
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
            defer{~posX = i.linlin(0, normalized.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh;};
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
        ~currentData.globalKey = \55;
        //compressed = data.select({|item, i| i%reduce == 0});
        normalized = data.normalize(300, 3000);
        mean = normalized.mean;
        range = mean / 6;
        buf1 = ~currentSample[\base].normalize;
        buf2 = ~currentSample[\tension].normalize;
        buf3 = ~currentSample[\relax].normalize;
        s.sync;
        syn1 = Synth(\brsaw, [\buf, buf1, \amp, 0.4, \out, ~ch2.inbus, \outdry, ~dryBus]);
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
            defer{~posX = i.linlin(0, normalized.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh;};
        });
        syn1.release(2);

    },

    \57 : {// für Vowel Synthesis
        var syn, data, compressed, normalized, reduce, dbs, buf, mn, mx;
        reduce= ~currentData[\57][\reduce];
        data = ~currentData[\57][\data].asArray;
        ~currentData.globalKey = \57;
        //compressed = data.select({|item, i| i%reduce == 0});
        #mn, mx = [0.02, 0.09];
        normalized = data.normalize(mn, mx);
        buf = ~currentSample[\base].normalize;
        syn = Synth(\bpfstack, [\buf, buf, \amp, 0.7, \rls, 1.0, \outdry, ~dryBus]);
        s.sync;
        ~activeSynths.put(\57, syn);
        normalized.do({
            |d, i|
            // welche Werte werden für Vowels benutzt?
            var key = d.linlin(mn, mx, 1, 24).asInteger;
            dbs =  Vowel.formLib.at(~vowelDict[key][0], ~vowelDict[key][1], \db);
            "key % dbs %  sum % ".format(key, dbs, dbs[0..2].sum).postln;
            if (dbs[0..2].sum > -16, {
                syn.set(\vow, key, \fade, 0.9)
            },{
                syn.set(\vow, key, \fade, 1.5);
            }
            );
            d.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh;};
        });
        syn.release(2);

    },

   \58 : {// für Vowel Synthesis
        var syn, data, compressed, normalized, reduce, buf1, buf2, buf3, mean, range, mn, mx;
        reduce= ~currentData[\58][\reduce];
        data = ~currentData[\58][\data].asArray;
         ~currentData.globalKey = \58;
        //compressed = data.select({|item, i| i%reduce == 0});
        #mn, mx = [1, 100];
        normalized = data.normalize(mn, mx);
        mean = normalized.mean;
        range = mean / 30;
        buf1 = ~currentSample[\base].normalize;
        buf2 = ~currentSample[\tension].normalize;
        buf3 = ~currentSample[\relax].normalize;
        syn = Synth(\vowelklank2, [\buf, buf1, \amp, 0.1, \out, ~voc, \outdry, ~dryBus]);
        s.sync;
        ~activeSynths.put(\58, syn);
        normalized.do({
            |d, i|
            // Vowels werden mit key geändert
            var c, key = d.linlin(1, 100, 0, 20).asInteger;
            c = case
            {(d >= (normalized.mean - range)) && (d<= (normalized.mean + range))}{
                syn.set(\vow, 0, \stp, d.linlin(mn, mx, 0.1, 2.1), \buf, buf1, \freqScale, d.linlin(1, 100, 0.1, 0.6));
            }
            {d < (normalized.mean -range)}{
                syn.set(\vow, 5, \stp, d.linlin(mn, mx, 0.1, 2.1), \buf, buf1,\freqScale, d.linlin(1, 100, 0.1, 0.6));
            }
            {(d > (normalized.mean + range))}{
                syn.set(\vow, 10, \stp, d.linlin(mn, mx, 0.1, 2.1), \buf, buf1,\freqScale, d.linlin(1, 100, 0.1, 0.6))
            }
            {true}{"no case".postln};
           0.03.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh};
        });
        syn.release(2);

    },

    \60 : {
        //MikrobenAktivität && Temperatur
        var syn, data, compressed, normalized, reduce, lastPos, mn, mx, avg, borders;
        reduce= ~currentData[\60][\reduce];
        //# in, out = [~currentData.dataIn, ~currentData.dataOut];
        data = ~currentData[\60][\data].asArray;
         ~currentData.globalKey = \60;
        lastPos =  ~currentData[\60][\position];
        //compressed = data.select({|item, i| i%reduce == 0});
        #mn, mx = [-5, 50];
        normalized = data.normalize(mn, mx);
        avg = normalized.mean;
        borders = [[0.0, 10.0 ], [10.0, 18.0], [18.0, 25.0], [25.0, 35.0]];
        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        syn = Synth(\crisps, ~synthArgs.nematode);
        ~activeSynths.put(\60, syn);
        data.do({
            |d, i|
            var c;
            c = case
            {d > borders[3][1]} {syn.set(\trg, d.linexp(0, 50, 75, 125))}
            {(d > borders[3][0]) && (d <= borders[3][1])}
            {syn.set(\trg, d.linexp(0, 50, 30, 75))}
            {(d > borders[2][0]) && (d <= borders[2][1])}
            {syn.set(\trg, d.linexp(0, 50, 20, 30))}
            {(d > borders[1][0]) && (d <= borders[1][1])}
            {syn.set(\trg, d.linexp(0, 50, 8, 20))}
            {(d > borders[0][0]) && (d <= borders[0][1])}
            {syn.set(\trg, d.linexp(0, 50, 1, 8))}
            {true}{"data % out of border".format(d).postln};
            "original data  %  at  %".format(d.round(0.01),  i).postln;
            syn.set(\ffreq, d.linlin(0, 50, 120, 4300), \rq, d.linlin(0, 50, 0.1, 0.5), \pan, d.explin(8, 40, -0.5, 0.5 )) ;
            ~currentData[\60][\position] = i + lastPos;
           0.1.wait;
            defer{~posX = i.linlin(0, data.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh;};

        });
        syn.release(2);
        ~currentData[\60][\position] = 0;
    },

    \62 : {
        // C-N Akkord
        var syn, data, compressed, normalized, reduce, oldSize, lastPos, mn, mx;
        reduce= ~currentData[\62][\reduce];
        data = ~currentData[\62][\data].asArray;
        ~currentData.globalKey = \62;
        lastPos =  ~currentData[\62][\position];
        //compressed = data.select({|item, i| i%reduce == 0});
          oldSize = data.size; //logic for pause/resume
        #mn, mx = [-25.0, 25.0];
        if (~currentData[\globalPos] == 0, {normalized = data.normalize(mn, mx)[lastPos..oldSize-1]},{normalized = data.normalize(mn, mx)[~currentData[\globalPos]..oldSize-1]});


        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        syn = Synth(\arrayarg, [\amp, 0.1, \freq, [65, 71, 73].midicps -24, \mods, [2.0, -12.0, -3.0], \lg, 0.4, \rq, 0.2, \phsMod, 0.5, \out, ~ch1.inbus]);
        ~activeSynths.put(\62, syn);
        data.do({
            |d, i|
            "original data  % at %".format(d, i).postln;
            syn.setn(\mods, Array.fill(3,  {|n| d * (n+1)}),
                \freq, [53, 49, 51].midicps * [[0.8, 1.2], [0.5, 1.9], [0.95, 1.05] ].collect({|r| {d.linlin(mn, mx, r[0], r[1])}}));
            ~currentData[\62][\position] = i + lastPos;
            0.1.wait;
            defer{~posX = i.linlin(0, data.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh;};

        });
        syn.release(2);
        ~currentData[\62][\position] = 0;
    },


);
