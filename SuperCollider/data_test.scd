(
//ServerOptions.devices
//~audioInterface = "MacBook Pro-Lautsprecher";
~audioInterface = "Fireface 400 (BEF)";
Server.default.options.numInputBusChannels_(0);
Server.default.options.outDevice_(~audioInterface);
//Server.default.options.inDevice_(~audioInterface);
s.newBusAllocators;
ServerTree.removeAll; // löscht alle funktionen
~projectRoot = PathName(thisProcess.nowExecutingPath).parentPath;
~dataPath = PathName(~projectRoot).parentPath ++ "data";
~baromabs= List.new;
~temps = List.new;

~csvFile = CSVFileReader.read(~dataPath ++ "/test_data.csv", true);
~csvFile.do({
    |row, i|
    if (i != 0, {
        ~baromabs.add(row[1]);
        ~temps.add(row[2]);
    })
});

s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	Pbindef.all.do(_.clear);
	s.sync;
	MIDIClient.init;
	MIDIIn.connectAll;
	~midiOut = MIDIOut.new(0);
	~midiIn = MIDIIn.new(0);

	SynthDef(\baro, {
		|gate=1, freqRatio=1, modInd=1, tempFactor=1|
		var sig, mod, env, freqs;
		env = EnvGen.kr(Env([0, 1, 0], [\atk.kr(1.0), \rls.kr(1)], \crv.kr(3)), gate, doneAction:2);
		//mod = SinOsc.ar([freq, freq1, freq2] * freqRatio, mul: freq * freqRatio * modInd);
		freqs = NamedControl.kr(\freqs, [800, 800, 800]);
		sig = DynKlang.ar(
			`[
				// {ExpRand(freq, freq*tempFactor)}!3,
				freqs.poll,
				0.3 ! 3,
				{ExpRand(0.1, 0.5)}!3
			], 1, 0
		);
		//sig = PMOsc.ar(freq, freq * freqRatio, modInd);
		sig = Pan2.ar(sig, \pan.kr(0), \pLag.kr(0));
		sig = sig * env * \amp.kr(0.2);
		Out.ar(\out.kr(0), sig);
	}).add;

	SynthDef(\arrayarg, { |out, amp = 0.1, gate = 1|
		var env, sines;
		var freqs = NamedControl.kr(\freqs, [300, 400, 500, 600]);
		env = Linen.kr(gate, 0.1, 1, 1, 2) * amp;
		sines = SinOsc.ar(freqs +.t [0,0.5]).cubed.sum; // A mix of 4 oscillators
		Out.ar(out, sines * env);
	}, [0, 0.1, 0]).add;


	"done".postln;

})

)
(

)

x = Synth(\arrayarg);
x.setn(\freqs, [ 998.7137378093677, 998.6121461501574, 998.5105544909471 ])

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
        |bt|
		var syn, btArray;
        if (bt.isArray, {
			//bt.postln;
			btArray = Array.newFrom(bt);
			btArray.postln;
			syn = Synth(\arrayarg, [\amp, 0.3, \pan, rrand(-0.9, 0.9), \pLag, 0.1]);
			//syn.setn(\freqs, exprand(900, 1000)!3);
			syn.setn(\freqs, btArray);
/*     /*       bt.do{
                |b|
				b[0].postln;
				(b[1].asFloat /100).postln;*/
				// Synth(\baro, [\freq, b[0], \tempFactor, (b[1].asFloat / 100), \amp, 0.1, \pan, rrand(-0.9, 0.9), \pLag, 0.1]);
            }*/

        } );

        2.wait;
    })
}).play;
)
~test.stop
