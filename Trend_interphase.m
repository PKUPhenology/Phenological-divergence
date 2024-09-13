%% This programme is for estimating the temporal trends of the length of interphase between two paired phenophases.

clear all
clc
load 'K:\workspace\data\plant_phen_deduplicateddata_.mat';% variables: 'dataset' and 'dscode'- the dataset name and ID;'phlist' and 'phcode'-phenology event name and ID;'splist' and 'spcode'- species name and ID; 'phenstan'-data; 'stlist'- site ID and locations.

[phc,phli]=xlsread('K:\workspace\data\plant_phen_class.xlsx','Sheet1','A2:D254');;% phc-phenological event ID and phenophase ID; phli-name of phenological event.
for i=1:length(phlist)
    phcode(i,2)=phc(strcmp(phli(:,1),phlist(i))==1,3);% the list of the phenological event ID and Phenophase ID.
end
for i=1:length(phcode)
    phenstan(phenstan(:,4)==phc(i,1),7)=phcode(i,2); %phenological event were classified as the phenophase.
end

% the data beyond the study period (1980-2020) were excluded.
phenstan(phenstan(:,5)>2020,:)=[];
phenstan(phenstan(:,5)<1980,:)=[];

sta=[];
nrc=length(phlist);
tims=unique(phenstan(:,[2 3 4 7]),'rows');% the time series list, colomns 1-4: site, species, phenological eventID, phenophaseID
for ph1=1:nrc-1
    for ph2=ph1+1:nrc
        tim_tran_e=tims(tims(:,4)==ph1,:);%%the site-species-phenological event time series for earlier phenophase
        tim_tran_l=tims(tims(:,4)==ph2,:);%the site-species-phenological event time series for later phenophase
        phen_tran_e=phenstan(phenstan(:,7)==ph1,2:7);% the annual data for the site-species-phenological event time series for earlier phenophase
        phen_tran_l=phenstan(phenstan(:,7)==ph2,2:7);%the annual data for the site-species-phenological event time series for later phenophase
        stsp_tim=unique(tim_tran_e(:,[1 2 4]),'rows');%the site-species-phenophase time series for earlier phenophase
        for stp=1:size(stsp_tim,1)
            disp(['Processing the',num2str(ph1),'phenclass',num2str(stp),'tim series/',num2str(size(stsp_tim,1)),';']);
            pp_e=unique(tim_tran_e(tim_tran_e(:,1)==stsp_tim(stp,1)&tim_tran_e(:,2)==stsp_tim(stp,2),3));%the phenological event for the earlier phenophase for the given site and species
            pp_l=unique(tim_tran_l(tim_tran_l(:,1)==stsp_tim(stp,1)&tim_tran_l(:,2)==stsp_tim(stp,2),3));%the phenological event for the later phenophase for the given site and species
            yr=[1980:1:2021]';
            if isempty(pp_l)==0
                stap=[];
                for i=1:length(pp_e)
                    for j=1:length(pp_l)
                        ph_olp=nan(length(yr),2);%define a null variable for storaging phenoloigcal data
                        phl=phen_tran_l(phen_tran_l(:,1)==stsp_tim(stp,1)&phen_tran_l(:,2)==stsp_tim(stp,2)&phen_tran_l(:,3)==pp_l(j),4:5);
                        phl(abs(phl(:,2)-nanmean(phl(:,2)))>2*nanstd(phl(:,2)),:)=[];% exclude the outliers for later phenophase
                        phe=phen_tran_e(phen_tran_e(:,1)==stsp_tim(stp,1)&phen_tran_e(:,2)==stsp_tim(stp,2)&phen_tran_e(:,3)==pp_e(i),4:5);
                        phe(abs(phe(:,2)-nanmean(phe(:,2)))>2*nanstd(phe(:,2)),:)=[];% exclude the outliers for ealier phenophase
                        ph_olp(phl(:,1)-1979,1)=phl(:,2);
                        ph_olp(phe(:,1)-1979,2)=phe(:,2);
                        nyr=mean(ph_olp,2);%the data for the paired phenophase

                        if sum(~isnan(nyr))>=5
                            ph_olp(isnan(nyr),1)=nan;%the data beyond the overlapping year were set to be NAN.
                            ph_olp(isnan(nyr),2)=nan;%the data beyond the overlapping year were set to be NAN.
                            ph_olp=ph_olp+366;
                            %
                            phml=round(nanmean(ph_olp(:,1)));%the mean date for later phenological event
                            phme=round(nanmean(ph_olp(:,2)));%the mean date for earlier phenological event
                            %

                            %% estimate the trends of the length of interphase between two paired phenophases

                            nyr=mean(ph_olp,2);
                            if phml>phme %% The phenolgoical event for the later phenophase should occur later than the one for the earlier phenophase
                                stap=[stap; [ph_olp(:,1)-ph_olp(:,2) yr ones(length(yr),1)*i ones(length(yr),1)*j]];% The columns denotes the length of interphases, year, Earlier phenophase ID, Later phenophase ID
                            end
                        end
                    end
                end
                if ~isempty(stap)
                    stap(isnan(stap(:,1)),:)=[];
                    dat = array2table(stap,'VariableNames',{'y','year','phevente','pheventl'});
                    dat.phevente= nominal(dat.phevente);% earlier phenophase classes
                    dat.pheventl= nominal(dat.pheventl);% later phenophase classes
                    lme = fitlme(dat,'y~year+(1|phevente)+(1|pheventl)');% fixed effects:year, random effects: the classes of the paired phenophases.
                    sta=[sta; [stsp_tim(stp,:) ph2 lme.Coefficients.Estimate(2) coefTest(lme) length(unique(stap(:,2)))]];
                end
            end
        end
    end
end
save('K:\workspace\result\plant_interphase_trend.mat','sta');