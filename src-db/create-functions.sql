

DROP TABLE IF EXISTS t_gene_diplotype_input;
CREATE TEMP TABLE IF NOT EXISTS t_gene_diplotype_input AS
SELECT 'CYP2D6' AS gene, '*33' AS a1, '*148' AS a2
	UNION ALL
	SELECT 'CYP2B6','*8','*45'
	UNION ALL
	SELECT 'CYP2C19', '*2', '*24';

DROP TABLE IF EXISTS t_drug_input;
CREATE TEMP TABLE IF NOT EXISTS t_drug_input AS
SELECT 'RxNorm:5640' AS drugid
	UNION ALL
	SELECT 'RxNorm:7407'
	UNION ALL
	SELECT 'RxNorm:32937';

DROP TABLE IF EXISTS t_genetics;
CREATE TEMP TABLE IF NOT EXISTS t_genetics AS
SELECT hcdata.*, grd.diplotypekey,
grl.lookupkey, grl.description,
gr.genesymbol, gr.result, gr.activityscore, gr.ehrpriority, gr.consultationtext,
g.chr, g.genesequenceid, g.proteinsequenceid, g.mrnasequenceid, g.hgncid, g.ncbiid, g.ensemblid, g.pharmgkbid, g.frequencymethods, g.lookupmethod, g.notesondiplotype, g.url, g.functionmethods, g.notesonallelenaming  
FROM 
(SELECT t_gene_diplotype_input.*, t_gene_diplotype_input.a1 || '/'|| t_gene_diplotype_input.a2 AS diplotype FROM t_gene_diplotype_input) hcdata
LEFT OUTER JOIN cpic.gene_result_diplotype grd ON hcdata.diplotype = grd.diplotype AND grd.diplotypekey ? hcdata.gene
INNER JOIN cpic.gene_result_lookup grl ON grd.functionphenotypeid = grl.id
INNER JOIN cpic.gene_result gr ON grl.phenotypeid =gr.id
INNER JOIN cpic.gene g ON g.symbol = gr.genesymbol;
--WHERE hcdata.gene=gr.genesymbol;

--SELECT * FROM t_genetics;

DROP TABLE IF EXISTS t_pharmacogenetics;
CREATE TEMP TABLE IF NOT EXISTS t_pharmacogenetics AS
SELECT d.*,
p.cpiclevel,p.pgkbcalevel,
g.gene,g.chr,g.a1,g.a2,g.description,g.result,g.activityscore,g.ehrpriority,g.consultationtext FROM 
t_genetics g INNER JOIN cpic.pair p ON p.genesymbol = g.genesymbol
INNER JOIN cpic.drug d ON d.drugid = p.drugid
WHERE p.removed = FALSE AND p.usedforrecommendation = TRUE;

--example play algorithm
SELECT * FROM t_pharmacogenetics WHERE cpiclevel = 'A' AND pgkbcalevel = '1A';
--AND ehrpriority != 'none';

