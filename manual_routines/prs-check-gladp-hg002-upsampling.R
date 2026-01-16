#This is a comparison of PRS performance in GLAD+ across different coverage fractions


library(data.table)

#install.packages(c("Rcpp", "data.table", "stringi", "BH",  "RcppEigen"))
#install.packages("https://github.com/zhilizheng/SBayesRC/releases/download/v0.2.6/SBayesRC_0.2.6.tar.gz", repos=NULL, type="source") #this does not work
#devtools::install_github("https://github.com/zhilizheng/SBayesRC") #something wrong with the current package dependencies?
#remotes::install_github("https://github.com/johanzvrskovec/SBayesRC",ref='dev_jz') #use edited version that builds on new R


#command line parameters
commandArgs<-commandArgs(trailingOnly = TRUE)
if(length(commandArgs)>0) {
  cat("\nRunning command ",commandArgs(TRUE))
}

actionCommand<-NULL
if(length(commandArgs)>0) actionCommand<-commandArgs[1] else actionCommand = ""

selectedCode<-NULL
if(length(commandArgs)>1) selectedCode<-commandArgs[2]

if(!is.null(selectedCode)) cat("\nSelected code",selectedCode)


# All PRS analyses

setting_project_folderpath <- "/scratch/prj/sgdp_nanopore/Projects/prada_jz"
setting_ld_folderPath<-"/scratch/prj/bioresource/recovered/Public/PRS/SBayesRC/ukbEUR_Imputed"        # LD reference (download from "Resources")
#setting_ld_folderPath<-"../data/ld_scores/ukbEUR_HM3"        # LD reference (download from "Resources")

setting_annot<-"/scratch/prj/gwas_sumstats/variant_lists/sbayesrc/annot_baseline2.2.zip"         # Functional annotation (download from "Resources")



setting_refFilePath<-"/scratch/prj/gwas_sumstats/variant_lists/hc1kgp3.b38.eur.l2.jz2024.gz"

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
fractions<-c("05","10","15","20","25","50","75","100")


if(actionCommand=="munge"){
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
  quit(save='no')
}

#fall back to the first item in metadata if nothing selected beyond this point
if(is.null(selectedCode)) selectedCode<-metadata$code[[1]]

if(actionCommand=="tidyimpute"){
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

  quit(save='no')
}

if(actionCommand=="weights"){

  score_filePath<-paste0(selectedCode,'_sbrc')
  if(!file.exists(score_filePath)){
    SBayesRC::sbayesrc(mafile=imp_filePath, LDdir=setting_ld_folderPath, outPrefix=score_filePath, annot=setting_annot)
    #imp2_filePath
  }
  quit(save='no')
}


#pgs tests
#

if(actionCommand=="score"){

  cat("\nScoring individuals\n")
  #per fraction
  #for(iFraction in 1:length(fraction)){
    #iFraction<-1
    #cFraction<-fractions[iFraction]
    for(iTrait in 1:length(traitsForPGS)){
      #iTrait<-1
      cTrait<-traitsForPGS[iTrait]

      if(is.null(selectedCode) | (!is.null(selectedCode) & selectedCode==cTrait)){
        cat("\nScoring trait ",selectedCode,"\n")
        cScoreFilePath<-paste0(cTrait,'_sbrc.txt')
        #cScoreFilePath<-metadata[cTrait,]$weightfile
        #cOutPrefix<-paste0('hg002_',cFraction,'_',cTrait)
        cOutPrefix<-paste0('hg002-multisampled_',cTrait)

        #cFreqFilePath<-"/scratch/prj/gwas_sumstats/reference_panel/1kg_bed/1KG_Phase3.WG.CLEANED.EUR_MAF001.CM23.frq.frq" #grch37
        cFreqFilePath<-"/scratch/prj/gwas_sumstats/reference_panel/hc1kgp3.b38.plink/1kGP_high_coverage_Illumina.filtered.SNV_INDEL_SV_phased_panel.frq.frq"

        #cPlinkDatasetPath<-paste0("hg002-upsampled-",cFraction)
        #cPlinkDatasetPath<-"/users/k2481717/project/prada_jz/data/geno/GLADv3_EDGIv1_NBRv2/imputed/bfiles/GLAD_EDGI_NBR" #for testing
        cPlinkDatasetPath<-"hg002-multisampled"
        SBayesRC::prs(weight=cScoreFilePath, genoPrefix=cPlinkDatasetPath, outPrefix = cOutPrefix ,freqFile = cFreqFilePath)

      }

    }
  #}

  quit(save='no')
}

#
# #read this again
# ldVariants<-data.table::fread(file = file.path(setting_ld_folderPath,"snp.info"), na.strings = c(".",
#                                                                  NA, "NA", ""), encoding = "UTF-8", check.names = T,
#                            fill = T, blank.lines.skip = T, data.table = T, nThread = 6,
#                            showProgress = F)
# ldVariants[,CHR:=paste0("chr",Chrom)]
# data.table::setkeyv(ldVariants, cols = c("CHR","PhysPos","ID"))
#
#
#
#
# #scores
# allScores<-c()
# for(iFraction in 1:length(fractions)){
#   cFraction<-fractions[iFraction]
#   cFractionSuffix<-fractionSuffixes[iFraction]
#
#   scores.fraction<-NULL
#
#   for(iTrait in 1:length(traitsForPGS)){
#     cTraitCode<-traitsForPGS[iTrait]
#     filepathScore<-paste0(cTraitCode,cFractionSuffix,"_prs.score.txt")
#     cat("\n",filepathScore)
#     scoreResults<-data.table::fread(file = filepathScore, na.strings = c(".",
#                                                                                                      NA, "NA", ""), encoding = "UTF-8", check.names = T,
#                                   fill = T, blank.lines.skip = T, data.table = T, nThread = 6,
#                                   showProgress = F)
#
#     if(is.null(scores.fraction)){
#       scores.fraction<-scoreResults[,.(FID,IID)]
#       data.table::setkeyv(scores.fraction, cols = c("FID","IID"))
#     }
#
#     scores.fraction[scoreResults, on=c("FID","IID"),c(cTraitCode):=list(i.SCORE)]
#
#
#     allScores[cFraction]<-list(as.data.frame(scores.fraction))
#
#   }
# }
#
# saveRDS(allScores,file = "prs-check-gladp.allScores.Rds")
#
# allScores<-readRDS("prs-check-gladp.allScores.Rds")
#
#
# results.correlations<-as.data.frame(matrix(data = NA,nrow = 0,ncol = 0))
# for(iTrait in 1:length(traitsForPGS)){
#   #iTrait<-1
#   cTraitCode<-traitsForPGS[iTrait]
#   cat("\n",cTraitCode,"\n")
#   blT<-allScores["baseline"][[1]]
#   setDT(blT)
#   setkeyv(blT, cols = c("FID","IID"))
#   for(iFraction in 2:length(fractions)){ #from baseline + 1
#     cFraction<-fractions[iFraction]
#     cat("\n",cFraction,"\n")
#     cT<-allScores[cFraction][[1]]
#     setDT(cT)
#     setkeyv(cT, cols = c("FID","IID"))
#     testResult <- cor.test(unlist(blT[,..cTraitCode]),unlist(cT[,..cTraitCode]))
#     results.correlations[cFraction,cTraitCode]<-testResult$estimate
#   }
# }
# # if(!file.exists(setting_PRS_covar_filePath)){
# #   # Polygenic risk score
# #   # genoPrefix="test_chr{CHR}" # {CHR} means multiple genotype file.
# #   ## If just one genotype, input the full prefix genoPrefix="test"
# #   # genoCHR="1-22,X" ## means {CHR} expands to 1-22 and X,
# #   ## if just one genotype file, input genoCHR=""
# #   # output="test"
# #   SBayesRC::prs(weight=setting_score_filePath, genoPrefix='CSSB_Apr_LC12+_fix', out='business', genoCHR='')
# # }
# #
# # originalFAM <- shru::readFile(setting_originalFAMFilePath,nThreads = 6)
# # toTest <- shru::readFile(setting_PRS_covar_filePath, nThreads = 6)
# # toTest[originalFAM,on=c(FID="V1",IID="V2"),c('SEX','PHENO') := list(i.V5,i.V6)]
# # toTest[,PHENO:=PHENO-1]
# # toTest<-as.data.frame(toTest)
# # toTest$SCORE_SCALED<-scale(toTest$SCORE,center = T)
# # quantile(toTest$SCORE_SCALED)
# #
# # #toTest$PHENO<-as.factor(toTest$PHENO)
# # #toTest$SEX<-as.factor(toTest$SEX)
# # #testing
# # model1 <- glm(PHENO ~ SCORE_SCALED,family=binomial(link='logit'),data=toTest,maxit=100)
# # summary(model1)
# # model2 <- glm(PHENO ~ SCORE_SCALED + SEX,family=binomial(link='logit'),data=toTest,maxit=100)
# # summary(model2)
# # model3 <- glm(PHENO ~ SCORE_SCALED, data=toTest,maxit=100)
# # summary(model3)
# # cor.test(toTest$PHENO, toTest$SCORE_SCALED)
# #
# # plot(toTest$SCORE_SCALED,toTest$PHENO)
# #
# #
#



