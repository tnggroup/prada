--View for Genes in GENCODE but Not in CPIC
CREATE OR REPLACE VIEW prada.gencode_not_in_cpic AS
SELECT g.gene_name, g.chr, g.gene_id
FROM prada.gencode_gene g
LEFT JOIN cpic.gene c ON g.gene_name = c.symbol
WHERE c.symbol IS NULL;

CREATE OR REPLACE VIEW prada.gencode_not_in_cpic_strict AS
SELECT g.gene_name, g.chr, g.gene_id
FROM prada.gencode_gene g
LEFT JOIN cpic.gene c
  ON g.gene_name = c.symbol
     OR g.gene_id = c.ensemblid
     OR (g.chr = c.chr AND g.gene_name ILIKE c.symbol)
WHERE c.symbol IS NULL;


--Join with pgx_gene to See What Panels They’re On
CREATE OR REPLACE VIEW prada.gencode_not_in_cpic_with_panels AS
SELECT gn.gene_name,
       gn.chr,
       gn.gene_id,
       pgx."CPIC",
       pgx."PharmGKB",
       pgx."DPWG",
       pgx."Twist",
       pgx."PharmVar",
       pgx."CMRG",
       pgx."PharmCAT"
FROM prada.gencode_not_in_cpic gn
LEFT JOIN prada.pgx_gene pgx ON gn.gene_name = pgx."Gene";

CREATE OR REPLACE VIEW prada.gencode_not_in_cpic_with_panels_strict AS
SELECT gn.gene_name,
       gn.chr,
       gn.gene_id,
       pgx."CPIC",
       pgx."PharmGKB",
       pgx."DPWG",
       pgx."Twist",
       pgx."PharmVar",
       pgx."CMRG",
       pgx."PharmCAT"
FROM prada.gencode_not_in_cpic_strict gn
LEFT JOIN prada.pgx_gene pgx ON gn.gene_name = pgx."Gene";


-- Confirm distinct gene counts
SELECT COUNT(*) FROM prada.gencode_gene;
--86364
SELECT COUNT(DISTINCT symbol) FROM cpic.gene;
--132
SELECT COUNT(*) FROM prada.gencode_not_in_cpic;
--86166
SELECT COUNT(*) FROM prada.gencode_not_in_cpic_with_panels WHERE "CPIC" IS NOT NULL OR "PharmGKB" IS NOT NULL;
--48
SELECT COUNT(*) FROM prada.gencode_not_in_cpic_strict;
--86165
SELECT COUNT(*) FROM prada.gencode_not_in_cpic_with_panels_strict WHERE "CPIC" IS NOT NULL OR "PharmGKB" IS NOT NULL;
--48





---confidence matching
CREATE OR REPLACE VIEW prada.gencode_to_cpic_match_confidence AS
SELECT
  g.gene_name,
  g.chr,
  g.gene_id,
  CASE
    WHEN c1.symbol IS NOT NULL THEN 'symbol_match'
    WHEN c2.ensemblid IS NOT NULL THEN 'ensembl_match'
    WHEN c3.symbol IS NOT NULL THEN 'chr_fuzzy_match'
    ELSE 'no_match'
  END AS match_confidence
FROM prada.gencode_gene g
FULL JOIN cpic.gene c1 ON g.gene_name = c1.symbol
FULL JOIN cpic.gene c2 ON g.gene_id = c2.ensemblid
FULL JOIN cpic.gene c3 ON g.chr = c3.chr AND g.gene_name ILIKE c3.symbol;

--- check for chromosome (both on cpic and accross)
-- symbols to double check and get ensemble id accross a) symbols b) ensembl ids 
--sensitivity to symbols for case-sensitivity comparison 

	--strictly no match
CREATE OR REPLACE VIEW prada.gencode_not_in_cpic_with_confidence AS
SELECT *
FROM prada.gencode_to_cpic_match_confidence
WHERE match_confidence = 'no_match'; 



-- Running prioritised pgx adaptive gene list against gencode
SELECT gene_name, gene_id
FROM prada.gencode_gene
WHERE gene_name IN (
  'ABCB1', 'ABCC4', 'ABCG2', 'ABL2', 'ACE', 'ACYP2', 'ADD1', 'ADORA2A', 'ADRA2A', 'ADRB1',
  'ADRB2', 'ALDH2', 'ANKK1', 'APOE', 'ASL', 'ASS1', 'ATIC', 'BCHE', 'C11ORF65', 'C8ORF34',
  'CACNA1S', 'CALU', 'CBR3', 'CCHCR1', 'CES1', 'CETP', 'CFTR', 'CHRNA3', 'CHRNA5', 'COL22A1',
  'COMT', 'COQ2', 'CPS1', 'CRHR1', 'CRHR2', 'CYB5R1', 'CYB5R2', 'CYB5R3', 'CYB5R4', 'CYP1A2',
  'CYP2A6', 'CYP2A13', 'CYP2B6', 'CYP2C19', 'CYP2C8', 'CYP2C9', 'CYP2D6', 'CYP3A4', 'CYP3A5',
  'CYP4F2', 'DPYD', 'DRD2', 'DYNC2H1', 'EGF', 'EGFR', 'ENOSF1', 'EPAS1', 'EPHX1', 'ERCC1',
  'F2', 'F5', 'FCGR3A', 'FDPS', 'FKBP5', 'G6PD', 'GBA', 'GGCX', 'GNB3', 'GP1BA', 'GRIK4',
  'GRK5', 'GSTM1', 'GSTP1', 'HAS3', 'HLA-A', 'HLA-B', 'HLA-C', 'HLA-DPB1', 'HLA-DQA1',
  'HLA-DRB1', 'HMGCR', 'HPRT1', 'HTR1A', 'HTR2A', 'HTR2C', 'IFNL3', 'IFNL4', 'ITPA', 'KIF6',
  'LDLR', 'LPA', 'LTC4S', 'MC4R', 'MTHFR', 'MT-RNR1', 'MTRR', 'NAGS', 'NAT2', 'NEDD4L',
  'NQO1', 'NT5C2', 'NUDT15', 'OPRM1',  'OTC','POLG','PRKCA','PROC','PROS1','PTGFR','PTGS1','RYR1',
'SCN1A','SEMA3C','SERPINC1','SLC19A1','SLC28A3','SLC6A4','SLCO1B1','SOD2','TNF','TPMT','TYMS',
'UGT1A1','UGT1A4','UGT2B15','UGT2B7','UMPS','VDR','VKORC1','XPC','XRCC1','YEATS4','ABCC2','AGT',
'ANK3','APOL1','ATM','BDNF','CACNA1C','CDA','CHRNA1','CTBP2','DBH','DRD1','DRD3','DRD4','EDN1',
'GABRA6','GABRP','GLP1R','GRIK1','GSTA1','ITGB3','KCNIP1','NAT1','NR1H3','NR1I2','OPRD1','OPRK1',
'P2RY12','PNPLA5','POR','SLC22A1','SLC6A2','SULT4A1','UGT2B10');


-- find variant anchors for prioritised gene list based on chromosomal position

SELECT DISTINCT v.*
FROM prada.variant v
JOIN prada.gencode_gene g ON v.chr::text = g.chr::text
WHERE g.gene_name IN (
  'ABCB1', 'ABCC4', 'ABCG2', 'ABL2', 'ACE', 'ACYP2', 'ADD1', 'ADORA2A', 'ADRA2A', 'ADRB1',
  'ADRB2', 'ALDH2', 'ANKK1', 'APOE', 'ASL', 'ASS1', 'ATIC', 'BCHE', 'C11ORF65', 'C8ORF34',
  'CACNA1S', 'CALU', 'CBR3', 'CCHCR1', 'CES1', 'CETP', 'CFTR', 'CHRNA3', 'CHRNA5', 'COL22A1',
  'COMT', 'COQ2', 'CPS1', 'CRHR1', 'CRHR2', 'CYB5R1', 'CYB5R2', 'CYB5R3', 'CYB5R4', 'CYP1A2',
  'CYP2A6', 'CYP2A13', 'CYP2B6', 'CYP2C19', 'CYP2C8', 'CYP2C9', 'CYP2D6', 'CYP3A4', 'CYP3A5',
  'CYP4F2', 'DPYD', 'DRD2', 'DYNC2H1', 'EGF', 'EGFR', 'ENOSF1', 'EPAS1', 'EPHX1', 'ERCC1',
  'F2', 'F5', 'FCGR3A', 'FDPS', 'FKBP5', 'G6PD', 'GBA', 'GGCX', 'GNB3', 'GP1BA', 'GRIK4',
  'GRK5', 'GSTM1', 'GSTP1', 'HAS3', 'HLA-A', 'HLA-B', 'HLA-C', 'HLA-DPB1', 'HLA-DQA1',
  'HLA-DRB1', 'HMGCR', 'HPRT1', 'HTR1A', 'HTR2A', 'HTR2C', 'IFNL3', 'IFNL4', 'ITPA', 'KIF6',
  'LDLR', 'LPA', 'LTC4S', 'MC4R', 'MTHFR', 'MT-RNR1', 'MTRR', 'NAGS', 'NAT2', 'NEDD4L',
  'NQO1', 'NT5C2', 'NUDT15', 'OPRM1',  'OTC','POLG','PRKCA','PROC','PROS1','PTGFR','PTGS1','RYR1',
  'SCN1A','SEMA3C','SERPINC1','SLC19A1','SLC28A3','SLC6A4','SLCO1B1','SOD2','TNF','TPMT','TYMS',
  'UGT1A1','UGT1A4','UGT2B15','UGT2B7','UMPS','VDR','VKORC1','XPC','XRCC1','YEATS4','ABCC2','AGT',
  'ANK3','APOL1','ATM','BDNF','CACNA1C','CDA','CHRNA1','CTBP2','DBH','DRD1','DRD3','DRD4','EDN1',
  'GABRA6','GABRP','GLP1R','GRIK1','GSTA1','ITGB3','KCNIP1','NAT1','NR1H3','NR1I2','OPRD1','OPRK1',
  'P2RY12','PNPLA5','POR','SLC22A1','SLC6A2','SULT4A1','UGT2B10')
  AND v.bp BETWEEN g.bp1 AND g.bp2;


--attempt for backbone
--CREATE OR REPLACE VIEW pgx_backbone_genes AS
--SELECT
--    g.gene_name,
--    g.gene_id AS ensembl_id,
--    g.chr,
--    GREATEST(g.bp1 - 1000, 0) AS start,
--    g.bp2 + 1000 AS end,
--    now() AS added_on,
--    'PGx priority list' AS source,
--    TRUE AS is_anchor
--FROM prada.gencode_gene g
--WHERE g.gene_name IN (
--    'ABCB1', 'ABCC4', 'ABCG2', 'ABL2', 'ACE', 'ACYP2', 'ADD1', 'ADORA2A', 'ADRA2A', 'ADRB1',
--  'ADRB2', 'ALDH2', 'ANKK1', 'APOE', 'ASL', 'ASS1', 'ATIC', 'BCHE', 'C11ORF65', 'C8ORF34',
--  'CACNA1S', 'CALU', 'CBR3', 'CCHCR1', 'CES1', 'CETP', 'CFTR', 'CHRNA3', 'CHRNA5', 'COL22A1',
--  'COMT', 'COQ2', 'CPS1', 'CRHR1', 'CRHR2', 'CYB5R1', 'CYB5R2', 'CYB5R3', 'CYB5R4', 'CYP1A2',
--  'CYP2A6', 'CYP2A13', 'CYP2B6', 'CYP2C19', 'CYP2C8', 'CYP2C9', 'CYP2D6', 'CYP3A4', 'CYP3A5',
--  'CYP4F2', 'DPYD', 'DRD2', 'DYNC2H1', 'EGF', 'EGFR', 'ENOSF1', 'EPAS1', 'EPHX1', 'ERCC1',
--  'F2', 'F5', 'FCGR3A', 'FDPS', 'FKBP5', 'G6PD', 'GBA', 'GGCX', 'GNB3', 'GP1BA', 'GRIK4',
--  'GRK5', 'GSTM1', 'GSTP1', 'HAS3', 'HLA-A', 'HLA-B', 'HLA-C', 'HLA-DPB1', 'HLA-DQA1',
--  'HLA-DRB1', 'HMGCR', 'HPRT1', 'HTR1A', 'HTR2A', 'HTR2C', 'IFNL3', 'IFNL4', 'ITPA', 'KIF6',
--  'LDLR', 'LPA', 'LTC4S', 'MC4R', 'MTHFR', 'MT-RNR1', 'MTRR', 'NAGS', 'NAT2', 'NEDD4L',
--  'NQO1', 'NT5C2', 'NUDT15', 'OPRM1',  'OTC','POLG','PRKCA','PROC','PROS1','PTGFR','PTGS1','RYR1',
--  'SCN1A','SEMA3C','SERPINC1','SLC19A1','SLC28A3','SLC6A4','SLCO1B1','SOD2','TNF','TPMT','TYMS',
--  'UGT1A1','UGT1A4','UGT2B15','UGT2B7','UMPS','VDR','VKORC1','XPC','XRCC1','YEATS4','ABCC2','AGT',
--  'ANK3','APOL1','ATM','BDNF','CACNA1C','CDA','CHRNA1','CTBP2','DBH','DRD1','DRD3','DRD4','EDN1',
--  'GABRA6','GABRP','GLP1R','GRIK1','GSTA1','ITGB3','KCNIP1','NAT1','NR1H3','NR1I2','OPRD1','OPRK1',
--  'P2RY12','PNPLA5','POR','SLC22A1','SLC6A2','SULT4A1','UGT2B10'
--);
-- routing to update the pgx_gene table and updates upon this for all of this 