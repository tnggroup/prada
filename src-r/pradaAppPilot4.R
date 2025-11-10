
#this was sequenced after changes to the dna extraction protocol
#devtools::install_github("tnggroup/prada")
#devtools::install_github("tnggroup/prada",ref = 'jz_dev')
library(prada)
library(data.table)

projectFolderPath<-"/scratch/prj/sgdp_nanopore/Projects/prada_jz"
pradaObj<-PradaClass()

pradaObj$addAnalysisSetting(settingLabel = "p4-1",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/pilot4/20251016_1622_1B_PBI33309_46543eba"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/pilot4/p4-1"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/pilot4/p4-1"))


pradaObj$collectAnalysisCallData("p4-1")

pradaObj$collectAnalysisDepthData("p4-1")

pradaObj$computeDepthDataStatistics(filePathBed <- file.path(projectFolderPath,"data/bed/pgx.grch38.5k.0p7percent.bed"),filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv"))
pradaObj$computeCallStatistics(filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv"))

pradaObj$printData()

