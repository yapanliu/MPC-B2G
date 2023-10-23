% Created by Amin 02/16/2016

function [c, ceq] = constraint(x)
 
a=-6.918199274290182e+02;
b=-8.075994730681530;
c0=0.600008145473636;
d=72.321032284417700;
e=-0.552014991281195;
f=-0.859544622418754;

   global oc;
   global X0;
   global w;
   global T;
   global n;
   global nvars
   global yy;
   global tsetpoint;
   global cop;
   global pc0;
   pc00=pc0;
   global batcap;
   global batterys0;
   global chargrate5
global dischargrate5
dischargrate5;
   bterystorageint=batterys0(n);
   
   nvars0=nvars/2;
   Tz00=X0(2);
     c=1:2*nvars;
  
   int=[yy(1) yy(2)]';
   
   for i=n:n+nvars0-1
   
       
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

for j=1:nvars0;
     if oc(n+j)==1;
        c(j)=Tz00(j+1)-tsetpoint(j+n)-0.5;
        c(j+nvars0)=-Tz00(j+1)+tsetpoint(j+n)-0.5;
     else 
        c(j)=Tz00(j+1)-27;
        c(j+nvars0)=-Tz00(j+1)+23;
     end
end

%% battery---------------- %simulate

% batstoragprediction=bterystorageint;

% for k=1:nvars0
%     
% if x(k+nvars/2)==1;         % battry chargging
% batstoragprediction=[batstoragprediction batstoragprediction(k)+chargrate5*5*60]
% 
% elseif x(k+nvars/2)==0;     % battry off
% batstoragprediction=[batstoragprediction batstoragprediction(k)]
%     totalcost=totalcost;
% elseif x(k+nvars/2)==-1 && x(k)==1;    % battry dischargging and AC on
%     if dischargrate5>pc00
%        
%         batstoragprediction=[batstoragprediction batstoragprediction(k)-pc00*5*60];
%     else
%        
%         batstoragprediction=[batstoragprediction batstoragprediction(k)-(dischargrate5)*5*60];
%     end
%     
% elseif x(k+nvars/2)==-1 && x(k)==0;    % battry dischargging and AC off
%         batstoragprediction=[batstoragprediction batstoragprediction(k)-dischargrate5*5*60];
%    
% end
% end


% battery C maker
for l=1:nvars0;
    
%     c(l+2*nvars0)=(batstoragprediction(l+1)-patcap)/100000;
    c(l+2*nvars0)=(sum(x(1+nvars0:l+nvars0))*chargrate5+bterystorageint)-batcap;
    c(l+3*nvars0)=-(sum(x(1+nvars0:l+nvars0))*chargrate5+bterystorageint);
end

% battery----------------
%% batery can not discharge when the AC is off
for m=1:nvars0;
    if x(m)==0 && x(m+nvars0)==-1 
    c(m+4*nvars0)=10;
    else
    c(m+4*nvars0)=-10; 
    end
end

%% batery can not discharg when the AC is off





%     c(1:nvars)=Tz00(2:nvars+1)-tsetpoint(n:n+nvars-1)-0.5-(1-oc(n:n+nvars-1))*2;
%     c(nvars+1:2*nvars)=-Tz00(2:nvars+1)+tsetpoint(n:n+nvars-1)-0.5-(1-oc(n:n+nvars-1))*2;
%   
  ceq = [];
   
   
   
   
   
   
   
   