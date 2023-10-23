

Tlimitup=0;
Tlimitdown=0;

for j=1:size(tsetpoint');
     
        Tlimitdown(j)=tsetpoint(j)-0.5;
        Tlimitup(j)=+tsetpoint(j)+0.5;
     
end

hold on;
plot(Tlimitdown);
plot(Tlimitup);


sum(AcPowerBB)*5/60
sum(AcPowerMPCwE)*5/60
sum(AcPowerMPC)*5/60
