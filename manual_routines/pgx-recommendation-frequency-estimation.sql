--This is to estimate the number of non-standrard PGx variants (depression only) and how many changes in PRADA recommendations we expect from adding in the genetic data.
--SELECT * FROM prada.cpic_genetics cg ;
--LEFT OUTER JOIN cpic.allele a ON g.genesymbol = a.genesymbol AND 


-- Experiments
--SELECT g.*,g.diplotypekey::jsonb -> g.genesymbol FROM prada.cpic_genetics g
--
--SELECT *,row_number() OVER (PARTITION BY g1.chr, g1.genesymbol, g1.diplotype) rn FROM (SELECT g.*,jsonb_object_keys(g.diplotypekey::jsonb -> g.genesymbol) allele FROM prada.cpic_genetics g) g1
--
--ORDER BY g.chr, g.genesymbol,rn;
--
--WITH a AS (
--SELECT *,row_number() OVER (PARTITION BY chr, genesymbol, diplotype) rn FROM (SELECT g.*,jsonb_object_keys(g.diplotypekey::jsonb -> g.genesymbol) allele FROM prada.cpic_genetics g) g1
--),
--a2 AS (
--SELECT g.*, a1.allele::text allele1, a2.allele::text allele2 FROM prada.cpic_genetics g
--LEFT OUTER JOIN a a1 ON g.chr=a1.chr AND g.genesymbol=a1.genesymbol AND g.diplotypekey=a1.diplotypekey AND a1.rn=1
--LEFT OUTER JOIN a a2 ON g.chr=a2.chr AND g.genesymbol=a2.genesymbol AND g.diplotypekey=a2.diplotypekey AND a2.rn=2
--)
--SELECT a2.*, al1.frequency allele1_frequency, al2.frequency allele2_frequency FROM a2 
--LEFT OUTER JOIN cpic.allele al1 ON a2.genesymbol=al1.genesymbol AND a2.allele1=al1.name
--LEFT OUTER JOIN cpic.allele al2 ON a2.genesymbol=al2.genesymbol AND a2.allele2=al2.name
--ORDER BY chr,genesymbol;

--SELECT * FROM prada.harmonised_combined_pgx hcp;

--compute frequencies for selection of drugs
DROP TABLE IF EXISTS t_freq_recommendation;
CREATE TEMP TABLE IF NOT EXISTS t_freq_recommendation AS
WITH pgx AS (SELECT hcp.*, (hcp.diplotype_frequency ->> 'European')::numeric diplotype_frequency_pop, (hcp.allele1_frequency ->> 'European')::numeric allele1_frequency_pop, (hcp.allele2_frequency ->> 'European')::numeric allele2_frequency_pop
--WITH pgx AS (SELECT hcp.*, (hcp.diplotype_frequency ->> 'East Asian')::numeric diplotype_frequency_pop, (hcp.allele1_frequency ->> 'East Asian')::numeric allele1_frequency_pop, (hcp.allele2_frequency ->> 'East Asian')::numeric allele2_frequency_pop
--WITH pgx AS (SELECT hcp.*, (hcp.diplotype_frequency ->> 'Latino')::numeric diplotype_frequency_pop, (hcp.allele1_frequency ->> 'Latino')::numeric allele1_frequency_pop, (hcp.allele2_frequency ->> 'Latino')::numeric allele2_frequency_pop
--WITH pgx AS (SELECT hcp.*, (hcp.diplotype_frequency ->> 'Central/South Asian')::numeric diplotype_frequency_pop, (hcp.allele1_frequency ->> 'Central/South Asian')::numeric allele1_frequency_pop, (hcp.allele2_frequency ->> 'Central/South Asian')::numeric allele2_frequency_pop
--WITH pgx AS (SELECT hcp.*, (hcp.diplotype_frequency ->> 'Sub-Saharan African')::numeric diplotype_frequency_pop, (hcp.allele1_frequency ->> 'Sub-Saharan African')::numeric allele1_frequency_pop, (hcp.allele2_frequency ->> 'Sub-Saharan African')::numeric allele2_frequency_pop
--WITH pgx AS (SELECT hcp.*, (hcp.diplotype_frequency ->> 'African American/Afro-Caribbean')::numeric diplotype_frequency_pop, (hcp.allele1_frequency ->> 'African American/Afro-Caribbean')::numeric allele1_frequency_pop, (hcp.allele2_frequency ->> 'African American/Afro-Caribbean')::numeric allele2_frequency_pop
--WITH pgx AS (SELECT hcp.*, (hcp.diplotype_frequency ->> 'Near Eastern')::numeric diplotype_frequency_pop, (hcp.allele1_frequency ->> 'Near Eastern')::numeric allele1_frequency_pop, (hcp.allele2_frequency ->> 'Near Eastern')::numeric allele2_frequency_pop

FROM prada.harmonised_combined_pgx hcp
INNER JOIN prada.drug d ON hcp.drug_name = d.name AND d.class IS NOT NULL
WHERE d.type='antidepressant' OR d.type='generic')
SELECT 
pgx.*,
COALESCE(pgx.diplotype_frequency_pop, 2*pgx.allele1_frequency_pop*pgx.allele2_frequency_pop) consensus_allele_frequency --2*pgx.allele1_frequency_pop*pgx.allele1_frequency_pop, 2*pgx.allele2_frequency_pop*pgx.allele2_frequency_pop
FROM pgx
WHERE recommendation IS NOT NULL
;


--SELECT * FROM t_freq_recommendation WHERE consensus_allele_frequency>0 ORDER BY consensus_allele_frequency DESC,recommendation, diplotype;
--SELECT * FROM t_freq_recommendation WHERE drug_name='doxepin' AND gene_name='CYP2D6' ORDER BY diplotype,recommendation;
--SELECT * FROM t_freq_recommendation WHERE drug_name='doxepin' AND gene_name='CYP2D6' ORDER BY consensus_allele_frequency DESC,recommendation, diplotype;
--SELECT * FROM t_freq_recommendation WHERE recommendation=5992831 AND gene_name='CYP2D6' ORDER BY diplotype;
--SELECT * FROM t_freq_recommendation rec INNER JOIN prada.recommendation r ON r.recommendation = rec.recommendation AND r.drugid = rec.drug_name AND r.gene_name = rec.gene_name
--WHERE rec.recommendation=5992831 AND rec.gene_name='CYP2D6' ORDER BY diplotype;

----all combinatons before later distinct
--SELECT * FROM t_freq_recommendation rec INNER JOIN prada.recommendation r ON r.recommendation = rec.recommendation AND r.drugid = rec.drug_name AND r.gene_name = rec.gene_name
--WHERE r.prada_start_dose !=1 OR r.prada_target_dose !=1 OR r.prada_titration_speed !=2 OR r.prada_switch1_drug =1 OR r.prada_switch1_gene =1 OR r.prada_switch2_drug =1 OR r.prada_switch2_gene =1 OR r.prada_tdm =1
--ORDER BY rec.recommendation,rec.gene_name,rec.diplotype;
--
----compare with online ref
--SELECT DISTINCT rec.gene_name, rec.diplotype, rec.diplotype_frequency_pop, rec.allele1_frequency_pop, rec.allele2_frequency_pop, rec.consensus_allele_frequency  FROM t_freq_recommendation rec
--WHERE rec.gene_name='CYP2B6';


DROP TABLE IF EXISTS t_distinct_diplotype_any;
CREATE TEMP TABLE IF NOT EXISTS t_distinct_diplotype_any AS
WITH d AS (
SELECT DISTINCT ON (rec.drug_name, rec.gene_name, rec.diplotype) rec.recommendation, rec.drug_name, rec.gene_name, rec.diplotype, rec.diplotype_frequency_pop, rec.allele1_frequency_pop, rec.allele2_frequency_pop, rec.consensus_allele_frequency 
FROM t_freq_recommendation rec
INNER JOIN prada.recommendation r ON r.recommendation = rec.recommendation AND r.drugid = rec.drug_name AND r.gene_name = rec.gene_name
WHERE r.prada_start_dose !=1 OR r.prada_target_dose !=1 OR r.prada_titration_speed !=2 OR r.prada_switch1_drug =1 OR r.prada_switch1_gene =1 OR r.prada_switch2_drug =1 OR r.prada_switch2_gene =1 OR r.prada_tdm =1
ORDER BY rec.drug_name, rec.gene_name, rec.diplotype, rec.recommendation, rec.lookupkey::text, rec.implications
) 
SELECT r.gene_name,r.drugid,
sum(d.consensus_allele_frequency) freq_sum_any,
count(d.consensus_allele_frequency) num_any
FROM
prada.recommendation r
INNER JOIN d ON r.recommendation = d.recommendation AND r.drugid = d.drug_name AND r.gene_name = d.gene_name
GROUP BY r.gene_name,r.drugid;
SELECT * FROM t_distinct_diplotype_any;

DROP TABLE IF EXISTS t_distinct_diplotype_start_dose;
CREATE TEMP TABLE IF NOT EXISTS t_distinct_diplotype_start_dose AS
WITH d AS (
SELECT DISTINCT ON (rec.drug_name, rec.gene_name, rec.diplotype) rec.recommendation, rec.drug_name, rec.gene_name, rec.diplotype, rec.diplotype_frequency_pop, rec.allele1_frequency_pop, rec.allele2_frequency_pop, rec.consensus_allele_frequency 
FROM t_freq_recommendation rec
INNER JOIN prada.recommendation r ON r.recommendation = rec.recommendation AND r.drugid = rec.drug_name AND r.gene_name = rec.gene_name
WHERE r.prada_start_dose !=1
ORDER BY rec.drug_name, rec.gene_name, rec.diplotype, rec.recommendation, rec.lookupkey::text, rec.implications
) 
SELECT r.gene_name,r.drugid,
sum(d.consensus_allele_frequency) freq_sum_start_dose,
count(d.consensus_allele_frequency) num_start_dose
FROM
prada.recommendation r
INNER JOIN d ON r.recommendation = d.recommendation AND r.drugid = d.drug_name AND r.gene_name = d.gene_name
GROUP BY r.gene_name,r.drugid;
SELECT * FROM t_distinct_diplotype_start_dose;

DROP TABLE IF EXISTS t_distinct_diplotype_target_dose;
CREATE TEMP TABLE IF NOT EXISTS t_distinct_diplotype_target_dose AS
WITH d AS (
SELECT DISTINCT ON (rec.drug_name, rec.gene_name, rec.diplotype) rec.recommendation, rec.drug_name, rec.gene_name, rec.diplotype, rec.diplotype_frequency_pop, rec.allele1_frequency_pop, rec.allele2_frequency_pop, rec.consensus_allele_frequency 
FROM t_freq_recommendation rec
INNER JOIN prada.recommendation r ON r.recommendation = rec.recommendation AND r.drugid = rec.drug_name AND r.gene_name = rec.gene_name
WHERE r.prada_target_dose !=1
ORDER BY rec.drug_name, rec.gene_name, rec.diplotype, rec.recommendation, rec.lookupkey::text, rec.implications
) 
SELECT r.gene_name,r.drugid,
sum(d.consensus_allele_frequency) freq_sum_target_dose,
count(d.consensus_allele_frequency) num_target_dose
FROM
prada.recommendation r
INNER JOIN d ON r.recommendation = d.recommendation AND r.drugid = d.drug_name AND r.gene_name = d.gene_name
GROUP BY r.gene_name,r.drugid;
SELECT * FROM t_distinct_diplotype_target_dose;

DROP TABLE IF EXISTS t_distinct_diplotype_titration_speed;
CREATE TEMP TABLE IF NOT EXISTS t_distinct_diplotype_titration_speed AS
WITH d AS (
SELECT DISTINCT ON (rec.drug_name, rec.gene_name, rec.diplotype) rec.recommendation, rec.drug_name, rec.gene_name, rec.diplotype, rec.diplotype_frequency_pop, rec.allele1_frequency_pop, rec.allele2_frequency_pop, rec.consensus_allele_frequency 
FROM t_freq_recommendation rec
INNER JOIN prada.recommendation r ON r.recommendation = rec.recommendation AND r.drugid = rec.drug_name AND r.gene_name = rec.gene_name
WHERE r.prada_titration_speed !=2
ORDER BY rec.drug_name, rec.gene_name, rec.diplotype, rec.recommendation, rec.lookupkey::text, rec.implications
) 
SELECT r.gene_name,r.drugid,
sum(d.consensus_allele_frequency) freq_sum_titration_speed,
count(d.consensus_allele_frequency) num_titration_speed
FROM
prada.recommendation r
INNER JOIN d ON r.recommendation = d.recommendation AND r.drugid = d.drug_name AND r.gene_name = d.gene_name
GROUP BY r.gene_name,r.drugid;
SELECT * FROM t_distinct_diplotype_titration_speed;

DROP TABLE IF EXISTS t_distinct_diplotype_switch_any;
CREATE TEMP TABLE IF NOT EXISTS t_distinct_diplotype_switch_any AS
WITH d AS (
SELECT DISTINCT ON (rec.drug_name, rec.gene_name, rec.diplotype) rec.recommendation, rec.drug_name, rec.gene_name, rec.diplotype, rec.diplotype_frequency_pop, rec.allele1_frequency_pop, rec.allele2_frequency_pop, rec.consensus_allele_frequency 
FROM t_freq_recommendation rec
INNER JOIN prada.recommendation r ON r.recommendation = rec.recommendation AND r.drugid = rec.drug_name AND r.gene_name = rec.gene_name
WHERE r.prada_switch1_drug =1 OR r.prada_switch1_gene =1 OR r.prada_switch2_drug =1 OR r.prada_switch2_gene =1
ORDER BY rec.drug_name, rec.gene_name, rec.diplotype, rec.recommendation, rec.lookupkey::text, rec.implications
) 
SELECT r.gene_name,r.drugid,
sum(d.consensus_allele_frequency) freq_sum_switch_any,
count(d.consensus_allele_frequency) num_switch_any
FROM
prada.recommendation r
INNER JOIN d ON r.recommendation = d.recommendation AND r.drugid = d.drug_name AND r.gene_name = d.gene_name
GROUP BY r.gene_name,r.drugid;
SELECT * FROM t_distinct_diplotype_switch_any;

DROP TABLE IF EXISTS t_distinct_diplotype_switch_drug;
CREATE TEMP TABLE IF NOT EXISTS t_distinct_diplotype_switch_drug AS
WITH d AS (
SELECT DISTINCT ON (rec.drug_name, rec.gene_name, rec.diplotype) rec.recommendation, rec.drug_name, rec.gene_name, rec.diplotype, rec.diplotype_frequency_pop, rec.allele1_frequency_pop, rec.allele2_frequency_pop, rec.consensus_allele_frequency 
FROM t_freq_recommendation rec
INNER JOIN prada.recommendation r ON r.recommendation = rec.recommendation AND r.drugid = rec.drug_name AND r.gene_name = rec.gene_name
WHERE r.prada_switch1_drug =1 OR r.prada_switch2_drug =1
ORDER BY rec.drug_name, rec.gene_name, rec.diplotype, rec.recommendation, rec.lookupkey::text, rec.implications
) 
SELECT r.gene_name,r.drugid,
sum(d.consensus_allele_frequency) freq_sum_switch_drug,
count(d.consensus_allele_frequency) num_switch_drug
FROM
prada.recommendation r
INNER JOIN d ON r.recommendation = d.recommendation AND r.drugid = d.drug_name AND r.gene_name = d.gene_name
GROUP BY r.gene_name,r.drugid;
SELECT * FROM t_distinct_diplotype_switch_drug;

DROP TABLE IF EXISTS t_distinct_diplotype_switch_gene;
CREATE TEMP TABLE IF NOT EXISTS t_distinct_diplotype_switch_gene AS
WITH d AS (
SELECT DISTINCT ON (rec.drug_name, rec.gene_name, rec.diplotype) rec.recommendation, rec.drug_name, rec.gene_name, rec.diplotype, rec.diplotype_frequency_pop, rec.allele1_frequency_pop, rec.allele2_frequency_pop, rec.consensus_allele_frequency 
FROM t_freq_recommendation rec
INNER JOIN prada.recommendation r ON r.recommendation = rec.recommendation AND r.drugid = rec.drug_name AND r.gene_name = rec.gene_name
WHERE r.prada_switch1_gene =1 OR r.prada_switch2_gene =1
ORDER BY rec.drug_name, rec.gene_name, rec.diplotype, rec.recommendation, rec.lookupkey::text, rec.implications
) 
SELECT r.gene_name,r.drugid,
sum(d.consensus_allele_frequency) freq_sum_switch_gene,
count(d.consensus_allele_frequency) num_switch_gene
FROM
prada.recommendation r
INNER JOIN d ON r.recommendation = d.recommendation AND r.drugid = d.drug_name AND r.gene_name = d.gene_name
GROUP BY r.gene_name,r.drugid;
SELECT * FROM t_distinct_diplotype_switch_gene;

DROP TABLE IF EXISTS t_distinct_diplotype_tdm;
CREATE TEMP TABLE IF NOT EXISTS t_distinct_diplotype_tdm AS
WITH d AS (
SELECT DISTINCT ON (rec.drug_name, rec.gene_name, rec.diplotype) rec.recommendation, rec.drug_name, rec.gene_name, rec.diplotype, rec.diplotype_frequency_pop, rec.allele1_frequency_pop, rec.allele2_frequency_pop, rec.consensus_allele_frequency 
FROM t_freq_recommendation rec
INNER JOIN prada.recommendation r ON r.recommendation = rec.recommendation AND r.drugid = rec.drug_name AND r.gene_name = rec.gene_name
WHERE r.prada_tdm =1
ORDER BY rec.drug_name, rec.gene_name, rec.diplotype, rec.recommendation, rec.lookupkey::text, rec.implications
) 
SELECT r.gene_name,r.drugid,
sum(d.consensus_allele_frequency) freq_sum_tdm,
count(d.consensus_allele_frequency) num_switch_tdm
FROM
prada.recommendation r
INNER JOIN d ON r.recommendation = d.recommendation AND r.drugid = d.drug_name AND r.gene_name = d.gene_name
GROUP BY r.gene_name,r.drugid;
SELECT * FROM t_distinct_diplotype_tdm;


DROP TABLE IF EXISTS t_freq_recommendation_summary;
CREATE TEMP TABLE IF NOT EXISTS t_freq_recommendation_summary AS
SELECT 
da.drugid,da.gene_name,
da.freq_sum_any, --da.num_any,
dsd.freq_sum_start_dose, --dsd.num_start_dose,
dtd.freq_sum_target_dose,
dts.freq_sum_titration_speed,
dswa.freq_sum_switch_any,
dswd.freq_sum_switch_drug,
dswg.freq_sum_switch_gene,
dtdm.freq_sum_tdm

FROM
t_distinct_diplotype_any da
LEFT OUTER JOIN t_distinct_diplotype_start_dose dsd ON da.drugid = dsd.drugid AND da.gene_name = dsd.gene_name
LEFT OUTER JOIN t_distinct_diplotype_target_dose dtd ON da.drugid = dtd.drugid AND da.gene_name = dtd.gene_name
LEFT OUTER JOIN t_distinct_diplotype_titration_speed dts ON da.drugid = dts.drugid AND da.gene_name = dts.gene_name
LEFT OUTER JOIN t_distinct_diplotype_switch_any dswa ON da.drugid = dswa.drugid AND da.gene_name = dswa.gene_name
LEFT OUTER JOIN t_distinct_diplotype_switch_drug dswd ON da.drugid = dswd.drugid AND da.gene_name = dswd.gene_name
LEFT OUTER JOIN t_distinct_diplotype_switch_gene dswg ON da.drugid = dswg.drugid AND da.gene_name = dswg.gene_name
LEFT OUTER JOIN t_distinct_diplotype_tdm dtdm ON da.drugid = dtdm.drugid AND da.gene_name = dtdm.gene_name
;
SELECT * FROM t_freq_recommendation_summary
ORDER BY drugid,gene_name;


--SELECT 
--rec.recommendation,
--rec.gene_name,
--rec.drug_name,
----rec.diplotype,
--sum(rec.consensus_allele_frequency) freq,
--count(rec.consensus_allele_frequency) num
--FROM t_freq_recommendation rec 
--GROUP BY rec.recommendation,rec.gene_name,rec.drug_name;

--DROP TABLE IF EXISTS t_freq_agg_recommendation;
--CREATE TEMP TABLE IF NOT EXISTS t_freq_agg_recommendation AS
--SELECT 
----rec.recommendation,
--rec.gene_name,
--rec.drug_name,
----rec.diplotype,
--sum(rec.consensus_allele_frequency) freq,
--count(rec.consensus_allele_frequency) num
--FROM t_freq_recommendation rec INNER JOIN prada.recommendation r ON r.recommendation = rec.recommendation AND r.drugid = rec.drug_name AND r.gene_name = rec.gene_name
--WHERE r.prada_start_dose !=1 OR r.prada_target_dose !=1 OR r.prada_titration_speed !=2 OR r.prada_switch1_drug =1 OR r.prada_switch1_gene =1 OR r.prada_switch2_drug =1 OR r.prada_switch2_gene =1 OR r.prada_tdm =1
--GROUP BY rec.recommendation,rec.gene_name,rec.drug_name;
--
--SELECT * FROM t_freq_agg_recommendation f INNER JOIN prada.recommendation r ON r.recommendation = f.recommendation AND r.gene_name = f.gene_name;
--
--DROP TABLE IF EXISTS t_freq_agg_recommendation2;
--CREATE TEMP TABLE IF NOT EXISTS t_freq_agg_recommendation2 AS
--SELECT 
--rec.recommendation,
--rec.gene_name,
--rec.drug_name,
----rec.diplotype,
--sum(rec.consensus_allele_frequency) freq,
--count(rec.consensus_allele_frequency) num
--FROM t_freq_recommendation rec INNER JOIN prada.recommendation r ON r.recommendation = rec.recommendation AND r.drugid = rec.drug_name AND r.gene_name = rec.gene_name
--WHERE NOT (r.prada_start_dose !=1 OR r.prada_target_dose !=1 OR r.prada_titration_speed !=2 OR r.prada_switch1_drug =1 OR r.prada_switch1_gene =1 OR r.prada_switch2_drug =1 OR r.prada_switch2_gene =1 OR r.prada_tdm =1)
--GROUP BY rec.recommendation,rec.gene_name,rec.drug_name;
--
--SELECT * FROM t_freq_agg_recommendation2;




