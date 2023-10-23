% Created by Amin
% A simple example using direct control and MPC 

close all;clear;clc;

% Input Building Parameters 

global A_opt;
global b_opt;
global Tsetwh;
global oc;
global WHlbT;

input=csvread('2.Predictionfile.csv');
input=input'; 
inputP=csvread('1.PredictionfileP.csv');
inputwh=csvread('3.PredictionfileWH.csv');
inputwh=inputwh';
inputP=inputP';
price=inputP(2,:);   %1.ercot 2.detroit 3.CA
%price=input(10,:);
ocall(1,:)=input(11,:);
ocall(2,:)=input(12,:);

Tsetall(1,:)=input(8,:)-1;
Tsetall(2,:)=input(13,:)-1;
whuseall(1,:)=input(14,:);
whuseall(2,:)=input(15,:);
whLBall(1,:)=inputwh(7,:);
whLBall(2,:)=inputwh(7,:);
n=[];
nvars=[];
pc0=[];

global xx;
global n;
global nvars;
global Twh;
global Tenv;
global totalR;
global valvegain;
global WHusage;
global mc;
global TimeStep;
global Qelement;
global whinit;


global PredictionHorizon
PredictionHorizon=1*60;  %should be devidable to timestep
TimeStep=5;    %min
TwhAllmpc=[];
TwhAllbb=[];
BillwhBB=[];
QwhBB=[];
QwhBBtotal=[]
QwhMPCtotal=[]
QwhMPC=[];
BillwhMPC=[];
dateL=[];

%% -------------------------------------------------
for nb=1:1   %number of buildings

    % simulation parameters

    oc=ocall(nb,:);
    WHusage=whuseall(nb,:);
    WHlbT=whLBall(nb,:);
    Tenv=(Tsetall(nb,:)-32)*(5/9);
    initialT=40+10*nb;
    Tsetwh=60;
    Qelement=2500;      %joule/second   R*I2
    valvegain=0.15*4217;    %C*liter/second
    totalR=0.4;      %Celsius/(joule/second)
    mc=100*4217;    %liter*C
    energyfactor=0.95;
    
    % reset for each building and controller
    Qwh=[];
    Twh=initialT;
    bill=0;
    
for n=1:288-12*3;

    
%% bang bang controler

            if Twh(n)>Tsetwh+5
                Qwh=[Qwh 0];
            elseif Twh(n)<Tsetwh-5
                Qwh=[Qwh Qelement];
            else
                if n==1;
                    Qwh=[Qwh Qelement];
                else
                    Qwh=[Qwh Qwh(n-1)];
                end
            end 

% water heater simulation
    
    Twh(n+1)=Twh(n)+(Qwh(n)-(Twh(n)-Tenv(n))/totalR-valvegain*WHusage(n)*(Twh(n)-Tenv(n)))/mc*TimeStep*60;
 
bill=bill+Qwh(n)*price(n)/500000/energyfactor;    
dateL=[dateL date];
end
TwhAllbb(nb,:)=Twh;
BillwhBB(nb)=bill
QwhBB(nb,:)=Qwh;
QwhBBtotal(nb)=sum(Qwh)/12;
% BB plotter

figure;
plot(TwhAllbb(nb,:),'LineWidth',2);
str = ['Water Heater Temperature Bang Bang controller building #',num2str(nb)];
title(str,'FontSize',16,'color','black');
xlabel('Time (Five Minute intervals)','FontSize',16);
ylabel('C','FontSize',16);
hold on;
plot(WHusage*10+20,'LineWidth',2);



%% MPC -----------------------------------------------
    % reset for each building and controller
    Qwh=[];
    Twh=initialT;
    bill=0;
    
nvars = PredictionHorizon/TimeStep;    % Number of variables

for n=1:288-12*3;

    
%% MPC controler
          
c_opt=[];
whinit=Twh(n);
A_opt=tril(ones(nvars,nvars));
b_opt = [];                          %A*x <= b

for i=1:nvars;
c_opt = [c_opt price(n+i)/500000];     %min c'*x

A_opt(i:end,i) = Qelement*TimeStep*60/mc;
b_opt(i)=whinit+(Qelement*i-(Twh(n)-Tenv(n))/totalR-valvegain*WHusage(n+i)*(Twh(n)-Tenv(n)))*TimeStep*60/mc+2+(1-WHlbT(n+i)).*30;    % setpoint is missing!!!!!
b_opt(nvars+i)=-(whinit+(Qelement*i-(Twh(n)-Tenv(n))/totalR-valvegain*WHusage(n+i)*(Twh(n)-Tenv(n)))*TimeStep*60/mc)+2;

end
A_opt=[A_opt;-A_opt];
b_opt=b_opt';


intcon=1:nvars;
options = gaoptimset;
options.TimeLimit=100;
options = gaoptimset(options,'PopulationSize',50);
LB = zeros(1,nvars);   % Lower bound
UB = ones(1,nvars);  % Upper bound


whobjfun=@(x) ((x*Qelement)*c_opt');
Constraint=@constraintwh;
%Constraint=@(x) (A_opt*x'-b_opt,[]);
[x_wh,fval_wh] = ga(whobjfun,nvars,[],[],[],[],LB,UB,Constraint,intcon,options);
           

% water heater simulation
    Qwh(n)=x_wh(1)*Qelement;
    Twh(n+1)=Twh(n)+(Qwh(n)-(Twh(n)-Tenv(n))/totalR-valvegain*WHusage(n)*(Twh(n)-Tenv(n)))/mc*TimeStep*60;
    bill=bill+Qwh(n)*price(n)/500000/energyfactor; 
        
end
TwhAllmpc(nb,:)=Twh;
BillwhMPC(nb)=bill;
QwhMPC(nb,:)=Qwh;
QwhMPCtotal(nb)=sum(Qwh)/12;
% MPC plotter

figure;
plot(TwhAllmpc(nb,:),'LineWidth',2);
str = ['Water Heater Temperature MPC building #',num2str(nb)];
title(str,'FontSize',16,'color','black');
xlabel('Time (Five Minute intervals)','FontSize',16);
ylabel('C','FontSize',16);
hold on;
plot(WHusage*10+20,'LineWidth',2);
plot(oc*5+25,'LineWidth',2);
plot(60-5-(1-WHlbT(nb,:)).*30,'LineWidth',2,'LineStyle','--');
plot(60+5+WHlbT(nb,:).*0,'LineWidth',2,'LineStyle','--');





%subplot first building


figure
subplot(1,2,1);
plot(TwhAllbb(nb,:),'b','LineWidth',1,'Color',[0.152941182255745 0.227450981736183 0.372549027204514]);
str = ['Water Heater Temperature Bang Bang controller building #',num2str(nb)];
title(str,'FontSize',16,'color','black');
xlabel('Time (Five Minute intervals)','FontSize',16);
ylabel('C','FontSize',16);
hold on;
plot(WHusage*10+20,'LineWidth',1);
plot(60+5+WHlbT(nb,:).*0,'LineWidth',1,'LineWidth',1,'LineStyle','--','Color',[0 0 0]);
plot(60-5+WHlbT(nb,:).*0,'LineWidth',1,'LineWidth',1,'LineStyle','--','Color',[0 0 0]);

subplot(1,2,2);
plot(TwhAllmpc(nb,:),'b','LineWidth',1,'Color',[0.152941182255745 0.227450981736183 0.372549027204514]);
str = ['Water Heater Temperature MPC building #',num2str(nb)];
title(str,'FontSize',16,'color','black');
xlabel('Time (Five Minute intervals)','FontSize',16);
ylabel('C','FontSize',16);
hold on;
plot(WHusage*10+20,'LineWidth',1);
plot(oc*5+25,'r','LineWidth',1,'Color',[0.635294139385223 0.0784313753247261 0.184313729405403],'LineStyle','-');
plot(60-5-(1-WHlbT(nb,:)).*30,'LineWidth',1,'LineWidth',1,'LineStyle','--','Color',[0 0 0]);
plot(60+5+WHlbT(nb,:).*0,'LineWidth',1,'LineWidth',1,'LineStyle','--','Color',[0 0 0]);



end




