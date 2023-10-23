% Created by Bing Dong 12/21/2015
% bing.dong@utsa.edu

function [AcPower, Tz] = SIPMPCLoad(Qinternal,T,IDIRW,IDIRE,IDIRN,IDIRS,IDIR,Tset,rnw,north,rsw,south,rew,east,rww,west,floor,roof)

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
global cop;
global oc;
global init00;


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

a=-6.918199274290182e+02;
b=-8.075994730681530;
c=0.600008145473636;
d=72.321032284417700;
e=-0.552014991281195;
f=-0.859544622418754;
np = 3; %prediciton horizon (hrs)
tp = 5; % simulation timestep


for n=1:288-12*3;
    Tamb=T(1,n);
    Tse=Tset(1,n);
    
    if n==1;
        initial=init00;
        Qhvac=[Qhvac 4.390166666666667e+02];
    else
        initial=[Tw1(n-1) Tw2(n-1) ];
    end

%     [t,Y]=ode15s(@Network, [0 300],[initial Tamb Q1(n) Q2(n) Q3(n) Q4(n) Q5(n) Q6(n)  -5*Qhvac(n) Qinternal(n)]);

    X0 = initial';
    Tg = 10;
    u=[0 -cop*Qhvac(n)]';
    w= [Tamb Tg Q1(n) Q2(n) Q3(n) Q4(n) Q5(n) Q6(n) Qinternal(n) ]';
    tic
    Y = SSNetwork (X0,u,w); 
    toc
    Tz=[Tz Y(2)];
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
    
    if n>1
        if Tz(n-1)<=Tz(n) && oc(n)==1
            if Tz(n)>(Tse-32)*(5/9)+0.5
                initial=Y(end,1:2);
                %Network(tt,[initial Tamb Q1(n) Q2(n) Q3(n) Q4(n) Q5(n) Q6(n) -5*Qhvac(n) Qinternal(n)]);
                Tr=Tz(n);
                performancecurve=2*(a+b*Tamb+c*(Tamb^2)+d*Tr+e*(Tr^2)+f*Tamb*Tr);
                Qhvac=[Qhvac performancecurve];
            else
                Qhvac=[Qhvac 0];
            end
        elseif Tz(n-1)>Tz(n) && oc(n)==1
            if Tz(n)>(Tse-32)*(5/9)-0.5
                initial=Y(end,1:2);
                %Network(tt,[initial Tamb Q1(n) Q2(n) Q3(n) Q4(n) Q5(n) Q6(n) -5*Qhvac(n) Qinternal(n)]);
                Tr=Tz(n);
                performancecurve=2*(a+b*Tamb+c*(Tamb^2)+d*Tr+e*(Tr^2)+f*Tamb*Tr);
                Qhvac=[Qhvac performancecurve];
            else
                Qhvac=[Qhvac 0];
            end
            
            
        elseif Tz(n-1)<=Tz(n) && oc(n)==0
            if Tz(n)>(Tse-32)*(5/9)+0.5+1.5
                initial=Y(end,1:2);
                %Network(tt,[initial Tamb Q1(n) Q2(n) Q3(n) Q4(n) Q5(n) Q6(n) -5*Qhvac(n) Qinternal(n)]);
                Tr=Tz(n);
                performancecurve=2*(a+b*Tamb+c*(Tamb^2)+d*Tr+e*(Tr^2)+f*Tamb*Tr);
                Qhvac=[Qhvac performancecurve];
            else
                Qhvac=[Qhvac 0];
            end
        elseif Tz(n-1)>Tz(n) && oc(n)==0
            if Tz(n)>(Tse-32)*(5/9)-0.5+1.5
                initial=Y(end,1:2);
                %Network(tt,[initial Tamb Q1(n) Q2(n) Q3(n) Q4(n) Q5(n) Q6(n) -5*Qhvac(n) Qinternal(n)]);
                Tr=Tz(n);
                performancecurve=2*(a+b*Tamb+c*(Tamb^2)+d*Tr+e*(Tr^2)+f*Tamb*Tr);
                Qhvac=[Qhvac performancecurve];
            else
                Qhvac=[Qhvac 0];
            end
            
            
            
            
        else
            Qhvac=[Qhvac 0];
        end
    else
        if Tz(n)>(Tse-32)*(5/9)+1 && oc(n)==1
            initial=Y(end,1:2);
            %Network(tt,[initial Tamb Q1(n) Q2(n) Q3(n) Q4(n) Q5(n) Q6(n) -5*Qhvac(n) Qinternal(n)]);
            Tr=Tz(n);
            performancecurve=2*(a+b*Tamb+c*(Tamb^2)+d*Tr+e*(Tr^2)+f*Tamb*Tr);
            Qhvac=[Qhvac performancecurve];
        else
            Qhvac=[Qhvac 0];
        end
    end
    
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

