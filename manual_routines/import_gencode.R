library(data.table)

gencode <- data.table::fread("~/Downloads/gencode.v48.chr_patch_hapl_scaff.basic.annotation.gff3",header = F,fill = T, blank.lines.skip = T,data.table = T,skip = 7,sep = '\t')
gencode <- gencode[V3=='gene',]
gencode <- as.data.frame(gencode)

gencode$INFO.split<-strsplit(gencode$V9, split = ";",fixed = T)
gencode$gene_name<-lapply(
    gencode$INFO.split,FUN = function(x){

      trimws(strsplit(grep(pattern = "^gene_name", x = x, fixed = F, value=T)[[1]],split="=",fixed = T)[[1]][[2]])

      }
)

#View(gencode)

data.table::setDT(gencode)
gencode<-as.data.frame(gencode[,.(V1,V4,V5,gene_name)])
colnames(gencode)<-c("CHR","BP1","BP2","gene_name")

gencode$gene_name<-trimws(gencode$gene_name) #not sure why we have to do this a second time

#View(gencode)

pradaO<-PradaClass()
pradaO$connectPradaDatabase("tng_prada_system")

pradaO$pradaApplicationDAO$importDataAsTable(name = "prada.gencode_gene",df = gencode, temporary = F)
