function y = SSNetwork(x,u,w)
%http://www.plasticsportal.net/wa/plasticsEU~ro_RO/function/conversions:/publish/common/upload/technical_journals/plastics_trendreports/Rigid_polystyrene_foam.pdf
%http://en.wikipedia.org/wiki/Structural_insulated_panel
%http://www.icc-es.org/Reports/pdf_files/load_file.cfm?file_type=pdf&file_name=ESR-1844.pdf
%http://www.andersenwindows.com/technical-documents/tdoctype/performance/0#w=*&af=tdoctype%3aperformance
%http://bigladdersoftware.com/epx/docs/8-1/engineering-reference/page-026.html
y=zeros(2,1);

Anorthwindow=1.2192*(0.9144+0.047625)*2+0.9144*0.6096*3+0.9144*1.2192*2;
Anorthdoor=(1.8288+0.254)*(0.9144+0.0508);
Anorth=2.4384*(7.3152+0.1651)+(7.0104+0.1397)*(3.3528+0.05715)-Anorthwindow-Anorthdoor;
Asouthwindow=1.2192*0.9144+3*1.2192*0.6096+0.6096*(0.6096+0.1524);
Asouthdoor=(1.8288+0.254)*(0.6096+0.1524);
Asouth=(2.4384+0.2413)*14.6304-Asouthwindow-Asouthdoor;
Aeastwindow=1.2192*0.9144;
Aeastdoor=(1.8288+0.254)*(0.9144+0.0508);
Aeast=(3.6576+0.1397)*(2.4384+0.2413)-((1.2192+0.1397)*(4.572+0.2286))/2-((0.9144+0.2032)*(3.9624+0.0762))/2-Aeastwindow-Aeastdoor;
Awestwindow=0.6096*(0.3048+0.1524)+1.2192*(0.3048+0.1524);
Awest=(3.6576+0.1397)*(2.4384+0.2413)-((1.2192+0.1397)*(4.572+0.2286))/2-((0.9144+0.2032)*(3.9624+0.0762))/2-Awestwindow;
Afloor=(6.096+0.0254)*14.6304-3.8576*(7.0104+0.1397);
Aroof=(6.096+0.0254)*14.6304-3.8576*(7.0104+0.1397);

%Capacity Caculatin
cSIP=1500*25*0.1651;%
cgypsum=1090*9.8*0.0127;
croof=1500*25*0.2667+cgypsum;
cwall=cSIP+cgypsum;
cfloor=0.15*2240*900;
csoil=100*1500*800;
%Each wall capacity
c1=Aeast*cwall;
c2=Awest*cwall;
c3=Asouth*cwall;
c4=Anorth*cwall;
c5=Aroof*croof*(17)^0.5/4;%Caculate roof capacity with an angel
c6=Afloor*(cfloor+csoil);
csurface=0.01*(c1+c2+c3+c4+c5+c6);

%Caculatin of resistance
Rwin=1/5.9;
Rdoor=1/1.53;

RSIP=26;
Rgypsum=0.079;
rfloor=0.077;
rsoil=1/(1.3/100);
Rwall=RSIP+Rgypsum;
Rwall1=1/(1/(Rwall/Aeast)+1/(Rwin/Aeastwindow)+1/(Rdoor/Aeastdoor));%Resistance for east wall
Rwall2=1/(1/(Rwall/Awest)+1/(Rwin/Awestwindow));%R for west wall
Rwall3=1/(1/(Rwall/Anorth)+1/(Rwin/Anorthwindow)+1/(Rdoor/Anorthdoor));%R for north wall
Rwall4=1/(1/(Rwall/Asouth)+1/(Rwin/Asouthwindow)+1/(Rdoor/Asouthwindow));%R for south wall
Rroof=rfloor/(Aroof*(17)^0.5/4);%R for roof
Rfloor=(rfloor+rsoil)/Afloor;%R for floor
Rsurface=1/(1/Rwall1+1/Rwall2+1/Rwall3+1/Rwall4+1/Rroof);

Rsurf=1/8.29;
% Rsurf1=Rsurf/Aeast;
% Rw11=Rsurf1+Rwall1/2;
% Rw12=Rsurf1+Rwall1/2;
% 
% Rsurf2=Rsurf/Awest;
% Rw21=Rsurf2+Rwall2/2;
% Rw22=Rsurf2+Rwall2/2;
% 
% Rsurf3=Rsurf/Anorth;
% Rw31=Rsurf3+Rwall3/2;
% Rw32=Rsurf3+Rwall3/2;
% 
% Rsurf4=Rsurf/Asouth;
% Rw41=Rsurf4+Rwall4/2;
% Rw42=Rsurf4+Rwall4/2;
% 
% Rsurf5=Rsurf/Aroof;
% Rw51=Rsurf5+Rroof/2;
% Rw52=Rsurf5+Rroof/2;
Rhouse11=Rsurf/(Aeast+Awest+Anorth+Asouth+Aroof)+Rsurface/2;
Rhouse12=Rsurf/(Aeast+Awest+Anorth+Asouth+Aroof)+Rsurface/2;

Rsurf6=Rsurf/Afloor;
Rw61=Rsurf6+Rfloor/2;
Rw62=Rfloor/2+Rsurf6;

%Infiltration resistant
Vroom=((6.096+0.0254)*14.6304-3.8576*(7.0104+0.1397))*2.4384+(0.9144+0.05715)*(14.6304*2)*(3.6576+0.2921)/2-(0.9144+0.05715)*3.6575*(7.0104+0.1397)/2;
densityofair=1.225;
Cair=1005;
UAinf=0.01*Vroom*densityofair*Cair/3600;
Rinf=1/UAinf;

%2R1C 
mroom=Vroom*densityofair;
c7=10*mroom*Cair;%need to esitimate internal C
Tg=10;%ground T of SA

% x should be [23 23]';
A=[ 1-1/(Rhouse11*csurface)-1/(Rhouse12*csurface) 1/(Rhouse12*csurface);
    1/(Rhouse12*c7) 1+(-1/Rhouse12-1/Rinf)/c7];
% u should be  u=[0 -5*Qhvac(n)]'
Bu=1/c7;
% w should be  [Tamb Tg(is a constatnt 10) Q1(n) Q2(n) Q3(n) Q4(n) Q5(n) Q6(n) Qinternal(n) ]' in ode solver line
Bw=[1/(Rhouse11*csurface) 0 1/csurface 1/csurface 1/csurface 1/csurface 1/csurface 1/csurface 0;
   1/(Rinf*c7) 0 0 0 0 0 0 0 1/c7];
for i=1:300;
y=A*x + Bu*u+Bw*w;
x=y;
end
y=y';
end
