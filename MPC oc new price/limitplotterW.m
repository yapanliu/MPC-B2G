

Tlimitupw=0;
Tlimitdownw=0;

for j=1:size(tsetpoint');
     
        Tlimitdownw(j)=tsetpoint(j)-0.5;
        Tlimitupw(j)=+tsetpoint(j)+0.5;
     
end

hold on;
plot(Tlimitdownw);
plot(Tlimitupw);


sum(AcPowerBB)*5/60
sum(AcPowerMPCwE)*5/60
sum(AcPowerMPC)*5/60
