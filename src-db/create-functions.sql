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
	nPrioritisedGenes integer,
	anchorTypes text[],
	paddingGeneBp integer DEFAULT 10000
	paddingPRSAnchorBp integer DEFAULT 10000
) RETURNS int AS $$
DECLARE
    nid int = NULL;
BEGIN
	--use $ -notation if there is a collision between argument names and column names
--	
--	DROP TABLE IF EXISTS t_coverage_genes;
--	CREATE TEMP TABLE IF NOT EXISTS t_coverage_genes AS SELECT DISTINCT px.gene_name, px.gene_id, px.chr, px.bp1, px.bp2, prada_cpiclevel_num, prada_pgkbcalevel_num, prada_ehrpriority_num
--	FROM prada.combined_pgx px
--	WHERE prada_cpiclevel_num > 0 OR prada_pgkbcalevel_num > 0 OR prada_ehrpriority_num > 0 
--	ORDER BY prada_cpiclevel_num DESC, prada_pgkbcalevel_num DESC, prada_ehrpriority_num DESC
--	LIMIT nPrioritisedGenes;



/* -----------------------------------------------------------
two “match” CTEs
----------------------------------------------------------- */

WITH sym_match AS (
  SELECT DISTINCT ON (pgx."Gene")
         pgx."Gene"                 AS pgx_gene,
         g.chr,
         g.bp1 - 1                  AS start0,          -- BED 0-based
         g.bp2                      AS end1,            -- BED end
         g.gene_name,
         g.gene_id,
         'symbol'::text             AS match_rule
  FROM   prada.pgx_gene      pgx
  JOIN   prada.gencode_gene  g
         ON LOWER(g.gene_name) = LOWER(pgx."Gene")
  WHERE  g.chr LIKE 'chr%'                             -- primary assembly
  ORDER  BY pgx."Gene", g.bp1
), id_match AS (
  SELECT DISTINCT ON (pgx."Gene")
         pgx."Gene"                 AS pgx_gene,
         g.chr,
         g.bp1 - 1                  AS start0,
         g.bp2                      AS end1,
         g.gene_name,
         g.gene_id,
         'ensembl'::text            AS match_rule
  FROM   prada.pgx_gene      pgx
  JOIN   cpic.gene           c  ON  c.symbol   = pgx."Gene"
  JOIN   prada.gencode_gene  g  ON  g.gene_id  = c.ensemblid
  WHERE  pgx."Gene" NOT IN (SELECT pgx_gene FROM sym_match)   -- fallback only
    AND  g.chr LIKE 'chr%'
  ORDER  BY pgx."Gene", g.bp1
), union_matches AS (
  SELECT * FROM sym_match
  UNION ALL
  SELECT * FROM id_match
)
SELECT *
FROM   union_matches          -- ← this is the bit that was missing
ORDER  BY chr, start0;

/* -----------------------------------------------------------
 BED and show still-unmatched
   ----------------------------------------------------------- */
--  BED file: four columns + comment column (match rule)
WITH sym_match AS (
  SELECT DISTINCT ON (pgx."Gene")
         pgx."Gene"                 AS pgx_gene,
         g.chr,
         g.bp1 - 1                  AS start0,          -- BED 0-based
         g.bp2                      AS end1,            -- BED end
         g.gene_name,
         g.gene_id,
         'symbol'::text             AS match_rule
  FROM   prada.pgx_gene      pgx
  JOIN   prada.gencode_gene  g
         ON LOWER(g.gene_name) = LOWER(pgx."Gene")
  WHERE  g.chr LIKE 'chr%'                             -- primary assembly
  ORDER  BY pgx."Gene", g.bp1
), id_match AS (
  SELECT DISTINCT ON (pgx."Gene")
         pgx."Gene"                 AS pgx_gene,
         g.chr,
         g.bp1 - 1                  AS start0,
         g.bp2                      AS end1,
         g.gene_name,
         g.gene_id,
         'ensembl'::text            AS match_rule
  FROM   prada.pgx_gene      pgx
  JOIN   cpic.gene           c  ON  c.symbol   = pgx."Gene"
  JOIN   prada.gencode_gene  g  ON  g.gene_id  = c.ensemblid
  WHERE  pgx."Gene" NOT IN (SELECT pgx_gene FROM sym_match)   -- fallback only
    AND  g.chr LIKE 'chr%'
  ORDER  BY pgx."Gene", g.bp1
), union_matches AS (
  SELECT * FROM sym_match
  UNION ALL
  SELECT * FROM id_match
)
SELECT
      chr,
      start0 as chromStart ,
      end1 as chromEnd ,
      pgx_gene AS name   -- 4th BED column
  FROM   union_matches
  ORDER  BY
      /* numeric chr 1-22 → 1-22,   chrX=23, chrY=24, chrM/chrMT=25 */
      CASE
          WHEN chr = 'chrX'                   THEN 23
          WHEN chr = 'chrY'                   THEN 24
          WHEN chr IN ('chrM','chrMT')        THEN 25
          WHEN chr ~ '^chr[0-9]+$'            THEN CAST(substr(chr,4) AS int)
          ELSE 99
      END,
      start0;

/* list pharmacogenes still without any GENCODE hit -- NULL!! */
--WITH sym_match AS (
--  SELECT DISTINCT ON (pgx."Gene")
--         pgx."Gene"                 AS pgx_gene,
--         g.chr,
--         g.bp1 - 1                  AS start0,          -- BED 0-based
--         g.bp2                      AS end1,            -- BED end
--         g.gene_name,
--         g.gene_id,
--         'symbol'::text             AS match_rule
--  FROM   prada.pgx_gene      pgx
--  JOIN   prada.gencode_gene  g
--         ON LOWER(g.gene_name) = LOWER(pgx."Gene")
--  WHERE  g.chr LIKE 'chr%'                             -- primary assembly
--  ORDER  BY pgx."Gene", g.bp1
--), id_match AS (
--  SELECT DISTINCT ON (pgx."Gene")
--         pgx."Gene"                 AS pgx_gene,
--         g.chr,
--         g.bp1 - 1                  AS start0,
--         g.bp2                      AS end1,
--         g.gene_name,
--         g.gene_id,
--         'ensembl'::text            AS match_rule
--  FROM   prada.pgx_gene      pgx
--  JOIN   cpic.gene           c  ON  c.symbol   = pgx."Gene"
--  JOIN   prada.gencode_gene  g  ON  g.gene_id  = c.ensemblid
--  WHERE  pgx."Gene" NOT IN (SELECT pgx_gene FROM sym_match)   -- fallback only
--    AND  g.chr LIKE 'chr%'
--  ORDER  BY pgx."Gene", g.bp1
--), union_matches AS (
--  SELECT * FROM sym_match
--  UNION ALL
--  SELECT * FROM id_match
--)SELECT pgx."Gene"
--FROM   prada.pgx_gene  AS pgx
--LEFT   JOIN union_matches AS u
--       ON u.pgx_gene = pgx."Gene"
--WHERE  u.pgx_gene IS NULL
--ORDER  BY pgx."Gene";


	
	RETURN nid;
END;
$$ LANGUAGE plpgsql;

