s.boot;

(
~baromabs= List.new;
~temps = List.new;

)
(
var file;
file = CSVFileReader.read("/Users/borisjoens/Documents/Projekte/DataMusic/DataMusic/data/test_data.csv", true);
file.do({
    |row, i|
    if (i != 0, {
        ~baromabs.add(row[1]);
        ~temps.add(row[2]);
    })
});
)

(
SynthDef(\baro, {
    |gate=1, freqRatio=1, modInd=1, freq=800|
    var sig, mod, env;
    env = EnvGen.kr(Env([0, 1, 0], [\atk.kr(1.0), \rls.kr(1)], \crv.kr(3)), gate, doneAction:2);
    //mod = SinOsc.ar([freq, freq1, freq2] * freqRatio, mul: freq * freqRatio * modInd);
    sig = Klang.ar(
        `[
            freq,
            0 ! 3,
            {ExpRand(0.1, 0.5)}!3
        ], 1, 0
    );
    //sig = PMOsc.ar(freq, freq * freqRatio, modInd);
    sig = Pan2.ar(sig, \pan.kr(0), \pLag.kr(0));
    sig = sig * env * \amp.kr(0.2);
    Out.ar(\out.kr(0), sig);
}).add;
)
(
~barotemps = ~baromabs.collect({
    |b, i|
    [b, ~temps[i]]
}
)
)

(
~test = Routine({
    ~baromabs.clump(3).do({
        |b|
        if (b.isArray, {
            //b.postln;
            b.do{
                |f|
                Synth(\baro, [\freq, f, \amp, 0.1, \pan, rrand(-0.9, 0.9), \pLag, 0.9]);
            }

        } );

        (1).wait;
    })
}).play;
)
~test.stop
