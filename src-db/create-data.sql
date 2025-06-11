--Based on assembly GRCh38.p14
--https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000001405.40/
INSERT INTO prada.chromosome(number, sizebp) VALUES (1,248956422);
INSERT INTO prada.chromosome(number, sizebp) VALUES (2,242193529);
INSERT INTO prada.chromosome(number, sizebp) VALUES (3,198295559);
INSERT INTO prada.chromosome(number, sizebp) VALUES (4,190214555);
INSERT INTO prada.chromosome(number, sizebp) VALUES (5,181538259);
INSERT INTO prada.chromosome(number, sizebp) VALUES (6,170805979);
INSERT INTO prada.chromosome(number, sizebp) VALUES (7,159345973);
INSERT INTO prada.chromosome(number, sizebp) VALUES (8,145138636);
INSERT INTO prada.chromosome(number, sizebp) VALUES (9,138394717);
INSERT INTO prada.chromosome(number, sizebp) VALUES (10,133797422);
INSERT INTO prada.chromosome(number, sizebp) VALUES (11,135086622);
INSERT INTO prada.chromosome(number, sizebp) VALUES (12,133275309);
INSERT INTO prada.chromosome(number, sizebp) VALUES (13,114364328);
INSERT INTO prada.chromosome(number, sizebp) VALUES (14,107043718);
INSERT INTO prada.chromosome(number, sizebp) VALUES (15,101991189);
INSERT INTO prada.chromosome(number, sizebp) VALUES (16,90338345);
INSERT INTO prada.chromosome(number, sizebp) VALUES (17,83257441);
INSERT INTO prada.chromosome(number, sizebp) VALUES (18,80373285);
INSERT INTO prada.chromosome(number, sizebp) VALUES (19,58617616);
INSERT INTO prada.chromosome(number, sizebp) VALUES (20,64444167);
INSERT INTO prada.chromosome(number, sizebp) VALUES (21,46709983);
INSERT INTO prada.chromosome(number, sizebp) VALUES (22,50818468);
INSERT INTO prada.chromosome(number, sizebp) VALUES (23,156040895); --X
INSERT INTO prada.chromosome(number, sizebp) VALUES (24,57227415); --Y
--INSERT INTO prada.chromosome(number, sizebp) VALUES (25,NULL); --XY
--INSERT INTO prada.chromosome(number, sizebp) VALUES (26,NULL); --MT

WITH prev_chrom AS (SELECT CASE
WHEN c.number <23 THEN 'chr'||c.number
WHEN c.number =23 THEN 'chrX'
WHEN c.number =24 THEN 'chrY'
WHEN c.number =25 THEN 'chrXY'
WHEN c.number =26 THEN 'chrMT'
END AS name, c.number
FROM prada.chromosome c
)
UPDATE prada.chromosome SET name=p.name FROM prev_chrom p WHERE chromosome.number=p.number;

--Harmonise the pgx_gene custom data with gencode gene codes
UPDATE prada.pgx_gene pg SET "Gene"='GBA1' WHERE "Gene"='GBA';


--insert drug data
--pharmgkb cancer - cancer_drugs_pharmgkb.tsv
INSERT INTO prada.drug(name,type,weight) SELECT cdp.drug, 'cancer',0.5 FROM prada.cancer_drugs_pharmgkb cdp;

