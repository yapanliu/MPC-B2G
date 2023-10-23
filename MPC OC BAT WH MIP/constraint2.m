% Created by Amin 02/16/2016

function [c, ceq] = constraint(x)
 
a=-6.918199274290182e+02;
b=-8.075994730681530;
c0=0.600008145473636;
d=72.321032284417700;
e=-0.552014991281195;
f=-0.859544622418754;

   global oc2;
   global X0;
   global w;
   global T;
   global n;
   global nvars;
   global yy;
   global tsetpoint;
   global cop;
   Tz00=X0(2);
     c=1:2*nvars;
  
   int=[yy(1) yy(2)]';
   
   for i=n:n+nvars-1
   
       
   if x(i-n+1)==1  
         
        Tr=Tz00(i-n+1);
        Tamb=T(i);
        pc0=2*(a+b*Tamb+c0*(Tamb^2)+d*Tr+e*(Tr^2)+f*Tamb*Tr);
        u=[0 -cop*pc0]';
        Y = SSNetwork (int,u,w);
        
   else
       u=[0 0]';
   Y = SSNetwork (int,u,w);
   
   end
   
   int=[Y(1) Y(2)]';
   Tz00=[Tz00 Y(2)];
   
   end

for j=1:nvars;
     if oc2(n+j)==1;
        c(j)=Tz00(j+1)-tsetpoint(j+n)-0.5;
        c(j+nvars)=-Tz00(j+1)+tsetpoint(j+n)-0.5;
     else 
        c(j)=Tz00(j+1)-27;
        c(j+nvars)=-Tz00(j+1)+23;
     end
end

        
%     c(1:nvars)=Tz00(2:nvars+1)-tsetpoint(n:n+nvars-1)-0.5-(1-oc(n:n+nvars-1))*2;
%     c(nvars+1:2*nvars)=-Tz00(2:nvars+1)+tsetpoint(n:n+nvars-1)-0.5-(1-oc(n:n+nvars-1))*2;
%   
  ceq = [];
   
   
   
   
   
   
   
   