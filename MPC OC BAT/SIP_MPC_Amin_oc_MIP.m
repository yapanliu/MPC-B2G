% Created by Amin 02/16/2016

function [AcPower, Tz, batenergy, batchargseq, bill] = SIPMPCLoad(Qinternal,T,IDIRW,IDIRE,IDIRN,IDIRS,IDIR,Tset,rnw,north,rsw,south,rew,east,rww,west,floor,roof,price)

% global Anw
% global Anorth
% global Asw
% global Asouth
% global Aew
% global Aeast
% global Aww
% global Awest
% global Afloor
% global Aroof


global n;
global nn;
global Tamb;
global Tz0;
global xx;
global xx_bat
x_bat=[];
xx_bat=[];
xx=[];
x=1;
global p;
p=price;
global nvars;
global AConoff;
AConoff=[];
global X0;
global w;
global oc;
global pc0;
global yy;
global cop;
global tsetpoint;
tsetpoint=(Tset-32)*(5/9);
global init00;
global chargrate5          %battery charge rate
global dischargrate5          %battery discharge rate
global batcap;    
batchargseq=[];
bill=0;



Anorthwindow=rnw*north;
Anorth=north*(1-rnw);
Asouthwindow=rsw*south;
Asouth=south*(1-rsw);
Aeastwindow=rew*east;
Aeast=east*(1-rew);
Awestwindow=rww*west;
Awest=west*(1-rww);
Afloor=floor;
Aroof=roof;

Qo1=0.4*0.1*Awest*(IDIRW);
Qo2=0.4*0.1*Aeast*(IDIRE);
Qo3=0.4*0.1*Anorth*(IDIRN);
Qo4=0.4*0.1*Asouth*(IDIRS);
Qo5=0.4*0.1*Aroof*(IDIR);
exteriorwindow=Anorthwindow*IDIRN+Asouthwindow*IDIRS+Aeastwindow*IDIRE+Awestwindow*IDIRW;
Qwin=0.1*exteriorwindow;
Qi1=0.025*Qwin;
Qi2=0.025*Qwin;
Qi3=0.025*Qwin;
Qi4=0.025*Qwin;
Qi5=0.2*Qwin;
Qi6=0.7*Qwin;

Q1=Qo1+Qi1;
Q2=Qo2+Qi2;
Q3=Qo3+Qi3;
Q4=Qo4+Qi4;
Q5=Qo5+Qi5;
Q6=Qi6;

%Main simulation

Tz=[];

Tw1=[];
Tw2=[];
Tw3=[];
Tw4=[];
Tw5=[];
Tw6=[];
Vroom=((6.096+0.0254)*14.6304-3.8576*(7.0104+0.1397))*2.4384+(0.9144+0.05715)*(14.6304*2)*(3.6576+0.2921)/2-(0.9144+0.05715)*3.6575*(7.0104+0.1397)/2;
densityofair=1.225;
Cair=1005;
mroom=Vroom*densityofair;
Qhvac=[];
CoolLoad=0;
batenergy=0;


ACON=0.5
ACOFF=0.5


a=-6.918199274290182e+02;
b=-8.075994730681530;
c=0.600008145473636;
d=72.321032284417700;
e=-0.552014991281195;
f=-0.859544622418754;
np = 3; %prediciton horizon (hrs)
tp = 5; % simulation timestep


for n=1:288-12*3;
    nn=n
    Tamb=T(1,n);
    Tse=Tset(1,n);

    
    stepcost=0;
    totalcost=0;
    
    if n==1;
        initial=init00;
        Qhvac=[Qhvac 4.390166666666667e+02];
    else
        initial=[Tw1(n-1) Tw2(n-1) ];
    end

%     [t,Y]=ode15s(@Network, [0 300],[initial Tamb Q1(n) Q2(n) Q3(n) Q4(n) Q5(n) Q6(n)  -5*Qhvac(n) Qinternal(n)]);

%%building simulation
    X0 = initial';
    Tg = 10;
    u=[0 -cop*Qhvac(n)]';
    w= [Tamb Tg Q1(n) Q2(n) Q3(n) Q4(n) Q5(n) Q6(n) Qinternal(n) ]';
    tic
    Y = SSNetwork (X0,u,w); 
    toc
    Tz=[Tz Y(2)];
    Tz0=Tz;
    yy=Y;
    X0=[Y(1) Y(2)];


%%Controller
%-----------------------------------------------------------------------
%%  GA    
       
Tr=Tz(n);
pc0=2*(a+b*Tamb+c*(Tamb^2)+d*Tr+e*(Tr^2)+f*Tamb*Tr);
    
       
PredictionHorizon=3*60;  %should be devidable to timestep
TimeStep=5;

nvars = PredictionHorizon/TimeStep;    % Number of variables

LB = zeros(1,nvars);   % Lower bound
UB = ones(1,nvars);  % Upper bound
intcon=1:nvars;

ConstraintFunction = @constraint;
ObjectiveFunction = @error_f;
options = gaoptimset;
% gaoptimset.Display= 'iter'
options.TimeLimit=70;
options = gaoptimset(options,'PopulationSize',30);
%options.FitnessLimit=3

% [x,fval] = ga(ObjectiveFunction,nvars,[],[],[],[],LB,UB,ConstraintFunction,intcon,options);
% 


% temperature increase and decrease identification------
if x(1)==1 && n>1
    
    ACON=Tz(n-1)-Tz(n);
    
elseif x(1)==0 && n>1
    
    ACOFF=Tz(n)-Tz(n-1);
    
end

AConoff0=[ACON;ACOFF];
AConoff=[AConoff AConoff0];


% A B C builder ----------------------------------------
A_opt_T=tril(ones(nvars,nvars));
b_opt_T=0;
c_opt_T=0;

for m=1:nvars;

c_opt_T(m) = price(n+m)/500000;              %min c'*x

A_opt_T(m:end,m) = -ACON-ACOFF;                   %A*x <= b
    
b_opt_T(m)=-m*ACOFF-Tz(n)+tsetpoint(1,n)+3.5+oc(n);
b_opt_T(m+nvars)=m*ACOFF+Tz(n)-tsetpoint(1,n)+3.5+oc(n);
end

A_opt_T=[A_opt_T;-A_opt_T];


%optimization
TMIPobjfun=@(x) (x*c_opt_T');
[x,fval] = ga(TMIPobjfun,nvars,A_opt_T,b_opt_T,[],[],LB,UB,[],intcon,options);


xx=[xx x'];
    
%---------------------------------------------------------
Tr=Tz(n);
performancecurve=2*(a+b*Tamb+c*(Tamb^2)+d*Tr+e*(Tr^2)+f*Tamb*Tr);

 if x(1)==1
     
      Qhvac=[Qhvac performancecurve];
 else
      Qhvac=[Qhvac 0];
 end
  
 
%% battery MPC   MIP
batinit=batenergy(n);
c_opt=[];
lb_mip=[];
ub_mip =[];
yidx_mip=[];
A_opt=tril(ones(nvars,nvars));
b_opt = [];                          %A*x <= b

for i=1:nvars;

c_opt = [c_opt price(n+i)/500000];     %min c'*x

if x(i)==1
    lb_mip = [lb_mip;-1];                 %  lb <= x <= ub   lb = [0 0 0 0]'
    ub_mip = [ub_mip;1];         %  lb <= x <= ub   ub = [1 1 1 1]'
    if performancecurve>dischargrate5
        A_opt(i:end,i) = dischargrate5;
    else
        A_opt(i:end,i) = performancecurve;
    end

else
    lb_mip = [lb_mip;0];                 
    ub_mip = [ub_mip;1]; 
    A_opt(i:end,i) = chargrate5;
end


end
A_opt=[A_opt;-A_opt].*5.*60;
b_opt(1:nvars) = batcap-batinit;
b_opt(nvars+1:2*nvars) = batinit;
b_opt;
b_opt=b_opt';
yidx_mip=true(nvars,1);
%x_bat=miprog(c_opt,A_opt,b_opt,A_opt,b_opt,lb_mip,ub_mip,yidx_mip);

batobjfun=@(x) (x*c_opt');
[x_bat,fval_bat] = ga(batobjfun,nvars,A_opt,b_opt,[],[],lb_mip,ub_mip,[],intcon,options);

%A_opt=[A_opt;eye(nvars,nvars);-eye(nvars,nvars)];
%b_opt=[b_opt;ub_mip;lb_mip];



%x_bat=bintprog(c_opt,A_opt,b_opt)
xbat0=[x_bat';fval_bat];
xx_bat=[xx_bat xbat0];

batchargseq=[batchargseq x_bat(1)];


%% battery simulation

if x_bat(1)==1          % battry chargging
    batenergy=[batenergy batenergy(n)+chargrate5*5*60];
    stepcost=chargrate5*p(n)/500000;
    totalcost=stepcost+totalcost;
elseif x_bat(1)==-1         % battry dischargging and AC on
    if performancecurve>dischargrate5
          batenergy=[batenergy batenergy(n)-dischargrate5*5*60];
         stepcost=-dischargrate5*p(n)/500000;
        totalcost=stepcost+totalcost;
    else
          batenergy=[batenergy batenergy(n)-performancecurve*5*60];
        stepcost=-performancecurve*p(n)/500000;
        totalcost=stepcost+totalcost;
    end
else        % battry off
    batenergy=[batenergy batenergy(n)];
end
    

 batenergy;
   %%batery simulation finish---------------------------
 
  %bill 
bill=bill+totalcost+Qhvac(n)*p(n)/500000;


%%
 
%     Tz=[Tz Y(end,7)];
% %     tt = t(end);
% %-----------------   
% %     % MPC: 
% %     % simulation timestep: 5 minutes; 
% %     % prediciton horizon is: 3 hours;
% %     % Object: sum of next 3 hours' total energy consumption
% %     
%     %X0=Y(end,1:7);
% 
%     u0 = 200*ones(1,np*60/tp); % 3 hours 
% %     u = Qhvac(n)*ones(1,np*60/tp);
%     opt = optimoptions('fmincon','algorithm','sqp','display','iter-detailed');
%     tic;
%     AcPower_future = fmincon(@(u)objfcn(u,n, np, tp, T, Q1, Q2, Q3, Q4, Q5, Q6, Qinternal,initial),u0, [], [], [], [],...
%         u_L, u_U,@(u)zonenonlinear(u,n, np, tp, T, Q1, Q2, Q3, Q4, Q5, Q6, Qinternal,initial, Tset),opt);
%     toc;
%     % only the first time-step is implmemented. 
%      Qhvac = [Qhvac,AcPower_future(1)];
  %---------------------- 
    
  
    
    Tw1=[Tw1 Y(1)];
    Tw2=[Tw2 Y(2)];
% 
%     Tw1=[Tw1 Y(end,1)];
%     Tw2=[Tw2 Y(end,2)];
%     Tw3=[Tw3 Y(end,3)];
%     Tw4=[Tw4 Y(end,4)];
%     Tw5=[Tw5 Y(end,5)];
%     Tw6=[Tw6 Y(end,6)];

end

% Hourly load
% AcPower=[];
% for i=1:24;
%     AcPower=[AcPower mean(Qhvac(1+(i-1)*12:i*12))];
% end
AcPower = Qhvac;
end

