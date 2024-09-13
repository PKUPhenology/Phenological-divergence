%% This programme is for analyzing the effects of an earlier occurred phenological event to the later one, as well as the effects of climatic factors between the two events.

clear all
clc
load 'K:\workspace\data\T.mat';% import temperature data,Variables: T1,T2,pix. pix records the numbers of the row and column in the original data.
% the three dimensions (x,y,z) denote the day of year (x), the site (y) and the year (z).
% The x contains the day of year at the prvious, current and the following year.
% The precipitation data is similar with the temperature data.

load 'K:\workspace\data\Pre.mat';% import precipitation data,  Variables: P1,P2


% Due to the limitation of the storage of individual document, we have divided the data into two parts. Here, the data were merged back together.
yrtmp=cat(2,T1,T2);%daily mean 2m air temperature
yrtp=cat(2,P1,P2);%daily total precipitation


clear T P

load 'K:\workspace\plant_phen_deduplicateddata_.mat';% variables: 'dataset' and 'dscode'- the dataset name and ID;'phlist' and 'phcode'-phenology event name and ID;'splist' and 'spcode'- species name and ID; 'phenstan'-data; 'stlist'- site ID and locations.

[phc,phli]=xlsread('K:\workspace\data\plant_phen_class.xlsx','Sheet1','A2:D254');% phc-phenological event ID and phenophase ID; phli-name of phenological event.

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
        tim_tran_e=tims(tims(:,4)==ph1,:);%the site-species-phenological event time series for earlier phenophase
        tim_tran_l=tims(tims(:,4)==ph2,:);%the site-species-phenological event time series for later phenophase
        phen_tran_e=phenstan(phenstan(:,7)==ph1,2:7);% the annual data for the site-species-phenological event time series for earlier phenophase
        phen_tran_l=phenstan(phenstan(:,7)==ph2,2:7);% the annual data for the site-species-phenological event time series for later phenophase
        stsp_tim=unique(tim_tran_e(:,[1 2 4]),'rows');%the site-species-phenophase time series for earlier phenophase
        for stp=1:size(stsp_tim,1)
            disp(['Processing the',num2str(ph1),'phenclass',num2str(stp),'tim series/',num2str(size(stsp_tim,1)),';']);
            pp_e=unique(tim_tran_e(tim_tran_e(:,1)==stsp_tim(stp,1)&tim_tran_e(:,2)==stsp_tim(stp,2),3));% the phenological event for the earlier phenophase for the given site and species
            pp_l=unique(tim_tran_l(tim_tran_l(:,1)==stsp_tim(stp,1)&tim_tran_l(:,2)==stsp_tim(stp,2),3));%the phenological event for the later phenophase for the given site and species
            yr=[1980:1:2021]';


            if isempty(pp_l)==0
                                
                % preset the output variables in the analysis
                prtran=nan(length(pp_e),length(pp_l));
                pp=nan(length(pp_e),length(pp_l));
                tprtran=nan(length(pp_e),length(pp_l));
                ENtran=nan(length(pp_e),length(pp_l));
                ENtrana=nan(length(pp_e),length(pp_l));
                EPhtran=nan(length(pp_e),length(pp_l));
                EPhtrana=nan(length(pp_e),length(pp_l));
                tpp=nan(length(pp_e),length(pp_l));
                slotran=nan(length(pp_e),length(pp_l));
                slop=nan(length(pp_e),length(pp_l));
                MR2_ph_e=nan(length(pp_e),length(pp_l));
                MR2_cli_e=nan(length(pp_e),length(pp_l));

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

                        rl=stlist(stlist(:,1)==stsp_tim(stp,1),2);
                        cl=stlist(stlist(:,1)==stsp_tim(stp,1),3);
                        rl=ceil((90-rl)/0.1);%the row number
                        cl=ceil((180+cl)/0.1);%the column number
                        [pixi,~]=find(pix(:,1)==rl&pix(:,2)==cl);

                        if sum(~isnan(nyr))>=5
                            ph_olp(isnan(nyr),1)=nan;%the data beyond the overlapping year were set to be NAN.
                            ph_olp(isnan(nyr),2)=nan;%the data beyond the overlapping year were set to be NAN.
                            ph_olp=ph_olp+366;

                            phml=round(nanmean(ph_olp(:,1)));%the mean date for later phenological event
                            phme=round(nanmean(ph_olp(:,2)));%the mean date for earlier phenological event
                            %% calculating the mean temperature and total precipitation between two phenological events
                            t_interval=squeeze(nanmean(yrtmp(pixi,phme:phml,:),2));
                            p_interval=squeeze(nansum(yrtp(pixi,phme:phml,:),2));
                            %% calculating the mean temperature and total precipitation during 30 days prior the later phenological event
                            tl_premonth=squeeze(nanmean(yrtmp(pixi,phml-30:phml,:),2));
                            pl_premonth=squeeze(nansum(yrtp(pixi,phml-30:phml,:),2));

                            %% calculating the mean temperature and total precipitation during 30 days prior the earlier phenological event
                            te_premonth=squeeze(nanmean(yrtmp(pixi,phme-30:phme,:),2));
                            pe_premonth=squeeze(nansum(yrtp(pixi,phme-30:phme,:),2));


                            %% the input data of temperature and precipitation in regression models
                            tyr=t_interval;% tl_premonth %either t_interval or tl_premonth were used.
                            pyr=p_interval;% pl_premonth %either p_interval or pl_premonth were used.

                            if phml>phme %% The phenolgoical event for the later phenophase should occur later than the one for the earlier phenophase
                                % [rtran(i,j),p(i,j)]=corr(ph_olp(~isnan(nyr),1),ph_olp(~isnan(nyr),2));% the correlations between two phenological event time series
                                [prtran(i,j),pp(i,j)]=partialcorr(ph_olp(~isnan(nyr),1),ph_olp(~isnan(nyr),2),[tyr(~isnan(nyr)) pyr(~isnan(nyr))]);% the correlations between two phenological event time series,excluding the effects of temperature and precipitation
                                [tprtran(i,j),tpp(i,j)]=partialcorr(ph_olp(~isnan(nyr),1),tyr(~isnan(nyr)),[ph_olp(~isnan(nyr),2) pyr(~isnan(nyr))]);% the correlations between later phenological event and temperature,excluding the effects of earlier phenophase and precipitation
                                [pprtran(i,j),ppp(i,j)]=partialcorr(ph_olp(~isnan(nyr),1),pyr(~isnan(nyr)),[ph_olp(~isnan(nyr),2) tyr(~isnan(nyr))]);% the correlations between later phenological event and precipitation,excluding the effects of earlier phenophase and temperature

                                [Ct,~]=partialcorr(ph_olp(~isnan(nyr),1),tyr(~isnan(nyr)),ph_olp(~isnan(nyr),2));% the partial correlations between later phenological event and temperature,excluding the effects of earlier phenophase
                                [Cp,~]=partialcorr(ph_olp(~isnan(nyr),1),pyr(~isnan(nyr)),ph_olp(~isnan(nyr),2));% the partial correlations between later phenological event and precipitation,excluding the effects of earlier phenophase

                                [bt,~,~,~,statst]=regress(ph_olp(~isnan(nyr),1),[ph_olp(~isnan(nyr),2) tyr(~isnan(nyr)) ones(length(tyr(~isnan(nyr))),1)]);% the regression model with dependent variable: later phenological event, independent variables: earlier phenological event and temperature
                                [bp,~,~,~,statsp]=regress(ph_olp(~isnan(nyr),1),[ph_olp(~isnan(nyr),2) pyr(~isnan(nyr))  ones(length(pyr(~isnan(nyr))),1)]);% the regression model with dependent variable: later phenological event, independent variables: earlier phenological event and precipitation

                                [btcli,~,~,~,statstcli]=regress(ph_olp(~isnan(nyr),1),[te_premonth(~isnan(nyr)) tyr(~isnan(nyr)) ones(length(tyr(~isnan(nyr))),1)]);% the regression model with dependent variable: later phenological event, independent variables: temperature prior earlier phenological event and temperature prior later phenological event
                                [bpcli,~,~,~,statspcli]=regress(ph_olp(~isnan(nyr),1),[pe_premonth(~isnan(nyr)) pyr(~isnan(nyr))  ones(length(pyr(~isnan(nyr))),1)]);% the regression model with dependent variable: later phenological event, independent variables: precipitation prior earlier phenological event and precipitation prior later phenological event
                                %
                                [~,loc]=max([statst(1) statsp(1)]);% select the main driver between temperature and precipitation

                                if loc==1% temperature is the main driver
                                    EPhtran(i,j)=partialcorr(ph_olp(~isnan(nyr),1),ph_olp(~isnan(nyr),2),tyr(~isnan(nyr)));%partial correlation between later event and earlier event excluding the effect of temperature
                                    EPhtrana(i,j)=abs(partialcorr(ph_olp(~isnan(nyr),1),ph_olp(~isnan(nyr),2),tyr(~isnan(nyr))));%absolute value of partial correlation between later event and earlier event excluding the effect of temperature
                                    ENtran(i,j)=Ct;%partial correlation between later event and temperature excluding the effect of earlier event
                                    ENtrana(i,j)=abs(Ct);%absolute value of partial correlation between later event and temperature excluding the effect of earlier event
                                    MR2_ph_e(i,j)=statst(1);% R2 for the earlier events based regression model
                                    MR2_cli_e(i,j)=statstcli(1);% R2 for the regression model based on the temperature prior the earlier event
                                else% precipitation is the main driver
                                    EPhtran(i,j)=partialcorr(ph_olp(~isnan(nyr),1),ph_olp(~isnan(nyr),2),pyr(~isnan(nyr)));%partial correlation between later event and earlier event excluding the effect of precipitation
                                    EPhtrana(i,j)=abs(partialcorr(ph_olp(~isnan(nyr),1),ph_olp(~isnan(nyr),2),pyr(~isnan(nyr))));%absolute value of partial correlation between later event and earlier event excluding the effect of precipitation
                                    ENtran(i,j)=Cp;%partial correlation between later event and precipitation excluding the effect of earlier event
                                    ENtrana(i,j)=abs(Cp);%absolute value of partial correlation between later event and precipitation excluding the effect of earlier event
                                    MR2_ph_e(i,j)=statsp(1);% R2 for the earlier events based regression model
                                    MR2_cli_e(i,j)=statspcli(1);% R2 for the regression model based on the precipitation prior the earlier event
                                end
                            end
                        end
                    end
                end

                if ~isnan(nanmean(pp(:))) %The analysis results of the available phenological pairs.
                    sta=[sta; [stsp_tim(stp,:) ph2 nanmedian(prtran(:)) nanmean(prtran(:)) nanmedian(tprtran(:)) nanmean(tprtran(:)) nanmedian(pprtran(:)) nanmean(pprtran(:)) nanmedian(EPhtran(:)) nanmean(EPhtran(:)) nanmedian(ENtran(:)) nanmean(ENtran(:)) nanmedian(EPhtrana(:)) nanmean(EPhtrana(:)) nanmedian(ENtrana(:)) nanmean(ENtrana(:))  nanmedian(MR2_ph_e(:)) nanmedian(MR2_cli_e(:))]];
                end
            end
        end
    end
end
sta(isnan(sta(:,5)),:)=[];%remove the null data
stace= [cell({'stID','spID','phclase','phclasl', 'prmedian','prmean','tprmedian','tprmean','pprmedian','pprmean','Phmax2median','Phmax2mean','ENmax2median','ENmax2mean','Phamax2median','Phamax2mean','ENamax2median','ENamax2mean','MR2_ph_e','MR2_cli_e'}); mat2cell(sta,ones(size(sta,1),1),ones(1,20))];

save('K:\workspace\result\clim_carryover_effect_dailytp.mat','stace');