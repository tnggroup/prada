
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