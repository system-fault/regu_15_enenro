%% Término de segundo orden (xi=0.5)
figure(1)
s=tf('s')
wc=10; 
wn=wc;
xi=0.5;
G=wn^2/(s^2+2*xi*wn*s+wn^2)
bode(G,'r')
grid on
%% Inversa del término de segundo orden (xi=0.5)
figure(2)
s=tf('s')
wc=10; 
wn=wc;
xi=0.5;
G=(s^2+2*xi*wn*s+wn^2)/wn^2
bode(G,'r')
grid on
%% Inversa del término de segundo orden (xi=0.5) fase no minima
figure(3)
s=tf('s')
wc=10; 
wn=wc;
xi=0.5;
G=(s^2-2*xi*wn*s+wn^2)/wn^2
bode(G,'r')
grid on
%% Término de segundo orden (xi diferentes)
figure(4)
s=tf('s')
wc=10; 
wn=wc;
for xi=0:0.2:1
G=wn^2/(s^2+2*xi*wn*s+wn^2)
bode(G)
grid
hold on
wr = wn*sqrt(1-2*xi^2);
end
legend('xi=0','xi=0.2','xi=0.4','xi=0.6','xi=0.8','xi=1')

%% Inversa del término de segundo orden(xi diferentes)
figure(5)
s=tf('s')
wc=10; 
wn=wc;
for xi=0:0.1:1
G=(s^2+2*xi*wn*s+wn^2)/wn^2
bode(G)
grid
wr = wn*sqrt(1-2*xi^2);
hold on
end
legend('xi=0', 'xi=0.1', 'xi=0.2', 'xi=0.3', 'xi=0.4', 'xi=0.5', 'xi=0.6', 'xi=0.7', 'xi=0.8', 'xi=0.9', 'xi=1');