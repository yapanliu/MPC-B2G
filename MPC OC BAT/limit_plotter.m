


Tlimitup=0;
Tlimitdown=0;

for j=1:size(tsetpoint');
     if oc(j)==1;
        Tlimitdown(j)=tsetpoint(j)-0.5;
        Tlimitup(j)=+tsetpoint(j)+0.5;
     else 
        Tlimitdown(j)=23;
        Tlimitup(j)=27;
     end
end

hold on;
plot(Tlimitdown);
plot(Tlimitup);

