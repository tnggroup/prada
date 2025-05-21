--DROP MATERIALIZED VIEW prada.cpic_genetics;
CREATE MATERIALIZED VIEW prada.cpic_genetics --OR REPLACE
AS SELECT
grd.diplotype,
grd.diplotypekey,
grl.description,
grl.lookupkey,
gr.genesymbol,
gr.result,
gr.activityscore,
gr.ehrpriority,
gr.consultationtext,
g.chr,
g.genesequenceid,
g.proteinsequenceid,
g.mrnasequenceid,
g.hgncid,
g.ncbiid,
g.ensemblid,
g.pharmgkbid,
g.frequencymethods,
g.lookupmethod,
g.notesondiplotype,
g.url,
g.functionmethods,
g.notesonallelenaming  
FROM 
cpic.gene_result_diplotype grd
INNER JOIN cpic.gene_result_lookup grl ON grd.functionphenotypeid = grl.id
INNER JOIN cpic.gene_result gr ON grl.phenotypeid =gr.id
INNER JOIN cpic.gene g ON g.symbol = gr.genesymbol;

CREATE INDEX cpic_genetics_i ON prada.cpic_genetics (chr,genesymbol,ensemblid,ehrpriority);

--REFRESH MATERIALIZED VIEW prada.cpic_genetics;

--101,956 rows with inner join
--102,084 rows with full join

--SELECT * FROM prada.cpic_genetics WHERE lookupkey IS NULL;

--DROP MATERIALIZED VIEW prada.cpic_pgx;
CREATE MATERIALIZED VIEW prada.cpic_pgx --OR REPLACE
AS SELECT
d.name drug_name,
d.pharmgkbid,
d.rxnormid,
d.drugbankid,
d.atcid,
d.umlscui,
d.flowchart,
d.version,
d.guidelineid,
p.cpiclevel,
p.pgkbcalevel,
gl.name guideline_name,
gl.url guideline_url,
g.genesymbol,
g.ensemblid,
g.chr,
g.diplotype,
g.description,
g.result,
g.activityscore,
g.ehrpriority,
g.consultationtext,
--g.lookupkey,
--g.diplotypekey,
(
	CASE
		WHEN p.cpiclevel='A' THEN 4
		WHEN p.cpiclevel='B' THEN 3
		WHEN p.cpiclevel='C' THEN 2
		ELSE 1
	END
) AS prada_cpiclevel_num,
(
	CASE
		WHEN p.pgkbcalevel='1A' THEN 5
		WHEN p.pgkbcalevel='2A' THEN 4
		WHEN p.pgkbcalevel='3' THEN 3
		WHEN p.pgkbcalevel='4' THEN 2
		ELSE 1
	END
) AS prada_pgkbcalevel_num,
(
	CASE
		WHEN g.ehrpriority='Abnormal/Priority/High Risk' THEN 3
		WHEN g.ehrpriority='Priority/High-Risk' THEN 3
		WHEN g.ehrpriority='Normal Risk' THEN 2
		WHEN g.ehrpriority='Normal/Routine/ Low Risk' THEN 2
		WHEN g.ehrpriority='Normal/Routine/Low Risk' THEN 2
		WHEN g.ehrpriority='Routine/Low-Risk' THEN 2
		ELSE 1
	END
) AS prada_ehrpriority_num
FROM 
prada.cpic_genetics g INNER JOIN cpic.pair p ON p.genesymbol = g.genesymbol AND p.removed = FALSE AND p.usedforrecommendation = TRUE
LEFT OUTER JOIN cpic.drug d ON d.drugid = p.drugid
LEFT OUTER JOIN cpic.guideline gl ON d.guidelineid = gl.id;

CREATE INDEX cpic_pgx_i ON prada.cpic_pgx (drug_name,pharmgkbid,genesymbol,ensemblid,chr,prada_cpiclevel_num,prada_pgkbcalevel_num,prada_ehrpriority_num);

--REFRESH MATERIALIZED VIEW prada.cpic_pgx;

-- 1,340,988 rows with full join
-- 1,340,482 rows with LOJ
-- 1,340,482 rows with innner join

--SELECT * FROM  prada.cpic_pgx tp WHERE tp.drug_name='azathioprine' ORDER by drug_name;
--SELECT * FROM  prada.cpic_pgx tp WHERE guideline_name IS NULL ORDER by drug_name;
/*
SELECT DISTINCT genesymbol
	FROM prada.cpic_pgx px
	ORDER BY genesymbol;
	
SELECT DISTINCT cpiclevel
	FROM prada.cpic_pgx px
	ORDER BY cpiclevel;
	
SELECT DISTINCT pgkbcalevel
	FROM prada.cpic_pgx px
	ORDER BY pgkbcalevel;

SELECT DISTINCT ehrpriority
	FROM prada.cpic_pgx px
	ORDER BY ehrpriority;
	

*/

--DROP VIEW prada.combined_pgx;
CREATE OR REPLACE VIEW prada.combined_pgx
AS SELECT 
g.chr,
g.bp1,
g.bp2,
g.gene_name,
g.gene_id,
g.gene_id0,
--pgx."CPIC" cpiclevel2,
--pgx."PharmGKB" pgkbcalevel2,
(pgx."Gene" IS NOT NULL) AS in_pgx,
(cpic.cpiclevel IS NOT NULL) AS in_cpic,
(pgx."DPWG")::boolean in_dpwg,
(pgx."Twist")::boolean in_twist,
(pgx."PharmVar")::boolean in_pharmvar,
(pgx."CMRG")::boolean in_cmrg,
(pgx."PharmCAT")::boolean in_pharmcat,
cpic.drug_name,
cpic.pharmgkbid,
cpic.rxnormid,
cpic.drugbankid,
cpic.atcid,
cpic.umlscui,
cpic.cpiclevel,
cpic.pgkbcalevel,
cpic.guideline_name,
cpic.guideline_url,
--cpic.genesymbol,
--cpic.ensemblid,
--cpic.chr,
cpic.diplotype,
cpic.description,
cpic.result,
cpic.activityscore,
cpic.ehrpriority,
cpic.consultationtext,
cpic.prada_cpiclevel_num,
cpic.prada_pgkbcalevel_num,
cpic.prada_ehrpriority_num
FROM 
prada.gencode_gene g
LEFT OUTER JOIN prada.pgx_gene pgx ON g.gene_name=pgx."Gene" --AND g.chr=pgx.chr -- we don't have chr data here
LEFT OUTER JOIN prada.cpic_pgx cpic ON (
	(cpic.ensemblid=g.gene_id OR ((cpic.ensemblid IS NULL OR g.gene_id IS NULL) AND g.gene_name = cpic.genesymbol))
	AND g.chr=cpic.chr
	)
;

--SELECT * FROM  prada.combined_pgx tp WHERE tp.drug_name='azathioprine' ORDER by drug_name;
--SELECT * FROM  prada.combined_pgx tp ORDER by drug_name;
/*SELECT * FROM  prada.combined_pgx tp ORDER by prada_ehrpriority_num DESC, prada_cpiclevel_num DESC, prada_pgkbcalevel_num DESC
LIMIT 100;*/
--SELECT DISTINCT chr,bp1,bp2,gene_name,gene_id FROM  prada.combined_pgx tp WHERE prada_cpiclevel_num > 0 OR prada_pgkbcalevel_num > 0 OR prada_pgkbcalevel_num > 0 ORDER by chr,bp1,bp2;