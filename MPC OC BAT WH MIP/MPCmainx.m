% Created by Amin, Zhaoxuan Li, Bing Dong, 06062016
% This program schedual batteries in two building using HVAC consumtion schedual
% should run MPCmain2.m first
% close all;
% clear;clc;
% Input Building Parameters 
global oc;
global oc2;
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
% Tset=input(8,:)-1;  % should have been loaded in HVAC simulation
% price=input(10,:); Price should have been loaded in HVAC simulation
oc=input(11,:); %  should have been loaded in HVAC simulation
oc2=input(12,:); %  should have been loaded in HVAC simulation

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
%cop=5;                    % COP
global PredictionHorizon
PredictionHorizon=3*60;  %should be devidable to timestep

global init00;           %initial value

global chargrate5          %battery charge rate    (amount saved in the battery, consumed energy=1.05*chargerate)
global dischargrate5          %battery discharge rate   (amount used form energy inside the battery,, available energy for consumption= 0.95*dischargerate)

global xx_bat
global batcap;                 % J
global bateff;
bateff=1;              %0-1

chargrate5=1000;              % watt  (j/s)
dischargrate5=1000;             % watt  (j/s)

batcap=100000000;                  % battery capacity  
init00= [26 26];


%load schedual
global xxMPCocga;
global xxMPCocga2;

%%

%% Run Building Simulation  MPC with oc and bat building 1 with comunication
% Use GA to solve MPC

[AcPowerMPCocbx1, TzoneMPCocbx1, batenergyMPCocx1, batchargseqMPCocx1, BillMPCocBx1, Batteryearned1]= SIP_MPC_Amin_oc_bat_x1(Qinternal,T,IDIRW,IDIRE,IDIRN,IDIRS,IDIR,Tset,rnw,north,rsw,south,rew,east,rww,west,floor,roof,price);

figure;
plot(batenergyMPCocx1,'--*b','LineWidth',2);
title('batenergyMPCocx1','FontSize',16,'color','black');
xlabel('Time (Five Minutes)','FontSize',16,'color','black');
ylabel('W','FontSize',16,'color','black');
legend('batenergy MPC oc x 1 building#1');



%% Run Building Simulation  MPC with oc and bat building #2  with comunication
% Use GA to solve MPC

[AcPowerMPCocbx2, TzoneMPCocbx2, batenergyMPCocx2, batchargseqMPCocx2, BillMPCocBx2, Batteryearned2]= SIP_MPC_Amin_oc_bat_x2(Qinternal,T,IDIRW,IDIRE,IDIRN,IDIRS,IDIR,Tset,rnw,north,rsw,south,rew,east,rww,west,floor,roof,price);

figure;
plot(batenergyMPCocx2,'--*b','LineWidth',2);
title('batenergy MPC oc x 2 Building #2','FontSize',16,'color','black');
xlabel('Time (Five Minutes)','FontSize',16,'color','black');
ylabel('W','FontSize',16,'color','black');
legend('batenergyMPCocx2 building #2');



%% Run Building Simulation  MPC with oc and bat building 1   without comunication
% Use GA to solve MPC

[AcPowerMPCocbxw1, TzoneMPCocbxw1, batenergyMPCocxw1, batchargseqMPCocxw1, BillMPCocBxw1, Batteryearnedw1]= SIP_MPC_Amin_oc_bat_xw1(Qinternal,T,IDIRW,IDIRE,IDIRN,IDIRS,IDIR,Tset,rnw,north,rsw,south,rew,east,rww,west,floor,roof,price);

figure;
plot(batenergyMPCocxw1,'--*b','LineWidth',2);
title('batenergyMPCocxw1 witout connection','FontSize',16,'color','black');
xlabel('Time (Five Minutes)','FontSize',16,'color','black');
ylabel('W','FontSize',16,'color','black');
legend('batenergyMPCocxw1 building#1');




%% Run Building Simulation  MPC with oc and bat building 2   without comunication
% Use GA to solve MPC

[AcPowerMPCocbxw2, TzoneMPCocbxw2, batenergyMPCocxw2, batchargseqMPCocxw2, BillMPCocBxw2, Batteryearnedw2]= SIP_MPC_Amin_oc_bat_xw2(Qinternal,T,IDIRW,IDIRE,IDIRN,IDIRS,IDIR,Tset,rnw,north,rsw,south,rew,east,rww,west,floor,roof,price);

figure;
plot(batenergyMPCocxw2,'--*b','LineWidth',2);
title('batenergyMPCocxw2 witout connection','FontSize',16,'color','black');
xlabel('Time (Five Minutes)','FontSize',16,'color','black');
ylabel('W','FontSize',16,'color','black');
legend('batenergyMPCocxw1 building#2');

