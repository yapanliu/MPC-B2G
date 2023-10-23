
Tlimitup=0;
Tlimitdown=0;

for j=1:size(tsetpoint');
     if oc(j)==1;
        Tlimitdown(j)=(Tset(j)-32)*(5/9)-0.5;
        Tlimitup(j)=+(Tset(j)-32)*(5/9)+0.5;
     else 
        Tlimitdown(j)=23;
        Tlimitup(j)=27;
     end
end


Tlimitupw=0;
Tlimitdownw=0;

for j=1:size(tsetpoint');
     
        Tlimitdownw(j)=tsetpoint(j)-0.5;
        Tlimitupw(j)=+tsetpoint(j)+0.5;
     
end


figure
subplot(2,2,1);
hold on;
plot(TzoneMPCw,'b','LineWidth',1,'Color',[0.152941182255745 0.227450981736183 0.372549027204514]);
plot((Tset-32)*(5/9),'LineWidth',1,'Color',[0.24705882370472 0.24705882370472 0.24705882370472]);
plot(Tlimitdownw,'LineWidth',1,'LineWidth',1,'LineStyle','--','Color',[0 0 0]);
plot(Tlimitupw,'LineWidth',1,'LineWidth',1,'LineStyle','--','Color',[0 0 0]);
hold off;

xlabel('Time','HorizontalAlignment','center','FontSize',14);
ylabel('C','HorizontalAlignment','center','FontSize',14);


subplot(2,2,2);

xlabel('Time (Five Minutes)','FontSize',14,'color','black');
ylabel('W','FontSize',16,'color','black');


hold on;
plot(TzoneMPC,'b','LineWidth',1,'Color',[0.152941182255745 0.227450981736183 0.372549027204514]);
plot((Tset-32)*(5/9),'LineWidth',1,'Color',[0.24705882370472 0.24705882370472 0.24705882370472]);
plot(oc/4+22.5,'r','LineWidth',1,'Color',[0.635294139385223 0.0784313753247261 0.184313729405403],'LineStyle','-');
plot(Tlimitdown,'LineWidth',1,'LineStyle','--','Color',[0 0 0]);
plot(Tlimitup,'LineWidth',1,'LineStyle','--','Color',[0 0 0]);

hold off;

xlabel('Time (Five Minutes)','FontSize',14,'color','black');
ylabel('C','FontSize',16,'color','black');


subplot(2,2,3);

hold on;

plot(Tlimitdownw,'LineWidth',1,'LineStyle','--','Color',[0 0 0]);
plot(Tlimitupw,'LineWidth',1,'LineStyle','--','Color',[0 0 0]);

plot(TzoneBB,'b','LineWidth',1,'Color',[0.152941182255745 0.227450981736183 0.372549027204514]);
plot((Tset-32)*(5/9),'LineWidth',1,'Color',[0.24705882370472 0.24705882370472 0.24705882370472]);
hold off;

xlabel('Time (Five Minute)','FontSize',14,'color','black');
ylabel('C','FontSize',14,'color','black');


hold off;
xlabel('Time (Five Minute)','FontSize',14,'color','black');
ylabel('C','FontSize',14,'color','black');


subplot(2,2,4);

xlabel('Time (Five Minute)','FontSize',14,'color','black');
ylabel('W','FontSize',14,'color','black');


hold on;
plot(TzoneBBS,'b','LineWidth',1,'Color',[0.152941182255745 0.227450981736183 0.372549027204514]);
plot((Tset-32)*(5/9),'LineWidth',1,'Color',[0.24705882370472 0.24705882370472 0.24705882370472]);
plot(Tlimitdown,'LineWidth',1,'LineStyle','--','Color',[0 0 0]);
plot(Tlimitup,'LineWidth',1,'LineStyle','--','Color',[0 0 0]);
plot(oc/4+22.5,'r','LineWidth',1,'Color',[0.635294139385223 0.0784313753247261 0.184313729405403],'LineStyle','-');

hold off;

xlabel('Time (Five Minute)','FontSize',14,'color','black');
ylabel('C','FontSize',14,'color','black');
