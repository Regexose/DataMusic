
~patFuncs = (
      \klic : {
        // statt patterns jetzt eine Routine, die das \gate Argument reguliert
        var data, compressed, normalized, reduce, lastPos, oldSize, mn, mx, syn;
        reduce= ~currentData[\klic][\reduce];
        #mn, mx = [0.05, 0.9];
        lastPos =  ~currentData[\klic][\position];
        data = ~currentData[\klic][\data].asArray;
        ~currentData.globalKey = \klic;
        //compressed = data.select({|item, i| i%reduce == 0});
        oldSize = data.size; //logic for pause/resume
        //
        data = data.normalize(mn, mx)[lastPos..oldSize-1];
        syn = Synth(\dynklank, ~synthArgs.klic);
         ~activeSynths.put(\klic, syn);
        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        data.do({
            |d, i|
            syn.set(\freqScale, d, \decayScale, d,  \ffreq, d.linlin(mn, mx, 200, 3000));
            ~sends.perc_snd_vrb1.level= d.explin(mn, mx, 0.001, 0.04);
            ~currentData[\klic][\position] = i + lastPos;
            ~currentData[\globalPos] = i + ~currentData[\globalPos];
            ( ~t.beatDur * 4).wait;
         /*   defer{~posX = (i+lastPos).linlin(0, normalized.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh};*/
        });
        syn.free;
         ~currentData[\klic][\position] = 0;
    },

    \snarl : {
        var data, compressed, normalized, reduce, lastPos, oldSize, mn, mx, syn;
        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        reduce= ~currentData[\snarl][\reduce];
        data = ~currentData[\snarl][\data].asArray;
        ~currentData.globalKey = \snarl;
        lastPos =  ~currentData[\snarl][\position];
        //compressed = data.select({|item, i| i%reduce == 0});
        oldSize = data.size; //logic for pause/resume
        #mn, mx = [0.05, 0.9];
        data = data.normalize(mn, mx)[lastPos..oldSize-1];
        syn = Synth(\oddeven, ~synthArgs.snarl);
         ~activeSynths.put(\snarl, syn);
        data.do({
            |d, i|
            "  normalized data   %  at   %".format(data[i].trunc(0.0001), i + lastPos).postln;
            syn.set( \vowelIndex, d.linlin(mn, mx, 0, 5).asInteger * 4, \freqScale, d,
                \baseFreq, [60, 63, 68].midicps * d );
            ~currentData[\snarl][\position] = i + lastPos;
         ~t.beatDur.wait;
           /* defer{~posX = (i+lastPos).linlin(0, normalized.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh};*/
        });
        syn.free;
         ~currentData[\snarl][\position] = 0;
    },

    \voc1 : {
        var data, normalized, reduce, lastPos, oldSize, mn, mx, avg, ranges, syn;
        reduce= ~currentData[\voc1][\reduce];
        data = ~currentData[\voc1][\data].asArray;
        ~currentData.globalKey = \voc1;
        lastPos =  ~currentData[\voc1][\position];
        //compressed = data.select({|item, i| i%reduce == 0});
        oldSize = data.size; //logic for pause/resume
        #mn, mx = [0.05, 0.9];
        normalized = data.normalize(mn, mx)[lastPos..oldSize-1];
        avg = normalized.mean;
        ranges = [0.1, 0.25, 0.5, 0.75] * avg;
        syn = Synth(\vowelklank, ~synthArgs.voc1);
         ~activeSynths.put(\voc1, syn);
        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        normalized.do({
            |d, i|
            var c;
            //"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i + lastPos).postln;
            c = case
            {(d >= (avg - ranges[0])) && (d <= (avg + ranges[0]))}{"range 0".postln; syn.set(\vow, 1)}
            {(d >= (avg - ranges[1])) && (d <= (avg + ranges[1]))}{"range 1".postln;syn.set(\vow, 6)}
            {(d >=  (avg - ranges[2])) && (d <= (avg + ranges[2]))}{"range 2".postln;syn.set(\vow, 11)}
            {(d >= (avg - ranges[3])) && (d <= (avg + ranges[3]))}{"range 3".postln;syn.set(\vow, 16)}
            {(d >= 0) && (d <= mx)}{"range 4".postln; syn.set(\vow, 21)}
            {true}{"d outside range".postln};
            syn.set( \freqScale, d, \ffreq, d * 2000);
            ~currentData[\voc1][\position] = i+lastPos;
             ~t.beatDur.wait;
          /* defer{~posX = (i+lastPos).linlin(0, normalized.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh};*/
        });
        syn.free;
           ~currentData[\voc1][\position] = 0;
    },

    \dark : {
        var key=\dark, data, normalized, reduce, lastPos, oldSize, mn, mx, syn;
        reduce= ~currentData[key][\reduce];
        data = ~currentData[key][\data].asArray;
        ~currentData.globalKey = [key];
        lastPos =  ~currentData[key][\position];
        oldSize = data.size; //logic for pause/resume
        #mn, mx = [0.5, 3.0];
        normalized = data.normalize(mn, mx)[lastPos..oldSize-1];
        syn = Synth(\array_1b, ~synthArgs.dark);
         ~activeSynths.put(key, syn);
        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        normalized.do({
            |d, i|
            var c;
            //"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i + lastPos).postln;
            syn.set( \amp, d, \freq, 24.midicps * d);
            ~currentData[key][\position] = i+lastPos;
             (~t.beatDur* 1).wait;
            defer{~posX = (i+lastPos).linlin(0, normalized.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh};
        });
        syn.release(2);
           ~currentData[key][\position] = 0;
    },


);

~patternChannels = (
        //hier werden die sendNames für die Postsendregler festgelegt für ~makeCC
    \perc: [~perc, "_snd_dela"],
    \voc: [~voc, "_snd_dela"],
    );
