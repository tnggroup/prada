#unified plotting

#devtools::install_github("tnggroup/prada")
#devtools::install_github("tnggroup/prada",ref = 'jz_dev')
library(prada)
library(data.table)

projectFolderPath<-"/scratch/prj/sgdp_nanopore/Projects/prada_jz"
#projectFolderPath<-"/Users/jakz/Documents/work_rstudio/prada" #test

sampleMetaTot<-as.data.table(matrix(NA,0,0))
setDT(sampleMetaTot)

#pilot 2
cSampleMeta<-data.table::fread(file.path(projectFolderPath,"work","pradaApp","pilot2","sampleMeta.tsv"))
sampleMetaTot <- data.table::rbindlist(l=list(sampleMetaTot=sampleMetaTot,cSampleMeta=cSampleMeta),fill = TRUE)

#pilot 3
cSampleMeta<-data.table::fread(file.path(projectFolderPath,"work","pradaApp","pilot3","sampleMeta.tsv"))
sampleMetaTot <- data.table::rbindlist(l=list(sampleMetaTot=sampleMetaTot,cSampleMeta=cSampleMeta),fill = TRUE)

#pilot 4
cSampleMeta<-data.table::fread(file.path(projectFolderPath,"work","pradaApp","pilot4","sampleMeta.tsv"))
sampleMetaTot <- data.table::rbindlist(l=list(sampleMetaTot=sampleMetaTot,cSampleMeta=cSampleMeta),fill = TRUE)

#downsampled bam
cSampleMeta<-data.table::fread(file.path(projectFolderPath,"work","pradaApp","downsampled-bam-runs","sampleMeta.tsv"))
sampleMetaTot <- data.table::rbindlist(l=list(sampleMetaTot=sampleMetaTot,cSampleMeta=cSampleMeta),fill = TRUE)


library(ggplot2)
library(ggrepel)

ggplot(sampleMetaTot,aes(x = sdepth_q050_bed, y = nvarq_region, colour = analysis, label=analysis)) +
  geom_point() +
  ggtitle("# quality variants in PGx regions (on target)") +
  geom_text_repel(size = 2.5) +
  theme_minimal()
ggsave(filename = file.path(projectFolderPath,"work","pradaApp","unified-plots","nvarq_region.png"), plot = get_last_plot())


ggplot(sampleMetaTot,aes(x = sdepth_q050_bed, y = vcallacc_q050_region, colour = analysis, label=analysis)) +
  geom_point() +
  ggtitle("SNP call accuracy in PGx regions (on target)") +
  geom_text_repel(size = 2.5) +
  theme_minimal()
ggsave(filename = file.path(projectFolderPath,"work","pradaApp","unified-plots","vcallacc_region.png"), plot = get_last_plot())


ggplot(sampleMetaTot,aes(x = sdepth_q050_bed, y = meanPgxVariantRatio, colour = analysis, label=analysis)) +
  geom_point() +
  ggtitle("Mean PGx SNP ratio called/total") +
  geom_text_repel(size = 2.5) +
  theme_minimal()
ggsave(filename = file.path(projectFolderPath,"work","pradaApp","unified-plots","pgxvariantratio.png"), plot = get_last_plot())

ggplot(sampleMetaTot,aes(x = sdepth_q050_bed, y = nCalledPgx, colour = analysis, label=analysis)) +
  geom_point() +
  ggtitle("# called PGx diplotype variants") +
  geom_text_repel(size = 2.5) +
  theme_minimal()
ggsave(filename = file.path(projectFolderPath,"work","pradaApp","unified-plots","ncalledpgx.png"), plot = get_last_plot())


ggplot(sampleMetaTot,aes(x = sdepth_q050_nobed, y = nvarq_noregion, colour = analysis, label=analysis)) +
  geom_point() +
  ggtitle("# quality variants outside of PGx regions (off target)") +
  geom_text_repel(size = 2.5) +
  theme_minimal()
ggsave(filename = file.path(projectFolderPath,"work","pradaApp","unified-plots","nvarq_noregion.png"), plot = get_last_plot())

ggplot(sampleMetaTot,aes(x = sdepth_q050_nobed, y = vcallacc_q050_noregion, colour = analysis, label=analysis)) +
  geom_point() +
  ggtitle("SNP call accuracy outside of PGx regions (off target)") +
  geom_text_repel(size = 2.5) +
  theme_minimal()
ggsave(filename = file.path(projectFolderPath,"work","pradaApp","unified-plots","vcallacc_noregion.png"), plot = get_last_plot())

fwrite(sampleMetaTot,file = file.path(projectFolderPath,"work","pradaApp","unified-plots","sampleMetaTot.tsv"),sep = "\t",row.names = F,col.names = T, append = F)
setorder(sampleMetaTot,-sdepth_q050_bed)
fwrite(sampleMetaTot,file = file.path(projectFolderPath,"work","pradaApp","unified-plots","sampleMetaTot.sortx.tsv"),sep = "\t",row.names = F,col.names = T, append = F)
