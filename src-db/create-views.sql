--DROP VIEW prada.cpic_genetics;
CREATE OR REPLACE VIEW prada.cpic_genetics
AS SELECT grd.diplotype, grd.diplotypekey,
grl.description, grl.lookupkey,
gr.genesymbol, gr.result, gr.activityscore, gr.ehrpriority, gr.consultationtext,
g.chr, g.genesequenceid, g.proteinsequenceid, g.mrnasequenceid, g.hgncid, g.ncbiid, g.ensemblid, g.pharmgkbid, g.frequencymethods, g.lookupmethod, g.notesondiplotype, g.url, g.functionmethods, g.notesonallelenaming  
FROM 
cpic.gene_result_diplotype grd INNER JOIN cpic.gene_result_lookup grl ON grd.functionphenotypeid = grl.id
INNER JOIN cpic.gene_result gr ON grl.phenotypeid =gr.id
INNER JOIN cpic.gene g ON g.symbol = gr.genesymbol;

--SELECT * FROM prada.cpic_genetics;

--DROP VIEW prada.cpic_pgx;
CREATE OR REPLACE VIEW prada.cpic_pgx
AS SELECT d.*,
p.cpiclevel,p.pgkbcalevel,
gl.name guideline_name, gl.url guideline_url,
g.genesymbol,g.chr,g.diplotype,g.description,g.result,g.activityscore,g.ehrpriority,g.consultationtext
--g.lookupkey, g.diplotypekey
FROM 
prada.cpic_genetics g INNER JOIN cpic.pair p ON p.genesymbol = g.genesymbol
INNER JOIN cpic.drug d ON d.drugid = p.drugid
INNER JOIN cpic.guideline gl ON d.guidelineid = gl.id
WHERE p.removed = FALSE AND p.usedforrecommendation = TRUE;

--SELECT * FROM  prada.cpic_pgx tp WHERE tp.name='azathioprine' ORDER by name;

--DROP VIEW prada.combined_pgx;
CREATE OR REPLACE VIEW prada.combined_pgx
AS SELECT d.*,
p.cpiclevel,p.pgkbcalevel,
gl.name guideline_name, gl.url guideline_url,
g.genesymbol,g.chr,g.diplotype,g.description,g.result,g.activityscore,g.ehrpriority,g.consultationtext,
--g.lookupkey, g.diplotypekey
pgx_gene."CPIC" as cpiclevel2, pgx_gene."PharmGKB" as pgkbcalevel2, pgx_gene."DPWG" as in_dpwg, pgx_gene."Twist" as in_twist, pgx_gene."PharmVar" as in_pharmvar, pgx_gene."CMRG" as in_cmrg, pgx_gene."PharmCAT" as in_pharmcat
FROM 
prada.cpic_genetics g INNER JOIN cpic.pair p ON p.genesymbol = g.genesymbol
INNER JOIN cpic.drug d ON d.drugid = p.drugid
INNER JOIN cpic.guideline gl ON d.guidelineid = gl.id
LEFT OUTER JOIN prada.pgx_gene ON pgx_gene."Gene"=g.genesymbol
WHERE p.removed = FALSE AND p.usedforrecommendation = TRUE;

--SELECT * FROM  prada.combined_pgx tp WHERE tp.name='azathioprine' ORDER by name;