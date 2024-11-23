~live = (

    \48 :{
        /* spielt liveSynth-Synth mit und harmonischer verstimmung
        */
        var midikey, data, normalized, compressed, reduce, buf, syn, mn, mx;
        /* s.record(~recordingPath ++ "/proto01.wav", duration: 60);
        wait(0.02);*/
        midikey = \48;
        data = ~currentData[midikey][\data].asArray;
        ~currentData.globalKey = midikey;
        //compressed = data.select({|item, i| i%reduce == 0});
        # mn, mx = [0.0, 100]; // Bodenfeuchte WHC Water Holding Capacity
        normalized = data.normalize(mn, mx);
        buf = ~grainBuffer;
        s.sync;
        syn = Synth(\livegran, [\amp, 0.5, \ptrBus, ~ptrBus, \buf, buf, \rq, 0.44, \dens, 40, \ptrSampleDelay, s.sampleRate/3, \ptrRandSamples, 0, \out, ~ch1.inbus], ~grainGrp);
        "post Syn % out %".format(midikey, syn.get(\out)).postln;

        ~activeSynths.put(midikey, syn);
        normalized.do({
            |d, i|
            //"original data  %   normalized data   %  at  %".format(d, normalized[i].trunc(0.01), i).postln;

            syn.set( \harm, d.linlin(mn, mx , [-12.0, -6.0, -0.5], [24.0, 18.0, 12.5]));
            ~t.beatDur.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh}; // Update GUI
        });
        syn.release(2);
    },


    \50 :{
        /* spielt liveSynth-Synth mit filter frequency manipulation \ffreq
        und harmonischer verstimmung
        */
        var midikey, data, normalized, reduce, buf, syn, mn, mx;
        /* s.record(~recordingPath ++ "/proto01.wav", duration: 60);
        wait(0.02);*/
        midikey = \50;
        data = ~currentData[midikey][\data].asArray;
        ~currentData.globalKey = midikey;
        # mn, mx = [0.0, 100]; // Bodenfeuchte WHC Water Holding Capacity
        normalized = data.normalize(mn, mx);
        buf = ~grainBuffer;
        s.sync;
        "pre Syn %".format(midikey).postln;
         syn = Synth(\livegran, [\amp, 0.5, \ptrBus, ~ptrBus, \buf, buf, \rq, 0.44, \dens, 40, \ptrSampleDelay, s.sampleRate/3, \ptrRandSamples, 0, \out, ~ch2.inbus], ~grainGrp);
        ~activeSynths.put(midikey, syn);
        normalized.do({
            |d, i|
            //"original data  %   normalized data   %  at  %".format(d, normalized[i].trunc(0.01), i).postln;

            syn.set( \harm, d.linlin(mn, mx , [-12.0, -6.0, -0.5], [12.0, 6.0, 0.5]));
            ~t.beatDur.wait;
            defer{~posX = i.linlin(0, normalized.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh}; // Update GUI
        });
        syn.release(2);
    },

    \52 :{
        /* spielt liveSynth-Synth mit rate analog zu Temperatur Aktivität
        */
        var midikey, data, normalized, borders, compressed, reduce, buf, syn, mn, mx;
        /* s.record(~recordingPath ++ "/proto01.wav", duration: 60);
        wait(0.02);*/
        //reduce = ~currentData[\50][\reduce];
        midikey = \52;
        data = ~currentData[midikey][\data].asArray;
        "pre Syn \51".postln;
        ~currentData.globalKey = midikey;
        //# mn, mx = [0.0, 100]; // Bodenfeuchte WHC Water Holding Capacity
        borders = [[0.0, 10.0 ], [10.0, 18.0], [18.0, 25.0], [25.0, 35.0]];
        buf = ~grainBuffer;
        s.sync;
        syn = Synth(\livegran, [\amp, 0.5, \ptrBus, ~ptrBus, \buf, buf, \rq, 0.44, \dens, 40, \ptrSampleDelay, s.sampleRate/3, \ptrRandSamples, 0, \out, ~ch3.inbus], ~grainGrp);
        ~activeSynths.put(midikey, syn);
        data.do({
            |d, i|
            var c;
            //"original data %  at %".format(d, i).postln;
            c = case
            {d > borders[3][1]} {syn.set(\rate, d.linexp(0, 50, 2.1, 3.5))}
            {(d > borders[3][0]) && (d <= borders[3][1])}
            {syn.set(\rate, d.linexp(0, 50, 1.6, 2.5))}
            {(d > borders[2][0]) && (d <= borders[2][1])}
            {syn.set(\rate, d.linexp(0, 50, 1.01, 1.6))}
            {(d > borders[1][0]) && (d <= borders[1][1])}
            {syn.set(\rate, d.linexp(0, 50, 0.85, 1.0))}
            {(d > borders[0][0]) && (d <= borders[0][1])}
            {syn.set(\rate, d.linexp(0, 50, 0.45, 0.87))}
            {true}{"data % out of border".format(d).postln};

            0.05.wait;
            defer{~posX = i.linlin(0, data.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh}; // Update GUI
        });
        syn.release(2);
    },

    \53 :{
        /*
        gleich wie 52 aber mit Live Stimme (tgrains_live)
        SoilMoisture 50, 70 und 90 dienen als Referenz (SMref) zur Manipulation von harmonics und fmmod
        Sonifiziert wird das fortschreitende Level von N_release, verfügbarer Stickstoff im Lauf der Zeit
        attack: die ersten 4 Wochen, steile Kurve in SMref Effekt auf Pitch / harmonics
        release : nach 4 Wochen, fast gerade Linie. Effekt of FM Mod
        */
        var midikey=\53, data, ref50, buf, syn, mn, mx;
        /*    s.record(~recordingPath ++ "/live52.wav", duration: 120);
        wait(0.02);*/
        data = ~currentData[midikey][\data].asArray;
        ref50 = ~alignData.(midikey, \sm50);
        ~currentData.globalKey = midikey;
        # mn, mx = [0.01, 70.0]; // Bodenfeuchte WHC Water Holding Capacity
        buf = ~liveBuffer;
        s.sync;
        "Pre Syn \52".postln;
        syn = Synth(\tgrains_live, [\in, ~soundIn, \buf, buf, \grainDur, 1.0, \grainAmp, 0.001, \ffreq, 4000, \amp, 0.35, \lg, 0.5,  \out, ~ch4.inbus]);
        ~activeSynths.put(midikey, syn);
        ref50.do({
            |r, i|
            var d = data[i]; // Nitrifikation
            var dFactor = d.linlin(mn, mx, 0.0, 1.5); // Annahme: bei 90 % WHC ist der Faktor 1.5 Um diesen Faktor wird der prognostizierte Wert erniedrigt oder erhöht
            var day, hour;
            day =  ~currentData[midikey][\in] + i /(60*24);
            hour = (~currentData[midikey][\in] + i /60) % 24;
          /*  if (i%60==0,
                {"\t++++\t+++\noriginal data %  ref % \nat day: %  hour: %\ndFactor: %".format(d.trunc(0.01), r, day.trunc(0.01), hour, dFactor.trunc(0.01)).postln;});*/
            syn.set(\dens, max(0.2, (r * dFactor)), \grainAmp, r.lincurve(mn, 60, 0.01, 0.5), \rate, dFactor, \harm, d.linlin(0, 70, -5, 5), \fmdens, max(0.2, (r * dFactor)), \carfreq, r * dFactor * 25 * rrand(0.9, 1.1), \index, min(10, r), \fmAmp, r.lincurve( mn, 60, 0.01, 0.25), \modfreq, d/r);

            0.025.wait;
            defer{~posX = i.linlin(0, data.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh}; // Update GUI
        });
        syn.release(2);
    },

    \55 : {
        /* Live filter frequency manipulation \ffreq
        */
        var midikey=\55, data, reduce, buf, mic, ptr, rec, syn, mn, mx;
        /* s.record(~recordingPath ++ "/gunter_soilmoist.wav", duration: 60);
        wait(0.02);*/
        #mn, mx = [150, 5000];
        data = ~currentData[midikey][\data].asArray.normalize(mn, mx);
        ~currentData.globalKey = midikey; // für handling des RangeSliders
        buf = ~grainBuffer;
        buf.zero;
        s.sync;
        "pre Syn \53".postln;
        syn = Synth(\livegran, [\amp, 0.5, \ptrBus, ~ptrBus, \buf, buf, \rq, 0.1, \dens, 40, \ptrSampleDelay, s.sampleRate/3, \ptrRandSamples, 0, \out, ~ch5.inbus], ~grainGrp);
        ~activeSynths.put(midikey, syn);
        data.do({
            |d, i|
            //"original data  %   normalized data   %  at   %".format(compressed[i].trunc(0.0001), d, i).postln;
            syn.set( \ffreq, d);
            0.05.wait;
            defer{~posX = i.linlin(0, data.size-1, 0, ~dataSlider.bounds.width); ~cursor.refresh}; // Update GUI
        });
        syn.release(2);

    },
);

~liveChannels = ( //hier werden die sendNames für die Postsendregler festgelegt für ~makeCC
    \ch1: [~ch1, "_snd_dela"],
    \ch2: [~ch2, "_snd_dela"],
    \ch3: [~ch3, "_snd_ring"],
    \ch4: [~ch4, "_snd_dela"],
    \ch5: [~ch5, "_snd_dela"],
);