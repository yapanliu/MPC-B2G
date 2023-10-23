% Created by Amin
% A simple example using direct control and MPC 

close all;clear;clc;

% Input Building Parameters 

global A_opt;
global b_opt;
global Tsetwh;
global oc;
global WHlbT;

global xx;
global n;
global nvars;
global Twh;
global Tenv;
global totalR;
global valvegain;
global EVusage;
global ConsumtionGain;
global Cev;
global ChargW
global SOCinit;
global SOC;
global SOClb;
global mc;
global TimeStep;
global Qelement;
global whinit;
global EVconected;

global PredictionHorizon
EVusage=[];
input=csvread('2.Predictionfile.csv');
input=input'; 
inputP=csvread('1.PredictionfileP.csv'); % price signal
inputwh=csvread('3.PredictionfileWH.csv'); % water heater
inputEV=csvread('4.PredictionfileEV.csv'); % EV; connect status, lower bound, usage status. 
inputwh=inputwh';
inputEV=inputEV';
EVconected=inputEV(1,:);
EVusage=inputEV(3,:);
SOClb=inputEV(2,:)-0.1;

inputP=inputP';
price=inputP(2,:);   %1.ercot 2.detroit 3.CA; different price signals from various locations
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

PredictionHorizon=10*60;  %should be devidable to timestep
TimeStep=5;    %min
SOCevAllmpc=[];
SOCAllbb=[];
BillevBB=[];
EVenergyBB=[];
EVenergyBBtotal=[]
EVenergyMPCtotal=[]
EVenergyMPC=[];
BillevMPC=[];


%% -------------------------------------------------
for nb=1:1   %number of buildings

    % simulation parameters

  %  oc=ocall(nb,:);
   % EVusage=EVuseall(nb,:);
    %EVlb=EVLBall(nb,:);    SOClb

    ChargW=5800;      %joule/second   R*I2
    ConsumtionGain=300*50;    %WH/mile * speed  = J/s
    chargingEF=0.90;
    Cev=34*1000*60*60   % battery capacity J kWh*hour*minute
    % reset for each building and controller
    initialSOC=SOClb(1)-0.1;
    EVchargeEnergy=[];
    SOC=initialSOC;
    bill=0;
    SOClb=[SOClb SOClb];
    EVconected=[EVconected EVconected];
    price=[price price];
    EVusage=[EVusage EVusage];
for n=1:288;

    
%% bang bang controler

            if SOC(n)>0.9 && EVconected(n)==1
                EVchargeEnergy=[EVchargeEnergy 0];
            elseif SOC(n)<0.9-0.01 && EVconected(n)==1
                EVchargeEnergy=[EVchargeEnergy ChargW];
            else
                if n==1 && EVconected(n)==1
                    EVchargeEnergy=[EVchargeEnergy ChargW];
                elseif  EVconected(n)==0
                    EVchargeEnergy=[EVchargeEnergy 0];
                else
                    EVchargeEnergy=[EVchargeEnergy EVchargeEnergy(n-1)];
                end
            end 

% water heater simulation
    

SOC(n+1)=SOC(n)+(EVchargeEnergy(n)-ConsumtionGain*EVusage(n))/Cev*TimeStep*60;
bill=bill+EVchargeEnergy(n)*price(n)/500000/chargingEF;    

end
SOCAllbb(nb,:)=SOC;
BillevBB(nb)=bill
EVenergyBB(nb,:)=EVchargeEnergy;
EVenergyBBtotal(nb)=sum(EVchargeEnergy)/12;
% BB plotter

figure;
plot(SOCAllbb(nb,:),'LineWidth',2);
str = ['EV SOC Bang Bang controller EV #',num2str(nb)];
title(str,'FontSize',16,'color','black');
xlabel('Time (Five Minute intervals)','FontSize',16);
ylabel('%','FontSize',16);
hold on;
plot(EVusage(1:288)*0.07,'LineWidth',2);
plot(EVconected(1:288)*0.07+0.10,'LineWidth',2);


%% MPC -----------------------------------------------
    % reset for each building and controller
    EVchargeEnergy=[];
    SOC=initialSOC;
    bill=0;
    
nvars = PredictionHorizon/TimeStep;    % Number of variables

for n=1:288;
n
%% MPC controler
          
c_opt=[];
%whinit=Twh(n);
%A_opt=tril(ones(nvars,nvars));
%b_opt = [];                          %A*x <= b

for i=1:nvars;
c_opt = [c_opt price(n+i)/500000];     %min c'*x

%A_opt(i:end,i) = Qelement*TimeStep*60/mc;
%b_opt(i)=whinit+(Qelement*i-(Twh(n)-Tenv(n))/totalR-valvegain*EVusage(n+i)*(Twh(n)-Tenv(n)))*TimeStep*60/mc+2+(1-WHlbT(n+i)).*30;    % setpoint is missing!!!!!
%b_opt(nvars+i)=-(whinit+(Qelement*i-(Twh(n)-Tenv(n))/totalR-valvegain*EVusage(n+i)*(Twh(n)-Tenv(n)))*TimeStep*60/mc)+2;

end
%A_opt=[A_opt;-A_opt];
%b_opt=b_opt';


intcon=1:nvars;
options = gaoptimset;
options.TimeLimit=100;
options = gaoptimset(options,'PopulationSize',50);
LB = zeros(1,nvars);   % Lower bound
UB = ones(1,nvars);  % Upper bound
for iub=1:nvars
    if EVconected(n+iub)==0
        UB(iub) = 0;  % Upper bound  when ev is not connected to charger
    end
end

whobjfun=@(x) ((x*ChargW)*c_opt');
Constraint=@constraintEV;
%Constraint=@(x) (A_opt*x'-b_opt,[]);
[x_EV,fval_wh] = ga(whobjfun,nvars,[],[],[],[],LB,UB,Constraint,intcon,options);
           

% EV simulation
    EVchargeEnergy(n)=x_EV(1)*ChargW;
    SOC(n+1)=SOC(n)+(EVchargeEnergy(n)-ConsumtionGain*EVusage(n))/Cev*TimeStep*60;
    bill=bill+EVchargeEnergy(n)*price(n)/500000/chargingEF; 
        
end
SOCevAllmpc(nb,:)=SOC;
BillevMPC(nb)=bill;
EVenergyMPC(nb,:)=EVchargeEnergy;
EVenergyMPCtotal(nb)=sum(EVchargeEnergy)/12;
% MPC plotter

figure;
plot(SOCevAllmpc(nb,:),'LineWidth',2); % EV SOC, blue line
str = ['MPC EV #',num2str(nb)];
title(str,'FontSize',16,'color','black');
xlabel('Time (Five Minute intervals)','FontSize',16);
ylabel('C','FontSize',16);
hold on;
plot(EVusage(1:288)*0.07,'LineWidth',2); % EV usage, red line
plot(EVconected(1:288)*0.07+0.10,'LineWidth',2); % EV connected yellow line
plot(SOClb(1:288),'LineWidth',1,'LineWidth',1,'LineStyle','--','Color',[0 0 0]); % black dash line
plot(0.91+SOClb(1:288).*0,'LineWidth',1,'LineWidth',1,'LineStyle','--','Color',[0 0 0]); % 0.91 hline, upper limit of EV SOC


%subplot first building

figure
subplot(2,1,1);
plot(SOCAllbb(nb,:),'b','LineWidth',1,'Color',[0.152941182255745 0.227450981736183 0.372549027204514]);
str = ['BB EV #',num2str(nb)];
title(str,'FontSize',16,'color','black');
xlabel('Time (Five Minute intervals)','FontSize',16);
ylabel('C','FontSize',16);
hold on;
plot(EVusage(1:288)*0.07,'r','LineWidth',1,'Color',[0.635294139385223 0.0784313753247261 0.184313729405403],'LineStyle','-');
plot(EVconected(1:288)*0.07+0.10,'r','LineWidth',1,'Color',[0.635294139385223 0.0784313753247261 0.184313729405403],'LineStyle','-');
plot(0.91+SOClb(1:288).*0,'LineWidth',1,'LineWidth',1,'LineStyle','--','Color',[0 0 0]);

subplot(2,1,2);
plot(SOCevAllmpc(nb,:),'b','LineWidth',1,'Color',[0.152941182255745 0.227450981736183 0.372549027204514]);
str = ['Water Heater Temperature MPC building #',num2str(nb)];
title(str,'FontSize',16,'color','black');
xlabel('Time (Five Minute intervals)','FontSize',16);
ylabel('C','FontSize',16);
hold on;
plot(EVusage(1:288)*0.07,'r','LineWidth',1,'Color',[0.635294139385223 0.0784313753247261 0.184313729405403],'LineStyle','-');
plot(EVconected(1:288)*0.07+0.10,'r','LineWidth',1,'Color',[0.635294139385223 0.0784313753247261 0.184313729405403],'LineStyle','-');
plot(SOClb(1:288),'LineWidth',1,'LineWidth',1,'LineStyle','--','Color',[0 0 0]);
plot(0.91+SOClb(1:288).*0,'LineWidth',1,'LineWidth',1,'LineStyle','--','Color',[0 0 0]);



end




