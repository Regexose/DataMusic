(
ServerTree.removeAll; // löscht alle funktionen
~projectRoot = PathName(thisProcess.nowExecutingPath).parentPath;
~configFile = ~projectRoot ++ "config.scd";
~configFile.load;
~resourcePath = ~projectRoot ++ "resources/";

Server.default.options.numInputBusChannels_(0);
Server.default.options.outDevice_(~audioInterface);
Server.default.options.inDevice_(~audioInterface);
Server.default.options.numInputBusChannels_(1);
s.newBusAllocators;

s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	s.sync;
	/// load SynthDefs, Constants, Functions
	(~resourcePath ++ "constants.scd").load;
	(~resourcePath ++ "synthDefs.scd").load;
	(~resourcePath ++ "initialization.scd").load;
	(~resourcePath ++ "functions.scd").load;
	(~resourcePath ++ "routinefunctions.scd").load;

	"done".postln;
})

)
~recOnOff = {}
~recOnOff.()
~liveBuffer.play
~liveBuffer.plot
~data.keys.do(_.postln)
~data.humidity.asArray.normalize
~data.findKeyForValue( ~data.humidity)
~buffers.keys.do({|k| k.postln})
~makeWaveTable.(4096, ~data.solar, \solar);
~buffers[\rainrate].numFrames

Synth(\oscfm, [\buf1, ~buffers[\rainrate], \buf2, ~buffers[\solar]]) 