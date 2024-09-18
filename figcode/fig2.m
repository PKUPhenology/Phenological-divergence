clear all
clc
phlist={'Dormancy','Budburst','Leafing','Flowering','Fruiting','Fruit ripening','Foliar senescence'}';
ssta=importdata('K:\workspace\result\trend_estimation\plant_site_species_level_LMM_trend.mat');

% tims=ssta;
tims=ssta(ssta(:,7)>0,:);%observation 1 professional 2 citizen
tims(isnan(tims(:,5)),:)=[];
tims(:,5)=tims(:,5)*10;

color = jet(7);
color(5,:)=[];
color1=flipud([204 85 0;204 85 0;255 170 130;255 170 130;227 160 64;227 160 64; 125 203 91;125 203 91;7 153 153;7 153 153;0 175 184;0 175 184;]./255);%plant phen
fda1=xlsread('K:\workspace\result\trend_estimation.xlsx','Sheet1','B3:AK8');
fda2=xlsread('K:\workspace\result\trend_estimation.xlsx','Sheet1','BM3:BO8');
fda=[fda1 fda2];
k1=6;
w=[0.6 0.8 1 0.3 0.8 0.7];%all [0.5 0.8 1 0.2 0.8 0.7];%citizen [0.7 0.7 1 0.15 0.6 0.7];%professional  
figure
for i=1:6
tran=tims(tims(:,3)==8-i,:);
nn(i)=length(tran(~isnan(tran(:,5))&abs(tran(:,5))<=80,5));
if i==1
    pos = [0.25 0.9-0.13*w(7-i)-0.04 0.45 0.13*w(7-i)+0.04];%0.075;0.8/k1
else 
pos = [0.25 0.9-0.13*sum(w(7-i:6))-0.04*i 0.45 0.13*w(7-i)+0.04];%0.075;0.8/k1

end
axes('position',pos,'linewidth',1.5)
yr=[5 10 20 30];
lstyle={'-','--','-.',':'};
for k=1:4
data_new = tran(tran(:,4)>=yr(k),5);
x_f =-30:0.1:30;
if ~isempty(data_new)
[y,x_values]=ksdensity(data_new,x_f);
if k==1
    y1=y;
end
if k==2
    ysum=sum(y(x_values>-15&x_values<15))*0.1;
end
yh=hist(data_new,-100:1:100);
yw(k,:)=smooth(yh,5);
[vi,vloc]=max(yw(k,:));
ryw(k)=yw(k,vloc)/yw(1,vloc);
    [mm,mloc]=max(y);
Wy=y*ryw(k)*y1(mloc)/mm;

if k==1
    patch([x_values(1) x_values x_values(end)],[0 Wy 0]*w(7-i),color1(2*(7-i)-1,:),'edgecolor','k','FaceAlpha',0.25*k)
    
    hold on
Wy1=Wy;
else
    patch([x_values(1) x_values x_values(end)],[0 Wy 0]*w(7-i),color1(2*(7-i)-1,:),'edgecolor','none','FaceAlpha',0.25*k)
    hold on
  text(-29,(max(Wy1)*w(7-i)+0.014)/2,strcat([num2str(round(ysum*100,1)),'%']),'fontname','Arial','fontsize',8)
end
end
end
plot([0 0],[0 ceil(0.085*w(7-i)*1000)/1000+0.05],'-k','linewidth',0.75)
errorbar(fda(7-i,28),max(Wy1)*w(7-i)+0.016,[],[],[fda(7-i,28)-fda(7-i,29)],[fda(7-i,30)-fda(7-i,28)],'o','markersize',2,'color',color(6,:),'CapSize',2);
errorbar(fda(7-i,16),max(Wy1)*w(7-i)+0.012,[],[],[fda(7-i,16)-fda(7-i,17)],[fda(7-i,18)-fda(7-i,16)],'.','markersize',8.5,'color',color(5,:),'CapSize',2);
errorbar(fda(7-i,37),max(Wy1)*w(7-i)+0.008,[],[],[fda(7-i,37)-fda(7-i,38)],[fda(7-i,39)-fda(7-i,37)],'o','markersize',2,'color',color(1,:),'CapSize',2);
errorbar(fda(7-i,4),max(Wy1)*w(7-i)+0.004,[],[],[fda(7-i,4)-fda(7-i,5)],[fda(7-i,6)-fda(7-i,4)],'.','markersize',8.5,'color',color(2,:),'CapSize',2);
if i==6
    set(gca,'xtick',[-30:10:30],'xticklabel',[-30:10:30],'ytick',[],'fontname','Arial','fontsize',8)%[ceil(0.085*w(7-i)*1000)/1000+0.045]/2,'YTickLabel',phlist(8-i),
    xlabel('Temporal trend (d/decade)','fontname','Arial','fontsize',8)
    set(gca,'color','none','fontname','Arial','fontsize',8)    
else
set(gca,'xtick',[],'XTickLabel',[],'ytick',[],'fontname','Arial','fontsize',8)%[ceil(0.085*w(7-i)*1000)/1000+0.045]/2,'YTickLabel',phlist(8-i),
set(gca,'color','none','fontname','Arial','fontsize',8)
end
text(-29,max(Wy1)*w(7-i)+0.014,phlist(8-i),'fontname','Arial','fontsize',8,'HorizontalAlignment','left')

text(29.2,(max(Wy1)*w(7-i)+0.014)/2,strcat(['{\it n} = ',num2str(nn(i))]),'fontname','Arial','fontsize',8,'HorizontalAlignment','right')

set(gca,'linewidth',0.75)
ylim([0 max(Wy1)*w(7-i)+0.02])
xlim([-30 30])

    box off
end