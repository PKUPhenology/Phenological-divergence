## Repository for analysis: 

Phenological divergence between plants and animals under climate change

## Authors: Weiguang Lang(1), Yao Zhang(1)*, Xiangyi Li(1), Fandong Meng(2), Qiang Liu(3), Kai Wang(1), Hao Xu(1), Anping Chen(4), Josep Peñuelas(5,6), Ivan A. Janssens(7), Shilong Piao(1,2)*

## Affiliations:

1. Institute of Carbon Neutrality, Sino–French Institute for Earth System Science, College of Urban and Environmental Sciences, Peking University, Beijing, China.
2. State Key Laboratory of Tibetan Plateau Earth System, Resources and Environment, Institute of Tibetan Plateau Research, Chinese Academy of Sciences, Beijing, China.
3. School of Remote Sensing & Geomatics Engineering, Nanjing University of Information Science & Technology, Nanjing 210044, China
4. Department of Biology and Graduate Degree Program in Ecology, Colorado State University, Fort Collins, CO, USA.
5. CREAF, Cerdanyola del Valles, Barcelona, Spain.
6. CSIC, Global Ecology Unit CREAF-CSIC-UAB, Barcelona, Spain.
7. Department of Biology, University of Antwerp, Wilrijk, Belgium.
*Corresponding author: Yao Zhang (zhangyao@pku.edu.cn)
Shilong Piao (slpiao@pku.edu.cn)

## About:

	This repository records the complete workflow that produced the analysis from the data.

	climate data: The daily data for temperature and precipitation were calculated from the ERA5 hourly data at surface levels from 1979 to the present (https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-land). We have extracted temperature and precipitation data corresponding to each site's location, which is provided in the following 4 mat files:
          1.T.mat,
          2.Pre.mat,
          3.T_animal.mat,
          4.Pre_animal.mat.
Due to the overlarge size of these files, we have stored these files at the following link: https://zenodo.org/records/13751230. The first two are temperature and precipitation data for plant phenology sites, respectively, and the last two are data for animal phenology sites. These four files should be moved to ‘data’ folder before running the code. 
	The core software dependency is Matlab (MathWorks Inc. Natick, MA, USA). 
	Codes are written and performed by Lang with Matlab R2023a on a windows 10 professional 22H2.
	This repository is intended to record a workflow, and is not designed or tested for distribution and wide use on multiple platforms. 
	For any reproducibility issue, you may contact W. Lang at lwg@pku.edu.cn.

## How to compile the code? 

  (i) First, run phenshifts.m. 
This file is the codes for estimating the temporal trends for each phenophase of plants using the four different methods. It will save the following 4 mat files in the “result” folder:
          1. plant_site_species_level_LMM_trend. mat,
          2. plant_site_level_LMM_trend.mat,
          3. plant_grid_level_LMM_trend.mat,
          4. plantshift_MK_trend. mat.
   (ii) Second, run Trend_interphase.m. 
This file provides the codes for estimating the trend of length of intervals between two paired phenophases. It will save the following 1 mat files in the “result” folder:
          5. plant_interphase_trend.mat.
   (iii) Third, run climatic_carryover_effect.m. 
This file provides the codes for estimating the carryover effect and climatic effect on phenological variations. It will save the following 1 mat files in the “result” folder:
          6. clim_carryover_effect_dailytp_interphase.mat.

***NOTE*** The code files serve as an example for plants. Before running the programmes, you need to adjust the calling path of the input data to match its storage path, otherwise an error will occur. The results for animals would be output, when the data for a given animal guild is input. We already provided the preprocessed phenology data and climatic data files for both plant and animal in the ‘data’ folder. You can get preliminary reports with further analysis from running the codes as mentioned in step (i-iii). The mat files are for the animals in the “data” folder:
1. animal_site_species_level_LMM_trend. mat,
          2. animal_site_level_LMM_trend.mat,
          3. animal_grid_level_LMM_trend.mat,
          4. animalshift_MK_trend. mat.
5. animal_interphase_trend.mat.
6. animal_clim_carryover_effect_dailytp_interphase.mat.

##NOTE:

   In this repository, we have provided 3 folders with preprocessed and output data files (“data” and “result”) and codes (“figcode”) that can be used to get main text figures (Figs. 2-4). Before running the programmes, the file ‘clim_carryover_effect_dailytp_interphase.mat.’ should be moved to “result” folder. Due to the overlarge size of this file, you can find this file at the following link: https://zenodo.org/records/13751230. These folders are particularly useful if you don't want to run the whole analysis of the following paper:
  "Phenological divergence between plants and animals under climate change" (Nature Ecology & Evolution).

## Funding and acknowledgment:

	This study was supported by the National Natural Science Foundation of China (grant no. 41988101).

