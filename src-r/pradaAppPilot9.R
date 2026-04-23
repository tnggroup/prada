
#this was sequenced after changes to the dna extraction protocol
#devtools::install_github("tnggroup/prada")
#devtools::install_github("tnggroup/prada",ref = 'jz_dev')
library(prada)
library(data.table)

projectFolderPath<-"/scratch/prj/sgdp_nanopore/Projects/prada_jz"
pradaObj<-PradaClass()

#adaptive-no_wash
pradaObj$addAnalysisSetting(settingLabel = "p9-nw",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/pilot9/adaptive-no_wash/20260401_1634_3B_PBA26904_c365c7b4"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/pilot9/adaptive-nowash"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/p9_nowash"))

#adaptive-wash
pradaObj$addAnalysisSetting(settingLabel = "p9-w",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/pilot9/adaptive-wash/20260401_1634_3A_PBA28248_6e48160c"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/pilot9/adaptive-wash"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/p9_wash"))

#wgs-nowash
pradaObj$addAnalysisSetting(settingLabel = "p9-wgs",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/pilot9/wgs/20260401_1636_3C_PBA27141_6e071834"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/pilot9/wgs-nowash"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/p9_wgs_nowash"))


pradaObj$collectAnalysisCallData("p9-nw")
pradaObj$collectAnalysisCallData("p9-w")
pradaObj$collectAnalysisCallData("p9-wgs")


pradaObj$collectAnalysisDepthData("p9-nw")
pradaObj$collectAnalysisDepthData("p9-w")
pradaObj$collectAnalysisDepthData("p9-wgs")


#TODO! Add separate BED-file results
pradaObj$computeDepthDataStatistics(filePathBed <- file.path(projectFolderPath,"data/bed/pgx.grch38.5k.0p7percent.bed"),filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv"))
pradaObj$computeCallStatistics(filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv"))

pradaObj$printData()

