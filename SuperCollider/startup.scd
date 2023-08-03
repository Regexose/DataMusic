(
Server.default.options.numInputBusChannels_(0);
Server.default.options.outDevice_(~audioInterface);
//Server.default.options.inDevice_(~audioInterface);
s.newBusAllocators;
ServerTree.removeAll; // löscht alle funktionen
~projectRoot = PathName(thisProcess.nowExecutingPath).parentPath;
~resourcePath = ~projectRoot ++ "resources/";

s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	s.sync;
	/// load SynthDefs, Constants, Functions
	(~resourcePath ++ "constants.scd").load;
	(~resourcePath ++ "synthDefs.scd").load;
	(~resourcePath ++ "initialization.scd").load;
	(~resourcePath ++ "functions.scd").load;

    ~createData.();

	"done".postln;
})

)
