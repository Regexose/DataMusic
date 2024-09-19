
s.boot;
t = TempoClock(100/60).permanent_(true);
Ndef(\klik).play;
Ndef(\klik).fadeTime_(4);
Ndef(\klik).clock_(~t);
Ndef(\klik).quant_(4);

p = ProxySpace.new(s, clock: t)
p.push;
currentEnvironment;
(
~klik;
~klik.play;
~klik.fadeTime_(4);
~klik.quant_(4);

)
(
~klik = {
    var sig, trig, freqs, amps, rls, env;
    rls = 0.2;
    trig = Trig.kr(Impulse.kr(4), rls);
    freqs = Array.series(5, 48.midicps, 240);
    env = Env.perc(0.001, rls).kr(0, trig);
    amps = Array.fill(5, {exprand(0.1, 0.5)});
    sig = Klang.ar(`[freqs, amps, nil]);
    sig = sig * 0.2 * env;
};

)
~klik.release

p.clear;
p.pop
