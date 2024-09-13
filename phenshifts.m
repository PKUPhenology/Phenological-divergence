%% This programme is for estimating the temporal trends for each phenphases of plants.
clear all
clc

%% import data
load 'K:\workspace\data\plant_phen_deduplicateddata_.mat';% variables: 'dataset' and 'dscode'- the dataset name and ID;'phlist' and 'phcode'-phenology event name and ID;'splist' and 'spcode'- species name and ID; 'phenstan'-data; 'stlist'- site ID and locations(row and column of the pixel that the site locates in).
dstype=xlsread('K:\workspace\plantnetworkclass.xlsx','Sheet1','B2:C11');
dasite=unique(phenstan(:,1:2),'rows');
for i=1:size(dstype)
dasite(dasite(:,1)==dstype(i,1),3)=dstype(i,2);
end

%% classify the phenological envent into phenophases
[phc,phli]=xlsread('K:\workspace\plantphenclass.xlsx','plant','I2:O254');% phc-phenological event ID and phenophase ID; phli-name of phenological event.
for i=1:length(phlist)
phcode(i,2)=phc(strcmp(phli(:,1),phlist(i))==1,6);
end

% 
for i=1:length(phcode)
    phenstan(phenstan(:,4)==phc(i,1),7)=phcode(i,2);% columns 1-7 represent the dataset ID, site ID,species ID, phenological event ID, year, phenological date(day of year)and phenophase ID, respectively.
end
% % for i=1:length(stlist)
% %     phenstan(phenstan(:,2)==stlist(i,1),8)=stlist(i,2);
% %     phenstan(phenstan(:,2)==stlist(i,1),9)=stlist(i,3);
% %     phenstan(phenstan(:,2)==dasite(i,2),10)=dasitesort(i,3);
% % end
phenstan(:,8)=nan;
for i=1:length(stlist)
    phenstan(x,9)=stlist(i,2);% the row of the grid that the site locates in
    phenstan(x,10)=stlist(i,3);% the column of the grid that the site locates in
end

phenclas=unique(phcode(:,2));

%% estimate the linear trend using linear mixed effect models at site-species level
ssta=[];
for pc=1:length(phenclas)
    pcdata=phenstan(phenstan(:,7)==phenclas(pc),:);%extracting the data of the pc-th phenophase
    sstim=unique(pcdata(:,[2 3]),'rows');% the time series for the referred phenophase
    sstim(:,3:6)=nan;
    for i=1:size(sstim,1)
        trandata=pcdata(pcdata(:,2)==sstim(i,1)&pcdata(:,3)==sstim(i,2),[6 5 4]);%Three columns represent the phendate, year and phenological event ID, respectively.
        sstim(i,3:4)=[phenclas(pc) length(unique(trandata(:,2)))];
        if sstim(i,4)>=5&&std(trandata(:,1))>0 % the time series over 5 years in length and having interannual variations were considered.
            disp(['Processing the ',num2str(pc),'event and ',num2str(i),'ss time series;'])
        dat = array2table(trandata,'VariableNames',{'y','year','pheventID'});
        dat.pheventID= nominal(dat.pheventID);
        lme = fitlme(dat,'y~year+(1|pheventID)');
        sstim(i,5:6)=[lme.Coefficients.Estimate(2) coefTest(lme)];
        end
    end
    ssta=[ssta;sstim];
end
save('K:\workspace\result\plant_site_species_level_LMMtrend.mat','ssta');

%% estimate the linear trend using linear mixed effect models at site-level
sta=[];
for pc=1:length(phenclas)
    pcdata=phenstan(phenstan(:,7)==phenclas(pc),:);
    stim=unique(pcdata(:,2),'rows');
    stim(:,2:5)=nan;
    for i=1:size(stim,1)
        trandata=pcdata(pcdata(:,2)==stim(i,1),[6 5 4 3]);%Three columns represent the phendate, year phenological event ID,and species ID, respectively.
        stim(i,2:3)=[phenclas(pc) length(unique(trandata(:,2)))];
        if stim(i,3)>=5
             disp(['Processing the ',num2str(pc),'event and ',num2str(i),'site time series;'])
        dat = array2table(trandata,'VariableNames',{'y','year','pheventID','speciesID'});
        dat.pheventID= nominal(dat.pheventID);
        dat.speciesID= nominal(dat.speciesID);
        lme = fitlme(dat,'y~year+(1|pheventID)+(1|speciesID)');
        stim(i,4:5)=[lme.Coefficients.Estimate(2) coefTest(lme)];
        end
    end
    sta=[sta;stim];
end
save('K:\workspace\result\plant_site_level_LMMtrend.mat','sta');

%% estimate the linear trend using linear mixed effect models at grid-level
gsta=[];
for pc=1:length(phenclas)
    pcdata=phenstan(phenstan(:,7)==phenclas(pc),:);
    stim=unique(pcdata(:,9:10),'rows');
    % stim=unique(pcdata(:,2),'rows');
    stim(:,3:6)=nan;
    for i=1:size(stim,1)
        trandata=pcdata(pcdata(:,9)==stim(i,1)&pcdata(:,10)==stim(i,2),[6 5 4 3 8 11 12]);%phendat, year, phen_event, datasetsource
        stim(i,3:4)=[phenclas(pc) length(unique(trandata(:,2)))];
        if stim(i,4)>=5
             disp(['Processing the ',num2str(pc),'event and ',num2str(i),'site time series;'])
        dat = array2table(trandata,'VariableNames',{'y','year','phevent','species','das','lat','lon'});
        dat.phevent= nominal(dat.phevent);
        dat.species= nominal(dat.species);
        dat.das= nominal(dat.das);
        lme = fitlme(dat,'y~year+(1|lat)+(1|lon)+(1|phevent)+(1|species)');
        stim(i,5:6)=[lme.Coefficients.Estimate(2) coefTest(lme)];
        end
    end
    gsta=[gsta;stim];
end
save('K:\workspace\result\plant_grid_level_LMM_trend.mat','gsta');
 
%% Classify the observation into two groups: 1 professional observations; 2 citizen observations
ssta(:,7)=nan;
sta(:,6)=nan;
for i=1:size(dasite)
    ssta(ssta(:,1)==dasite(i,2),7)=dasite(i,3); %1 professional observations; 2 citizen observations
    sta(sta(:,1)==dasite(i,2),6)=dasite(i,3);%1 professional observations; 2 citizen observations
end
%% global Sen's trend estimator and confidence interval

phcl=[2 3 4 5 6 7]';%plant phenophaseID, 2-7: budburst, leafing, flowering, fruiting, fruit ripening, foliar senescence
for i=1:length(phcl)
    datatran=phenstan(phenstan(:,7)==phcl(i,1),2:7);%extract data for the i-th phenophase
    tims=unique(datatran(:,1:3),'rows');% time series for the refered phenophase
    s=nan(size(tims,1),1000);% Predefined a variable storing the phenological trend between each two years
    nn=0;  
    staall=[];
    for j=1:size(tims,1)% the number of the time series
        disp(['Processing the ',num2str(i),'phase',num2str(j),'/',num2str(length(tims)),'time series;'])
        tran=datatran(datatran(:,1)==tims(j,1)&datatran(:,2)==tims(j,2)&datatran(:,3)==tims(j,3),4:5);% the data for a refered time series
        
        yrr=unique(tran(:,1));
        if length(yrr)<length(tran(:))
            for year=1:length(yrr)
                yrr(year,2)=nanmean(tran(tran(:,1)==yrr(year,1),2)); %If there is more than one observation in a year, their mean is used
            end
            tran=yrr;
        end

       %% calculate the linear trends between each two years within a time series
        n=length(tran);
        s(j,[1 2 3])=[n phcl(i) tims(j,2)];
        ti=4;
        if n>=10
            nn=nn+n;
            for k=1:n-1
                for ki=k+1:n
                    if  tran(ki,1) - tran(k,1)>0&&abs(tran(ki,2) - tran(k,2))<100
                        s(j,ti) = ( tran(ki,2) - tran(k,2) ) / ( tran(ki,1) - tran(k,1) );
                    end
                    ti = ti + 1;
                end
            end
        end
    end
staall=[staall;s];% the trends of every two years for all time series was put together.

s(:,1:2)=[];

%% estimate the Sen's trend estimators and their confidence intervals
nc=length(s(~isnan(s)));
nn=floor((1+sqrt(1+8*nc))/2);
ss=sum(sign(s(~isnan(s))));
v = (( nn * ( nn - 1 ) * ( 2 * nn + 5 ) )) / 18;
if ss == 0
z = 0;
elseif ss > 0
z = ( ss - 1 ) / sqrt( v );
else
z = ( ss + 1 ) / sqrt( v );
end
nor = 1.96;%|z|>1.96 indicates the Sen's estimator is significant at a 95% confidence level. 
m1 = fix( ( nc - nor * sqrt( v ) ) / 2 );
m2 = fix( ( nc  + nor * sqrt( v ) ) / 2 );
s1 = sort( s (~isnan(s)));
lc = s1( m1 );% lower limit of the confidence interval
uc = s1( m2 + 1 );% upper limit of the confidence interval

sss=s1(~isnan(s1));
stamk(i,1:4)=[median(sss) lc uc z];
end
stamk(:,1:3)=round(stamk(:,1:3)*10,1);% the unit of the trends was shifted from d/a (per year) to d/decade (per decade).

save('K:\workspace\result\plantshift_MKtrend.mat','stamk');
