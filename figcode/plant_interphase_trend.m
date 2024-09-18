% This program need to be called and run by the 'fig3.m'.
load('K:\workspace\result\plant_interphase_trend.mat')
DATA_all=nan(6,6);
DATA_allsd=nan(6,6);
DATA_allr=nan(6,6);
for i=1:5
for j=i+1:6
tran=sta(sta(:,3)==i+1&sta(:,4)==j+1&sta(:,7)>=10,5);
bootstat=bootstrp(10000,@median,tran);
btci=bootci(10000,@mean,tran);
DATA_all(i,j)=median(bootstat);
DATA_allsd(i,j)=(btci(2)-btci(1))/2;
DATA_allr(i,j)=length(tran(tran<0))/length(tran);
end
end
phlist={'Budburst','Leafing','Flowering','Fruiting','Fruit ripening','Foliar senescence'}';

figure
im = imagesc(flipud(DATA_allr)); 
set(im,'alphadata',~isnan(flipud(DATA_allr)));
hold on
ch = colorbar('eastoutside','xtick',[-1.5 1]) ;
get(gca,'position')
set(gca,'position',get(gca,'position'))
caxis([0 1]); 

ylabel(ch,'Percentage of shortened interval days (%)','fontname','Arial','fontsize',8);
colorcorrelation= jet(60);
colormap(colorcorrelation([6:20,41:50],:));

nn=size(DATA_all,1);
hold on
for i=1:nn+1
plot([i-0.5 i-0.5],[0 nn+1],'-w','linewidth',5.5);
plot([0 nn+1],[i-0.5 i-0.5],'-w','linewidth',5.5);
end
for i=1:nn+1
plot([i-0.5 i-0.5],[0 nn+1],':k','linewidth',0.5);
plot([0 nn+1],[i-0.5 i-0.5],':k','linewidth',0.5);
end
for i=2:nn+1
plot([i+0.5 i+0.5],[nn+2-i-0.5  nn+3-i-0.5 ],'-r','linewidth',2);
if i==nn
    plot([i+0.5 i+0.5],[nn+1-i-0.5  nn+2-i+0.5 ],'-r','linewidth',2);
end
end


addpath('K:\workspace\functions\hatchfill2_r8\');
b = flipud(DATA_all);
bci = flipud(DATA_allsd);
rp=flipud(rp);
c=flipud(DATA_all);

[h l] = find(~isnan(b));
m = horzcat(h,l);
for sm = 1:length(m)
    bsm=round(b(m(sm,1),m(sm,2))*100)/10;
    if bsm<0
        bstr='- ';
    else
        bstr='';
    end
text(m(sm,2),m(sm,1)-0.175,sprintf('%s',strcat([bstr,num2str(abs(bsm))])),'FontSize',8,'fontname','Arial','color','k','horizontalalignment','center')
text(m(sm,2),m(sm,1)+0.175,sprintf('%s',strcat(['± ',num2str(round(bci(m(sm,1),m(sm,2))*100)/10)])),'FontSize',8,'fontname','Arial','color','k','horizontalalignment','center')
hold on
if rp(m(sm,1),m(sm,2))<0.1*nanmax(rp(:)) 
hx=patch('Xdata',[m(sm,2)-0.5 m(sm,2)+0.5 m(sm,2)+0.5 m(sm,2)-0.5],'ydata',[m(sm,1)-0.5 m(sm,1)-0.5 m(sm,1)+0.5 m(sm,1)+0.5],'FaceColor','b','EdgeColor','none','LineWidth',1,'EdgeAlpha',0,'FaceAlpha',0);
hatchfill2(hx,'single','HatchAngle',45,'HatchDensity',30,'HatchColor','k','HatchLineWidth',0.25,'HatchLineStyle','-');
end

end

   
set(gca,'position',[0.2 0.25 0.6 0.6])
box on
axis square
caxis([0 1]); 
colorcorrelation= jet(60);
colormap(colorcorrelation([11:2:20,41:2:50],:));
set(ch,'ytick',(0:0.25:1),'ticklength',0.015,'fontsize',8,'yticklabel',{'0','25','50','75','100'}); 

hold on
xlim([0.5 nn+0.5])
ylim([0.5 nn+0.5])
hold on
box on
plot([0.5 size(DATA_all,1)+0.5],[ size(DATA_all,1)+0.5 0.5],'--k','linewidth',1.5)

for i=2:nn
plot([i-0.5 i+0.5],[nn+3-i-0.5  nn+3-i-0.5],'-r','linewidth',2);
if i==2
    plot([i-0.5-1 i+0.5-1],[nn+3-i-0.5  nn+3-i-0.5],'-r','linewidth',2);
end
end

set(gca,'linewidth',1)
set(gca,'position',[0.25 0.25  0.55*k/6 0.55*k/6]);
 colorr=importdata('K:\workspace\data\MPL_RdYlBu_rgb.txt');
 caxis([0 1]); 
colormap(colorr([10:1:55 73:1:118],1:3)./255);
