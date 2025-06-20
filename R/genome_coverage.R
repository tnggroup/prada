#Functions to compute the genome coverage
# PradaClass$methods(
# computeGenomeCoverage=function(
#     nPrioritisedPharmacogenes,
#     paddingPRSAnchorBp,
#     paddingGeneBp
#     ){
#
#
# }
# )
#
# pradaO<-PradaClass()
# pradaO$connectPradaDatabase("tng_prada_system")
# writeToThisBedPath<-"grch38.5k.1p3percent.bed"
PradaClass$methods(
computeGenomeCoverage=function(
    writeToThisBedPath=NULL,
    paddingGeneBp=10000,
    paddingVariantCnvBp=10000,
    paddingVariantSnpBp=5000,
    nPrioritisedGene=300,
    nPrioritisedCnv=100,
    nPrioritisedSnp=200000,
    nPrioritisedTotal=25000,
    wGene=1e20,
    wVariantCnv=1e6,
    wVariantSnp=1
    ){
  #pradaApplicationDAO<-pradaO$pradaApplicationDAO
  res<-pradaApplicationDAO$selectApplicationCoverageRegions(
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
    );
  applicationCoverageRegions <- pradaApplicationDAO$selectFilteredApplicationCoverageRegions();
  setDT(applicationCoverageRegions)
  setkeyv(applicationCoverageRegions,cols = c("id","chr","abp1","abp2"))

  cat("The coverage of the current selection is ",sum(applicationCoverageRegions$coveragebp), "bp or ",sum(applicationCoverageRegions$coveragebp/3088269832))

  if(!is.null(writeToThisBedPath)){
    bedDf<-applicationCoverageRegions[,.(chr,start=abp1,end=abp2,id)]
    data.table::setorderv(bedDf,cols = c("chr","start","end","id"))
    fwrite(bedDf,file = writeToThisBedPath,append = F,sep = "\t",encoding = "UTF-8")
  }
}
)

#nPrioritisedTotal = 50000 : The coverage of the current selection is  182576580 bp or  0.05911937
#nPrioritisedTotal = 100000 : The coverage of the current selection is  302578649 bp or  0.09797675
