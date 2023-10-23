% Created by Amin 04/26/2016
function [c, ceq] = constraint(x)


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
Twhsim=[];



for i=1:nvars;
Twhsim(i)=whinit+(Qelement*x(i)-(Twh(n)-Tenv(n))/totalR-valvegain*WHusage(n+i)*(Twh(n)-Tenv(n)))/mc*TimeStep*60;

end


c=1:2*nvars;


for j=1:nvars;
     if oc(n+j)==1;
        c(j)=Twhsim(j)-Tsetwh-3;
        c(j+nvars)=-Twhsim(j)+Tsetwh-3;
     else 
        c(j)=Twhsim(j)-Tsetwh-10;
        c(j+nvars)=-Twhsim(j)+Tsetwh-10;
     end
end


ceq = [];
   
   
   
   
   
   
   
   