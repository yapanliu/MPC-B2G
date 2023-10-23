% Created by Amin 02/16/2016

function [c, ceq] = constraint(x)
 

 
   global X0;
   global w;
   global pc0;
   global n;
   global nvars;
   global yy;
      global tsetpoint;
   Tz00=X0(2);
     c=1:2*nvars;
  
   int=[yy(1) yy(2)]';
   
   for i=n:n+nvars-1
   
       
   if x(i-n+1)==1    
        u=[0 -5*pc0]';
        Y = SSNetwork (int,u,w);
        
   else
       u=[0 0]';
   Y = SSNetwork (int,u,w);
   
   end
   
   int=[Y(1) Y(2)]';
   Tz00=[Tz00 Y(2)];
   
   end

   
  c(1:nvars)=Tz00(2:nvars+1)-tsetpoint(n:n+nvars-1)-0.7;
    c(nvars+1:2*nvars)=-Tz00(2:nvars+1)+tsetpoint(n:n+nvars-1)-0.7;
  
  ceq = [];
   
   
   
   
   
   
   
   