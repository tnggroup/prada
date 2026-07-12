#Also includeds the WGS-2026may

#remotes::install_github("tnggroup/prada")
#remotes::install_github("tnggroup/prada",ref = 'jz_dev')
library(prada)
library(data.table)

projectFolderPath<-"/scratch/prj/sgdp_nanopore/Projects/prada_jz"
pradaObj<-PradaClass()

#wgs
pradaObj$addAnalysisSetting(settingLabel = "p10-wgs-A",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/wgs-2026-may/Prada_WGS_Sample_A1/20260511_1548_1A_PBA26918_72d1a60f"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/WGS-2026may/A/wf-pgx_01KS2K4NY5NWGH5FD6MQTTKVSQ"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/WGS-2026may")) #using the merged depth computations
pradaObj$addSampleSetting(analysis = "p10-wgs-A",sampleLabel = "Prada_WGS_Sample_A")
pradaObj$addAnalysisSetting(settingLabel = "p10-wgs-B",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/wgs-2026-may/Prada_WGS_Sample_B1/20260511_1548_1C_PBA27005_e155cf4b"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/WGS-2026may/B/wf-pgx_01KS7W85PT3EPN2VKEXN98NBT5"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/WGS-2026may")) #using the merged depth computations
pradaObj$addSampleSetting(analysis = "p10-wgs-B",sampleLabel = "Prada_WGS_Sample_B")
pradaObj$addAnalysisSetting(settingLabel = "p10-wgs-C",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/wgs-2026-may/Prada_WGS_Sample_C1/20260511_1548_1E_PBA29598_ef8e3fc8"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/WGS-2026may/C/wf-pgx_01KS7WA6WXNJ7PC4F8G574Z23A"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/WGS-2026may")) #using the merged depth computations
pradaObj$addSampleSetting(analysis = "p10-wgs-C",sampleLabel = "Prada_WGS_Sample_C")

#adaptive-no_wash
pradaObj$addAnalysisSetting(settingLabel = "p10",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/pilot10/Adaptive_Wash_2805/20260528_1108_1B_PBM53823_2f5d19fd"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/pilot10"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/pilot10"))


#test
# settingLabel <- "p10-wgs-A"
# pradaApplicationDAO<-pradaObj$pradaApplicationDAO
# nThread<-pradaObj$nThread
# analysisSettingsList<-pradaObj$analysisSettingsList
# sampleSettingsList<-pradaObj$sampleSettingsList
# analysisMeta<-pradaObj$analysisMeta
# sampleMeta<-pradaObj$sampleMeta


pradaObj$collectAnalysisCallData("p10-wgs-A")
pradaObj$collectAnalysisCallData("p10-wgs-B")
pradaObj$collectAnalysisCallData("p10-wgs-C")
pradaObj$collectAnalysisCallData("p10")

pradaObj$collectAnalysisDepthData("p10-wgs-A")
pradaObj$collectAnalysisDepthData("p10-wgs-B")
pradaObj$collectAnalysisDepthData("p10-wgs-C")
pradaObj$collectAnalysisDepthData("p10")


pradaObj$computeDepthDataStatistics(filePathBed <- file.path(projectFolderPath,"data/bed/pgx.grch38.5k.0p7percent.bed"),filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv"))
pradaObj$computeCallStatistics(filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv"))

pradaObj$printData()

