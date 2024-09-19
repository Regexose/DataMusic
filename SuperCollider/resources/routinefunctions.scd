~patFuncs = (
      \klic : {
        var data, compressed, normalized, reduce;
        reduce= ~currentData[\60][\reduce];
        data = ~currentData[\60][\data].asArray;
        compressed = data.select({|item, i| i%reduce == 0});
        normalized = compressed.normalize(0.05, 1.0);
        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        normalized.do({
            |d, i|
            "original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            Pbindef(\klic,
                \vowelIndex, d.linlin(0.05, 1.0, 0, 24).asInteger,
                \dur, 0.5,
                \stopFilterOrders, [1.0, 3.1, 2.4, 2.1, 3.4] *d,
                \baseFreq, [150, 500, 1200] * d,
            );

           0.5.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh};
        });
        Pbindef(\klic).stop;
    },

    \arp3 : {
        var data, compressed, normalized, reduce;
        reduce= ~currentData[\60][\reduce];
        data = ~currentData[\60][\data].asArray;
        compressed = data.select({|item, i| i%reduce == 0});
        normalized = compressed.normalize(0.05, 0.9);
        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        normalized.do({
            |d, i|
            "original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            Pbindef(\arp3,
                \freqScale, d,
                \dur, 0.5
            );

           0.5.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh};
        });
        Pbindef(\arp3).stop;
    },

    \voc1 : {
        var data, compressed, normalized, reduce;
        reduce= ~currentData[\60][\reduce];
        data = ~currentData[\60][\data].asArray;
        compressed = data.select({|item, i| i%reduce == 0});
        normalized = compressed.normalize(0.05, 0.9);
        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        normalized.do({
            |d, i|
            "original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            Pbindef(\voc1,
                \vow, d.linlin(0.05, 0.9, 0, 24).asInteger,
                \freqScale, d,
                \decayScale, d,
                \buf, ~currentSample[\base],

            );

             4.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 14, 900); ~cursor.refresh};
        });
        Pbindef(\voc1).stop;
    }

)