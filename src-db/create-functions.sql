

-- Pharmgkb score => clinical annotation levels: https://www.pharmgkb.org/page/clinAnnLevels

-- Suggestion for the quantitative side: cpic/pharmgkb scores + PRS weighted into PETRUSHKA 'domain' scores

-- The BED format: https://genome.ucsc.edu/FAQ/FAQformat.html#format1

--DROP FUNCTION prada.get_application_coverage_regions;
--WIP!!!!


--SELECT
--    g.chr                       AS chrom,          -- e.g. 1, 2, X, Y, MT
--    g.bp1 - 1                   AS chromStart,     -- 0-based for BED
--    g.bp2                       AS chromEnd,       -- 1-based, exclusive
--    pgx."Gene"                    AS gene_symbol,    -- canonical symbol
--    c.hgncid                    AS hgnc_id,        -- example extra annotations
--    c.ensemblid                AS ensembl_id,
--    c.ncbiid                     AS ncbi_gene_id
--FROM
--    prada.pgx_gene      AS pgx                       -- ① driver table
--JOIN
--    cpic.gene           AS c   ON  c.symbol     = pgx."Gene"
--JOIN
--    prada.gencode_gene  AS g   ON  g.gene_name  = pgx."Gene"
--ORDER BY
--    CASE                                           -- tidy sort
--        WHEN g.chr ~ '^[0-9]+$' THEN CAST(g.chr AS INT)
--        WHEN g.chr = 'X'        THEN 23
--        WHEN g.chr = 'Y'        THEN 24
--        WHEN g.chr = 'MT'       THEN 25
--        ELSE 99
--    END,
--    g.bp1;
--    AND g.feature_type = 'gene'                     -- keep full-gene rows


SELECT DISTINCT ON (pgx."Gene")           -- one row per pharmacogene
         g.chr                AS chrom,
         g.bp1 - 1            AS chromStart,       -- 0-based for BED
         g.bp2                AS chromEnd,
         pgx."Gene"             AS gene_symbol
  FROM   prada.pgx_gene        AS pgx
  JOIN   cpic.gene             AS c   ON c.symbol     = pgx."Gene"
  JOIN   prada.gencode_gene    AS g   ON g.gene_name  = pgx."Gene"
  WHERE  g.chr IN ( 'chr1','chr2','chr3','chr4','chr5','chr6','chr7','chr8',
                    'chr9','chr10','chr11','chr12','chr13','chr14','chr15',
                    'chr16','chr17','chr18','chr19','chr20','chr21','chr22',
                    'chrX','chrY','chrM' )          -- primary assembly only
  ORDER BY pgx."Gene",
           -- tie-breaker: pick the lowest genomic coordinate if duplicates
           CASE
             WHEN g.chr ~ '^[0-9]+$' THEN CAST(substr(g.chr,4) AS int)
             WHEN g.chr = 'chrX' THEN 23
             WHEN g.chr = 'chrY' THEN 24
             WHEN g.chr = 'chrM' THEN 25
             ELSE 99
           END,
           g.bp1;


-- Any pharmacogene with zero match in GENCODE?
SELECT pgx."Gene"
FROM   prada.pgx_gene pgx
LEFT JOIN prada.gencode_gene g
  ON g.gene_name = pgx."Gene"
     AND g.chr LIKE 'chr%'
WHERE  g.gene_name IS NULL;

-- Any pharmacogene still producing >1 row?
SELECT pgx."Gene", COUNT(*) AS n_rows
FROM   prada.pgx_gene pgx
JOIN   prada.gencode_gene g  ON g.gene_name = pgx."Gene"
WHERE  g.chr LIKE 'chr%'         -- primary assembly only
GROUP BY pgx."Gene"
HAVING COUNT(*) > 1;


CREATE OR REPLACE FUNCTION prada.get_application_coverage_regions
(
	nPrioritisedGenes integer DEFAULT 300,
	paddingGeneBp integer DEFAULT 10000,
	paddingPRSAnchorBp integer DEFAULT 10000,
	anchorTypes text[] DEFAULT NULL --not used yet
) RETURNS int AS $$
DECLARE
    nid int = NULL;
BEGIN
	--use $ -notation if there is a collision between argument names and column names
	
	DROP TABLE IF EXISTS t_coverage_genes;
	CREATE TEMP TABLE IF NOT EXISTS t_coverage_genes AS
	WITH g AS 
	(
		SELECT 
		g.*,
		
		(g.bp1-paddingGeneBp) abp1,
		(g.bp2+paddingGeneBp) abp2,
		c.sizebp chromosome_sizebp
		FROM prada.harmonised_combined_pgx_gene g
		INNER JOIN prada.chromosome c ON g.chr=c.name
	), g2 AS (
		SELECT 
		g.*,
		(
		CASE
			WHEN abp1<0 THEN 0
			ELSE abp1
		END
		) abp1_trimmed,
		(
		CASE
			WHEN abp2>chromosome_sizebp THEN chromosome_sizebp
			ELSE abp2
		END
		) abp2_trimmed
		FROM g
	)
	SELECT 
	g2.*,
	(g2.abp2_trimmed-g2.abp1_trimmed) coveragebp,
	((g2.abp2_trimmed-g2.abp1_trimmed)/chromosome_sizebp) coveragecf
	FROM g2
	ORDER BY prada_gene_score DESC
	LIMIT nPrioritisedGenes;

	RETURN nid;
END;
$$ LANGUAGE plpgsql;

--SELECT * FROM prada.get_application_coverage_regions();
--SELECT * FROM t_coverage_genes;
--SELECT g.chr, sum(g.coveragecf), sum(g.coveragebp) FROM t_coverage_genes g GROUP BY g.chr; -- per chromosome
--WITH c AS (SELECT sum(sizebp) gsize FROM prada.chromosome c)
--SELECT sum(g.coveragebp) totalbp, sum(g.coveragebp)/c.gsize totalf
--FROM t_coverage_genes g INNER JOIN c ON TRUE
--GROUP BY c.gsize --gsize = 3088269832
--; --20541620bp, 0.00665149780215189435

--SELECT * FROM t_coverage_genes a INNER JOIN t_coverage_genes b ON a.chr=b.chr AND 
--(
--	(a.bp1>b.bp2 AND a.bp1<b.bp2)
--	OR
--	(b.bp1>a.bp2 AND b.bp1<a.bp2) 
--)
--; -- no overlaps

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
-- PLACEHOLDER FUNCTION, TO BE UPDATED
CREATE OR REPLACE FUNCTION prada.get_application_recommendation() RETURNS TABLE(
name text,
genesymbol text,
result text,
consultationtext text,
prada_cpiclevel_num numeric,
prada_pgkbcalevel_num numeric,
prada_ehrpriority_num numeric
) AS $$
	
	SELECT pg.drug_name, pg.gene_name, pg.result, pg.consultationtext, pg.prada_cpiclevel_num, pg.prada_pgkbcalevel_num, pg.prada_ehrpriority_num
	FROM prada.combined_pgx pg --pg.*
	INNER JOIN (SELECT t_gene_diplotype_input.*, t_gene_diplotype_input.a1 || '/'|| t_gene_diplotype_input.a2 AS diplotype FROM t_gene_diplotype_input) hcdata ON hcdata.gene = pg.gene_name AND hcdata.diplotype = pg.diplotype
	--INNER JOIN t_drug_input d ON d.drugid=pg.drugid
	WHERE prada_cpiclevel_num > 0 OR prada_pgkbcalevel_num > 0 OR prada_ehrpriority_num > 1
	AND (pgkbcalevel = '1A' OR pgkbcalevel = '1B' OR pgkbcalevel = '2A' OR pgkbcalevel = '2B');
	-- AND cpiclevel = 'A'
	-- AND ehrpriority != 'none';

$$ LANGUAGE sql;

--SELECT * FROM prada.get_application_recommendation();

