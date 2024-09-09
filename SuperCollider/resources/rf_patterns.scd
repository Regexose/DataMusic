
~patFuncs = (
      \klic : {
        // ist der Master, der die globale Position vorgibt
        var data, compressed, normalized, reduce, lastPos, oldSize, mn, mx;
        reduce= ~currentData[\klic][\reduce];
        data = ~currentData[\klic][\data].asArray;
        ~currentData.globalKey = \klic;
        lastPos =  ~currentData[\klic][\position];
        //compressed = data.select({|item, i| i%reduce == 0});
        oldSize = data.size; //logic for pause/resume
        #mn, mx = [0.05, 0.9];
        //
        normalized = data.normalize(mn, mx)[lastPos..oldSize-1];

        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        normalized.do({
            |d, i|
            Pbindef(\klic,
                \freqScale, d,
                \decayScale, d,
            );
            ~sends.perc_snd_vrb1.level= d.explin(mn, mx, 0.001, 0.04);
            ~currentData[\klic][\position] = i + lastPos;
           ~currentData[\globalPos] = i + ~currentData[\globalPos];

          ( ~t.beatDur * 4).wait;
            defer{~posX = (i+lastPos).linlin(0, normalized.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh};
        });
        Pbindef(\klic).stop;
         ~currentData[\klic][\position] = 0;
    },

    \snarl : {
        var data, compressed, normalized, reduce, lastPos, oldSize, mn, mx;
        reduce= ~currentData[\snarl][\reduce];
        data = ~currentData[\snarl][\data].asArray;
        ~currentData.globalKey = \snarl;
        lastPos =  ~currentData[\snarl][\position];
        //compressed = data.select({|item, i| i%reduce == 0});
        oldSize = data.size; //logic for pause/resume
        #mn, mx = [0.05, 0.9];
        normalized = data.normalize(0.05, 0.9)[lastPos..oldSize-1];
        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        normalized.do({
            |d, i|
            //"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i + lastPos).postln;
            Pbindef(\snarl,
                \vowelIndex, d.linlin(mn, mx, 0, 5).asInteger * 4,
                \freqScale, d,
            );
              ~currentData[\snarl][\position] = i + lastPos;
         ~t.beatDur.wait;
            defer{~posX = (i+lastPos).linlin(0, normalized.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh};
        });
        Pbindef(\snarl).stop;
         ~currentData[\snarl][\position] = 0;
    },

    \voc1 : {
        var data, compressed, normalized, reduce, lastPos, oldSize, mn, mx, avg, ranges;
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
            defer{~posX = (i+lastPos).linlin(0, normalized.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh};
        });
        Pbindef(\voc1).stop;
           ~currentData[\voc1][\position] = 0;
    },


)
