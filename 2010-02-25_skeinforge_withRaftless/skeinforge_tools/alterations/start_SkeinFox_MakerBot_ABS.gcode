(***************FIRST SET Z TO 20*********************)
(homing routing)
M104 S240 T0 (Temperature to 240 celsius)
G21 (Metric FTW)
G90 (Absolute Positioning)
G92 X0 Y0 Z20 (You are now at 0,0,20)
(You have failed me for the last time, MakerBot)
M108 S255 (Extruder speed = max)
M6 T0 (Wait for tool to heat up)
G0 Z0	(Go back to zero.)
(end of start.)
