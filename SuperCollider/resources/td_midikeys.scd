~td = (
    // on Off Play
    \48 : {
        /* spielt brsaw-Synth mit filter frequency manipulation \ffreq
        */
        var key= \48, data, reduce, buf, syn;
        //"play TD %  sm %".format(key, ~sm1).postln;
        buf = ~grainBuffer;
        s.sync;
        syn = Synth(\grainBuf, [\amp, 0.5, \ptrBus, ~ptrBus, \buf,  buf, \rq, 0.44, \dens, 40, \drywet, 0.9, \ptrSampleDelay, s.sampleRate/3, \ptrRandSamples, 0, \grainEnv,-1, \out, 0], ~sourceGrp);
        ~activeSynths.put(key, syn);
        loop{
            data = ~currentData.td[\sm1];
            syn.set(\ffreq, data.linexp(0.3, 0.75, 500, 3000),
                \harm, data.linlin(0.3, 0.6 , [-12.0, -6.0, -0.5], [24.0, 18.0, 12.5]));
            0.05.wait};

    },
    \50 :{
        var key= \50, data, buf, syn;
        //"play TD %  sm %".format(key, ~sm1).postln;
        buf = ~grainBuffer;
        s.sync;
        syn = Synth(\grainBuf, [\amp, 0.5, \ptrBus, ~ptrBus, \buf,  buf, \rq, 0.44, \dens, 40, \drywet, 0.9, \ptrSampleDelay, s.sampleRate/3, \ptrRandSamples, 0, \grainEnv,-1, \out, 0], ~sourceGrp);
        ~activeSynths.put(key, syn);
        loop{
            data = ~currentData.td[\sm1];
            syn.set(\ptrSampleDelay, data.linlin(0.0, 1, 15000, 500000),
                \minPtrDelay, data.linlin(0.0, 1, 1000, 10000),
                \dens, data.linlin(0, 1, 20, 100)
            );
            0.05.wait};
    },

    \52 : {
        var key= \52, data, syn, fx;
        //"play TD %  sm %".format(key, ~sm1).postln;
        syn = Synth(\grainBuf, [\ptrBus, ~ptrBus, \ptrSampleDelay, 3000, \amp, 0.5, \buf, ~grainBuffer, \dens, 20, \baseDur, 0.1, \out, ~fxBus], ~grainGrp);
        //syn = Synth(\brsaw, [\amp, 0.5, \buf, ~grainBuffer, \out, ~fxBus], ~grainGrp);
        fx = Synth(\combdelay, [\bus, ~fxBus, \decayTime, 3, \blend, 0.8, \out, 0], ~fxGrp);
        ~activeSynths.put(key, [syn, fx]);
        loop{
            data = ~currentData.td[\sm1];
            //"data % \t ffreq % \t deltime %".format(data, data.linlin(0, 1, 1500, 3500), data.linlin(0, 1, 0.02, 0.8) ).postln;
            syn.set(\harm, data);//data.linlin(0, 1, 1500, 3500));
            fx.set(\delTime, data.linlin(0, 1, 0.005, 0.5));
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
