#unified plotting

#devtools::install_github("tnggroup/prada")
#devtools::install_github("tnggroup/prada",ref = 'jz_dev')
library(prada)
library(data.table)
library(vcfR)

projectFolderPath<-"/scratch/prj/sgdp_nanopore/Projects/prada_jz"
#projectFolderPath<-"/Users/jakz/Documents/work_rstudio/prada" #local

dAnalysis <- fread(file.path(projectFolderPath,"data","pradaApp","prada_sequencing_run_database.analysis.tsv.txt"))
dSample <- fread(file.path(projectFolderPath,"data","pradaApp","prada_sequencing_run_database.sample.tsv.txt"))

#reference H (HG002)
dSampleVCF<-read.vcfR(file.path(projectFolderPath,"work","pgx","downsampled-bam-runs","truth-set","HG002_GRCh38_1_22_v4.2.1_benchmark.vcf.gz"), verbose = F)
dSampleVCF.H<-as.data.frame(getFIX(dSampleVCF))
dSampleVCF.H<-dSampleVCF.H[dSampleVCF.H$CHROM=="chr1",] #subset to chr1
dSamplePGX.H<-fread(file.path(projectFolderPath,"work","pradaApp","downsampled-bam-runs","pgxCallsAggCustom_multi-hg002-100_HG002_new_hg19_merged_hg38.tsv"))
setDT(dSampleVCF.H)
setkeyv(dSampleVCF.H,c("CHROM","POS","REF","ALT"))

#reference A
dSampleVCF<-read.vcfR(file.path(projectFolderPath,dAnalysis[`analysis id`=="p10-wgs-A",c("pathAnalysisOutput")],"output","Prada_WGS_Sample_A",paste0("Prada_WGS_Sample_A",".filtered.vcf.gz")), verbose = F)
dSampleVCF.A<-as.data.frame(getFIX(dSampleVCF))
dSampleVCF.A<-dSampleVCF.A[dSampleVCF.A$CHROM=="chr1",] #subset to chr1
dSamplePGX.A<-fread(file.path(projectFolderPath,"work","pradaApp","pilot10","pgxCallsAggCustom_p10-wgs-A_Prada_WGS_Sample_A.tsv"))
setDT(dSampleVCF.A)
setkeyv(dSampleVCF.A,c("CHROM","POS","REF","ALT"))

#reference B
dSampleVCF<-read.vcfR(file.path(projectFolderPath,dAnalysis[`analysis id`=="p10-wgs-B",c("pathAnalysisOutput")],"output","Prada_WGS_Sample_B",paste0("Prada_WGS_Sample_B",".filtered.vcf.gz")), verbose = F)
dSampleVCF.B<-as.data.frame(getFIX(dSampleVCF))
dSampleVCF.B<-dSampleVCF.B[dSampleVCF.B$CHROM=="chr1",] #subset to chr1
dSamplePGX.B<-fread(file.path(projectFolderPath,"work","pradaApp","pilot10","pgxCallsAggCustom_p10-wgs-B_Prada_WGS_Sample_B.tsv"))
setDT(dSampleVCF.B)
setkeyv(dSampleVCF.B,c("CHROM","POS","REF","ALT"))

#reference C
dSampleVCF<-read.vcfR(file.path(projectFolderPath,dAnalysis[`analysis id`=="p10-wgs-C",c("pathAnalysisOutput")],"output","Prada_WGS_Sample_C",paste0("Prada_WGS_Sample_C",".filtered.vcf.gz")), verbose = F)
dSampleVCF.C<-as.data.frame(getFIX(dSampleVCF))
dSampleVCF.C<-dSampleVCF.C[dSampleVCF.C$CHROM=="chr1",] #subset to chr1
dSamplePGX.C<-fread(file.path(projectFolderPath,"work","pradaApp","pilot10","pgxCallsAggCustom_p10-wgs-C_Prada_WGS_Sample_C.tsv"))
setDT(dSampleVCF.C)
setkeyv(dSampleVCF.C,c("CHROM","POS","REF","ALT"))

for(iSample in 1:nrow(dSample)){
  #iSample<-1
  cSampleID<-dSample[iSample,c("barcode")]
  cAnalysisID<-dSample[iSample,c("analysis")]
  cPilotID<-dAnalysis[`analysis id`==eval(cAnalysisID),c("pilot id")]
  cPathAnalysisOutput<-dAnalysis[`analysis id`==eval(cAnalysisID),c("pathAnalysisOutput")]

  # dSampleVCF.result<-shru::supermunge(filePaths = file.path(projectFolderPath,cPathAnalysisOutput,"output",cSampleID,paste0(cSampleID,".filtered.vcf.gz")),traitNames = cSampleID,writeOutput = F)
  # dSampleVCF<-dSampleVCF.result$last

  knownReference<-NA

  filePathVCF <- file.path(projectFolderPath,cPathAnalysisOutput,"output",cSampleID,paste0(cSampleID,".filtered.vcf.gz"))
  if(file.exists(filePathVCF)){
    dSampleVCF<-read.vcfR(filePathVCF, verbose = F)
    dSampleVCF.fix<-as.data.frame(getFIX(dSampleVCF))
    dSampleVCF.fix<-dSampleVCF.fix[dSampleVCF.fix$CHROM=="chr1",] #subset to chr1
    setDT(dSampleVCF.fix)
    setkeyv(dSampleVCF.fix,c("CHROM","POS","REF","ALT"))

  } else {
    #assume hg002
    dSampleVCF.fix <- dSampleVCF.H
    knownReference<-"H"
  }





  mostCredibleReference<-"NA"
  ratioOfMostCredibleReference<-0

  if(is.na(knownReference)){
    for(cComparison in c("H","A","B","C")){
      #cComparison<-"H"
      dSampleVCF.REF<-dSampleVCF.H
      if(cComparison=="H") dSampleVCF.REF<-dSampleVCF.H
      if(cComparison=="A") dSampleVCF.REF<-dSampleVCF.A
      if(cComparison=="B") dSampleVCF.REF<-dSampleVCF.B
      if(cComparison=="C") dSampleVCF.REF<-dSampleVCF.C

      colnames(dSampleVCF.REF)<-paste0(colnames(dSampleVCF.REF),".REF")

      dSampleVCF.fix.merged <- dSampleVCF.fix[dSampleVCF.REF, on=.(CHROM=CHROM.REF,POS=POS.REF)]

      mREF<-nrow(dSampleVCF.REF)
      mConcordantREF<-nrow(dSampleVCF.fix.merged[REF==REF.REF,])
      mConcordantALT<-nrow(dSampleVCF.fix.merged[ALT==ALT.REF,])
      mDiscordantREF<-nrow(dSampleVCF.fix.merged[REF!=REF.REF,])
      mDiscordantALT<-nrow(dSampleVCF.fix.merged[ALT!=ALT.REF,])

      evaluationRatio<-(mConcordantREF+1000*mConcordantALT-mDiscordantREF-1000*mDiscordantALT)/mREF
      if(evaluationRatio>ratioOfMostCredibleReference){
        mostCredibleReference<-cComparison
        ratioOfMostCredibleReference<-evaluationRatio
      }

      dSample[iSample,c(
        paste0("mREF.",cComparison),
        paste0("mConcordantREF.",cComparison),
        paste0("mConcordantALT.",cComparison),
        paste0("mDiscordantREF.",cComparison),
        paste0("mDiscordantALT.",cComparison)
      ):=list(mREF,mConcordantREF,mConcordantALT,mDiscordantREF,mDiscordantALT)]

    }
  } else {
    mostCredibleReference<-knownReference
  }

  dSample[iSample,c("mostCredibleReference"):=list(mostCredibleReference)]


  dSamplePGX<-fread(file.path(projectFolderPath,"work","pradaApp", cPilotID ,paste0("pgxCallsAggCustom_",cAnalysisID,"_",cSampleID,".tsv")))
  dSamplePGX.REF<-dSamplePGX.H
  if(mostCredibleReference=="H") dSamplePGX.REF<-dSamplePGX.H
  if(mostCredibleReference=="A") dSamplePGX.REF<-dSamplePGX.A
  if(mostCredibleReference=="B") dSamplePGX.REF<-dSamplePGX.B
  if(mostCredibleReference=="C") dSamplePGX.REF<-dSamplePGX.C

  colnames(dSamplePGX.REF)<-paste0(colnames(dSamplePGX.REF),".REF")
  dSamplePGX.merged <- dSamplePGX[dSamplePGX.REF, on=.(gene=gene.REF,chromosome_top=chromosome_top.REF)]
  allGeneCalls<-dSamplePGX.merged[,.(gene)]
  matchingGeneCalls<-dSamplePGX.merged[diplotype_name_top==diplotype_name_top.REF,.(gene)]
  matchingCond<-unlist(allGeneCalls) %in% unlist(matchingGeneCalls)

  allGeneCalls.columns<-paste0("GENE_CALL_",unlist(allGeneCalls))
  dSample[iSample,allGeneCalls.columns]<-0
  dSample[iSample,allGeneCalls.columns[matchingCond]]<-1

  shru::writeFile(dSample,file=file.path(projectFolderPath,"work","pradaApp","per-sample-analysis","samples.tsv"),nThreads = 5)

}


