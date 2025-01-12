clear all; close all;clc
%% Diagrama real
figure
s = tf('s')
G = 320*(s+2)/(s*(s+1)*(s^2 + 8*s + 64))
bode(G,'g');
grid on;


%% Diagrama asintótico
figure
num = 320*[1 2];
den = [1 9 72 64 0];
bode_as(num,den)