library(data.table)
library(shru)
library(prada)

#Run on CREATE because of the big variant list
# #d.idp <- shru::readFile(c("/scratch/prj/ppn_tng/IDP_GWAS/meta_sumstats/meta_pgc/IDP_PGC_DSM_METAL_GWAMA_MDD_CHRBP2STUDS.txt.gz"))
#
# d.idp.munge <- supermunge(
#   filePaths = c("/scratch/prj/ppn_tng/IDP_GWAS/meta_sumstats/meta_pgc/IDP_PGC_DSM_METAL_GWAMA_MDD_CHRBP2STUDS.txt.gz"),
#   refFilePath = "/scratch/prj/gwas_sumstats/variant_lists/hc1kgp3.b38.mix.l2.jz2024.gz", #we need a b38 ref
#   traitNames = c("IDPB38"),
#   ancestrySetting = "EUR"
# )



d.idp38 <- shru::readFile(c("~/Downloads/IDPB38.gz"))

d.idp38.formatted<-d.idp38[,.(type=1,snp=SNP,chr=CHR,bp=BP,bp2=NA_integer_,mdd_p=P,mdd_beta=BETA,mdd_beta_se=SE,mdd_n=N)]

pradaO<-PradaClass()
pradaO$connectPradaDatabase("tng_prada_system")

pradaO$pradaApplicationDAO$importDataAsTable(
  schema_name = "prada",
  table_name = "idp38_import",
  df = d.idp38.formatted[mdd_p<10e-3,],
  temporary = F,
  replace = T)
