(
ServerTree.removeAll; // löscht alle funktionen
~projectRoot = PathName(thisProcess.nowExecutingPath).parentPath;
~configFile = ~projectRoot ++ "config.scd";
~configFile.load;
~resourcePath = ~projectRoot ++ "resources/";

Server.default.options.outDevice_(~audioInterface);
Server.default.options.inDevice_(~audioInterface);
Server.default.options.numInputBusChannels_(1);
//s.newBusAllocators;

s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	OSCdef.freeAll;
	MIDIdef.freeAll;
	s.newBusAllocators;
	~dryBus = Bus.audio(s,2);
    ~wetBus = Bus.audio(s,2);
	s.sync;
	/// load SynthDefs, Constants, Functions

	(~resourcePath ++ "constants.scd").load;
	(~resourcePath ++ "synthDefs.scd").load;
	(~resourcePath ++ "rf_climart.scd").load;
	(~resourcePath ++ "initialization.scd").load;
	~createData.(); ~initCurrent.();
	(~resourcePath ++ "functions.scd").load;
	//(~resourcePath ++ "routinefunctions.scd").load;

	thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI/GUI_constructor.scd");
	thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI/GUI_make.scd");

	"done".postln;
})
)
~data.keys
(
~recordUser.("boris","base");
~recordUser.("ana_b", "tension");
~recordUser.("ana_b", "relax");
)
~scrub = Synth(\grainScrub, [\buf, ~currentSample[\base], \tr, 0.1 ]);
~scrub.set(\buf, ~currentSample[\base], \tr, 0.5, \pos, 0.4)
~scrub.set(\pan, )
~scrub.set(\buf, ~currentSample[\tension])
~scrub.set(\buf, ~currentSample[\relax])
// stop all Synths
~currentSample[\base]
s.defaultGroup.freeAll
~makeDataImages.()
s.makeWindow

(

{
    var buf = ~currentSample[\relax] , trate, dur, clk, pos, pan;
    trate = MouseY.kr(8,120,1);
    dur = 12 / trate;
    clk = Impulse.kr(trate);
    pos = MouseX.kr(0,BufDur.kr(buf)) + TRand.kr(0, 0.01, clk);
    pan = WhiteNoise.kr(0.6);
    TGrains2.ar(2, clk, buf, 1, pos, dur, pan, 0.1, dur * 0.3, dur * 0.5);
}.play;
)
