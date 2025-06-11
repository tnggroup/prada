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
PradaClass$methods(
computeGenomeCoverage=function(
    writeToThisBedPath=NULL,
    dfRegions=NULL, #should be CHR,BP1,BP2,TYPE[either 0 for anchor, or 1 for pharmacogene], #not used yet
    ){
  #pradaApplicationDAO<-pradaO$pradaApplicationDAO
  applicationCoverageRegions <- pradaApplicationDAO$selectApplicationCoverageRegions();
  setDT(applicationCoverageRegions)
  setkeyv(applicationCoverageRegions,cols = c("gene_name","chr","abp1_trimmed","abp2_trimmed"))

  cat("The coverage of the current selection is ",sum(applicationCoverageRegions$coveragebp), "bp or ",sum(applicationCoverageRegions$coveragebp/3088269832))

  if(!is.null(writeToThisBedPath)){
    bedDf<-applicationCoverageRegions[,.(chr,start=abp1_trimmed,end=abp2_trimmed,gene_name)]
    data.table::setorderv(bedDf,cols = c("chr","start","end","gene_name"))
    fwrite(bedDf,file = writeToThisBedPath,append = F,sep = "\t",encoding = "UTF-8")
  }
}
)
