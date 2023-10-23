% Created by Amin 02/16/2016

function [c, ceq] = constraint(x)
 

   global oc;
   global X0;
   global w;
   global pc0;
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
     if oc(n+j)==1;
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
   
   
   
   
   
   
   
   