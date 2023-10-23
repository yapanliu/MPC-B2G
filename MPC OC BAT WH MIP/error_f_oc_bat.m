function y = error_f(x)

global chargrate5
global dischargrate5
global n;
global p;
global nvars;
global pc0;
global batterys0;


pc00=pc0;                %performance
pp=p;                  %price
t=n;
totalcost=0;
stepcost=0;
for i=1:nvars/2;

    
   % HVAC cost--------------------------
if x(i)==1;

stepcost=pc00*pp(t+i)/500000;
totalcost=stepcost+totalcost;
else
    totalcost=totalcost;
end;


% battery cost and revenue---------------
if x(i+nvars/2)==1;         % battry chargging
stepcost=chargrate5*pp(t+i)/500000;
totalcost=stepcost+totalcost;


elseif x(i+nvars/2)==0;     % battry off
totalcost=totalcost;
    
elseif x(i+nvars/2)==-1 && x(i)==1;    % battry dischargging and AC on
    if dischargrate5>pc00
        stepcost=-pc00*pp(t+i)/500000;
        totalcost=stepcost+totalcost;
    else
        stepcost=-dischargrate5*pp(t+i)/500000;
        totalcost=stepcost+totalcost;
    end
    
elseif x(i+nvars/2)==-1 && x(i)==0;    % battry dischargging and AC off
    totalcost=totalcost+10000;
    
end



% end battry cost ond income------------

    
end

%%penalty on wrong local optimal solution
if x(1+nvars/2)==-1 && batterys0(n)<1
    totalcost=totalcost+10000;
end


%%end penalty on wrong local optimal solution
y=totalcost;

