/*
Hier werden die Oscdefs zur Kommunikation mit Touchdesigner geladen
*/


OSCdef(\TDnoteOn, {|msg, time, addr, recvPort|
    var key, buf, syn,  rout, funcDict;
    key = msg[1].asSymbol;
    ~activeRoutines.put(\td, ());
    funcDict = ~td;
    "key %  funcDict %".format(key, funcDict[key]).postln;
     ~activeRoutines[\td].put(key, Routine(funcDict[key]));
    rout = ~activeRoutines[\td][key];
    if ((rout.notNil && rout.isPlaying), {"stopping rout".postln; rout.stop});
    //"~activeRoutines % ".format(~activeRoutines).postln;
    rout.play;
},
'/noteOn'
);

OSCdef(\TDnoteOff, {|msg, time, addr, recvPort|
    var key, funcDict, rout;
    key = msg[1].asSymbol;
    rout = ~activeRoutines[\td][key];
    rout.stop;
    "stopped rout %".format(key).postln;
    ~activeSynths[key].free;
},
'/noteOff'
);


OSCdef(\lfo1, {|msg, time, addr, recvPort|
    //msg.postln;
    ~currentData[\td][\sm1] = msg[1];
},
    '/sm1'
);