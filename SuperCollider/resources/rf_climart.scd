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
        var data, normalized, compressed, reduce, buf, syn;
        /* s.record(~recordingPath ++ "/jan_solar.wav", duration: 60);
        wait(0.02);*/
        reduce = ~currentData[\50][\reduce];
        data = ~currentData[\50][\data].asArray;
        compressed = data.select({|item, i| i%reduce == 0});
        normalized = compressed.normalize(80, 3000);
        buf = ~liveBuffer;
        s.sync;
        syn = Synth(\tgrains_live, [\amp, 0.45, \buf, buf, \dens, 2, \grainDur, 1.4, \grainAmp, 0.9, \harm, [0,0], \outdry, ~dryBus]);
        ~activeSynths.put(\50, syn);
        normalized.do({
            |d, i|
            //"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            syn.set(\ffreq, d, \harm, d.linlin(20, 3000, -12, 12));
            0.05.wait;
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
        var syn, data, compressed, normalized, reduce;
        reduce= ~currentData[\60][\reduce];
        data = ~currentData[\60][\data].asArray;
        compressed = data.select({|item, i| i%reduce == 0});
        normalized = compressed.normalize(80.0, 3500.0);
        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        syn = Synth(\arrayarg, [\amp, 0.2, \freqs, [ 48, 72, 84].midicps]);
        ~activeSynths.put(\60, syn);
        normalized.do({
            |d, i|
            "original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            syn.set(\ffreq, d, \mod, d.linlin(80, 3500, 1.0, 5.0), \pm, d.linlin(80, 3500, 0.0, 2pi)) ;
            0.05.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh;};

        });
        syn.release(2);
    },

)
