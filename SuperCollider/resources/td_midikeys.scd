~td = (
    // on Off Play
    \48 : {
        /* am besten mit Zischgeräuschen
        */
        var key= \48, data, reduce, buf, syn, mn, mx;
        //"play TD %  sm %".format(key, ~sm1).postln;
        buf = ~grainBuffer.normalize;
        # mn, mx =[90, 125];
        s.sync;
        syn = Synth(\grainBuf, [\amp, 0.7, \ptrBus, ~ptrBus, \buf,  buf, \rq, 0.14, \dens, 40,    \baseDur, 0.15,  \out, 0], ~sourceGrp);
        ~activeSynths.put(key, syn);
        loop{
            data = ~currentData.td[\sm1];
            syn.set(\ffreq, data.linlin(mn, mx, 1000, 4000),
                \rateRand, data.linlin(mn, mx , 1, 2.5),
                \dens, data.linlin(mn, mx, 1, 20),
                \baseDur, data.linlin(mn, mx, 1, 0.05),
            );
            0.5.wait};

    },
    \50 :{// geht mit fast allen Sounds
        var key= \50, data, buf, syn, mn, mx;
        //Grains mit dezidierter ptrPos und pan
        buf = ~grainBuffer;
         # mn, mx =[90,125];
        s.sync;
        syn = Synth(\grainBuf2, [\amp, 0.7, \ptrBus, ~ptrBus, \buf,  buf, \rq, 0.2, \dens, 50, \minPtrDelay, 300, \out,2], ~grainGrp);
        ~activeSynths.put(key, syn);
        loop{
            data = ~currentData.td[\sm1];
            syn.set(\ptrSampleDelay, data.linlin(mn, mx, 305, 10000),
                \pan, data.linlin(mn, mx, -1, 1),
                \baseDur, data.linlin(mn, mx, 0.05, 0.5),
            );
            0.5.wait};
    },

    \52 :{
        var key= \52, data, buf, syn, mn, mx;
        //Grains mit dezidierter ptrPos und pan
        //buf = ~buffersByName[\nitro][\tension];
        buf = ~grainBuffer;
         # mn, mx =[90,125];
        s.sync;
        syn = Synth(\grainScrub, [\amp, 0.3, \ptrBus, ~ptrBus, \buf, buf, \tr, 0.2, \out,4], ~grainGrp);
        ~activeSynths.put(key, syn);
        loop{
            data = ~currentData.td[\sm2];
            syn.set(
                \pan, data.linlin(mn, mx, -1, 1),
                \pos, data.linlin(95, 120, 0.0, buf.numFrames / s.sampleRate),
                \tr, data.linlin(mn, mx, 0.05, 5),
                //\harm, data.linlin(mn, mx, 0,8)
            );
            0.5.wait};
    },

    \53 : {
        var key= \53, data, syn, fx, mn, mx;
        //"play TD %  sm %".format(key, ~sm1).postln;
        # mn, mx =[90, 125];
        syn = Synth(\grainBuf, [\ptrBus, ~ptrBus, \ptrSampleDelay, 800, \amp, 0.9, \buf, ~grainBuffer, \dens, 20, \baseDur, 0.1, \out, ~dryBus, \outfx, ~fxBus, \send, 1], ~grainGrp);
        fx = Synth(\combdelay, [\bus, ~fxBus, \maxDelTime, 4, \decayTime, 3, \blend, 1, \out, 6], ~fxGrp);
        ~activeSynths.put(key, [syn, fx]);
        loop{
            data = ~currentData.td[\sm1];
            //"data % \t ffreq % \t deltime %".format(data, data.linlin(0, 1, 1500, 3500), data.linlin(0, 1, 0.02, 0.8) ).postln;
            //syn.set(\ffreq, data.linlin(mn, mx, 1500, 3500));//);
            //fx.set(\delTime, data.linlin(0, 1, 0.005, 0.5));
            fx.set(\delTime, data.lincurve(mn, mx, 0.02, 0.1, -3),
                \decayTime, data.linlin(mn, mx, 4, 0.2)
            );
            0.5.wait};
    },

        \55 :{
        var key= \55, data, buf, syn, mn, mx;
        //"play TD %  sm %".format(key, ~sm1).postln;
        buf = ~grainBuffer;
        # mn, mx =[90, 125];
        s.sync;
        syn = Synth(\grainBuf, [\amp, 0.5, \ptrBus, ~ptrBus, \buf,  buf, \rq, 0.44, \dens, 40, \drywet, 0.9, \minPtrDelay, 500, \ptrSampleDelay, 800, \rateRand, 1.2, \out, 6], ~grainGrp);
        ~activeSynths.put(key, syn);
        loop{
            data = ~currentData.td[\temp];
            //data.postln;
            syn.set(\ptrRandSamples, data.linlin(mn, mx, 10, 500),
                \ptrNoise, data.linlin(mn, mx, 3, 20),
                \rateNoise, data.linlin(mn, mx, 3, 20),
                //\durRand, data.linlin(0.1, 1.0, 1, 3),
                \rate, data.linlin(mn, mx, 0.5, 3),
            );
            0.05.wait};
    },

    \57 : {
        var key= \57, data, syn, fx, mn, mx;
        //"play TD %  sm %".format(key, ~sm1).postln;
        # mn, mx =[90, 125];
        syn = Synth(\grainBuf, [\ptrBus, ~ptrBus, \ptrSampleDelay, 800, \amp, 0.4, \buf, ~grainBuffer, \dens, 20, \baseDur, 0.1, \out, ~dryBus, \outfx, ~fxBus, \send, 1], ~grainGrp);
        fx = Synth(\combdelay, [\bus, ~fxBus, \maxDelTime, 3, \decayTime, 3, \blend, 1, \out, 8], ~fxGrp);
        ~activeSynths.put(key, [syn, fx]);
        loop{
            data = ~currentData.td[\temp];
            //"data % \t ffreq % \t deltime %".format(data, data.linlin(0, 1, 1500, 3500), data.linlin(0, 1, 0.02, 0.8) ).postln;
            syn.set(\ffreq, data.linlin(mn, mx, 600, 3500));//);
            //fx.set(\delTime, data.linlin(0, 1, 0.005, 0.5));
            fx.set(\delTime, data.linlin(mn, mx, 0.02, 0.1),
                \decayTime, data.linlin(mn, mx, 1, 0.2)
            );
            0.05.wait};
    },

    \59 : {
        var key= \59, data, syn, fx, mn, mx;
        //"play TD %  sm %".format(key, ~sm1).postln;
         # mn, mx =[90, 125];
        syn = Synth(\vowelklank, [\ptrBus, ~ptrBus,  \amp, 0.07, \drywet, 1, \buf, ~grainBuffer, \out, 10], ~grainGrp);
        ~activeSynths.put(key, syn);
        loop{
            data = ~currentData.td[\gust];
            //data.postln;
            syn.set(\freqScale, data, \vow, data.linlin(mn, mx, 0, 15).asInteger);
            0.05.wait};
    },
);

/*
~midiChannels = (
        //hier werden die sendNames für die Postsendregler festgelegt für ~makeCC
    \ch1: [~ch1, "_snd_dela"],
    \ch2: [~ch2, "_snd_dela"],
    \ch3: [~ch3, "_snd_ring"],
    \ch4: [~ch4, "_snd_vrb1"],
    \ch5: [~ch5, "_snd_dela"],
    \ch6: [~ch6, "_snd_dela"],
    \ch7: [~ch7, "_snd_dela"],
    \ch8: [~ch8, "_snd_dela"],
    );


// wann kommen die zum einsatz?
~midi2 = (
      \55: {
        // vowel trig
        var midikey= \55, data, reduce, buf1, buf2, buf3, syn1, mean, range, speed, mn, mx;
        /*  s.record(~recordingPath ++ "/ana_52_humid.wav", duration: 45);
        wait(0.02);*/
        #mn, mx = [300, 3000];
        reduce = ~currentData[midikey][\reduce];
        data = ~currentData[midikey][\data].asArray.normalize(mn,mx);
        ~currentData.globalKey = \55;
        mean = data.mean;
        range = mean / 6;
        buf1 = ~currentSample[\base].normalize;
        buf2 = ~currentSample[\tension].normalize;
        buf3 = ~currentSample[\relax].normalize;
        s.sync;
        syn1 = Synth(\voweltrig, [\buf, buf1, \amp, 0.4, \out, ~ch2.inbus, \outdry, ~dryBus]);
        s.sync;
        ~activeSynths.put(\55, syn1);
        data.do({
            |d, i|
            var c;
            //"original data  %  normalized data   %  at  %".format(compressed[i].trunc(0.0001), d, i).postln;
            c = case
            {(d >= (mean - range)) && (d<= (mean + range))}{
                syn1.set(\buf, buf1, \vow, 1 ,\ffreq, d.linlin(mn, mx, 100, 799));
                "mean".postln;

            }
            {d < (mean - range)}{
                syn1.set(\buf, buf2, \vow, 6, \ffreq, d.linlin(mn, mx, 800, 2000));
                "tension".postln;

            }
            {(d > (mean + range))}{
                syn1.set(\buf, buf3, \vow, 11, \ffreq, d.linlin(mn, mx, 2000, 4000));
                "relax".postln;


            }
            {true}{"no case".postln};
            0.04.wait;
            defer{~posX = i.linlin(0, data.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh;};
        });
        syn1.release(2);

    },

    \58 : {
        //MikrobenAktivität && Temperatur
        var midikey=\58, syn, data, compressed, normalized, reduce, lastPos, mn, mx, avg, borders;
        reduce= ~currentData[midikey][\reduce];
        //# in, out = [~currentData.dataIn, ~currentData.dataOut];
        data = ~currentData[midikey][\data].asArray;
         ~currentData.globalKey = midikey;
        lastPos =  ~currentData[midikey][\position];
        //compressed = data.select({|item, i| i%reduce == 0});
        #mn, mx = [0, 40];
        normalized = data.normalize(mn, mx);
        avg = normalized.mean;
        borders = [[0.0, 10.0 ], [10.0, 18.0], [18.0, 25.0], [25.0, 35.0]];
        /*s.record("/Volumes/Macintosh HD 2/projekte/DataMusic/DataMusic/recordings/temperatur_bass.wav", duration: 40);
        wait(0.02);*/
        syn = Synth(\crisps, ~synthArgs.nematode);
        ~activeSynths.put(midikey, syn);
        data.do({
            |d, i|
            var c;
            c = case
            {d > borders[3][1]} {syn.set(\trg, d.linexp(0, 50, 75, 125))}
            {(d > borders[3][0]) && (d <= borders[3][1])}
            {syn.set(\trg, d.linexp(mn, mx, 30, 75))}
            {(d > borders[2][0]) && (d <= borders[2][1])}
            {syn.set(\trg, d.linexp(mn, mx, 20, 30))}
            {(d > borders[1][0]) && (d <= borders[1][1])}
            {syn.set(\trg, d.linexp(mn, mx, 8, 20))}
            {(d > borders[0][0]) && (d <= borders[0][1])}
            {syn.set(\trg, d.linexp(mn, mx, 1, 8))}
            {true}{"data % out of border".format(d).postln};
            "original data  %  at  %".format(d.round(0.01),  i).postln;
            syn.set(\ffreq, d.linlin(mn, mx, 120, 4300), \rq, d.linlin(mn, mx, 0.1, 0.5), \pan, d.linlin(mn, mx, -1.0, 1.0 ), \decayScale, d.linlin(mn, mx, 0.6, 0.06)) ;
            ~currentData[\60][\position] = i + lastPos;
           0.1.wait;
            defer{~posX = i.linlin(0, data.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh;};

        });
        syn.release(2);
        ~currentData[midikey][\position] = 0;
    },

    \60 : {
        // C-N Akkord
        var syn, midikey=\60, data,normalized, reduce, oldSize, lastPos, mn, mx;
        reduce= ~currentData[midikey][\reduce];
        data = ~currentData[midikey][\data].asArray;
        ~currentData.globalKey = midikey;
        lastPos =  ~currentData[midikey][\position];
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
            ~currentData[midikey][\position] = i + lastPos;
            0.1.wait;
            defer{~posX = i.linlin(0, data.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh;};

        });
        syn.release(2);
        ~currentData[midikey][\position] = 0;
    },
);
*/
