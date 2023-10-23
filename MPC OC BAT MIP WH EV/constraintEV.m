% Created by Amin 04/26/2016
function [c, ceq] = constraint(x)


global TimeStep;

global nvars;

global ConsumtionGain;
global EVusage;
global Cev;
global ChargW
global SOC;
global SOClb;
global n;
global EVconected;
SOCsim=SOC(n);

for i=1:nvars;
    SOCsim(i+1)=SOCsim(i)+(ChargW*x(i)-ConsumtionGain*EVusage(n+1))/Cev*TimeStep*60;
end


c=1:2*nvars;


for j=1:nvars;
        c(j)=SOCsim(j+1)-0.9-0.01;
        c(j+nvars)=-SOCsim(j+1)+0.9-(0.9-SOClb(n+j));
end


ceq = [];
   
   
   
   
   
   
   
   