clear
clc
load('K:\workspace\result\clim_carryover_effect_dailytp_interphase.mat');

sta=cell2mat(stace(2:end,:));
phlist={'Dormancy','Budburst','Leafing','Flowering','Fruiting','Fruit ripening','Foliar senescence'}';
[hc,hli]=xlsread('K:\workspace\data\plant_phen_class.xlsx','Sheet2','A2:H1651');
spc(:,[1 5])=hc(:,[1 8]);

statran=[];
for i=1:length(spc)
    sta(sta(:,2)==spc(i,1),48)=spc(i,4);
end
sta=statran;

nrc=length(phlist);
r=nan(nrc,nrc);
ro=nan(nrc,nrc);
rp=nan(nrc,nrc);
rstan=nan(nrc,nrc);
rtp=nan(nrc,nrc);
rtpsign=nan(nrc,nrc);


tim=unique(sta(:,[3 4 1]),'rows');
for i=1:length(tim)
    [xx,~]=find(sta(:,3)==tim(i,1)&sta(:,4)==tim(i,2)&sta(:,1)==tim(i,3));

    tim(i,5)=nanmedian(sta(xx,17));
    tim(i,9)=nanmedian(sta(xx,19));
    tim(i,6)=nanmedian(sta(xx,37));


    tim(i,7)=nanmedian(sta(xx,17));
    tim(i,8)=nanmedian(abs(sta(xx,21))-abs(sta(xx,23)));

    tim(i,10)=nanmedian(sta(xx,15));
    tim(i,11)=nanmedian(sta(xx,40));
    tim(i,12)=nanmedian(sta(xx,43));

end

for i=1:nrc-1
    for j=i+1:nrc
        [x,y]=find(tim(:,1)==i&tim(:,2)==j);
        rstan(i,j)=length(x);
        if ~isempty(x)&&length(x)>1
            r(i,j)=nanmedian(abs(tim(x,5)));%absolute partial correlation coefficient to preceding phenophase
            rtp(i,j)=nanmedian(abs(tim(x,9)));%absolute partial correlation coefficient to interphase climate
            rtpsign(i,j)=nanmedian(tim(x,9));%partial correlation coefficient to interphase climate
            ro(i,j)=nanmedian(tim(x,7));%
            rp(i,j)=length(tim(x,6));

        end
    end
end

lnn=1;
r(:,lnn)=[];
r(lnn,:)=[];
ro(:,lnn)=[];
ro(lnn,:)=[];
rtp(:,lnn)=[];
rtp(lnn,:)=[];
rtpsign(:,lnn)=[];
rtpsign(lnn,:)=[];
phlist(lnn)=[];

figure
hold on
[x1,y1]=find(ro<0);
[x2,y2]=find(ro>0);
[x3,y3]=find(rtpsign<0);
[x4,y4]=find(rtpsign>0);
h1=viscircles([x2 y2],r(ro>0)*0.5,'color','#0072BD','linewidth',1);
ch1=h1.Children;
set(ch1,'color','#0072BD','marker','_','markersize',1)
h3=viscircles([x1 y1],abs(r(ro<0)*0.5),'color','#0072BD','linewidth',1);
if ~isempty(h3)
    ch3=h3.Children;
    set(ch3,'color','#0072BD','LineStyle',':')
end
h2=viscircles([x4 y4],rtp(rtpsign>0)*0.5,'color','#D95319','linewidth',0.25);
if ~isempty(h2)
    ch2=h2.Children;
    set(ch2,'color','#D95319','marker','_','markersize',0.25)
end
h4=viscircles([x3 y3],abs(rtp(rtpsign<0)*0.5),'color','#D95319','linewidth',0.25);
ch4=h4.Children;
set(ch4,'color','#D95319','LineStyle',':')

nn=size(r,1);
for i=1:nn+1
    plot([i-0.5 i-0.5],[ i-0.5 nn+1],':k','linewidth',0.5);
    plot([0 i-0.5],[i-0.5 i-0.5],':k','linewidth',0.5);
end

k=length(phlist);
rp(:,lnn)=[];
rp(lnn,:)=[];
[h l] = find(~isnan(rp));
m = horzcat(h,l);
rn=rp;
addpath('K:\workspace\functions\hatchfill2_r8\');
for sm = 1:length(m)
    text(m(sm,1)-0.4,m(sm,2)+0.35,sprintf('%s',strcat([num2str(rp(m(sm,1),m(sm,2)))])),'FontSize',6,'fontname','Arial','color','k')
    hold on
    if rp(m(sm,1),m(sm,2))<0.1*nanmax(rp(:))%20 %
        hx=patch('Xdata',[m(sm,1)-0.5 m(sm,1)+0.5 m(sm,1)+0.5 m(sm,1)-0.5],'ydata',[m(sm,2)-0.5 m(sm,2)-0.5 m(sm,2)+0.5 m(sm,2)+0.5],'FaceColor','b','EdgeColor','none','LineWidth',1,'EdgeAlpha',0,'FaceAlpha',0);
        hatchfill2(hx,'single','HatchAngle',-45,'HatchDensity',30,'HatchColor','k','HatchLineWidth',0.25,'HatchLineStyle','-');
    end
end

axis square
xlim([0.5 k+0.5])
ylim([0.5 k+0.5])
set(gca,'xtick',[1:1:k],'XTickLabel',phlist,'fontname','Arial','fontsize',8,'XTickLabelRotation',45)
set(gca,'ytick',[1:1:k],'yTickLabel',phlist,'fontname','Arial','fontsize',8)
hold on
box on
plot([0.5 k+0.5],[0.5 k+0.5],'--k','linewidth',1.5)
for i=1:nn
    plot([nn+1-i+0.5 nn+1-i+0.5],[nn+3-i-0.5  nn+4-i-0.5 ],'-r','linewidth',2);
    if i==nn
        plot([nn-i+0.5 nn-i+0.5],[nn+1-i-0.5  nn+3-i-0.5 ],'-r','linewidth',2);
    end
end
for i=1:nn
    plot([nn-i-0.5 nn-i+0.5],[nn+2-i-0.5  nn+2-i-0.5],'-r','linewidth',2);
    if i==1
        plot([nn+1-i-0.5 nn+1-i+0.5],[nn+2-i-0.5  nn+2-i-0.5],'-r','linewidth',2);
    end
end


set(gca,'linewidth',1)
set(gca,'position',[0.25 0.25 0.55*k/6 0.55*k/6])

colorr=importdata('K:\workspace\data\prec_seq.txt');
caxis([0 1]);
colormap(colorr(40:1:215,2:4)./255);

addpath 'K:\workspace\figcode\';
plant_interphase_trend