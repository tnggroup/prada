library(data.table)
library(shru)
library(prada)

#build 37 version from 10.1001/jamapsychiatry.2019.0566
d.mmddcnv<-as.data.frame(matrix(data=NA, nrow = 0, ncol=0))
d.mmddcnv.columnnames<-c("syndrome","chr","bp","bp2")
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("1p36 del/dup (GABD)",1,0,2500000)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("TAR del/dup",1,145394955,145807817)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("1q21.1 del/dup",1,146527987,147394444)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("NRXN1 del",2,50145643,51259674)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("2q11.2 del (LMAN2L, ARID5A)",2,96742409,97677516)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("2q13 del/dup",2,111394040,112012649)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("2q37 del (HDAC4)",2,239716679,243199373)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("3q29 del",3,195720167,197354826)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("Wolf‐Hirschhorn del/dup",4,1552030,2091303)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("Sotos syndrome del",5,175720924,177052594)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("Williams‐Beuren syndrome (WBS) del/dup",7,72744915,74142892)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("8p23.1 del/dup",8,8098990,11872558)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("9q34 dup (EHMT1)",9,140513444,140730578)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("10q23 del (NRG3, GRID1)",10,82045472,88931651)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("Potocki‐Shaffer syndrome del (EXT2)",11,43940000,46020000)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("15q11.2 del/dup BP1‐BP2",15,22805313,23094530)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("Prader‐Willi syndrome/Angelman syndrome (PWS/AS) del/dup",15,22805313,28390339)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("15q13.3 del BP4‐BP5",15,31080645,32462776)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("15q24 del/dup",15,72900171,78151253)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("15q25 del",15,83219735,85722039)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("16p13.11 del/dup",16,15511655,16293689)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("16p12.1 del (520kb)",16,21950135,22431889)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("16p11.2 distal del/dup (220kb)",16,28823196,29046783)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("16p11.2 del/dup (593kb)",16,29650840,30200773)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("17p13.3 del/dup (YWHAE)",17,1247834,1303556)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("17p13.3 del/dup (PAFAH1B1)",17,2496923,2588909)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("Smith‐Magenis syndrome del/Potocki‐Lupski syndrome dup",17,16812771,20211017)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("17q11.2 del/dup (NF1)",17,29107491,30265075)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("Renal cysts and diabetes syndrome del (RCAD)/17q12 dup",17,34815904,36217432)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("17q21.31 del",17,43705356,44164691)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("22q11.2 del/dup",22,19037332,21466726)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("22q11.2 distal del/dup",22,21920127,23653646)
d.mmddcnv[nrow(d.mmddcnv)+1,d.mmddcnv.columnnames]<-c("SHANK3 del/dup",22,51113070,51171640)


#association p-values
d.mmddcnv$mdd_p<-1
rownames(d.mmddcnv)<-d.mmddcnv$syndrome

d.mmddcnv["1q21.1 del/dup",c("mdd_p")]<-9.08e-4 #dup
d.mmddcnv["3q29 del",c("mdd_p")]<-0.001 #del
d.mmddcnv["8p23.1 del/dup",c("mdd_p")]<-0.009 #dup
d.mmddcnv["Prader‐Willi syndrome/Angelman syndrome (PWS/AS) del/dup",c("mdd_p")]<-4.61e-5 #dup
d.mmddcnv["16p13.11 del/dup",c("mdd_p")]<-0.003 #del
d.mmddcnv["16p11.2 distal del/dup (220kb)",c("mdd_p")]<-0.05 #del
d.mmddcnv["16p11.2 del/dup (593kb)",c("mdd_p")]<-2.04e-4 #dup
d.mmddcnv["22q11.2 del/dup",c("mdd_p")]<-0.009 #dup

d.mmddcnv$chr<-as.integer(d.mmddcnv$chr)
d.mmddcnv$bp<-as.integer(d.mmddcnv$bp)
d.mmddcnv$bp2<-as.integer(d.mmddcnv$bp2)

d.mmddcnv$bedId<-paste0("chr",d.mmddcnv$chr,":",(d.mmddcnv$bp+1),"-",d.mmddcnv$bp2) #composite pos-id as used by the online UCSG lift over tool

#write 0-index bed
mmddcnv0index.b37.bed<-d.mmddcnv[,c(2,3,4,1)]
mmddcnv0index.b37.bed$chr<-paste0("chr",mmddcnv0index.b37.bed$chr)
mmddcnv0index.b37.bed[,c("score","strand")]<-NA
mmddcnv0index.b37.bed$score<-1
mmddcnv0index.b37.bed$strand<-1
#mmddcnv0index.b37.bed$strand<-"+"
mmddcnv0index.b37.bed$bp<-as.integer(mmddcnv0index.b37.bed$bp)
mmddcnv0index.b37.bed$bp2<-as.integer(mmddcnv0index.b37.bed$bp2)
fwrite(mmddcnv0index.b37.bed[,c(1,2,3)],file = "mmddcnv0index.b37.bed",sep = "\t",col.names = F)
#View(mmddcnv0index.b37.bed)

#LIFTOVER AT THE ONLINE UCSG LIFTOVER TOOL
#https://genome.ucsc.edu/cgi-bin/hgLiftOver

#join results
mmddcnv0index.b38.bed <- fread(file = "data/hglft_genome_2c4a33_1764e0.bed",header = F)
colnames(mmddcnv0index.b38.bed) <- c("chr","bp","bp2","bedId","aligns")
setDT(mmddcnv0index.b38.bed)
setDT(d.mmddcnv)

mmddcnv0index.b38.bed[d.mmddcnv,on=c(bedId='bedId'), c('nchr_old','syndrome_id','mdd_p'):=list(i.chr,i.syndrome,i.mdd_p)]
alts <- grepl(pattern = "chr\\d+_",ignore.case = T,x = mmddcnv0index.b38.bed$chr) #exclude alt mappings
#as integer
mmddcnv0index.b38.bed<-mmddcnv0index.b38.bed[!alts,]
mmddcnv0index.b38.bed[,chrs:=chr][,chr:=as.integer(substr(chr,4,6))]
##increment with 1 to use 1-based index
mmddcnv0index.b38.bed$bp<-as.integer(mmddcnv0index.b38.bed$bp)+1
mmddcnv0index.b38.bed$bp2<-as.integer(mmddcnv0index.b38.bed$bp2)+1

mmddcnv0index.b38.bed<-mmddcnv0index.b38.bed[chr==nchr_old,] #only keep matched chromosomes with the original syndrome associations

mmddcnv0index.b38.bed[,snp:=paste0(syndrome_id," - ",bedId,"_",.I)] #new snp id, guaranteed unique

# DO NOT TRUST THIS LIFTOVER!!
# smunge.res<-supermunge(
#   list_df = list(d.mmddcnv=d.mmddcnv),
#   chainFilePath = "~/Documents/local_db/SHARED/data/alignment_chains/hg19ToHg38.over.chain.gz",
#   lossless = T,
#   process = F,
#   writeOutput = F,
#   missingEssentialColumnsStop =c("BP","BP2")
# )
#
# View(d.mmddcnv)
# View(smunge.res$last)


pradaO<-PradaClass()
pradaO$connectPradaDatabase("tng_prada_system")

pradaO$pradaApplicationDAO$importDataAsTable(
  schema_name = "prada",
  table_name = "mmddcnv0index.b38.bed",
  df = as.data.frame(mmddcnv0index.b38.bed[,.(type=2,snp,chr,bp,bp2,mdd_p)]),
  temporary = F,
  replace = T)
