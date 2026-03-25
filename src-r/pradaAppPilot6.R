
#this was sequenced after changes to the dna extraction protocol
#devtools::install_github("tnggroup/prada")
#devtools::install_github("tnggroup/prada",ref = 'jz_dev')
library(prada)
library(data.table)

projectFolderPath<-"/scratch/prj/sgdp_nanopore/Projects/prada_jz"
pradaObj<-PradaClass()

pradaObj$addAnalysisSetting(settingLabel = "p6-nwr-ob",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/pilot6/Pilot8_repeat_nowash_reload_Old_bed/20260305_1106_1C_PBA20773_85ef8c12"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/pilot6/p6-1"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/pilot6"))


pradaObj$collectAnalysisCallData("p6-1")

pradaObj$collectAnalysisDepthData("p6-1")

pradaObj$computeDepthDataStatistics(filePathBed <- file.path(projectFolderPath,"data/bed/pgx.grch38.5k.0p7percent.bed"),filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv"))
pradaObj$computeCallStatistics(filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv"))

pradaObj$printData()

