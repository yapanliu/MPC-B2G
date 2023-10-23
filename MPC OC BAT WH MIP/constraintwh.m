% Created by Amin 04/26/2016
function [c, ceq] = constraint(x)

global WHlbT;
global n
global Twh;
global Tenv;
global totalR;
global valvegain;
global WHusage;
global mc;
global TimeStep;
global Qelement;
global whinit;
global nvars;
global oc
global Tsetwh
Twhsim=whinit;



for i=1:nvars;
    
Twhsim(i+1)=Twhsim(i)+(Qelement*x(i)-(Twh(n)-Tenv(n))/totalR-valvegain*WHusage(n+i)*(Twh(n)-Tenv(n)))/mc*TimeStep*60;

end


c=1:2*nvars;


for j=1:nvars;
     if oc(n+j)==1;
        c(j)=Twhsim(j+1)-Tsetwh-5;
        c(j+nvars)=-Twhsim(j+1)+Tsetwh-5-(1-WHlbT(n+j))*30;
     else 
        c(j)=Twhsim(j+1)-Tsetwh-5;
        c(j+nvars)=-Twhsim(j+1)+Tsetwh-5-(1-WHlbT(n+j))*30;
     end
end


ceq = [];
   
   
   
   
   
   
   
   