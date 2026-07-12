
#remotes::install_github("tnggroup/prada")
#remotes::install_github("tnggroup/prada",ref = 'jz_dev')
library(prada)
library(data.table)

projectFolderPath<-"/scratch/prj/sgdp_nanopore/Projects/prada_jz"
pradaObj<-PradaClass()

#wgs
pradaObj$addAnalysisSetting(settingLabel = "p11-wgs",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/pilot11/wgs/20260610_1408_2A_PBM54820_59bcd741"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/pilot11/wgs"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/pilot11-wgs")) #using the merged depth computations

#adaptive wash - note that this run was split because of the wash, this points to the pgx run for the first run/folder
pradaObj$addAnalysisSetting(settingLabel = "p11",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/pilot11/adaptive-wash/20260612_1130_2B_PBM62862_63f4f1e9"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/pilot11/adaptive-wash-prepause"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/pilot11"))

pradaObj$collectAnalysisCallData("p11-wgs")
pradaObj$collectAnalysisCallData("p11")

pradaObj$collectAnalysisDepthData("p11-wgs")
pradaObj$collectAnalysisDepthData("p11")


pradaObj$computeDepthDataStatistics(filePathBed <- file.path(projectFolderPath,"data/bed/pgx.grch38.5k.0p7percent.bed"),filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv"))

#for test
# pradaApplicationDAO<-pradaObj$pradaApplicationDAO
# nThread<-pradaObj$nThread
# analysisSettingsList<-pradaObj$analysisSettingsList
# sampleSettingsList<-pradaObj$sampleSettingsList
# analysisMeta<-pradaObj$analysisMeta
# sampleMeta<-pradaObj$sampleMeta
# applicationCoverageRegions<-pradaObj$applicationCoverageRegions
# #filePathApplicationCoverageRegions=NULL
# filePathApplicationCoverageRegions <- file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv")
# mddPharmacogeneticsRelevantGenes<-c("CYP2B6","CYP2C19","CYP2D6")

pradaObj$computeCallStatistics(filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv"))

pradaObj$printData()

