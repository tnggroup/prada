--recommendations overview - starting template
DROP TABLE IF EXISTS t_recommendations_overview;
CREATE TEMP TABLE IF NOT EXISTS t_recommendations_overview AS
SELECT ROW_NUMBER() OVER (PARTITION BY pgx.drug_name, pgx.gene_name, (pgx.lookupkey::text), pgx.recommendation ORDER BY pgx.prada_cpiclevel_num DESC, pgx.prada_ehrpriority_num DESC, pgx.diplotype NULLS LAST) AS rn, pgx.drug_name, pgx.drug_class, pgx.gene_name, pgx.flowchart, pgx.diplotype, pgx.cpiclevel, pgx.prada_cpiclevel_num, pgx.result, pgx.description, pgx.activityscore, pgx.ehrpriority, pgx.prada_ehrpriority_num, pgx.recommendation, pgx.guidelineid, pgx.lookupkey, pgx.implications, pgx.consultationtext, pgx.drugrecommendation, pgx.classification, pgx.population, pgx.comments
--pgx.drug_name, pgx.drug_class, pgx.gene_name, pgx.diplotype, pgx.description, pgx.result, pgx.ehrpriority, pgx.consultationtext, pgx.implications, pgx.drugrecommendations, pgx.phenotypes, pgx.classification, pgx.population, pgx.comments 
FROM prada.harmonised_combined_pgx pgx;
--INNER JOIN t_gene_diplotype_input g ON pgx.gene_name = g.gene AND pgx.diplotype = g.diplotype
--INNER JOIN t_drug_input d ON pgx.drug_name = d.drugname
--WHERE pgx.classification != 'Optional'
--ORDER BY drug_name, gene_name, pgx.diplotype, rn;

SELECT * FROM t_recommendations_overview WHERE rn = 1 AND recommendation IS NOT NULL
ORDER BY drug_name, gene_name, diplotype, recommendation;

--SELECT * FROM t_recommendations_overview
--WHERE recommendation IS NOT NULL
--ORDER BY drug_name, gene_name, (lookupkey::text), recommendation, rn
--LIMIT 1000;

--SELECT DISTINCT pgx.classification FROM prada.harmonised_combined_pgx pgx;

--recommendations overview - starting template, condensed
DROP TABLE IF EXISTS t_recommendations_overview2;
CREATE TEMP TABLE IF NOT EXISTS t_recommendations_overview2 AS
SELECT ROW_NUMBER() OVER (PARTITION BY pgx.drug_name, pgx.recommendation ORDER BY pgx.prada_cpiclevel_num DESC, pgx.prada_ehrpriority_num DESC, pgx.gene_name, pgx.diplotype NULLS LAST) AS rn, pgx.drug_name, pgx.drug_class, pgx.cpiclevel, pgx.prada_cpiclevel_num, pgx.recommendation, pgx.guidelineid, pgx.implications, pgx.drugrecommendation, pgx.classification, pgx.population, pgx.comments
--pgx.drug_name, pgx.drug_class, pgx.gene_name, pgx.diplotype, pgx.description, pgx.result, pgx.ehrpriority, pgx.consultationtext, pgx.implications, pgx.drugrecommendations, pgx.phenotypes, pgx.classification, pgx.population, pgx.comments 
FROM prada.harmonised_combined_pgx pgx;
--INNER JOIN t_gene_diplotype_input g ON pgx.gene_name = g.gene AND pgx.diplotype = g.diplotype
--INNER JOIN t_drug_input d ON pgx.drug_name = d.drugname
--WHERE pgx.classification != 'Optional'
--ORDER BY drug_name, gene_name, pgx.diplotype, rn;

SELECT * FROM t_recommendations_overview2 WHERE rn = 1 AND recommendation IS NOT NULL
ORDER BY drug_name, recommendation;