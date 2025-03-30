/*
Hier werden die Oscdefs zur Kommunikation mit Touchdesigner geladen
*/


OSCdef(\TDnoteOn, {|msg, time, addr, recvPort|
    var key, buf, syn,  rout, funcDict;
    key = msg[1].asSymbol;
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
    //~activeRoutines[\td].removeAt(key);
    ~activeSynths[key].free;
    "stopped rout %  activesynths % routines %".format(key, ~activeSynths, ~activeRoutines).postln;


},
'/noteOff'
);

OSCdef(\resetAll, {|msg, time, addr, recvPort|
    //msg[1].postln;
    ~activeRoutines[\td].keys.do({|k| ~activeRoutines[\td].removeAt(k) })
},
    '/reset'
);


OSCdef(\sm1, {|msg, time, addr, recvPort|
    //msg[1].postln;
    ~currentData[\td][\sm1] = msg[1];
},
    '/sm1'
);
OSCdef(\sm2, {|msg, time, addr, recvPort|
   //msg[1].postln;
    ~currentData[\td][\sm2] = msg[1];
},
    '/sm2'
);
OSCdef(\sm3, {|msg, time, addr, recvPort|
   // msg[1].postln;
    ~currentData[\td][\sm3] = msg[1];
},
    '/sm3'
);

OSCdef(\temp, {|msg, time, addr, recvPort|
    //msg.postln;
    ~currentData[\td][\temp] = msg[1];
},
    '/temp'
);

OSCdef(\wind, {|msg, time, addr, recvPort|
    //msg.postln;
    ~currentData[\td][\gust] = msg[1];
},
    '/gust'
);