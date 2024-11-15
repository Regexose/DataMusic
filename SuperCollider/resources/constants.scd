~dataPath = PathName(~projectRoot).parentPath ++ "data";
// ~imagePath = PathName(~projectRoot).parentPath ++ "data/img";
~dataFileName = "zku_OpenHausData_noTime.csv";
~recordingPath = PathName(~projectRoot).parentPath ++ "recordings";
~samplesPath = PathName(~projectRoot).parentPath ++ "samples";
~t = TempoClock(120/60).permanent_(true);
~buffersByName = Dictionary.new;
~buffersByCat = Dictionary.with(*[\base -> List.new, \tension -> List.new, \relax -> List.new]);
~liveBuffer = Buffer.alloc(s, 4 * s.sampleRate, 1);
~grainBuffer = Buffer.alloc(s, 4 * s.sampleRate, 1);
~userSound = Buffer.alloc(s, 4 * s.sampleRate, 1);
~currentSample = Dictionary.new;
~vowelDict = Dictionary.new;
~vowelIndex = 0;
//~dataImages = ();
~posX = 0; //position of the cursor in ~dataView, manipulated by ~moveCursor

~activeSynths = ();
~currentData = ();
~activeRoutines = ();

~dataGroups = (
    \cmsm : (//Cchicken manure mit WHC 50, 70, 90%
        \50 : [22.3, 32.8, 30.7, 35.3, 36.7],
        \70 : [26.0, 30.7, 28.8, 41.2, 41.3],
        \90 : [26.1, 25.0, 37.8, 40.2, 44.3]
    ),
    \apsm : (//AP (Pflanzenreste)  WHC 50, 70, 90%
        \50 : [15.3, 25.5, 30.4, 34.8, 41.1],
        \70 : [15.9, 22.4, 29.5, 40.0, 44.0],
        \90 : [14.0, 20.6, 30.9, 40.7, 45.9]
    ),

    \cmapsm : (//ausgehend von 66% AP (Pflanzenreste) und 34% CM (Tierkot etc). WHC 50, 70, 90%
        \50 : ([0.0, 22.3, 32.8, 30.7, 35.3, 36.7] * 0.34).collect({|n, i| var ap = ([0.0, 5.3, 25.5, 30.4, 34.8, 41.1] * 0.66); n + ap[i] }) ,
        \70 : ([0.0, 26.0, 30.7, 28.8, 41.2, 41.3]* 0.34).collect({|n, i| var ap = ([0.0, 5.9, 22.4, 29.5, 40.0, 44.0] * 0.66); n + ap[i] }),
        \90 : ([0.0, 26.1, 25.0, 37.8, 40.2, 44.3] * 0.34).collect({|n, i| var ap = ([0.0, 14.0, 20.6, 30.9, 40.7, 45.9] * 0.66); n + ap[i] })
    ),


	\freq: [// suitable for frequency values
		\solar,
		\yearly,
		\relative,
		\relative_low,
		\relative_high,
		\absolute,
	],
	\factors: //suitable for multiplying values
	[	\uvi,
		\daily,
		\hourly,
		\wind_speed,
		\wind_gust,
		\rain_rate,
		\haptic_array1,
		\haptic_array2,
		\haptic_array3,
		\haptic_array4,
	],

	\steady: [ //slowly changing values between 20 - 80
		\temperature,
		\temperature_1,
		\temperature_low,
		\temperature_high,
		\temperature_high_1,
		\humidity,
		\soilmoisture,
		\soilmoisture_1
	],

	\volatile: [ //rapidly changing values
		\event,
		\weekly,
		\monthly,
		\wind_direction
	],
	\static: [ // static values between 1-0 -2.0
		\temperature_sensor_ch1,
		\soilmoisture_sensor_ch1,
		\soilmoisture_sensor_ch2,
	],
	\low: [// values 0.0 -5.0
		\wind_speed,
		\haptic_array3,
		\hourly,
		\haptic_array4,
	],
	\med_low: [//values 0-20
		\uvi,
		\wind_gust,
		\rain_rate,
		\event,
	],
	\medium:[// 0.0 - 85
		\temperature,
		\temperature_low,
		\temperature_low_1,
		\temperature_high,
		\temperature_high_1,
		\temperature_1,
		\monthly,
	],
	\med_high: [//0-900
		\solar,
		\yearly,
		\wind_direction,
	],
	\high: [ // around 1000
		\relative,
		\relative_high,
		\relative_low,
		\absolute
	]
);
