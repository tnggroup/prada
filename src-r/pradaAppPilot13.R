
#remotes::install_github("tnggroup/pgxrex")
#remotes::install_github("tnggroup/pgxrex",ref = 'jz_dev')
library(pgxrex)
library(data.table)

projectFolderPath<-"/scratch/prj/sgdp_nanopore/Projects/prada_jz"
pgxrexObj<-PgxrexClass()
pgxrexObj$folderpathWork<-file.path(projectFolderPath,"work","pradaApp","pilot13") #the folder where this is executed
origWD<-getwd()

#wgs
pgxrexObj$addAnalysisSetting(settingLabel = "p13-wgs",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/pilot13_promplus/WGS/20260826_1405_2C_PBM20354_79281b41"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/pilot13_promplus/wgs"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/pilot13-wgs"))

#adaptive 8kb
pgxrexObj$addAnalysisSetting(settingLabel = "p13-8kb",folderPathAnalysisSequencingRaw = file.path(projectFolderPath,"data/ont_raw/pilot13_promplus/Adaptive_8kb/20260826_1404_2E_PBM20442_b5a6e3c8"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/pilot13_promplus/adaptive_8kb"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/pilot13-8kb"))

#adaptive 15kb
pgxrexObj$addAnalysisSetting(settingLabel = "p13-15kb",folderPathAnalysisSequencingRaw = file.path(projectFolderPath,"data/ont_raw/pilot13_promplus/Adaptive_15kb/20260826_1404_2D_PBM20554_77a488a28"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/pilot13_promplus/adaptive_15kb"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/pilot13-15kb"))

pgxrexObj$collectAnalysisCallData("p13-wgs")
pgxrexObj$collectAnalysisCallData("p13-8kb")
pgxrexObj$collectAnalysisCallData("p13-15kb")

analysisId<-"p13-wgs"
sampleMeta.analysis<-pgxrexObj$sampleMeta[pgxrexObj$sampleMeta$analysis==analysisId,]

analysisFolderpathWork.mosdepth<-file.path(pgxrexObj$analysisMeta[analysisId,c("folderPathDepthAnalysisOutputRaw")])
setwd(analysisFolderpathWork.mosdepth)

for(iSample in 1:nrow(sampleMeta.analysis)){
  #iSample<-1
  cBarcode<-sampleMeta.analysis[iSample,c("barcode")]
  if(file.exists(paste0(cBarcode,".per-base.bed.gz"))) next
  mosdepthOutput<-wrapper.mosdepth(
    label = cBarcode,bamFilePath = file.path(pgxrexObj$analysisSettingsList[[analysisId]]$folderPathAnalysisOutputRaw,"output",cBarcode,paste0(cBarcode,".haplotagged.bam")),
    threads = 6,
    mosdepthPath = "/users/k2481717/project/SHARED/software/mosdepth/mosdepth"
  )
}

analysisId<-"p13-8kb"
sampleMeta.analysis<-pgxrexObj$sampleMeta[pgxrexObj$sampleMeta$analysis==analysisId,]

analysisFolderpathWork.mosdepth<-file.path(pgxrexObj$analysisMeta[analysisId,c("folderPathDepthAnalysisOutputRaw")])
setwd(analysisFolderpathWork.mosdepth)

for(iSample in 1:nrow(sampleMeta.analysis)){
  #iSample<-1
  cBarcode<-sampleMeta.analysis[iSample,c("barcode")]
  if(file.exists(paste0(cBarcode,".per-base.bed.gz"))) next
  mosdepthOutput<-wrapper.mosdepth(
    label = cBarcode,bamFilePath = file.path(pgxrexObj$analysisSettingsList[[analysisId]]$folderPathAnalysisOutputRaw,"output",cBarcode,paste0(cBarcode,".haplotagged.bam")),
    threads = 6,
    mosdepthPath = "/users/k2481717/project/SHARED/software/mosdepth/mosdepth"
  )
}

analysisId<-"p13-15kb"
sampleMeta.analysis<-pgxrexObj$sampleMeta[pgxrexObj$sampleMeta$analysis==analysisId,]

analysisFolderpathWork.mosdepth<-file.path(pgxrexObj$analysisMeta[analysisId,c("folderPathDepthAnalysisOutputRaw")])
setwd(analysisFolderpathWork.mosdepth)

for(iSample in 1:nrow(sampleMeta.analysis)){
  #iSample<-1
  cBarcode<-sampleMeta.analysis[iSample,c("barcode")]
  if(file.exists(paste0(cBarcode,".per-base.bed.gz"))) next
  mosdepthOutput<-wrapper.mosdepth(
    label = cBarcode,bamFilePath = file.path(pgxrexObj$analysisSettingsList[[analysisId]]$folderPathAnalysisOutputRaw,"output",cBarcode,paste0(cBarcode,".haplotagged.bam")),
    threads = 6,
    mosdepthPath = "/users/k2481717/project/SHARED/software/mosdepth/mosdepth"
  )
}

setwd(pgxrexObj$folderpathWork)

pgxrexObj$collectAnalysisDepthData("p13-wgs")
pgxrexObj$collectAnalysisDepthData("p13-8kb")
pgxrexObj$collectAnalysisDepthData("p13-15kb")

pgxrexObj$computeDepthDataStatistics(filePathBed <- file.path(projectFolderPath,"data/bed/pgx.grch38.5k.0p7percent.bed"),filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv"))

#for test
# settingLabel <- "p13-wgs"
# pradaApplicationDAO<-pgxrexObj$pradaApplicationDAO
# nThread<-pgxrexObj$nThread
# analysisSettingsList<-pgxrexObj$analysisSettingsList
# sampleSettingsList<-pgxrexObj$sampleSettingsList
# analysisMeta<-pgxrexObj$analysisMeta
# sampleMeta<-pgxrexObj$sampleMeta
# applicationCoverageRegions<-pgxrexObj$applicationCoverageRegions
# #filePathApplicationCoverageRegions=NULL
# filePathApplicationCoverageRegions <- file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv")
# mddPharmacogeneticsRelevantGenes<-c("CYP2B6","CYP2C19","CYP2D6")

pgxrexObj$computeCallStatistics(filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv"))

pgxrexObj$printData()

