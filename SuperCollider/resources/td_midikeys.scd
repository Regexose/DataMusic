~td = (
    // on Off Play
    \48 : {
        /* am besten mit Zischgeräuschen
        */
        var key= \48, data,  buf, syn,  mn, mx;
        //"play TD %  sm %".format(key, ~sm1).postln;
        buf = ~grainBuffer.normalize;
        # mn, mx = [100, 130];
        s.sync;
        syn = Synth(\grainBuf2, [\amp, 0.7, \ptrBus, ~ptrBus, \minPtrDelay, 3000, \buf, buf, \rq, 0.2, \dens, 20, \rls, 2, \lg, 0.4], ~sourceGrp);

        ~activeSynths.put(key, [syn]);
        loop{
            data = ~currentData.td[\sm1];
            //"data 48 %".format(data).postln;
            syn.set(\ffreq, data.linlin(mn, mx, 800, 2000),
                \rate, data.linlin(mn, mx, 0.9, 1.1),
                \dens, data.linlin(mn, mx, 10, 20),
                \baseDur, data.linlin(mn, mx, 1, 6),
            );

            0.1.wait};

    },
    \50 :{// geht mit fast allen Sounds
        var key= \50, data, buf, syn, mn, mx;
        //Grains mit dezidierter ptrPos und pan
        buf = ~grainBuffer.normalize;
        # mn, mx =[50,120];
        s.sync;
        syn = Synth(\tgrains_live, [\amp, 0.5, \ptrBus, ~ptrBus, \buf,  buf, \rq, 0.2, \dens, 20, \lg, 0.5, \modfreq, 0.2, \out, 0, \outfx, 3], ~grainGrp);
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
                \fmdens, max(0.2, (data * dFactor)),


            );
            0.05.wait};
    },
    \51 :{// geht mit fast allen Sounds
        var key= \51, data, buf, syn, fx,mn, mx;
        //Grains mit dezidierter ptrPos und pan
        buf = ~grainBuffer.normalize;
        # mn, mx =[50,120];
        s.sync;
        syn = Synth(\voweltrig, [\amp, 0.7, \vow, 1, \buf,  buf, \rq, 0.2,  \out, 0, \outfx, 3], ~grainGrp);
        fx = Synth(\combdelay, [\bus, ~fxBus, \maxDelTime, 4, \decayTime, 3, \blend, 1, \out, 0], ~fxGrp);
        ~activeSynths.put(key, [syn, fx]);
        loop{
            data = ~currentData.td[\trock02];
            //"data 50 %".format(data).postln;
            syn.set(
                \ffreq, data.linlin(mn, mx, 1200, 2500),
                \freqscale, data.linlin(mn, mx, 0.1, 0.9),
                \freqscale, data.linlin(mn, mx, 0.1, 0.8),
                \vow, data.linlin(mn, mx, 1, 10).asInteger
            );
            fx.set(\delTime, data.lincurve(mn, mx, 0.02, 0.1, -3),
                \decayTime, data.linlin(mn, mx, 4, 0.2)
            );
            0.05.wait};
    },

    \52 :{
        var key= \52, data, buf, syn, mn, mx;
        //Grains mit dezidierter ptrPos und pan
        //buf = ~buffersByName[\nitro][\tension];
        buf = ~grainBuffer.normalize;
        # mn, mx =[-2.0, 30.0];
        s.sync;
        syn = Synth(\grainScrub, [\amp, 0.7, \ptrBus, ~ptrBus, \buf, buf, \tr, 0.2, \out,0], ~grainGrp);
        ~activeSynths.put(key, [syn]);
        loop{
            data = ~currentData.td[\trock02];
            syn.set(
                \pan, data.linlin(mn, mx, -1, 1),
                \pos, data.linlin(mn, mx, 0.0, buf.numFrames / s.sampleRate),
                \tr, data.linlin(mn, mx, 0.05, 5),
                \harm, data.linlin(mn, mx,-12,8)
            );
            0.1.wait};
    },

    \53 : {
        var key= \53, data, syn, fx, mn, mx;
        //"play TD %  sm %".format(key, ~sm1).postln;
        # mn, mx =[-2.0, 30.0];
        syn = Synth(\grainBuf, [\ptrBus, ~ptrBus, \ptrSampleDelay, 1800, \amp, 0.8, \buf, ~grainBuffer, \dens, 20, \baseDur, 0.1, \out, ~dryBus, \outfx, ~fxBus, \send, 1], ~grainGrp);
        fx = Synth(\combdelay, [\bus, ~fxBus, \maxDelTime, 4, \decayTime, 3, \blend, 1, \out, 0], ~fxGrp);
        ~activeSynths.put(key, [syn, fx]);
        loop{
            data = ~currentData.td[\temp_winter];
            //"data % \t ffreq % \t deltime %".format(data, data.linlin(0, 1, 1500, 3500), data.linlin(0, 1, 0.02, 0.8) ).postln;
            syn.set(\ffreq, data.linlin(mn, mx, 1500, 3500));
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
        syn = Synth(\grainBuf, [\amp, 0.5, \ptrBus, ~ptrBus, \buf,  buf, \rq, 0.44, \dens, 40, \drywet, 0.9, \minPtrDelay, 500, \ptrSampleDelay, 800, \rateRand, 1.2, \out, 0], ~grainGrp);
        ~activeSynths.put(key, [syn]);
        loop{
            data = ~currentData.td[\sm1];
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
        fx = Synth(\combdelay, [\bus, ~fxBus, \maxDelTime, 3, \decayTime, 3, \blend, 1, \out, 0], ~fxGrp);
        ~activeSynths.put(key, [syn, fx]);
        loop{
            data = ~currentData.td[\sm1];
            //"data % \t ffreq % \t deltime %".format(data, data.linlin(0, 1, 1500, 3500), data.linlin(0, 1, 0.02, 0.8) ).postln;
            syn.set(\ffreq, data.linlin(mn, mx, 600, 3500));//);
            //fx.set(\delTime, data.linlin(0, 1, 0.005, 0.5));
            fx.set(\delTime, data.linlin(mn, mx, 0.02, 0.1),
                \decayTime, data.linlin(mn, mx, 1, 0.2)
            );
            0.05.wait};
    },

    \59 : {
        // drone1. arbeitet mit der realen Verdunstung
        var key= \59, data,  mn, mx,  drone, baseFreq=100, fac1, fac2, fac3,
        freq1, freq2, freq3, df1, df2, df3;
        data = ~currentData.td[\drone];
        //"play TD %  drone %".format(key, data).postln;
        # mn, mx =[0.0, 4.5];
        # fac1, fac2, fac3 = [1, 2.2, 5];
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
        var key= \60, data,  buf, syn,  mn, mx;
        //"play TD %  sm %".format(key, ~sm1).postln;
        buf = ~grainBuffer.normalize;
        # mn, mx = [100, 130];
        s.sync;
        syn = Synth(\grainBuf2, [\amp, 0.7, \ptrBus, ~ptrBus, \minPtrDelay, 3000, \buf, buf, \rq, 0.2, \dens, 20, \rls, 2, \lg, 0.4], ~sourceGrp);

        ~activeSynths.put(key, [syn]);
        loop{
            data = ~currentData.td[\sm1];
            //"data 48 %".format(data).postln;
            syn.set(\ffreq, data.linlin(mn, mx, 800, 2000),
                \rate, data.linlin(mn, mx, 0.1, 1.9),
                \dens, data.linlin(mn, mx, 10, 20),
                \baseDur, data.linlin(mn, mx, 1, 6),
            );

            0.1.wait};

    },
       \62 :{// geht mit fast allen Sounds
        var key= \62, data, buf, syn, mn, mx;
        //Grains mit dezidierter ptrPos und pan
        buf = ~grainBuffer.normalize;
        # mn, mx =[50,120];
        s.sync;
        syn = Synth(\tgrains_live, [\amp, 0.5, \ptrBus, ~ptrBus, \buf,  buf, \rq, 0.2, \dens, 20, \lg, 0.5, \modfreq, 0.2, \out, 0, \outfx, 3], ~grainGrp);
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
                \fmdens, max(0.2, (data * dFactor)),
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

