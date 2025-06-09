--DROP MATERIALIZED VIEW prada.cpic_genetics;
CREATE MATERIALIZED VIEW prada.cpic_genetics --OR REPLACE
AS SELECT
g.chr,
g.symbol genesymbol,
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
g.notesonallelenaming,
grd.diplotype,
grd.diplotypekey,
grl.description,
grl.lookupkey,
gr.result,
gr.activityscore,
gr.ehrpriority,
gr.consultationtext,


(
	CASE
		WHEN gr.ehrpriority='Abnormal/Priority/High Risk' THEN 5
		WHEN gr.ehrpriority='Priority/High-Risk' THEN 4
		WHEN gr.ehrpriority='Normal Risk' THEN 3
		WHEN gr.ehrpriority='Normal/Routine/ Low Risk' THEN 2
		WHEN gr.ehrpriority='Normal/Routine/Low Risk' THEN 2
		WHEN gr.ehrpriority='Routine/Low-Risk' THEN 2
		ELSE 1
	END
) AS prada_ehrpriority_num
FROM
cpic.gene g
LEFT OUTER JOIN cpic.gene_result gr ON g.symbol = gr.genesymbol
LEFT OUTER JOIN cpic.gene_result_lookup grl ON grl.phenotypeid =gr.id
LEFT OUTER JOIN cpic.gene_result_diplotype grd ON grd.functionphenotypeid = grl.id;
--cpic.gene_result_diplotype grd
--INNER JOIN cpic.gene_result_lookup grl ON grd.functionphenotypeid = grl.id
--INNER JOIN cpic.gene_result gr ON grl.phenotypeid =gr.id
--INNER JOIN cpic.gene g ON g.symbol = gr.genesymbol;

CREATE INDEX cpic_genetics_i ON prada.cpic_genetics (chr,genesymbol,ensemblid,prada_ehrpriority_num);

--REFRESH MATERIALIZED VIEW prada.cpic_genetics;

--101,956 rows with inner join
--102,084 rows with full join

--SELECT * FROM prada.cpic_genetics WHERE diplotype IS NULL;
--SELECT DISTINCT genesymbol FROM prada.cpic_genetics;

--DROP MATERIALIZED VIEW prada.harmonised_cpic_pgx;
CREATE MATERIALIZED VIEW prada.harmonised_cpic_pgx --OR REPLACE
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
p.usedforrecommendation,
gl.name guideline_name,
gl.url guideline_url,
(
--TRANSLATION BUSINESS RULES FOR DISCREPANCIES IN GENE SYMBOLS BETWEEN CPIC AND GENCODE
	CASE 
		WHEN p.genesymbol='GBA' THEN 'GBA1'
		ELSE p.genesymbol
	END
) AS genesymbol,
(
--TRANSLATION BUSINESS RULES FOR DISCREPANCIES IN ENSEMBLID BETWEEN CPIC AND GENCODE
	CASE 
		WHEN g.ensemblid='ENSG00000112096' THEN 'ENSG00000291237' --SOD2
		ELSE g.ensemblid
	END
) AS ensemblid,
g.chr,
g.diplotype,
g.description,
g.result,
g.activityscore,
g.ehrpriority,
g.consultationtext,
--g.lookupkey,
--g.diplotypekey,
g.prada_ehrpriority_num,
(
	CASE
		WHEN p.cpiclevel='A' THEN 8
		WHEN p.cpiclevel='A/B' THEN 7
		WHEN p.cpiclevel='B' THEN 6
		WHEN p.cpiclevel='B/C' THEN 5
		WHEN p.cpiclevel='C' THEN 4
		WHEN p.cpiclevel='C/D' THEN 3
		WHEN p.cpiclevel='D' THEN 2
		ELSE 1
	END
) AS prada_cpiclevel_num,
(
	CASE
		WHEN p.pgkbcalevel='1A' THEN 7
		WHEN p.pgkbcalevel='1B' THEN 6
		WHEN p.pgkbcalevel='2A' THEN 5
		WHEN p.pgkbcalevel='2B' THEN 4
		WHEN p.pgkbcalevel='3' THEN 3
		WHEN p.pgkbcalevel='4' THEN 2
		ELSE 1
	END
) AS prada_pgkbcalevel_num,
(
	CASE
		WHEN p.usedforrecommendation = TRUE THEN 2
		ELSE 1
	END
) AS prada_usedforrecommendation_num
FROM 
prada.cpic_genetics g 
LEFT OUTER JOIN cpic.pair p ON p.genesymbol = g.genesymbol AND p.removed = FALSE --AND p.usedforrecommendation = TRUE
LEFT OUTER JOIN cpic.drug d ON d.drugid = p.drugid
LEFT OUTER JOIN cpic.guideline gl ON d.guidelineid = gl.id;

CREATE INDEX harmonised_cpic_pgx_i ON prada.harmonised_cpic_pgx (drug_name,pharmgkbid,genesymbol,ensemblid,chr,prada_ehrpriority_num,prada_cpiclevel_num,prada_pgkbcalevel_num,prada_usedforrecommendation_num);

--REFRESH MATERIALIZED VIEW prada.harmonised_cpic_pgx;

-- 2,571,684 rows with LOJ pair, drugs, guidelines, no usedforrecommendation condition

-- OLD inner join cpic_genetics
-- 1,340,988 rows with full join
-- 1,340,482 rows with LOJ
-- 1,340,482 rows with innner join

--SELECT * FROM  prada.harmonised_cpic_pgx tp WHERE tp.drug_name='azathioprine' ORDER by drug_name;
--SELECT * FROM  prada.harmonised_cpic_pgx tp ORDER by drug_name;
--SELECT * FROM  prada.harmonised_cpic_pgx tp WHERE guideline_name IS NULL ORDER by drug_name;

--SELECT * FROM  prada.harmonised_cpic_pgx p WHERE p.genesymbol = 'SOD2';
/*
SELECT DISTINCT genesymbol
	FROM prada.harmonised_cpic_pgx px
	ORDER BY genesymbol;
	
SELECT DISTINCT cpiclevel
	FROM prada.harmonised_cpic_pgx px
	ORDER BY cpiclevel;
	
SELECT DISTINCT pgkbcalevel
	FROM prada.harmonised_cpic_pgx px
	ORDER BY pgkbcalevel;

SELECT DISTINCT ehrpriority
	FROM prada.harmonised_cpic_pgx px
	ORDER BY ehrpriority;
	

*/


--DROP MATERIALIZED VIEW prada.harmonised_gene;
CREATE MATERIALIZED VIEW prada.harmonised_gene --OR REPLACE
AS 
SELECT
--cpicg.genesymbol,
--cpicg.ensemblid,
--cpicg.chr cpicchr,
--pgx."Gene",
g.chr,
g.bp1,
g.bp2,
g.gene_name,
g.gene_id,
g.gene_id0,
--pgx."CPIC" cpiclevel2,
--pgx."PharmGKB" pgkbcalevel2,
(pgx."Gene" IS NOT NULL) AS in_pgx,
(cpicg.genesymbol IS NOT NULL) AS in_cpic,
(cpic.genesymbol IS NOT NULL) AS has_cpiclevel,
(pgx."DPWG")::boolean in_dpwg,
(pgx."Twist")::boolean in_twist,
(pgx."PharmVar")::boolean in_pharmvar,
(pgx."CMRG")::boolean in_cmrg,
(pgx."PharmCAT")::boolean in_pharmcat
FROM
prada.gencode_gene g
LEFT OUTER JOIN (
SELECT DISTINCT genesymbol,ensemblid,chr
	FROM prada.harmonised_cpic_pgx WHERE genesymbol IS NOT NULL AND ensemblid IS NOT NULL AND chr IS NOT NULL
) AS cpicg ON (
	(cpicg.ensemblid=g.gene_id OR ((cpicg.ensemblid IS NULL OR g.gene_id IS NULL) AND g.gene_name = cpicg.genesymbol))
	AND g.chr=cpicg.chr
	)
LEFT OUTER JOIN (
SELECT DISTINCT genesymbol,ensemblid,chr
	FROM prada.harmonised_cpic_pgx 
	WHERE genesymbol IS NOT NULL AND ensemblid IS NOT NULL AND chr IS NOT NULL
	AND cpiclevel IS NOT NULL
) AS cpic ON (
	(cpic.ensemblid=g.gene_id OR ((cpic.ensemblid IS NULL OR g.gene_id IS NULL) AND g.gene_name = cpic.genesymbol))
	AND g.chr=cpic.chr
	)
LEFT OUTER JOIN prada.pgx_gene pgx ON g.gene_name=pgx."Gene" --OR cpicg.genesymbol=pgx."Gene" --AND g.chr=pgx.chr -- we don't have chr data here
;

CREATE UNIQUE INDEX harmonised_gene_u ON prada.harmonised_gene (chr,gene_id); -- chr,gene_name is not unique 
CREATE UNIQUE INDEX harmonised_gene_i ON prada.harmonised_gene (chr,bp1,bp2,gene_name,gene_id);

--REFRESH MATERIALIZED VIEW prada.harmonised_gene;

--SELECT * FROM prada.harmonised_gene WHERE in_cpic=TRUE;
--SELECT * FROM prada.harmonised_gene WHERE in_pgx=TRUE;
--SELECT * FROM prada.harmonised_gene WHERE bp1 IS NULL;
--SELECT * FROM prada.harmonised_gene WHERE in_cpic=TRUE
--SELECT * FROM prada.harmonised_gene WHERE bp1 IS NULL;
--SELECT * FROM prada.gencode_gene gg WHERE gg.gene_name = 'SOD2';
--SELECT * FROM prada.harmonised_gene WHERE gene_name= 'Metazoa_SRP';

--DROP VIEW prada.harmonised_combined_pgx;
CREATE OR REPLACE VIEW prada.harmonised_combined_pgx
AS SELECT
g.chr,
g.bp1,
g.bp2,
g.gene_name,
g.gene_id,
g.gene_id0,
g.in_pgx,
g.in_cpic,
g.has_cpiclevel,
g.in_dpwg,
g.in_twist,
g.in_pharmvar,
g.in_cmrg,
g.in_pharmcat,
p.drug_name,
p.pharmgkbid,
p.rxnormid,
p.drugbankid,
p.atcid,
p.umlscui,
p.flowchart,
p.version,
p.guidelineid,
p.cpiclevel,
p.pgkbcalevel,
p.usedforrecommendation,
p.guideline_name,
p.guideline_url,
p.diplotype,
p.description,
p.result,
p.activityscore,
p.ehrpriority,
p.consultationtext,
p.prada_ehrpriority_num,
p.prada_cpiclevel_num,
p.prada_pgkbcalevel_num,
p.prada_usedforrecommendation_num
FROM 
prada.harmonised_gene g
LEFT OUTER JOIN prada.harmonised_cpic_pgx p ON --we trust the ensemblid and chr mapping because of the harmonised cpic pgx view
	p.ensemblid=g.gene_id
	AND g.chr=p.chr
WHERE g.in_pgx=TRUE OR g.in_cpic=TRUE OR g.has_cpiclevel=TRUE OR g.in_dpwg=TRUE OR g.in_twist=TRUE OR g.in_pharmvar=TRUE OR g.in_cmrg=TRUE OR g.in_pharmcat=TRUE OR p.ensemblid IS NOT NULL
;

--SELECT * FROM  prada.harmonised_combined_pgx tp WHERE tp.drug_name='azathioprine' ORDER by drug_name;
--SELECT * FROM  prada.harmonised_combined_pgx tp ORDER by drug_name;
/*SELECT * FROM  prada.harmonised_combined_pgx tp ORDER by prada_ehrpriority_num DESC, prada_cpiclevel_num DESC, prada_pgkbcalevel_num DESC
LIMIT 100;*/
--SELECT DISTINCT chr,bp1,bp2,gene_name,gene_id FROM  prada.harmonised_combined_pgx tp WHERE prada_cpiclevel_num > 0 OR prada_pgkbcalevel_num > 0 OR prada_pgkbcalevel_num > 0 ORDER by chr,bp1,bp2;


--DROP MATERIALIZED VIEW prada.harmonised_combined_pgx_gene;
CREATE MATERIALIZED VIEW prada.harmonised_combined_pgx_gene
AS
SELECT
p.gene_name, p.gene_id, p.chr,

avg(p.bp1) bp1,
avg(p.bp2) bp2,
max(p.in_pgx::int) in_pgx_num,
max(p.in_cpic::int) in_cpic_num,
max(p.has_cpiclevel::int) has_cpiclevel_num,
max(p.in_dpwg::int) in_dpwg_num,
max(p.in_twist::int) in_twist_num,
max(p.in_pharmvar::int) in_pharmvar_num,
max(p.in_cmrg::int) in_cmrg_num,
max(p.in_pharmcat::int) in_pharmcat_num,
avg(prada_ehrpriority_num) prada_ehrpriority_avg,
avg(prada_cpiclevel_num) prada_cpiclevel_avg,
avg(prada_pgkbcalevel_num) prada_pgkbcalevel_avg,
avg(prada_usedforrecommendation_num) prada_usedforrecommendation_avg,
count(*) num_diplotype
FROM prada.harmonised_combined_pgx p
GROUP BY p.gene_name, p.gene_id, p.chr;

CREATE UNIQUE INDEX harmonised_combined_pgx_gene_u ON prada.harmonised_combined_pgx_gene (chr,gene_id); -- chr,gene_name is not unique 
CREATE UNIQUE INDEX harmonised_combined_pgx_gene_i ON prada.harmonised_combined_pgx_gene (chr,bp1,bp2,gene_name,gene_id);

--REFRESH MATERIALIZED VIEW prada.harmonised_combined_pgx_gene;

--SELECT * FROM prada.harmonised_combined_pgx_gene;