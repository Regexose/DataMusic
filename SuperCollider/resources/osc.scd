/*
Hier werden die Oscdefs zur Kommunikation mit Touchdesigner geladen
*/

// Keyhold
OSCdef(\TDOnKeyhold, {|msg, time, addr, recvPort|
    var key, buf, syn,  rout, funcDict;
    key = msg[1].asSymbol;
    funcDict = ~td;
    "receiving  NoteOn from TD OnKeyhold:key %  funcDict %".format(key, funcDict[key]).postln;
     ~activeRoutines[\td].put(key, Routine(funcDict[key]));
    rout = ~activeRoutines[\td][key];
    if ((rout.notNil && rout.isPlaying), {"stopping rout".postln; rout.stop});
    //"~activeRoutines % ".format(~activeRoutines).postln;
    rout.play;
},
'/OnKeyhold'
);

OSCdef(\TDOffKeyhold, {|msg, time, addr, recvPort|
    var key, funcDict, rout, patName;
    key = msg[1].asSymbol;
    patName = ("arp" ++msg[1]).asSymbol;
    rout = ~activeRoutines[\td][key];
    rout.stop;
    //~activeRoutines[\td].removeAt(key);
    ~activeSynths[key].do({|x| x.set(\gate, 0);});
    Pbindef(patName).stop;
    Pbindef(\arpeggio).stop;
    "stopped rout %  activesynths % pattern %".format(key, ~activeSynths, Pbindef(patName).isPlaying).postln;
},
'/OffKeyhold'
);




OSCdef(\resetAll, {|msg, time, addr, recvPort|
    msg[1].postln;
    ~activeRoutines[\td].keys.do({|k| ~activeRoutines[\td].removeAt(k) })
},
    '/reset'
);

OSCdef(\stopPattern, {|msg, time, addr, recvPort|
    //msg[1].postln;
    var patName;
    "stop Patterns".postln;
    patName = ("arp" ++ msg[1]).asSymbol;
    Pbindef(patName).stop;
    Pbindef.all.do(_.stop);
},
'/stopPattern'
);


OSCdef(\sm1, {|msg, time, addr, recvPort|
    //"receiving sm1 %".format(msg[1]).postln;
    ~currentData[\td][\sm1] = msg[1].asFloat;
},
    '/sm1'
);
OSCdef(\sm2, {|msg, time, addr, recvPort|
    //"receiving sm1 %".format(msg[1]).postln;
    ~currentData[\td][\sm2] = msg[1].asFloat;
},
    '/sm2'
);
OSCdef(\sm3, {|msg, time, addr, recvPort|
    //"receiving sm1 %".format(msg[1]).postln;
    ~currentData[\td][\sm3] = msg[1].asInteger;
},
    '/sm3'
);
OSCdef(\sm4, {|msg, time, addr, recvPort|
   //msg[1].postln;
    ~currentData[\td][\sm4] = msg[1];
},
    '/sm4'
);
OSCdef(\temp2, {|msg, time, addr, recvPort|
    //msg[1].postln;
    ~currentData[\td][\temp2] = msg[1].asInteger;
},
    '/temp2'
);

OSCdef(\temp3, {|msg, time, addr, recvPort|
    //msg[1].postln;
    ~currentData[\td][\temp3] = msg[1].asFloat;
},
    '/temp3'
);

OSCdef(\drone, {|msg, time, addr, recvPort|
     //"receiving drone %".format(msg[1]).postln;
    ~currentData[\td][\drone] = msg[1];
},
    '/drone'
);