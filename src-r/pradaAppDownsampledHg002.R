
#devtools::install_github("tnggroup/prada")
#devtools::install_github("tnggroup/prada",ref = 'jz_dev')
#install.packages("ggstats") #this is not installed automatically with packages for some reason. - added now to namespace.

library(prada)
library(data.table)

projectFolderPath<-"/scratch/prj/sgdp_nanopore/Projects/prada_jz"
pradaObj<-PradaClass()

pradaObj$addAnalysisSetting(settingLabel = "multi-hg002-100",folderPathAnalysisSequencingRaw = NA,folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/downsampled-bam-runs/test-2/wf-pgx/bed/hg002-100-p3"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/downsampled-bam-runs/multi-hg002-100"))
pradaObj$addSampleSetting(analysis = "multi-hg002-100",sampleLabel = "HG002_new_hg19_merged_hg38")
pradaObj$addAnalysisSetting(settingLabel = "multi-hg002-75",folderPathAnalysisSequencingRaw = NA,folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/downsampled-bam-runs/test-2/wf-pgx/bed/hg002-75-p3"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/downsampled-bam-runs/multi-hg002-75"))
pradaObj$addSampleSetting(analysis = "multi-hg002-75",sampleLabel = "HG002_new_hg19_merged")
pradaObj$addAnalysisSetting(settingLabel = "multi-hg002-50",folderPathAnalysisSequencingRaw = NA,folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/downsampled-bam-runs/test-2/wf-pgx/bed/hg002-50-p3"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/downsampled-bam-runs/multi-hg002-50"))
pradaObj$addSampleSetting(analysis = "multi-hg002-50",sampleLabel = "HG002_new_hg19_merged")
pradaObj$addAnalysisSetting(settingLabel = "multi-hg002-25",folderPathAnalysisSequencingRaw = NA,folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/downsampled-bam-runs/test-2/wf-pgx/bed/hg002-25-p3"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/downsampled-bam-runs/multi-hg002-25"))
pradaObj$addSampleSetting(analysis = "multi-hg002-25",sampleLabel = "HG002_new_hg19_merged")
pradaObj$addAnalysisSetting(settingLabel = "multi-hg002-20",folderPathAnalysisSequencingRaw = NA,folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/downsampled-bam-runs/test-2/wf-pgx/bed/hg002-20-p3"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/downsampled-bam-runs/multi-hg002-20"))
pradaObj$addSampleSetting(analysis = "multi-hg002-20",sampleLabel = "HG002_new_hg19_merged")
pradaObj$addAnalysisSetting(settingLabel = "multi-hg002-15",folderPathAnalysisSequencingRaw = NA,folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/downsampled-bam-runs/test-2/wf-pgx/bed/hg002-15-p3"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/downsampled-bam-runs/multi-hg002-15"))
pradaObj$addSampleSetting(analysis = "multi-hg002-15",sampleLabel = "HG002_new_hg19_merged")
pradaObj$addAnalysisSetting(settingLabel = "multi-hg002-10",folderPathAnalysisSequencingRaw = NA,folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/downsampled-bam-runs/test-2/wf-pgx/bed/hg002-10-p3"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/downsampled-bam-runs/multi-hg002-10"))
pradaObj$addSampleSetting(analysis = "multi-hg002-10",sampleLabel = "HG002_new_hg19_merged")
pradaObj$addAnalysisSetting(settingLabel = "multi-hg002-5",folderPathAnalysisSequencingRaw = NA,folderPathAnalysisOutputRaw = file.path(projectFolderPath, "work/pgx/downsampled-bam-runs/test-2/wf-pgx/bed/hg002-05-p3"),folderPathDepthAnalysisOutputRaw = file.path(projectFolderPath,"work/mosdepth/downsampled-bam-runs/multi-hg002-5"))
pradaObj$addSampleSetting(analysis = "multi-hg002-5",sampleLabel = "HG002_new_hg19_merged")



pradaObj$collectAnalysisCallData("multi-hg002-100")
pradaObj$collectAnalysisDepthData("multi-hg002-100")
pradaObj$collectAnalysisCallData("multi-hg002-75")
pradaObj$collectAnalysisDepthData("multi-hg002-75")
pradaObj$collectAnalysisCallData("multi-hg002-50")
pradaObj$collectAnalysisDepthData("multi-hg002-50")
pradaObj$collectAnalysisCallData("multi-hg002-25")
pradaObj$collectAnalysisDepthData("multi-hg002-25")
pradaObj$collectAnalysisCallData("multi-hg002-20")
pradaObj$collectAnalysisDepthData("multi-hg002-20")
pradaObj$collectAnalysisCallData("multi-hg002-15")
pradaObj$collectAnalysisDepthData("multi-hg002-15")
pradaObj$collectAnalysisCallData("multi-hg002-10")
pradaObj$collectAnalysisDepthData("multi-hg002-10")
pradaObj$collectAnalysisCallData("multi-hg002-5")
pradaObj$collectAnalysisDepthData("multi-hg002-5")

pradaObj$computeDepthDataStatistics(filePathBed <- file.path(projectFolderPath,"data/bed/pgx.grch38.5k.0p7percent.bed"),filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv"))
pradaObj$computeCallStatistics(filePathApplicationCoverageRegions = file.path(projectFolderPath,"data/roughApplicationCoverageRegionsAsOfPilot3.tsv"))
pradaObj$printData()
