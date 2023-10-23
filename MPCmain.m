% Created by Zhaoxuan Li, Bing Dong, 12/21/2015
% A simple example using direct control and MPC 
% bing.dong@utsa.edu
close all;
clear;clc;
% Input Building Parameters 
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
Tset=input(8,:);
price=input(10,:);

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


%% Run Building Simulation Without MPC
% Use a simple bang-bang control 
[AcPower2, Tzone2]= SIP_SS(Qinternal,T,IDIRW,IDIRE,IDIRN,IDIRS,IDIR,Tset,rnw,north,rsw,south,rew,east,rww,west,floor,roof);
figure;
plot(AcPower2,'-.ob','LineWidth',2);
title('AC','FontSize',16,'color','black');
xlabel('Time (Five Minute)','FontSize',16,'color','black');
ylabel('W','FontSize',16,'color','black');
legend('Bang Bang');

figure;
hold on
plot(Tzone2,'-.ob','LineWidth',2);
plot((Tset-32)*(5/9),'LineWidth',2);
hold off
title('Zone Temperature','FontSize',16,'color','black');
xlabel('Time (Five Minute)','FontSize',16,'color','black');
ylabel('C','FontSize',16,'color','black');
legend('Bang Bang');

Bill2= sum(AcPower2(1:250).*price(1:250)/500000)

%% Run Building Simulation With MPC
% Use fmincon to solve MPC

[AcPower, Tzone]= SIP_MPC_Amin(Qinternal,T,IDIRW,IDIRE,IDIRN,IDIRS,IDIR,Tset,rnw,north,rsw,south,rew,east,rww,west,floor,roof,price);
figure;
plot(AcPower,'--*b','LineWidth',2);
title('AC','FontSize',16,'color','black');
xlabel('Time (Five Minutes)','FontSize',16,'color','black');
ylabel('W','FontSize',16,'color','black');
legend('MPC');

figure;
hold on
plot(Tzone,'--*b','LineWidth',2);
plot((Tset-32)*(5/9),'LineWidth',2);
hold off
title('Zone Temperature','FontSize',16,'color','black');
xlabel('Time (Five Minutes)','FontSize',16,'color','black');
ylabel('C','FontSize',16,'color','black');
legend('MPC');

Bill1= sum(AcPower(1:250).*price(1:250)/500000)



