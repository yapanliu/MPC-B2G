function y = error_f(x)


global n;
global p;
global nvars;
global pc0;
pc00=pc0;
pp=p;
t=n;
totalcost=0;
stepcost=0;
for i=1:nvars;

if x(i)==1;

stepcost=pc00*pp(t+i)/500000;
totalcost=stepcost+totalcost;
else
    totalcost=totalcost;
end;


end
y=totalcost;

