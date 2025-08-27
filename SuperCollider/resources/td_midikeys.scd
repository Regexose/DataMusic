~td = (
    // on Off Play

    \48 :{// geht mit fast allen Sounds
        // der FM Teil indiziert Aktivität
        // der Grainsynth ist pitch Sonifikation
        var key= \48, data, buf, syn, mn, mx;
        //Grains mit dezidierter ptrPos und pan
        buf = ~buffersByName[\boris][\gras].normalize;
        //buf = ~grainBuffer.normalize;
        # mn, mx =[50,130];
        s.sync;
        syn = Synth(\tgrains_live, [\amp, 0.5, \ptrBus, ~ptrBus, \buf,  buf, \rq, 0.2, \dens, 20, \lg, 0.1, \grainDur, 0.9, \rate, 1.5,
            \out, 0, \fade, 0.9, \outfx, 3], ~grainGrp);
        ~activeSynths.put(key, [syn]);
        loop{
            var harm, dFactor;
            data = ~currentData.td[\trock02];
            dFactor = data.linlin(mn, mx, 0.0, 1.5);
            harm = data.linlin(mn, mx, [-12, -6] , [12, 6]);
            //"data 50 %".format(data).postln;
            syn.set(
                \harm, harm,
                \grainDur, data.linlin(mn, mx, 0.1, 0.9),
                \fmdens, data.linlin(mn, mx, 0.5, 3.0),
                \fade, ~currentData.fade[key]
            );
            0.05.wait};
    },
     \50 : {
        /* am besten mit Zischgeräuschen
        */
        var key= \50, data,  buf, syn, fx, mn, mx;
        //"play TD %  sm %".format(key, ~sm1).postln;
        buf =~buffersByName[\boris][\mega].normalize;
        # mn, mx = [-1, 30];
        s.sync;
        syn = Synth(\grainBuf2, [\amp, 0.7, \ptrBus, ~ptrBus, \minPtrDelay, 1500, \buf, buf, \rq, 0.15, \dens, 20, \rls, 2, \lg, 0.4], ~grainGrp);
        fx = Synth(\combdelay, [\bus, ~fxBus, \maxDelTime, 3, \decayTime, 3, \blend, 1, \out, 0], ~fxGrp);
        ~activeSynths.put(key, [syn, fx]);
        loop{
            data = ~currentData.td[\temp_winter];
            //"data 48 %".format(data).postln;
            syn.set(\ffreq, data.linlin(mn, mx, 500, 3000),
                \rate, data.linlin(mn, mx, 0.5, 1.5),
                \dens, data.linlin(mn, mx, 10, 40),
                \baseDur, data.linlin(mn, mx, 0.8, 0.4),
                \pan, data.linlin(mn, mx, -1.0, 1),
                \fade, ~currentData.fade[key]
            );
            fx.set(\delTime, data.linlin(mn, mx, 0.24, 0.04),
                \decayTime, data.linlin(mn, mx, 0.3, 1.5),
                \fade, ~currentData.fade[key]
            );

            0.1.wait};

    },


    \52 :{
        var key= \52, data, data2, buf, syn, mn, mx;
        //Grains mit dezidierter ptrPos und pan
        // Die Aktivität kommt zum Erliegen
       //buf = ~grainBuffer.normalize;
        buf =  ~buffersByName[\boris][\nema].normalize;
        # mn, mx =[-2.0, 30.0];
        s.sync;
        syn = Synth(\grainScrub, [\amp, 0.7, \ptrBus, ~ptrBus, \buf, buf, \tr, 0.2, \out,0], ~grainGrp);
        ~activeSynths.put(key, [syn]);
        loop{
            data = ~currentData.td[\trock02];
            data2 = ~currentData.td[\temp_winter];
            [data, data2].postln;
            syn.set(
                \pan, data.linlin(mn, mx, -1, 1),
                \pos, data.linlin(mn, mx, 0.0, buf.numFrames / s.sampleRate),
                \tr, data.linlin(mn, mx, 0.05, 5),
                \harm, data.linlin(mn, mx,-12,8),
                \fade, ~currentData.fade[key]
            );
            0.1.wait};
    },

    \53 : {
        var key= \53, data, syn, fx, mn, mx;
        //"play TD %  sm %".format(key, ~sm1).postln;
        # mn, mx =[-2.0, 30.0];
        syn = Synth(\voweltrig, [\amp, 0.5, \buf, ~buffersByName[\boris][\tension], \rls, 4, \out, 0], ~grainGrp);
        fx = Synth(\combdelay, [\amp, 0.4, \bus, ~fxBus, \maxDelTime, 4, \decayTime, 3, \blend, 1, \out, 0], ~fxGrp);
        ~activeSynths.put(key, [syn]);
        loop{var v;
            data = ~currentData.td[\temp_winter];
            case
            {data > 28.0}{v = 1}
            {(data > 23.0) && (data < 28.0)}{v = 2}
            {(data > 18.0) && (data < 23.0)}{v = 3}
            {(data > 10.0) && (data < 18.0)}{v = 11}
            {(data > 5.0) && (data < 10.0)}{v = 12}
             {(data > 0.0) && (data < 6.0)}{v = 13}
             {data < 0.0}{v = 5}
            {true}{"end of case".postln};
            //"data % \t ffreq % \t deltime %".format(data, data.linlin(0, 1, 1500, 3500), data.linlin(0, 1, 0.02, 0.8) ).postln;
            syn.set(\ffreq, data.linlin(mn, mx, 1500, 3500),
                \vow, v, \trg, data.linlin(mn, mx, 2, 30, \freqScale, data.linlin(mn, mx, 0.1, 0.9), \decayScale, data.linlin(mn, mx, 0.1, 0.9), \att, data.linlin(mn, mx, 0.04, 0.3), \dec, data.linlin(mn, mx, 0.1, 0.33)),
                \fade, ~currentData.fade[key]
            );
            0.5.wait};
    },

    \55 :{
        var key= \55, data, syn, mn, mx;
        //"play TD %  sm %".format(key, ~sm1).postln;

        # mn, mx =[30, 130];
        s.sync;
        syn = Synth(\crisps, [\amp, 0.5, \trg, 5, \freq, [80, 120, 350, 1010], \rq, 0.14, \punch, 0.2, \dec, 0.9, \out, 0]);
        ~activeSynths.put(key, [syn]);
        loop{
            var fr;
            data = ~currentData.td[\trock02];
            fr = Array.fill(4, {|n| (n+1) * data});
           //data.postln;
            syn.set(\ffreq, data.linlin(mn, mx, 400, 2800),
                \freq, fr,
                \trg, data.linlin(mn, mx, 2, 25),
                \dec, data.linlin(mn, mx, 0.9, 0.1),
                \freqScale, data.linlin(mn, mx, 0.1, 1.0),
                \decayScale, data.linlin(mn, mx, 0.1, 1.2),
                \pan,  data.linlin(mn, mx, -1, 1),
                \fade, ~currentData.fade[key]
            );
            0.05.wait};
    },

    \57 : {
        var key= \57, data, syn, fx, mn, mx;
        //"play TD %  sm %".format(key, ~sm1).postln;
        # mn, mx =[30, 125];
        syn = Synth(\grainBuf, [\ptrBus, ~ptrBus, \ptrSampleDelay, 800, \amp, 0.4, \buf, ~grainBuffer, \dens, 20, \baseDur, 0.1, \out, ~dryBus, \outfx, ~fxBus, \send, 1], ~grainGrp);
        fx = Synth(\combdelay, [\bus, ~fxBus, \maxDelTime, 3, \decayTime, 3, \blend, 1, \out, 0], ~fxGrp);
        ~activeSynths.put(key, [syn, fx]);
        loop{
            data = ~currentData.td[\trock02];
            //"data % \t ffreq % \t deltime %".format(data, data.linlin(0, 1, 1500, 3500), data.linlin(0, 1, 0.02, 0.8) ).postln;
            syn.set(\ffreq, data.linlin(mn, mx, 600, 3500),\fade, ~currentData.fade[key]);//);
            //fx.set(\delTime, data.linlin(0, 1, 0.005, 0.5));
            fx.set(\delTime, data.linlin(mn, mx, 0.08, 0.5),
                \decayTime, data.linlin(mn, mx, 2, 0.5),\fade, ~currentData.fade[key]
            );
            0.05.wait};
    },
    //
    // \59 : {
    //     // drone1. arbeitet mit der realen Verdunstung
    //     var key= \59, data,  mn, mx, drone, baseFreq=110, facs,
    //     freqs, dfs;
    //     data = ~currentData.td[\drone];
    //     //"play TD %  drone %".format(key, data).postln;
    //     # mn, mx =[0.0, 4.5];
    //     facs = Array.fill(8, {rrand(1.02, 1.6)});
    //     freqs = facs.collect({|f| [0.5, 0.25, 1, 2, 4].choose});
    //     dfs = Array.fill(8, {rrand(1.02, 1.96)});// datafactor
    //     drone = Synth(\array_1b, [\freq, baseFreq, \ffreq, 1500, \otFreqs, freqs, \freqLag, 2, \otLag, 0.7]);
    //     ~activeSynths.put(key, [drone]);
    //     loop{
    //         data = ~currentData.td[\drone];
    //         //"play TD %  drone %".format(key, data).postln;
    //         drone.set(\otAmps, Array.fill(8, {|n| var m = data.linlin(mn, mx, 0.05, 0.12); m * facs[n]}),
    //             \otFreqs, Array.fill(8, {|n| data * dfs[n] }),
    //             \ampMod, data.linlin(mn, mx, 80, 200)
    //         );
    //     0.05.wait};
    // },

    \59 : {
        // drone1. arbeitet mit der realen Verdunstung
        var key=\59, data,  mn, mx,  drone, baseFreq=100, fac1, fac2, fac3,
        freq1, freq2, freq3, df1, df2, df3;
        data = ~currentData.td[\drone];
        //"play TD %  drone %".format(key, data).postln;
        # mn, mx =[0.0, 4.5];
        # fac1, fac2, fac3 = [1, 2.2, 3.4];
        # freq1, freq2, freq3 = [fac1, fac2, fac3].collect({|f| baseFreq * f});
        # df1, df2, df3 = [1.8, 1.2, 1.05]; // datafactor
        drone = Synth(\arrayarg, [\freq, [freq1, freq2, freq3], \flg1, 6.1, \flg2, 7.0, \mlg1, 6.0, \mlg2, 7.0]);
        ~activeSynths.put(key, [drone]);
        loop{
            data = ~currentData.td[\drone];
            //"play TD %  drone %".format(key, data).postln;
            drone.set(\mods, Array.fill(3, {var m = data.linlin(mn, mx, 0.05, 0.12); [m * fac1, m*fac2, m*fac3 ]}),
                \freq, Array.fill(3, {[(data * fac1 * df1 * baseFreq), (data * fac2 * df2 * baseFreq), (data * fac3 * df3 * baseFreq)]}));
            0.05.wait};
    },

    \60 : {
        /* am besten mit Zischgeräuschen
        */
        var key= \60, data,  buf, syn, fx, mn, mx;
             //"play TD %  sm %".format(key, ~sm1).postln;
        buf = ~grainBuffer.normalize;
        # mn, mx = [50, 130];
        s.sync;
        syn = Synth(\grainBuf2, [\amp, 0.7, \ptrBus, ~ptrBus, \minPtrDelay, 1500, \buf, buf, \rq, 0.15, \dens, 20, \rls, 2, \lg, 0.4], ~grainGrp);
        fx = Synth(\combdelay, [\bus, ~fxBus, \maxDelTime, 3, \decayTime, 3, \blend, 1, \out, 0], ~fxGrp);
        ~activeSynths.put(key, [syn, fx]);
        loop{
            data = ~currentData.td[\trock02];
            //"data 48 %".format(data).postln;
            syn.set(\ffreq, data.linlin(mn, mx, 800, 3000),
                \rate, data.linlin(mn, mx, 0.9, 1.1),
                \dens, data.linlin(mn, mx, 10, 40),
                \baseDur, data.linlin(mn, mx, 0.5, 0.8),
                \pan, data.linlin(mn, mx, -1.0, 1),
                \fade, ~currentData.fade[key]
            );
            fx.set(\delTime, data.linlin(mn, mx, 0.08, 0.14),
                \decayTime, data.linlin(mn, mx, 0.3, 1.5),
                \fade, ~currentData.fade[key]
            );

            0.1.wait};

    },
    \62 :{// geht mit fast allen Sounds
        // Fm zeigt auf die quantität der
        var key= \62, data, buf, syn, mn, mx;
        //Grains mit dezidierter ptrPos und pan
        buf = ~grainBuffer.normalize;
        # mn, mx =[30,120];
        s.sync;
        syn = Synth(\tgrains_live, [\amp, 0.5, \ptrBus, ~ptrBus, \buf,  buf, \rq, 0.2, \dens, 20, \lg, 0.5,
            \fmffreq, 200, \fmAmp, 0.06, \numharm, 2, \index, 1,
            \out, 0, \fade, 0.9, \outfx, 3], ~grainGrp);
        ~activeSynths.put(key, [syn]);
        loop{
            var harm, dFactor;
            data = ~currentData.td[\trock02];
            dFactor = data.linlin(mn, mx, 0.0, 1.5);
            harm = data.linlin(mn, mx, [-12, -2] , [12, 2]);
            //"data 50 %".format(data).postln;
            syn.set(
                \harm, harm,
                \grainDur, data.linlin(mn, mx, 0.1, 0.5),
                \fmdens, data.linlin(mn, mx, 0.5, 3.0),
                \modfreq, data.linlin(mn, mx, 10, 1),
            );
            0.05.wait};
    },
    \64 :{
        var key= \64, data, buf, syn, mn, mx;
        //Grains mit dezidierter ptrPos und pan
        //buf = ~buffersByName[\nitro][\tension];
        buf = ~grainBuffer.normalize;
        # mn, mx =[-2.0, 30.0];
        s.sync;
        syn = Synth(\grainScrub, [\amp, 0.7, \ptrBus, ~ptrBus, \buf, buf, \tr, 0.2, \out,0], ~grainGrp);
        ~activeSynths.put(key, [syn]);
        loop{
            data = ~currentData.td[\temp_winter];
            syn.set(
                \pan, data.linlin(mn, mx, -1, 1),
                \pos, data.linlin(mn, mx, 0.0, buf.numFrames / s.sampleRate),
                \tr, data.linlin(mn, mx, 0.05, 5),
                \harm, data.linlin(mn, mx,-12,8)
            );
            0.1.wait};
    },
);

