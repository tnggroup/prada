
library(prada)
library(data.table)

projectFolderPath<-"/scratch/prj/sgdp_nanopore/Projects/prada_jz"
pradaObj<-PradaClass()

pradaObj$addAnalysisSetting(settingLabel = "p2-gtube",folderPathAnalysisSequencingRaw = file.path(projectFolderPath, "data/ont_raw/pilot2/Gtube/20250724_1536_3B_PAW94949_16dd4442"),folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/pilot2/p2-gtube"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/pilot2/p2-gtube"))
pradaObj$addAnalysisSetting(settingLabel = "p2-nogtube",folderPathAnalysisSequencingRaw = file.path(projectFolderPath,"data/ont_raw/pilot2/No_Gtube/20250724_1536_3C_PAY03690_092497cc"),folderPathAnalysisOutputRaw = file.path(projectFolderPath,"work/pgx/pilot2/p2-nogtube"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/pilot2/p2-nogtube"))
pradaObj$collectAnalysisCallData("p2-gtube")
pradaObj$collectAnalysisCallData("p2-nogtube")
pradaObj$collectAnalysisDepthData("p2-gtube")
pradaObj$collectAnalysisDepthData("p2-nogtube")
pradaObj$computeDepthDataStatistics(filePathBed <- file.path(projectFolderPath,"data/bed/pgx_cnv.grch38.5k.2p1percent.bed"),filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/applicationCoverageRegionsAsOfPilot2.tsv"))
pradaObj$computeCallStatistics(filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/applicationCoverageRegionsAsOfPilot2.tsv"))
pradaObj$printData()
