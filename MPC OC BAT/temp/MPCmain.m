% Created by Zhaoxuan Li, Bing Dong, 12/21/2015
% A simple example using direct control and MPC 
% bing.dong@utsa.edu
close all;
clear;clc;
% Input Building Parameters 
global oc;
global T;
input=csvread('2.Predictionfile.csv');
input=input'; 
building=csvread('3.Buildinginformation.csv');
Qinternal=input(1,:);
T=input(2,:);
IDIRW=input(3,:);
IDIRE=input(4,:);
IDIRN=input(5,:);
IDIRS=input(6,:);
IDIR=input(7,:);
Tset=input(8,:)-1;
price=input(10,:);
oc=input(11,:);

rnw=building(1,1);
north=building(1,2);
rsw=building(2,1);
south=building(2,2);
rew=building(3,1);
east=building(3,2);
rww=building(4,1);
west=building(4,2);
floor=building(5,2);
roof=building(6,2);


n=[];
Tamb=[];
Tz0=[];
p=[];
nvars=[];
X0=[];
w=[];
pc0=[];
tsetpoint=[];

global xx;
global n;
global Tamb;
global Tz0;
global p;
global nvars;
global X0;
global w;
global pc0;
global tsetpoint;
global yy;
global cop;
cop=5;                    % COP
global init00;           %initial value

global chargrate5          %battery charge rate
global dischargrate5          %battery discharge rate

global batcap;                 % J

chargrate5=500;              % watt  (j/s)
dischargrate5=500;             % watt  (j/s)

batcap=100000000;                  % battery capacity  
init00= [26 26];

%% Run Building Simulation BBS with occupancy measurement
% Use a simple bang-bang control 
[AcPowerBBS, TzoneBBS]= SIP_SS_BB_oc(Qinternal,T,IDIRW,IDIRE,IDIRN,IDIRS,IDIR,Tset,rnw,north,rsw,south,rew,east,rww,west,floor,roof);
figure;
plot(AcPowerBBS,'-.ob','LineWidth',2);
title('AC','FontSize',16,'color','black');
xlabel('Time (Five Minute)','FontSize',16,'color','black');
ylabel('W','FontSize',16,'color','black');
legend('Bang Bang with occupancy measurement');

figure;
hold on;
plot(TzoneBBS,'-.ob','LineWidth',2);
plot((Tset-32)*(5/9),'LineWidth',2);
plot(oc/2+23,'r');

hold off;
title('Zone temperature','FontSize',16,'color','black');
xlabel('Time (Five Minute)','FontSize',16,'color','black');
ylabel('C','FontSize',16,'color','black');
legend('Bang Bang with occupancy measurement');

BillBBS= sum(AcPowerBBS(1:250).*price(1:250)/500000)


%% Run Building Simulation BB
% Use a simple bang-bang control 
[AcPowerBB, TzoneBB]= SIP_SS(Qinternal,T,IDIRW,IDIRE,IDIRN,IDIRS,IDIR,Tset,rnw,north,rsw,south,rew,east,rww,west,floor,roof);
figure;
plot(AcPowerBB,'-.ob','LineWidth',2);
title('AC','FontSize',16,'color','black');
xlabel('Time (Five Minute)','FontSize',16,'color','black');
ylabel('W','FontSize',16,'color','black');
legend('Bang Bang');

figure;
hold on;
plot(TzoneBB,'-.ob','LineWidth',2);
plot((Tset-32)*(5/9),'LineWidth',2);
hold off;
title('Zone Temperature','FontSize',16,'color','black');
xlabel('Time (Five Minute)','FontSize',16,'color','black');
ylabel('C','FontSize',16,'color','black');
legend('Bang Bang');

BillBB= sum(AcPowerBB(1:250).*price(1:250)/500000)

%%----------------------------------------------------------------------------
%%----------------------------------------------------------------------------
%%


%% Run Building Simulation  MPC with oc and battery
% Use GA to solve MPC

[AcPowerMPCocB, TzoneMPCocB,batterystoredenergy, batchargseq, BillMPCocB]= SIP_MPC_oc_bat_Amin(Qinternal,T,IDIRW,IDIRE,IDIRN,IDIRS,IDIR,Tset,rnw,north,rsw,south,rew,east,rww,west,floor,roof,price);

figure;
plot(AcPowerMPCocB,'--*b','LineWidth',2);
title('AC','FontSize',16,'color','black');
xlabel('Time (Five Minutes)','FontSize',16,'color','black');
ylabel('W','FontSize',16,'color','black');
legend('MPC with occupancy and battery');

figure;
hold on;
plot(TzoneMPCocB,'--*b','LineWidth',2);
plot((Tset-32)*(5/9),'LineWidth',2);
plot(oc/2+23,'r');

hold off;
title('Zone Temperature','FontSize',16,'color','black');
xlabel('Time (Five Minutes)','FontSize',16,'color','black');
ylabel('C','FontSize',16,'color','black');
legend('MPC with occupancy and battery');

BillMPCocB
BillMPCocBAC= sum(AcPowerMPCocB(1:250).*price(1:250)/500000)



%% Run Building Simulation  MPC with oc
% Use GA to solve MPC

[AcPowerMPC, TzoneMPC]= SIP_MPC_Amin(Qinternal,T,IDIRW,IDIRE,IDIRN,IDIRS,IDIR,Tset,rnw,north,rsw,south,rew,east,rww,west,floor,roof,price);
figure;
plot(AcPowerMPC,'--*b','LineWidth',2);
title('AC','FontSize',16,'color','black');
xlabel('Time (Five Minutes)','FontSize',16,'color','black');
ylabel('W','FontSize',16,'color','black');
legend('MPC');

figure;
hold on;
plot(TzoneMPC,'--*b','LineWidth',2);
plot((Tset-32)*(5/9),'LineWidth',2);
plot(oc/2+23,'r');

hold off;
title('Zone Temperature','FontSize',16,'color','black');
xlabel('Time (Five Minutes)','FontSize',16,'color','black');
ylabel('C','FontSize',16,'color','black');
legend('MPC');

BillMPC= sum(AcPowerMPC(1:250).*price(1:250)/500000)



%% Run Building Simulation  MPC without oc
% Use GA to solve MPC

[AcPowerMPCw, TzoneMPCw]= SIP_MPCw_Amin(Qinternal,T,IDIRW,IDIRE,IDIRN,IDIRS,IDIR,Tset,rnw,north,rsw,south,rew,east,rww,west,floor,roof,price);
figure;
plot(AcPowerMPCw,'--*b','LineWidth',2);
title('AC','FontSize',16,'color','black');
xlabel('Time (Five Minutes)','FontSize',16,'color','black');
ylabel('W','FontSize',16,'color','black');
legend('MPC');

figure;
hold on;
plot(TzoneMPCw,'--*b','LineWidth',2);
plot((Tset-32)*(5/9),'LineWidth',2);
plot(oc/2+23,'r');

hold off;
title('Zone Temperature','FontSize',16,'color','black');
xlabel('Time (Five Minutes)','FontSize',16,'color','black');
ylabel('C','FontSize',16,'color','black');
legend('MPC');

BillMPCw= sum(AcPowerMPCw(1:250).*price(1:250)/500000)



