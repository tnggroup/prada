
library(STITCH)
library(mspbwt)
library(QUILT)
projectFolderPath<-"/users/k2481717/project/prada_jz"
workFolderPath<-file.path(projectFolderPath,"work","imputation","quilt")


chunks<-readRDS(file.path(workFolderPath,"chunks.quilt.Rds"))

#arguments specify which setup to run
args <- commandArgs(trailingOnly = TRUE)

cat("\nRead arguments:",args,"\n\n")

chunkIndex<-as.integer(args[1])


cChr<-chunks[chunkIndex,c("chr")]
cRegion<-chunks[chunkIndex,c("region")]
#test<-"chr22:33892524-36889852"
cRegionStart<-gsub(pattern = "^.+:(\\d+)-\\d+","\\1",cRegion)
cRegionEnd<-gsub(pattern = "^.+:\\d+-(\\d+)","\\1",cRegion)

cat("\n",paste0(cRegion,collapse = ""),"\n")
cat("\n",paste0(cChr,collapse = ""),"\n")
cat("\n",cRegionStart,"\n")
cat("\n",cRegionEnd,"\n")


#test of one-chromosome reference panel chunk
QUILT::QUILT_prepare_reference(
  outputdir=workFolderPath,
  chr=cChr,
  nGen=100,
  regionStart=1,
  regionEnd=55783303,
  buffer=500000,
  reference_vcf_file="/scratch/prj/gwas_sumstats/reference_panel/hc1kgp3.b38.vcf/1kGP_high_coverage_Illumina.filtered.SNV_INDEL_SV_phased_panel.vcf.gz"
)
#
# QUILT::QUILT_prepare_reference(
#   outputdir=workFolderPath,
#   chr=cChr,
#   nGen=100,
#   regionStart=as.integer(cRegionStart),
#   regionEnd=as.integer(cRegionEnd),
#   buffer=500000,
#   reference_vcf_file="/scratch/prj/gwas_sumstats/reference_panel/hc1kgp3.b38.vcf/1kGP_high_coverage_Illumina.filtered.SNV_INDEL_SV_phased_panel.vcf.gz"
# )
