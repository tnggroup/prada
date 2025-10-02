
library(prada)
library(data.table)

projectFolderPath<-"/scratch/prj/sgdp_nanopore/Projects/prada_jz"
pradaObj<-PradaClass()

pradaObj$addAnalysisSetting(settingLabel = "p3-1",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/pilot3/1/20250923_1641_1A_PBI33249_5330c06c"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/pilot3/p3-1"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/pilot3/p3-1"))
#pradaObj$addAnalysisSetting(settingLabel = "p3-2",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/pilot3/2/20250923_1641_1B_PBI36117_73f1a5cf"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/pilot3/p3-2"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/pilot3/p3-2"))


pradaObj$collectAnalysisCallData("p3-1")
#pradaObj$collectAnalysisCallData("p3-2")
pradaObj$collectAnalysisDepthData("p3-1")
#pradaObj$collectAnalysisDepthData("p3-2")
pradaObj$computeDepthDataStatistics(filePathBed <- file.path(projectFolderPath,"data/bed/pgx.grch38.5k.0p7percent.bed"),filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv"))
pradaObj$computeCallStatistics(filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv"))
pradaObj$printData()
