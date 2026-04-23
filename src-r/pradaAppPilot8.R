
#this was sequenced after changes to the dna extraction protocol
#devtools::install_github("tnggroup/prada")
#devtools::install_github("tnggroup/prada",ref = 'jz_dev')
library(prada)
library(data.table)

projectFolderPath<-"/scratch/prj/sgdp_nanopore/Projects/prada_jz"
pradaObj<-PradaClass()

#no_wash_reload_new_bed
pradaObj$addAnalysisSetting(settingLabel = "p8-nwnb",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/pilot8/Pilot8_repeat_no_wash_reload_new_bed/20260305_1103_1D_PAW74913_db99cf4f"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/pilot8/p8_nowash_reload_new-bed"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/p8_nowash_reload_new-bed"))

#no_wash_reload_old_bed
pradaObj$addAnalysisSetting(settingLabel = "p8-nwob",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/pilot8/Pilot8_repeat_nowash_reload_Old_bed/20260305_1106_1C_PBA20773_85ef8c12"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/pilot8/p8_nowash_reload_old-bed"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/p8_nowash_reload_old-bed"))

#wash_reload_new_bed
pradaObj$addAnalysisSetting(settingLabel = "p8-wnb",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/pilot8/Pilot8_repeat_wash_reload_new_bed/20260305_1103_1B_PBA27068_38854151"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/pilot8/p8_wash_reload_new-bed"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/p8_nowash_reload_new-bed"))

#wash_reload_old_bed
pradaObj$addAnalysisSetting(settingLabel = "p8-wob",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/pilot8/Pilot8_repeat_wash_reload_Old_bed/20260305_1106_1A_PBA20795_9c645987"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/pilot8/p8_wash_reload_old-bed"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/p8_wash_reload_old-bed"))


pradaObj$collectAnalysisCallData("p8-nwnb")
pradaObj$collectAnalysisCallData("p8-nwob")
pradaObj$collectAnalysisCallData("p8-wnb")
pradaObj$collectAnalysisCallData("p8-wob")

pradaObj$collectAnalysisDepthData("p8-nwnb")
pradaObj$collectAnalysisDepthData("p8-nwob")
pradaObj$collectAnalysisDepthData("p8-wnb")
pradaObj$collectAnalysisDepthData("p8-wob")

#TODO! Add separate BED-file results
pradaObj$computeDepthDataStatistics(filePathBed <- file.path(projectFolderPath,"data/bed/pgx.grch38.5k.0p7percent.bed"),filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv"))
pradaObj$computeCallStatistics(filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv"))

pradaObj$printData()

