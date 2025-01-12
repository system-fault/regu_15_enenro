% Borra todo
clear;
clc;
close all;

s = tf('s');

%G
G = (25)/(s*(s^2+15*s+50));

Mp = 4.33;
ts = 1.5;

xi = sqrt((log(Mp/100)^2)/(pi^2+log(Mp/100)^2));

Wn = 4/(xi*ts);
