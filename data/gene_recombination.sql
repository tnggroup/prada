BEGIN;

DROP VIEW "combined_pharmacogenomics_view";
DROP VIEW "combined_pharmacogenomics_view2";
-- rollback; 

CREATE OR REPLACE VIEW prada.cpic_pgx2 AS
SELECT d.drugid,
    d.name,
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
    gl.name AS guideline_name,
    gl.url AS guideline_url,
    g.genesymbol,
    g.ensemblid,
    g.chr,
    g.diplotype,
    g.description,
    g.result,
    g.activityscore,
    g.ehrpriority,
    g.consultationtext
   FROM prada.cpic_genetics g
     FULL JOIN cpic.pair p ON p.genesymbol::text = g.genesymbol::text AND p.removed = false AND p.usedforrecommendation = true
     FULL JOIN cpic.drug d ON d.drugid::text = p.drugid::text
     FULL JOIN cpic.guideline gl ON d.guidelineid = gl.id;


---previously used left join table dropped on cpic 
SAVEPOINT "cpic-pgx_view2";
-- ROLLBACK TO SAVEPOINT joint-table-creation;
--COMMIT;


SELECT count(*) FROM prada.cpic_pgx ;
--1340482

SELECT count(*) FROM prada.cpic_pgx2 ;
--1340988


-- CREATE VIEW combined_pharmacogenomics_view AS
-- SELECT
--     d.drugid,
--     d.name AS drug_name,
--     d.pharmgkbid AS drug_pharmgkbid,
--     d.rxnormid,
--     d.umlscui,
--     g.symbol AS gene_symbol,
--     g.chr AS gene_chr,
--     g.ensemblid AS gene_ensemblid,
--     g.pharmgkbid AS gene_pharmgkbid,
--     gg.gene_name,
--     gg.chr AS gencode_chr,
--     pgx.CPIC AS pgx_cpic_score,
--     gl.id AS guideline_id,
--     gl.name AS guideline_name,
--     gl.url AS guideline_url
-- FROM cpic.drug d
-- LEFT JOIN cpic.gene g ON d.pharmgkbid = g.pharmgkbid
-- LEFT JOIN prada.gencode_gene gg ON g.chr = gg.chr AND g.symbol = gg.gene_name
-- LEFT JOIN prada.pgx_gene pgx ON g.symbol = pgx.Gene
-- LEFT JOIN cpic.guideline gl ON d.guidelineid = gl.id;

-- prada.cpic_genetics source

CREATE OR REPLACE VIEW prada.cpic_genetics2
AS SELECT grd.diplotype,
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
   FROM cpic.gene_result_diplotype grd
    FULL JOIN cpic.gene_result_lookup grl ON grd.functionphenotypeid = grl.id
    FULL JOIN cpic.gene_result gr ON grl.phenotypeid = gr.id
    FULL JOIN cpic.gene g ON g.symbol::text = gr.genesymbol::text;


SAVEPOINT "prada_cpic-genetics2";


SELECT count(*) FROM prada.cpic_genetics ;

SELECT count(*) FROM prada.cpic_genetics2 ;

SAVEPOINT "prada_pgxcombined";


CREATE OR REPLACE VIEW prada.combined_pgx2
AS SELECT d.drugid,
    d.name,
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
    gl.name AS guideline_name,
    gl.url AS guideline_url,
    g.genesymbol,
    g.ensemblid,
    g.chr,
    g.diplotype,
    g.description,
    g.result,
    g.activityscore,
    g.ehrpriority,
    g.consultationtext,
    pgx_gene."CPIC" AS cpiclevel2,
    pgx_gene."PharmGKB" AS pgkbcalevel2,
    pgx_gene."DPWG" AS in_dpwg,
    pgx_gene."Twist" AS in_twist,
    pgx_gene."PharmVar" AS in_pharmvar,
    pgx_gene."CMRG" AS in_cmrg,
    pgx_gene."PharmCAT" AS in_pharmcat
   FROM prada.cpic_genetics g
     JOIN cpic.pair p ON p.genesymbol::text = g.genesymbol::text
     JOIN cpic.drug d ON d.drugid::text = p.drugid::text
     JOIN cpic.guideline gl ON d.guidelineid = gl.id
     FULL JOIN prada.pgx_gene ON pgx_gene."Gene"::text = g.genesymbol::text
  WHERE p.removed = false AND p.usedforrecommendation = true;


SAVEPOINT "prada.combined_pgx2";
SELECT count(*) FROM prada.combined_pgx2 ;

SELECT count(*) FROM prada.combined_pgx2;


-- pgx-backbone-genes
--CREATE TABLE pgx_backbone_genes (
--    gene_name TEXT PRIMARY KEY,
--    ensembl_id TEXT,
--    chr TEXT,
--    start INT,
--    end INT,
--    added_on TIMESTAMP DEFAULT now(),
--    source TEXT,
--    is_anchor BOOLEAN DEFAULT TRUE
--);




COMMIT;




