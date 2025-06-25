#Functions to compute the genome coverage
#

# writeToThisBedPath=NULL
# paddingGeneBp=10000
# paddingVariantCnvBp=10000
# paddingVariantSnpBp=5000
# paddingGroupFinal=10000
# nPrioritisedGene=300
# nPrioritisedCnv=100
# nPrioritisedSnp=200000
# nPrioritisedTotal=5000
# wGene=1e20
# wVariantCnv=1e6
# wVariantSnp=1

PradaClass$methods(
computeGenomeCoverage=function(
    writeToThisBedPath=NULL,
    paddingGeneBp=10000,
    paddingVariantCnvBp=10000,
    paddingVariantSnpBp=5000,
    paddingGroupFinal=10000,
    nPrioritisedGene=300,
    nPrioritisedCnv=100,
    nPrioritisedSnp=200000,
    nPrioritisedTotal=25000,
    wGene=1e20,
    wVariantCnv=1e7,
    wVariantSnp=1
    ){
  #pradaApplicationDAO<-pradaO$pradaApplicationDAO
  applicationCoverageRegions<<-pradaApplicationDAO$selectApplicationCoverageRegions(
    paddingGeneBp=paddingGeneBp,
    paddingVariantCnvBp=paddingVariantCnvBp,
    paddingVariantSnpBp=paddingVariantSnpBp,
    nPrioritisedGene=nPrioritisedGene,
    nPrioritisedCnv=nPrioritisedCnv,
    nPrioritisedSnp=nPrioritisedSnp,
    nPrioritisedTotal=nPrioritisedTotal,
    wGene=wGene,
    wVariantCnv=wVariantCnv,
    wVariantSnp=wVariantSnp
    )
  applicationCoverageRegionsFiltered <<- pradaApplicationDAO$selectFilteredApplicationCoverageRegions()
  setDT(applicationCoverageRegionsFiltered)

  cat("The coverage of the current selection is ",sum(applicationCoverageRegionsFiltered$coveragebp), "bp or ",sum(applicationCoverageRegionsFiltered$coveragebp/3088269832))


  applicationCoverageRegionsFiltered[,score:=0]
  rPos<-as.data.frame(applicationCoverageRegionsFiltered)
  setDT(rPos)
  rPos[,strand:='+'][,abp1_final:=bp1-eval(paddingGroupFinal)][,abp2_final:=bp2]
  rPos[abp1_final<1,abp1_final:=1]
  rNeg<-as.data.frame(applicationCoverageRegionsFiltered)
  setDT(rNeg)
  rNeg[,strand:='-'][,abp1_final:=bp1][,abp2_final:=bp2+eval(paddingGroupFinal)]
  rNeg[abp2_final>chromosome_sizebp,abp2_final:=chromosome_sizebp]

  applicationCoverageRegionsFilteredPaddedStrands<<-rbind(rPos,rNeg)
  setkeyv(applicationCoverageRegionsFilteredPaddedStrands,cols = c("id","chr","abp1_final","abp2_final"))



  if(!is.null(writeToThisBedPath)){

    bedDf<-applicationCoverageRegionsFilteredPaddedStrands
    data.table::setorderv(bedDf,
                          cols = c("chr","bp1","id","strand","bp2"),
                          order =c(1,1,1,1,1)
    )
    bedDf<-bedDf[,.(chr_name,abp1_final,abp2_final,id,score,strand)][,abp1_final:=abp1_final-1] #includes fix of bp1 indexing for BED

    #bedDf<-applicationCoverageRegionsFiltered[,.(chr_name,start=abp1,end=abp2,id=paste0("\"",id,"\""))]


    fwrite(bedDf,file = writeToThisBedPath,append = F,sep = "\t",encoding = "UTF-8",col.names = F)
  }
}
)

# pradaO<-PradaClass()
# pradaO$connectPradaDatabase(usernameToUse="tng_prada_system", dbnameToUse="prada_central")
# pradaO$computeGenomeCoverage( writeToThisBedPath = "pgx.grch38.5k.0p7percent.bed",nPrioritisedCnv=0, nPrioritisedSnp=0, nPrioritisedTotal = 5000)
# pradaO$computeGenomeCoverage( writeToThisBedPath = "pgx_cnv.grch38.5k.2p1percent.bed",nPrioritisedSnp=0, nPrioritisedTotal = 5000)
# #pradaO$computeGenomeCoverage( writeToThisBedPath = "pgx_cnv_mddeur.grch38.5k.1p3percent.bed",nPrioritisedTotal = 5000) #1e6 CNV weighting
# pradaO$computeGenomeCoverage( writeToThisBedPath = "pgx_cnv_mddeur.grch38.5k.2p5percent.bed",nPrioritisedTotal = 5000)
# pradaO$computeGenomeCoverage( writeToThisBedPath = "pgx_cnv_mddeur.grch38.50k.5p9percent.bed",nPrioritisedTotal = 50000)
# pradaO$computeGenomeCoverage( writeToThisBedPath = "pgx_cnv_mddeur.grch38.100k.9p8percent.bed",nPrioritisedTotal = 100000)


#
# pradaO$computeGenomeCoverage( writeToThisBedPath = "pgx.grch38.5k.0p7percent.bed",nPrioritisedCnv=0, nPrioritisedSnp=0, nPrioritisedTotal = 5000)
#
# View(pradaO$applicationCoverageRegionsFiltered)

#PGX: The coverage of the current selection is  20296834 bp or  0.006572235
#PGX + CNV: The coverage of the current selection is  66340186 bp or  0.02148134
#nPrioritisedTotal = 5000 :The coverage of the current selection is  38946202 bp or  0.01261101
#nPrioritisedTotal = 5000 (include all CNV's) : The coverage of the current selection is  76631628 bp or  0.02481377
#nPrioritisedTotal = 50000 : The coverage of the current selection is  182576580 bp or  0.05911937
#nPrioritisedTotal = 100000 : The coverage of the current selection is  302578649 bp or  0.09797675
