--2025

--test of cpic functon
--SELECT * FROM cpic.recommendation_lookup('{"CYP2C19": {"*4": 1, "*9": 1}}');


--New dummy report
DROP TABLE IF EXISTS t_gene_diplotype_input;
CREATE TEMP TABLE IF NOT EXISTS t_gene_diplotype_input AS
SELECT 'ABCG2' AS gene, 'rs2231142 reference (G)/rs2231142 reference (G)' AS diplotype
	UNION ALL
	SELECT 'CACNA1S','Reference/Reference'
	UNION ALL
	SELECT 'CFTR', 'Reference/Reference'
	UNION ALL
	SELECT 'CYP2B6', '*1/*4'
	UNION ALL
	SELECT 'CYP2C9', '*1/*1'
	UNION ALL
	SELECT 'CYP2C19', '*1/*4'
	UNION ALL
	SELECT 'CYP2C19', '*1/*17' --duplicate PharmCat output - equal weight
	UNION ALL
	SELECT 'CYP2D6', '*1/*41'
	UNION ALL
	SELECT 'CYP3A5', '*3/*3'
	UNION ALL
	SELECT 'CYP4F2', '*1/*1'
	UNION ALL
	SELECT 'DPYD', 'c.496A>G;c.2194G>A'
	UNION ALL
	SELECT 'G6PD', 'B (reference)/Orissa'
	UNION ALL
	SELECT 'IFNL3', '39248147' --check this diplotype
	UNION ALL
	SELECT 'NUDT15', '*1/*1'
	UNION ALL
	SELECT 'RYR1', 'c.6178G>T (heterozygous)'
	UNION ALL
	SELECT 'SLCO1B1', '*14/*37'
	UNION ALL
	SELECT 'TPMT', '*1/*1'
	UNION ALL
	SELECT 'UGT1A1', '*80+*28/*80+*28' -- duplication
	UNION ALL
	SELECT 'VKORC1', 'rs9923231' --check this diplotype
	;

DROP TABLE IF EXISTS t_drug_input;
CREATE TEMP TABLE IF NOT EXISTS t_drug_input AS
SELECT 'sertraline' AS drugname
	UNION ALL
	SELECT 'citalopram'
	UNION ALL
	SELECT 'escitalopram'
	UNION ALL
	SELECT 'fluoxetine'
	UNION ALL
	SELECT 'paroxetine'
	UNION ALL
	SELECT 'duloxetine'
	UNION ALL
	SELECT 'venlafaxine'
	UNION ALL
	SELECT 'amitriptyline'
	UNION ALL
	SELECT 'mirtazapine'
	UNION ALL
	SELECT 'trazodone'
	UNION ALL
	SELECT 'desipramine'
	UNION ALL
	SELECT 'maprotiline'
	UNION ALL
	SELECT 'isocarboxazid'
	UNION ALL
	SELECT 'bupropion';
	
SELECT pgx.drug_name, pgx.drug_class, pgx.gene_name, pgx.flowchart, pgx.diplotype, pgx.cpiclevel, pgx.prada_cpiclevel_num, pgx.result, pgx.description, pgx.activityscore, pgx.ehrpriority, pgx.implications, pgx.drugrecommendation, pgx.classification, pgx.population, pgx.comments
--pgx.drug_name, pgx.drug_class, pgx.gene_name, pgx.diplotype, pgx.description, pgx.result, pgx.ehrpriority, pgx.consultationtext, pgx.implications, pgx.drugrecommendations, pgx.phenotypes, pgx.classification, pgx.population, pgx.comments 
FROM prada.harmonised_combined_pgx pgx 
INNER JOIN t_gene_diplotype_input g ON pgx.gene_name = g.gene AND pgx.diplotype = g.diplotype
INNER JOIN t_drug_input d ON pgx.drug_name = d.drugname
ORDER BY drug_name, gene_name, pgx.diplotype;

--check for weird diplotype definitions
SELECT pgx.* FROM prada.harmonised_cpic_pgx pgx 
INNER JOIN t_gene_diplotype_input g ON pgx.genesymbol = g.gene --AND pgx.diplotype = g.diplotype
INNER JOIN t_drug_input d ON pgx.drug_name = d.drugname
WHERE genesymbol='VKORC1'
ORDER BY drug_name, genesymbol, pgx.diplotype
;

--Guidelines for drugs, example
	


SELECT pgx.genesymbol, pgx.diplotype, pgx.description, pgx.result, pgx.ehrpriority, pgx.consultationtext FROM prada.harmonised_cpic_pgx pgx WHERE pgx.drug_name='sertraline' ORDER BY genesymbol, diplotype;
SELECT pgx.drug_name, pgx.genesymbol, pgx.diplotype, pgx.description, pgx.result, pgx.ehrpriority, pgx.consultationtext FROM prada.harmonised_cpic_pgx pgx WHERE pgx.diplotype ='*1/*17' AND pgx.genesymbol ='CYP2C19';
SELECT DISTINCT pgx.genesymbol, pgx.diplotype, pgx.description, pgx.result, pgx.ehrpriority, pgx.consultationtext FROM prada.harmonised_cpic_pgx pgx WHERE pgx.genesymbol ='CYP2C9';
SELECT DISTINCT pgx.genesymbol, pgx.drug_name, pgx.ehrpriority, pgx.consultationtext FROM prada.harmonised_cpic_pgx pgx WHERE pgx.genesymbol ='CYP2C9';



SELECT DISTINCT pgx.description FROM prada.harmonised_cpic_pgx pgx;
SELECT DISTINCT pgx.result FROM prada.harmonised_cpic_pgx pgx;
SELECT DISTINCT pgx.ehrpriority FROM prada.harmonised_cpic_pgx pgx WHERE pgx.drug_name='sertraline';


--check of prada drug names correspondence with cpic drug names
SELECT d.name,d.atcid, pd.* FROM cpic.drug d LEFT OUTER JOIN prada.drug pd ON d.name=pd.name AND pd.type!='cancer' ORDER BY atcid;
SELECT * FROM prada.drug pd LEFT OUTER JOIN cpic.drug d  ON d.name=pd.name WHERE pd.type!='cancer';


SELECT * FROM prada.drug pd INNER JOIN prada.harmonised_cpic_pgx pgx ON pd.name = pgx.drug_name AND pd.type!='cancer' ORDER BY pd.type, pd.class, pd.name;

--STRING_AGG(genesymbol, ' ,')
WITH a AS (SELECT pd.type, pd.class, pgx.genesymbol FROM prada.drug pd INNER JOIN prada.harmonised_cpic_pgx pgx ON pd.name = pgx.drug_name AND pd.type!='cancer' GROUP BY pd.type, pd.class, pgx.genesymbol)
SELECT a.class, STRING_AGG(genesymbol, ', ') FROM a GROUP BY a.class;


--Old test and scetches predating prada table and view designs 


--How do the cpic guidelines work?
--How does this translate into the genetic model?

--These seem to be in a set order (smaller star -> larger star)
DROP TABLE IF EXISTS t_gene_diplotype_input;
CREATE TEMP TABLE IF NOT EXISTS t_gene_diplotype_input AS
SELECT 'CYP2D6' AS gene, '*33' AS a1, '*148' AS a2
	UNION ALL
	SELECT 'CYP2B6','*8','*45'
	UNION ALL
	SELECT 'CYP2C19', '*2', '*24'
	UNION ALL
	SELECT 'TPMT', '*4', '*14';

DROP TABLE IF EXISTS t_drug_input;
CREATE TEMP TABLE IF NOT EXISTS t_drug_input AS
SELECT 'RxNorm:5640' AS drugid
	UNION ALL
	SELECT 'RxNorm:7407'
	UNION ALL
	SELECT 'RxNorm:32937'
	UNION ALL
	SELECT 'RxNorm:36437'
	UNION ALL
	SELECT 'RxNorm:1256'; --azathioprine

DROP TABLE IF EXISTS t_genetics;
CREATE TEMP TABLE IF NOT EXISTS t_genetics AS
SELECT grd.diplotype, grd.diplotypekey,
grl.description, grl.lookupkey,
gr.genesymbol, gr.result, gr.activityscore, gr.ehrpriority, gr.consultationtext,
g.chr, g.genesequenceid, g.proteinsequenceid, g.mrnasequenceid, g.hgncid, g.ncbiid, g.ensemblid, g.pharmgkbid, g.frequencymethods, g.lookupmethod, g.notesondiplotype, g.url, g.functionmethods, g.notesonallelenaming  
FROM 
--(SELECT t_gene_diplotype_input.*, t_gene_diplotype_input.a1 || '/'|| t_gene_diplotype_input.a2 AS diplotype FROM t_gene_diplotype_input) hcdata
--LEFT OUTER JOIN cpic.gene_result_diplotype grd ON hcdata.diplotype = grd.diplotype AND grd.diplotypekey ? hcdata.gene
cpic.gene_result_diplotype grd INNER JOIN cpic.gene_result_lookup grl ON grd.functionphenotypeid = grl.id
INNER JOIN cpic.gene_result gr ON grl.phenotypeid =gr.id
INNER JOIN cpic.gene g ON g.symbol = gr.genesymbol;
--WHERE hcdata.gene=gr.genesymbol;

--SELECT * FROM t_genetics;

DROP TABLE IF EXISTS t_pharmacogenetics;
CREATE TEMP TABLE IF NOT EXISTS t_pharmacogenetics AS
SELECT d.*,
p.cpiclevel,p.pgkbcalevel,
gl.name guideline_name, gl.url guideline_url,
g.genesymbol,g.chr,g.diplotype,g.description,g.result,g.activityscore,g.ehrpriority,g.consultationtext
--g.lookupkey, g.diplotypekey
FROM 
t_genetics g INNER JOIN cpic.pair p ON p.genesymbol = g.genesymbol
INNER JOIN cpic.drug d ON d.drugid = p.drugid
INNER JOIN cpic.guideline gl ON d.guidelineid = gl.id
WHERE p.removed = FALSE AND p.usedforrecommendation = TRUE;

--SELECT * FROM t_pharmacogenetics tp WHERE tp.name='azathioprine' ORDER by name;

--example play algorithm
-- Outputs list of drugs with information
-- Probability of side-effects and dosage recommendations may be possible to extract from the guidelines (consultationtext). Drug exclusion - extreme of dosage recommendation?
SELECT pg.* FROM t_pharmacogenetics pg
INNER JOIN (SELECT t_gene_diplotype_input.*, t_gene_diplotype_input.a1 || '/'|| t_gene_diplotype_input.a2 AS diplotype FROM t_gene_diplotype_input) hcdata ON hcdata.gene = pg.genesymbol AND hcdata.diplotype = pg.diplotype
--INNER JOIN t_drug_input d ON d.drugid=pg.drugid
WHERE pgkbcalevel = '1A' OR pgkbcalevel = '1B' OR pgkbcalevel = '2A' OR pgkbcalevel = '2B';
-- AND cpiclevel = 'A'
-- AND ehrpriority != 'none';

-- Pharmgkb score => clinical annotation levels: https://www.pharmgkb.org/page/clinAnnLevels

-- Suggestion for the quantitative side: cpic/pharmgkb scores + PRS weighted into PETRUSHKA 'domain' scores


-- This result signifies that the patient has two copies of a no function allele. Based on the genotype result this patient is predicted to be a poor metabolizer of CYP2C19 substrates. This patient may be at a high risk for an adverse or poor response to medications that are metabolized by CYP2C19. To avoid an untoward drug response, dose adjustments or or alternative therapy may be necessary for medications metabolized by the CYP2C19. Please consult a clinical pharmacist for more information about how CYP2C19 metabolic status influences drug selection and dosing.
-- This result signifies that the patient has two copies of a no function allele. Based on the genotype result this patient is predicted to be a TPMT poor metabolizer. This patient may be at a high risk for an adverse reactions to medications that are metabolized by TPMT (eg. thiopurines). To avoid an untoward drug response, dose adjustments or or alternative therapy may be necessary for medications metabolized by TPMT. However, thiopurines can be affected by a patient's TPMT and NUDT15 phenotype. Please consult a clinical pharmacist for more information about how TPMT and NUDT16 metabolic status influences drug selection and dosing.










