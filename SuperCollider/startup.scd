(
ServerTree.removeAll; // löscht alle funktionen
~projectRoot = PathName(thisProcess.nowExecutingPath).parentPath;
~configFile = ~projectRoot ++ "config.scd";
~configFile.load;
~resourcePath = ~projectRoot ++ "resources/";

Server.default.options.outDevice_(~audioOut);
Server.default.options.inDevice_(~audioIn);
Server.default.options.numInputBusChannels_(1);
s.newBusAllocators;

s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	OSCdef.freeAll;
	s.sync;
	/// load SynthDefs, Constants, Functions
	(~resourcePath ++ "constants.scd").load;
	(~resourcePath ++ "synthDefs.scd").load;
	(~resourcePath ++ "initialization.scd").load;
	~createData.(); ~initCurrentData.();
	(~resourcePath ++ "functions.scd").load;
	//(~resourcePath ++ "routinefunctions.scd").load;
	(~resourcePath ++ "rf_climart.scd").load;

	thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI/GUI_constructor.scd");
	thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI/GUI_make.scd");

	"done".postln;
})

)
~liveBuffer.numFrames/~data.temperature.size
~recordUser.("test", "base");


Quarks.gui

~replacePlay.(True)
~replacePlay.(False)
~oneShotPlay.(True)
~oneShotPlay.(False)
~data.keys.do({|k| ~data[k].asArray.plot(k)})

(
{
    var b = ~buffers.test.base, trate, dur, clk;
    trate = MouseY.kr(2,200,1);
    dur = 4 / trate;
    clk = Dust.kr(trate);
    TGrains2.ar(2, clk, 10, 1.0, LFNoise2.kr(0.5).range(0, BufDur.kr(b)), dur, 0, TRand.kr(0.1, 0.2, clk), MouseX.kr(0.003, 0.01), 0.007, 4);
}.play;
)


~grainBuffer.play
~buffers.test.keys
~setBuffers[\stress]

~liveBuffer.play
~liveBuffer.plot
~baseSound.play
~baseSound.class
Platform.userExtensionDir
Platform.systemExtensionDir

b= Buffer.read(s, ~samplesPath ++ "/hugoloris/baseSound.wav")
b.plot


a = Synth(\tgrains, [\buf, ~buffers.test.base])
a.set(\amp, 0.3, \decayScale, 2, \freqScale, 1)