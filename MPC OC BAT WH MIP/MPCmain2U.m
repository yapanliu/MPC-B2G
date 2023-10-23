% Created by amin,
% A simple example using direct control and MPC 

close all;
clear;clc;
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
Tset=input(8,:)-1;
Tset2=input(13,:)-1;
price=input(10,:);
oc=input(11,:);
oc2=input(12,:);

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
global AConoff;

cop=5;                    % COP
global PredictionHorizon
PredictionHorizon=3*60;  %should be devidable to timestep
global init00;           %initial value


global chargrate5          %battery charge rate    (amount saved in the battery, cosumed energy=1.05*chargerate)
global dischargrate5          %battery discharge rate   (amount used form energy inside the battery,, available energy for consumption= 0.95*dischargerate)
global xx_bat
global batcap;                 % J

chargrate5=1000;              % watt  (j/s)
dischargrate5=1000;             % watt  (j/s)

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
plot((Tset-32)*(5/9)+0.5,'LineWidth',1);
plot((Tset-32)*(5/9)-0.5,'LineWidth',1);
hold off;
title('Zone Temperature','FontSize',16,'color','black');
xlabel('Time (Five Minute)','FontSize',16,'color','black');
ylabel('C','FontSize',16,'color','black');
legend('Bang Bang');

BillBB= sum(AcPowerBB(1:250).*price(1:250)/500000)

%%----------------------------------------------------------------------------
%% Run Building Simulation  MPC with oc and battery MIP
% Use MIP to solve MPC

[AcPowerMPCocMIP, TzoneMPCocMIP, batenergyMPCocMIP, batchargseqMPCocMIP, BillMPCocMIP]= SIP_MPC_Amin_oc_MIP(Qinternal,T,IDIRW,IDIRE,IDIRN,IDIRS,IDIR,Tset,rnw,north,rsw,south,rew,east,rww,west,floor,roof,price);

figure;
plot(AcPowerMPCocMIP,'--*b','LineWidth',2);
title('AC','FontSize',16,'color','black');
xlabel('Time (Five Minutes)','FontSize',16,'color','black');
ylabel('W','FontSize',16,'color','black');
legend('MPC with occupancy B and MIP');

figure;
hold on;
plot(TzoneMPCocMIP,'--*b','LineWidth',2);
plot((Tset-32)*(5/9),'LineWidth',2);
plot(oc/2+23,'r');

hold off;
title('Zone Temperature','FontSize',16,'color','black');
xlabel('Time (Five Minutes)','FontSize',16,'color','black');
ylabel('C','FontSize',16,'color','black');
legend('MPC with occupancy B and MIP');

BillMPCocMIP=BillMPCocMIP;
BillMPCocACmip= sum(AcPowerMPCocMIP(1:250).*price(1:250)/500000);
xxMPCocBMIP=xx;
xx_batMPCocBMIP=xx_bat;



stop=1;


%%----------------------------------------------------------------------------
%%

%% Run Building Simulation  MPC with oc building #1
% Use GA to solve MPC

[AcPowerMPC, TzoneMPC]= SIP_MPC_Amin(Qinternal,T,IDIRW,IDIRE,IDIRN,IDIRS,IDIR,Tset,rnw,north,rsw,south,rew,east,rww,west,floor,roof,price);
figure;
plot(AcPowerMPC,'--*b','LineWidth',2);
title('AC','FontSize',16,'color','black');
xlabel('Time (Five Minutes)','FontSize',16,'color','black');
ylabel('W','FontSize',16,'color','black');
legend('MPC with oc');

figure;
hold on;
plot(TzoneMPC,'--*b','LineWidth',2);
plot((Tset-32)*(5/9),'LineWidth',2);
plot(oc/2+23,'r');

hold off;
title('Zone Temperature','FontSize',16,'color','black');
xlabel('Time (Five Minutes)','FontSize',16,'color','black');
ylabel('C','FontSize',16,'color','black');
legend('MPC with oc');

BillMPC= sum(AcPowerMPC(1:250).*price(1:250)/500000)

xxMPCocga=xx;



%% Run Building Simulation  MPC with oc building #2
% Use GA to solve MPC

[AcPowerMPC2, TzoneMPC2]= SIP_MPC_Amin2(Qinternal,T,IDIRW,IDIRE,IDIRN,IDIRS,IDIR,Tset2,rnw,north,rsw,south,rew,east,rww,west,floor,roof,price);
figure;
plot(AcPowerMPC2,'--*b','LineWidth',2);
title('AC','FontSize',16,'color','black');
xlabel('Five Minutes intervals)','FontSize',16,'color','black');
ylabel('W','FontSize',16,'color','black');
legend('MPC with oc building 2');

figure;
hold on;
plot(TzoneMPC2,'--*b','LineWidth',2);
plot((Tset2-32)*(5/9),'LineWidth',2);
plot(oc2/2+23,'r');

hold off;
title('building 2 Zone Temperature','FontSize',16,'color','black');
xlabel('Time (Five Minutes)','FontSize',16,'color','black');
ylabel('C','FontSize',16,'color','black');
legend('MPC with oc building 2');

BillMPCoc2= sum(AcPowerMPC2(1:250).*price(1:250)/500000)
xxMPCocga2=xx;




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

BillMPCw= sum(AcPowerMPCw(1:250).*price(1:250)/500000);
xxMPCga=xx;


