#This is a comparison of PRS performance in GLAD+ across different coverage fractions

library(data.table)

#install.packages(c("Rcpp", "data.table", "stringi", "BH",  "RcppEigen"))
#install.packages("https://github.com/zhilizheng/SBayesRC/releases/download/v0.2.6/SBayesRC_0.2.6.tar.gz", repos=NULL, type="source") #this does not work
#devtools::install_github("https://github.com/zhilizheng/SBayesRC") #something wrong with the current package dependencies?


#command line parameters
commandArgs<-commandArgs(trailingOnly = TRUE)

selectedCode<-NULL
if(length(commandArgs)>0) selectedCode<-commandArgs(1)

if(!is.null(selectedCode)) cat("\nSelected code",commandArgs(1))


# All PRS analyses

setting_ld_folderPath<-"/scratch/prj/bioresource/recovered/Public/PRS/SBayesRC/ukbEUR_Imputed"        # LD reference (download from "Resources")
#setting_ld_folderPath<-"../data/ld_scores/ukbEUR_HM3"        # LD reference (download from "Resources")

setting_annot<-"../data/sbayesrc/annot_baseline2.2.zip"         # Functional annotation (download from "Resources")



setting_refFilePath<-"/scratch/prj/gwas_sumstats/variant_lists/hc1kgp3.b38.eur.l2.jz2024.gz"

setting_idatasetPlinkDatasetPath<-"/users/k19049801/project/prada_jz/data/geno/GLADv3_EDGIv1_NBRv2/imputed/bfiles/GLAD_EDGI_NBR"

setting_filepathPrsIncludeSnplist<-"snplistToIncludeInSBayesRC.txt"


metadata<-as.data.frame(matrix(NA,0,0))
metadata["MDDIDP",c("filepath")]<-c("/scratch/prj/ppn_tng/IDP_GWAS/meta_sumstats/meta_pgc/IDP_PGC_DSM_METAL_GWAMA_MDD_CHRBP2STUDS.txt.gz") #double check if this excludes the
metadata["BIPO03",c("filepath")]<-c("/scratch/prj/gwas_sumstats/original/pgc-bip2021-all.vcf2.tsv.gz")
metadata["ADHD06",c("filepath")]<-c("/scratch/prj/gwas_sumstats/original/ADHD_meta_Jan2022_iPSYCH1_iPSYCH2_deCODE_PGC.meta.gz")
metadata["SCHI06",c("filepath")]<-c("/scratch/prj/gwas_sumstats/original/SCHI06.gz")
metadata["SMOK11",c("filepath")]<-c("/scratch/prj/gwas_sumstats/original/GSCAN_CigDay_2022_GWAS_SUMMARY_STATS_EUR.txt.gz")

metadata$code<-rownames(metadata)
metadata$code.formatted<-paste0(metadata$code,".cojo")
filepath.code.formatted<-paste0(metadata$code.formatted,".gz")[[1]]


#already processed weights (Rujia's files)
# THESE ARE NOT THE SAME TRAITS AS FROM THE REPO
metadata["MDDIDP",c("weightfile")]<-c("/scratch/prj/ukbiobank/Rujia_2025/SBayesRC/IDP_PGC/IDP_PGC_DSM_meta/SAS/IDP_pgc_dsm_SAS_PRS_SBayesRC_sbrc.txt")
metadata["BIPO03",c("weightfile")]<-c("/scratch/prj/nihr_ukbiobank/recovered/UKB_GLAD_NBR/SBayesRC/prs_results/adhd/BIP2024noUKB_PRS_SBayesRC_sbrc.txt.gz")
metadata["ADHD06",c("weightfile")]<-c("/scratch/prj/nihr_ukbiobank/recovered/UKB_GLAD_NBR/SBayesRC/prs_results/adhd/ADHD_PRS_SBayesRC_sbrc.txt.gz")
metadata["SCHI06",c("weightfile")]<-c("/scratch/prj/nihr_ukbiobank/recovered/UKB_GLAD_NBR/SBayesRC/prs_results/scz/SCZnoUKB_PRS_SBayesRC_sbrc.txt.gz")
metadata["SMOK11",c("weightfile")]<-c(NA)


traitsForPGS<-c("MDDIDP","BIPO03","ADHD06","SCHI06")
fractions<-c("baseline","pgxcnv","5k","25k","50k","75k","100k")
fractionSuffixes<-c("_baseline","_5k.2p1percent","_5k.2p6percent","_25k.4p5percent","_50k.7p3percent","_75k.10p0percent","_100k.12p8percent")



metaToMunge<-metadata
if(!is.null(selectedCode)) metaToMunge<-metadata[selectedCode,]

if(!file.exists(filepath.code.formatted)){
  #munge
  mungeResults <- shru::supermunge(
    filePaths = metaToMunge$filepath,
    refFilePath = setting_refFilePath,
    traitNames = metaToMunge$code.formatted,
    outputFormat = "cojo"
  )
}

#fall back to the first item in metadata if nothing selected
if(is.null(selectedCode)) selectedCode<-metadata$code[[1]]

#we may want to set correct effective sample size here

#effective sample size
#https://github.com/GenomicSEM/GenomicSEM/wiki/2.1-Calculating-Sum-of-Effective-Sample-Size-and-Preparing-GWAS-Summary-Statistics
#samplePrevalence <- setting_n_cas/(setting_n_cas+setting_n_con)
#sampleEffectiveN <- 4*samplePrevalence*(1-samplePrevalence)*(setting_n_cas+setting_n_con)
cat("\ntidy ",filepath.code.formatted,"\n")
ma_filePath<-paste0(selectedCode,"_tidy.ma")
if(!file.exists(ma_filePath)){
  SBayesRC::tidy(mafile=filepath.code.formatted, LDdir=setting_ld_folderPath, output=ma_filePath) #rate2pq = 0.5 per default
}

imp_filePath<-paste0(selectedCode,"_imp.ma")
if(!file.exists(imp_filePath)){
  SBayesRC::impute(mafile=ma_filePath, LDdir=setting_ld_folderPath, output=imp_filePath)
}

imp2_filePath<-paste0(selectedCode,"_imp_tidy.ma")
if(!file.exists(imp2_filePath)){
  SBayesRC::tidy(mafile=imp_filePath, LDdir=setting_ld_folderPath, output=imp2_filePath)
}

# score_filePath<-paste0(selectedCode,'_sbrc')
# if(!file.exists(score_filePath)){
#   SBayesRC::sbayesrc(mafile=imp_filePath, LDdir=setting_ld_folderPath, outPrefix=score_filePath, annot=setting_annot)
#   #imp2_filePath
# }

#pgs tests
#

# #baseline
# for(iTrait in 1:length(traitsForPGS)){
#   cTrait<-traitsForPGS[iTrait]
#
#   cScoreFilePath<-paste0(cTrait,'_sbrc.txt')
#   #cScoreFilePath<-metadata[cTrait,]$weightfile
#   cOutPrefix<-paste0(cTrait,'_baseline_prs')
#
#   SBayesRC::prs(weight=cScoreFilePath, genoPrefix=setting_idatasetPlinkDatasetPath, out=cOutPrefix, genoCHR='')
#
# }

#PGX + CNV
#
# regionSelection<-data.table::fread(file = "/users/k19049801/project/prada_jz/data/bed/pgx_cnv.grch38.5k.2p1percent.bed", na.strings = c(".",NA, "NA", ""), encoding = "UTF-8",header = F, blank.lines.skip = T, data.table = T, nThread = 6,showProgress = F)
# data.table::setDT(regionSelection)
# data.table::setkeyv(regionSelection, cols = c("V1","V2","V3","V4"))
#
# ldVariants<-data.table::fread(file = file.path(setting_ld_folderPath,"snp.info"), na.strings = c(".",
#                                                                  NA, "NA", ""), encoding = "UTF-8", check.names = T,
#                            fill = T, blank.lines.skip = T, data.table = T, nThread = 6,
#                            showProgress = F)
# ldVariants[,CHR:=paste0("chr",Chrom)]
# data.table::setkeyv(ldVariants, cols = c("CHR","PhysPos","ID"))
# ldVariants[regionSelection,on=c(CHR="V1","PhysPos<=V3","PhysPos>=V2"),isIn:=i.V4]
# #nrow(ldVariants[!is.na(isIn),])
# #as.data.frame(ldVariants[!is.na(isIn),])$ID
#
# snplist<-ldVariants[!is.na(isIn),.(ID)]
# nrow(snplist)
# data.table::fwrite(snplist,file = setting_filepathPrsIncludeSnplist,append = F,sep = "\t",col.names = F, row.names = F)
#
# for(iTrait in 1:length(traitsForPGS)){
#   cTrait<-traitsForPGS[iTrait]
#
#   cScoreFilePath<-paste0(cTrait,'_sbrc.txt')
#   #cScoreFilePath<-metadata[cTrait,]$weightfile
#   cOutPrefix<-paste0(cTrait,'_5k.2p1percent_prs')
#
#   SBayesRC::prs(weight=cScoreFilePath, genoPrefix=setting_idatasetPlinkDatasetPath, out=cOutPrefix, genoCHR='',snplist = setting_filepathPrsIncludeSnplist)
#
# }

#
# #PGX + CNV + polygenic MDD, 5k variants total
# #pgx_cnv_mddeur.grch38.5k.2p6percent.bed
#
# regionSelection<-data.table::fread(file = "/users/k19049801/project/prada_jz/data/bed/pgx_cnv_mddeur.grch38.5k.2p6percent.bed", na.strings = c(".",NA, "NA", ""), encoding = "UTF-8",header = F, blank.lines.skip = T, data.table = T, nThread = 6,showProgress = F)
# data.table::setDT(regionSelection)
# data.table::setkeyv(regionSelection, cols = c("V1","V2","V3","V4"))
#
# ldVariants<-data.table::fread(file = file.path(setting_ld_folderPath,"snp.info"), na.strings = c(".",
#                                                                                                  NA, "NA", ""), encoding = "UTF-8", check.names = T,
#                               fill = T, blank.lines.skip = T, data.table = T, nThread = 6,
#                               showProgress = F)
# ldVariants[,CHR:=paste0("chr",Chrom)]
# data.table::setkeyv(ldVariants, cols = c("CHR","PhysPos","ID"))
# ldVariants[regionSelection,on=c(CHR="V1","PhysPos<=V3","PhysPos>=V2"),isIn:=i.V4]
# cat("\nNumber of PRS variants included: ",nrow(ldVariants[!is.na(isIn),]),"\n")
# #nrow(ldVariants[!is.na(isIn),])
# #as.data.frame(ldVariants[!is.na(isIn),])$ID
#
# snplist<-ldVariants[!is.na(isIn),.(ID)]
# nrow(snplist)
# data.table::fwrite(snplist,file = setting_filepathPrsIncludeSnplist,append = F,sep = "\t",col.names = F, row.names = F)
#
# for(iTrait in 1:length(traitsForPGS)){
#   cTrait<-traitsForPGS[iTrait]
#
#   cScoreFilePath<-paste0(cTrait,'_sbrc.txt')
#   #cScoreFilePath<-metadata[cTrait,]$weightfile
#   cOutPrefix<-paste0(cTrait,'_5k.2p6percent_prs')
#
#   SBayesRC::prs(weight=cScoreFilePath, genoPrefix=setting_idatasetPlinkDatasetPath, out=cOutPrefix, genoCHR='',snplist = setting_filepathPrsIncludeSnplist)
#
# }
#
#
#
# #PGX + CNV + polygenic MDD, 25k variants total
# #pgx_cnv_mddeur.grch38.25k.4p5percent.bed
#
# regionSelection<-data.table::fread(file = "/users/k19049801/project/prada_jz/data/bed/pgx_cnv_mddeur.grch38.25k.4p5percent.bed", na.strings = c(".",NA, "NA", ""), encoding = "UTF-8",header = F, blank.lines.skip = T, data.table = T, nThread = 6,showProgress = F)
# data.table::setDT(regionSelection)
# data.table::setkeyv(regionSelection, cols = c("V1","V2","V3","V4"))
#
# ldVariants<-data.table::fread(file = file.path(setting_ld_folderPath,"snp.info"), na.strings = c(".",
#                                                                                                  NA, "NA", ""), encoding = "UTF-8", check.names = T,
#                               fill = T, blank.lines.skip = T, data.table = T, nThread = 6,
#                               showProgress = F)
# ldVariants[,CHR:=paste0("chr",Chrom)]
# data.table::setkeyv(ldVariants, cols = c("CHR","PhysPos","ID"))
# ldVariants[regionSelection,on=c(CHR="V1","PhysPos<=V3","PhysPos>=V2"),isIn:=i.V4]
# cat("\nNumber of PRS variants included: ",nrow(ldVariants[!is.na(isIn),]),"\n")
# #nrow(ldVariants[!is.na(isIn),])
# #as.data.frame(ldVariants[!is.na(isIn),])$ID
#
# snplist<-ldVariants[!is.na(isIn),.(ID)]
# nrow(snplist)
# data.table::fwrite(snplist,file = setting_filepathPrsIncludeSnplist,append = F,sep = "\t",col.names = F, row.names = F)
#
# for(iTrait in 1:length(traitsForPGS)){
#   cTrait<-traitsForPGS[iTrait]
#
#   cScoreFilePath<-paste0(cTrait,'_sbrc.txt')
#   #cScoreFilePath<-metadata[cTrait,]$weightfile
#   cOutPrefix<-paste0(cTrait,'_25k.4p5percent_prs')
#
#   SBayesRC::prs(weight=cScoreFilePath, genoPrefix=setting_idatasetPlinkDatasetPath, out=cOutPrefix, genoCHR='',snplist = setting_filepathPrsIncludeSnplist)
#
# }
#
# #PGX + CNV + polygenic MDD, 50k variants total
# #pgx_cnv_mddeur.grch38.50k.7p3percent.bed
#
# regionSelection<-data.table::fread(file = "/users/k19049801/project/prada_jz/data/bed/pgx_cnv_mddeur.grch38.50k.7p3percent.bed", na.strings = c(".",NA, "NA", ""), encoding = "UTF-8",header = F, blank.lines.skip = T, data.table = T, nThread = 6,showProgress = F)
# data.table::setDT(regionSelection)
# data.table::setkeyv(regionSelection, cols = c("V1","V2","V3","V4"))
#
# ldVariants<-data.table::fread(file = file.path(setting_ld_folderPath,"snp.info"), na.strings = c(".",
#                                                                                                  NA, "NA", ""), encoding = "UTF-8", check.names = T,
#                               fill = T, blank.lines.skip = T, data.table = T, nThread = 6,
#                               showProgress = F)
# ldVariants[,CHR:=paste0("chr",Chrom)]
# data.table::setkeyv(ldVariants, cols = c("CHR","PhysPos","ID"))
# ldVariants[regionSelection,on=c(CHR="V1","PhysPos<=V3","PhysPos>=V2"),isIn:=i.V4]
# cat("\nNumber of PRS variants included: ",nrow(ldVariants[!is.na(isIn),]),"\n")
# #nrow(ldVariants[!is.na(isIn),])
# #as.data.frame(ldVariants[!is.na(isIn),])$ID
#
# snplist<-ldVariants[!is.na(isIn),.(ID)]
# nrow(snplist)
# data.table::fwrite(snplist,file = setting_filepathPrsIncludeSnplist,append = F,sep = "\t",col.names = F, row.names = F)
#
# for(iTrait in 1:length(traitsForPGS)){
#   cTrait<-traitsForPGS[iTrait]
#
#   cScoreFilePath<-paste0(cTrait,'_sbrc.txt')
#   #cScoreFilePath<-metadata[cTrait,]$weightfile
#   cOutPrefix<-paste0(cTrait,'_50k.7p3percent_prs')
#
#   SBayesRC::prs(weight=cScoreFilePath, genoPrefix=setting_idatasetPlinkDatasetPath, out=cOutPrefix, genoCHR='',snplist = setting_filepathPrsIncludeSnplist)
#
# }
#
# #PGX + CNV + polygenic MDD, 75k variants total
# #pgx_cnv_mddeur.grch38.75k.10p0percent.bed
#
# regionSelection<-data.table::fread(file = "/users/k19049801/project/prada_jz/data/bed/pgx_cnv_mddeur.grch38.75k.10p0percent.bed", na.strings = c(".",NA, "NA", ""), encoding = "UTF-8",header = F, blank.lines.skip = T, data.table = T, nThread = 6,showProgress = F)
# data.table::setDT(regionSelection)
# data.table::setkeyv(regionSelection, cols = c("V1","V2","V3","V4"))
#
# ldVariants<-data.table::fread(file = file.path(setting_ld_folderPath,"snp.info"), na.strings = c(".",
#                                                                                                  NA, "NA", ""), encoding = "UTF-8", check.names = T,
#                               fill = T, blank.lines.skip = T, data.table = T, nThread = 6,
#                               showProgress = F)
# ldVariants[,CHR:=paste0("chr",Chrom)]
# data.table::setkeyv(ldVariants, cols = c("CHR","PhysPos","ID"))
# ldVariants[regionSelection,on=c(CHR="V1","PhysPos<=V3","PhysPos>=V2"),isIn:=i.V4]
# cat("\nNumber of PRS variants included: ",nrow(ldVariants[!is.na(isIn),]),"\n")
# #nrow(ldVariants[!is.na(isIn),])
# #as.data.frame(ldVariants[!is.na(isIn),])$ID
#
# snplist<-ldVariants[!is.na(isIn),.(ID)]
# nrow(snplist)
# data.table::fwrite(snplist,file = setting_filepathPrsIncludeSnplist,append = F,sep = "\t",col.names = F, row.names = F)
#
# for(iTrait in 1:length(traitsForPGS)){
#   cTrait<-traitsForPGS[iTrait]
#
#   cScoreFilePath<-paste0(cTrait,'_sbrc.txt')
#   #cScoreFilePath<-metadata[cTrait,]$weightfile
#   cOutPrefix<-paste0(cTrait,'_75k.10p0percent_prs')
#
#   SBayesRC::prs(weight=cScoreFilePath, genoPrefix=setting_idatasetPlinkDatasetPath, out=cOutPrefix, genoCHR='',snplist = setting_filepathPrsIncludeSnplist)
#
# }
#
# #PGX + CNV + polygenic MDD, 100k variants total
# #pgx_cnv_mddeur.grch38.100k.12p8percent.bed
#
# regionSelection<-data.table::fread(file = "/users/k19049801/project/prada_jz/data/bed/pgx_cnv_mddeur.grch38.100k.12p8percent.bed", na.strings = c(".",NA, "NA", ""), encoding = "UTF-8",header = F, blank.lines.skip = T, data.table = T, nThread = 6,showProgress = F)
# data.table::setDT(regionSelection)
# data.table::setkeyv(regionSelection, cols = c("V1","V2","V3","V4"))
#
# ldVariants<-data.table::fread(file = file.path(setting_ld_folderPath,"snp.info"), na.strings = c(".",
#                                                                                                  NA, "NA", ""), encoding = "UTF-8", check.names = T,
#                               fill = T, blank.lines.skip = T, data.table = T, nThread = 6,
#                               showProgress = F)
# ldVariants[,CHR:=paste0("chr",Chrom)]
# data.table::setkeyv(ldVariants, cols = c("CHR","PhysPos","ID"))
# ldVariants[regionSelection,on=c(CHR="V1","PhysPos<=V3","PhysPos>=V2"),isIn:=i.V4]
# cat("\nNumber of PRS variants included: ",nrow(ldVariants[!is.na(isIn),]),"\n")
# #nrow(ldVariants[!is.na(isIn),])
# #as.data.frame(ldVariants[!is.na(isIn),])$ID
#
# snplist<-ldVariants[!is.na(isIn),.(ID)]
# nrow(snplist)
# data.table::fwrite(snplist,file = setting_filepathPrsIncludeSnplist,append = F,sep = "\t",col.names = F, row.names = F)
#
# for(iTrait in 1:length(traitsForPGS)){
#   cTrait<-traitsForPGS[iTrait]
#
#   cScoreFilePath<-paste0(cTrait,'_sbrc.txt')
#   #cScoreFilePath<-metadata[cTrait,]$weightfile
#   cOutPrefix<-paste0(cTrait,'_100k.12p8percent_prs')
#
#   SBayesRC::prs(weight=cScoreFilePath, genoPrefix=setting_idatasetPlinkDatasetPath, out=cOutPrefix, genoCHR='',snplist = setting_filepathPrsIncludeSnplist)
#
# }


#read this again
ldVariants<-data.table::fread(file = file.path(setting_ld_folderPath,"snp.info"), na.strings = c(".",
                                                                 NA, "NA", ""), encoding = "UTF-8", check.names = T,
                           fill = T, blank.lines.skip = T, data.table = T, nThread = 6,
                           showProgress = F)
ldVariants[,CHR:=paste0("chr",Chrom)]
data.table::setkeyv(ldVariants, cols = c("CHR","PhysPos","ID"))




#scores
allScores<-c()
for(iFraction in 1:length(fractions)){
  cFraction<-fractions[iFraction]
  cFractionSuffix<-fractionSuffixes[iFraction]

  scores.fraction<-NULL

  for(iTrait in 1:length(traitsForPGS)){
    cTraitCode<-traitsForPGS[iTrait]
    filepathScore<-paste0(cTraitCode,cFractionSuffix,"_prs.score.txt")
    cat("\n",filepathScore)
    scoreResults<-data.table::fread(file = filepathScore, na.strings = c(".",
                                                                                                     NA, "NA", ""), encoding = "UTF-8", check.names = T,
                                  fill = T, blank.lines.skip = T, data.table = T, nThread = 6,
                                  showProgress = F)

    if(is.null(scores.fraction)){
      scores.fraction<-scoreResults[,.(FID,IID)]
      data.table::setkeyv(scores.fraction, cols = c("FID","IID"))
    }

    scores.fraction[scoreResults, on=c("FID","IID"),c(cTraitCode):=list(i.SCORE)]


    allScores[cFraction]<-list(as.data.frame(scores.fraction))

  }
}

saveRDS(allScores,file = "prs-check-gladp.allScores.Rds")

allScores<-readRDS("prs-check-gladp.allScores.Rds")


results.correlations<-as.data.frame(matrix(data = NA,nrow = 0,ncol = 0))
for(iTrait in 1:length(traitsForPGS)){
  #iTrait<-1
  cTraitCode<-traitsForPGS[iTrait]
  cat("\n",cTraitCode,"\n")
  blT<-allScores["baseline"][[1]]
  setDT(blT)
  setkeyv(blT, cols = c("FID","IID"))
  for(iFraction in 2:length(fractions)){ #from baseline + 1
    cFraction<-fractions[iFraction]
    cat("\n",cFraction,"\n")
    cT<-allScores[cFraction][[1]]
    setDT(cT)
    setkeyv(cT, cols = c("FID","IID"))
    testResult <- cor.test(unlist(blT[,..cTraitCode]),unlist(cT[,..cTraitCode]))
    results.correlations[cFraction,cTraitCode]<-testResult$estimate
  }
}
# if(!file.exists(setting_PRS_covar_filePath)){
#   # Polygenic risk score
#   # genoPrefix="test_chr{CHR}" # {CHR} means multiple genotype file.
#   ## If just one genotype, input the full prefix genoPrefix="test"
#   # genoCHR="1-22,X" ## means {CHR} expands to 1-22 and X,
#   ## if just one genotype file, input genoCHR=""
#   # output="test"
#   SBayesRC::prs(weight=setting_score_filePath, genoPrefix='CSSB_Apr_LC12+_fix', out='business', genoCHR='')
# }
#
# originalFAM <- shru::readFile(setting_originalFAMFilePath,nThreads = 6)
# toTest <- shru::readFile(setting_PRS_covar_filePath, nThreads = 6)
# toTest[originalFAM,on=c(FID="V1",IID="V2"),c('SEX','PHENO') := list(i.V5,i.V6)]
# toTest[,PHENO:=PHENO-1]
# toTest<-as.data.frame(toTest)
# toTest$SCORE_SCALED<-scale(toTest$SCORE,center = T)
# quantile(toTest$SCORE_SCALED)
#
# #toTest$PHENO<-as.factor(toTest$PHENO)
# #toTest$SEX<-as.factor(toTest$SEX)
# #testing
# model1 <- glm(PHENO ~ SCORE_SCALED,family=binomial(link='logit'),data=toTest,maxit=100)
# summary(model1)
# model2 <- glm(PHENO ~ SCORE_SCALED + SEX,family=binomial(link='logit'),data=toTest,maxit=100)
# summary(model2)
# model3 <- glm(PHENO ~ SCORE_SCALED, data=toTest,maxit=100)
# summary(model3)
# cor.test(toTest$PHENO, toTest$SCORE_SCALED)
#
# plot(toTest$SCORE_SCALED,toTest$PHENO)
#
#




