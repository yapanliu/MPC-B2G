% Created by Amin
% A simple example using direct control and MPC 

close all;clear;clc;

% Input Building Parameters 

global A_opt;
global b_opt;
global Tsetwh;
global oc;


input=csvread('2.Predictionfile.csv');
input=input'; 

price=input(10,:);
ocall(1,:)=input(11,:);
ocall(2,:)=input(12,:);


Tsetall(1,:)=input(8,:)-1;
Tsetall(2,:)=input(13,:)-1;
whuseall(1,:)=input(14,:);
whuseall(2,:)=input(15,:);

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
PredictionHorizon=3*60;  %should be devidable to timestep
TimeStep=5;    %min
TwhAllmpc=[];
TwhAllbb=[];
BillwhBB=[];
BillwhMPC=[];


%% -------------------------------------------------
for nb=1:2   %number of buildings

    % simulation parameters

    oc=ocall(nb,:);
    WHusage=whuseall(nb,:);
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

            if Twh(n)>Tsetwh+3
                Qwh=[Qwh 0];
            elseif Twh(n)<Tsetwh-3
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

end
TwhAllbb(nb,:)=Twh;
BillwhBB(nb)=bill
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

A_opt(i:end,i) = Qelement*5*60/mc;
b_opt(i)=whinit+(Qelement*i-(Twh(n)-Tenv(n))/totalR-valvegain*WHusage(n+i)*(Twh(n)-Tenv(n)))/mc*TimeStep*60+2;
b_opt(nvars+i)=-(whinit+(Qelement*i-(Twh(n)-Tenv(n))/totalR-valvegain*WHusage(n+i)*(Twh(n)-Tenv(n)))/mc*TimeStep*60)+2;

end
A_opt=[A_opt;-A_opt];
b_opt=b_opt';


intcon=1:nvars;
options = gaoptimset;
options.TimeLimit=50;
options = gaoptimset(options,'PopulationSize',20);
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






end







