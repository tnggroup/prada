--example play algorithm
-- Outputs list of drugs with information
-- Probability of side-effects and dosage recommendations may be possible to extract from the guidelines (consultationtext). Drug exclusion - extreme of dosage recommendation?

-- example play input - this may actually be necessary to run before creating the function
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


--DROP FUNCTION prada.get_application_recommendation;
CREATE OR REPLACE FUNCTION prada.get_application_recommendation() RETURNS TABLE(
name text,
genesymbol text,
result text,
consultationtext text
) AS $$
	
	SELECT pg.name, pg.genesymbol, pg.result, pg.consultationtext FROM prada.cpic_pgx pg --pg.*
	INNER JOIN (SELECT t_gene_diplotype_input.*, t_gene_diplotype_input.a1 || '/'|| t_gene_diplotype_input.a2 AS diplotype FROM t_gene_diplotype_input) hcdata ON hcdata.gene = pg.genesymbol AND hcdata.diplotype = pg.diplotype
	--INNER JOIN t_drug_input d ON d.drugid=pg.drugid
	WHERE pgkbcalevel = '1A' OR pgkbcalevel = '1B' OR pgkbcalevel = '2A' OR pgkbcalevel = '2B';
	-- AND cpiclevel = 'A'
	-- AND ehrpriority != 'none';

$$ LANGUAGE sql;

--SELECT * FROM prada.get_application_recommendation();

-- Pharmgkb score => clinical annotation levels: https://www.pharmgkb.org/page/clinAnnLevels

-- Suggestion for the quantitative side: cpic/pharmgkb scores + PRS weighted into PETRUSHKA 'domain' scores


--DROP FUNCTION prada.get_application_coverage_regions;
--WIP!!!!
CREATE OR REPLACE FUNCTION prada.get_application_coverage_regions
(
	nPrioritisedGenes integer,
	anchorTypes text[],
	paddingGeneBp integer DEFAULT 10000
	paddingPRSAnchorBp integer DEFAULT 10000
) RETURNS int AS $$
DECLARE
    nid int = NULL;
BEGIN
	--use $ -notation if there is a collision between argument names and column names
	
	WITH SELECT gcg.gene_name, gcg.gene_id, gcg.bp1, gcg.bp2 
	FROM prada.gencode_gene gcg 
	ORDER BY 
	LIMIT nPrioritisedGenes
	
	RETURN nid;
END;
$$ LANGUAGE plpgsql;

