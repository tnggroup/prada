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
         pgx."Gene"        AS pgx_gene,
         g.chr,
         g.bp1 - 1         AS start0,  -- BED 0-based
         g.bp2             AS end1,    -- BED end
         g.gene_name,
         g.gene_id,
         'symbol'::text    AS match_rule
  FROM   prada.pgx_gene      pgx
  JOIN   prada.gencode_gene  g
         ON LOWER(g.gene_name) = LOWER(pgx."Gene")
  WHERE  g.chr LIKE 'chr%'   -- primary assembly
  ORDER  BY pgx."Gene", g.bp1
), 
id_match AS (
  SELECT DISTINCT ON (pgx."Gene")
         pgx."Gene"        AS pgx_gene,
         g.chr,
         g.bp1 - 1         AS start0,
         g.bp2             AS end1,
         g.gene_name,
         g.gene_id,
         'ensembl'::text   AS match_rule
  FROM   prada.pgx_gene      pgx
  JOIN   cpic.gene           c  ON  c.symbol = pgx."Gene"
  JOIN   prada.gencode_gene  g  ON  g.gene_id = c.ensemblid
  WHERE  pgx."Gene" NOT IN (SELECT pgx_gene FROM sym_match) -- fallback only
    AND  g.chr LIKE 'chr%'
  ORDER  BY pgx."Gene", g.bp1
), 
union_matches AS (
  SELECT * FROM sym_match
  UNION ALL
  SELECT * FROM id_match
), 
gene_overlaps AS (
  SELECT
      a.pgx_gene  AS gene1,
      b.pgx_gene  AS gene2,
      a.chr,
      a.start0    AS gene1_start,
      a.end1      AS gene1_end,
      b.start0    AS gene2_start,
      b.end1      AS gene2_end
  FROM union_matches a
  JOIN union_matches b
    ON a.chr = b.chr
   AND a.pgx_gene <> b.pgx_gene
   AND a.start0 < b.end1
   AND b.start0 < a.end1
)
SELECT
    um.chr,
    um.start0 AS chromStart,
    um.end1   AS chromEnd,
    um.pgx_gene AS name,  -- 4th BED column
    EXISTS (
        SELECT 1
        FROM gene_overlaps go
        WHERE go.gene1 = um.pgx_gene
    ) AS has_overlap
FROM union_matches um
ORDER BY
    CASE
        WHEN um.chr = 'chrX' THEN 23
        WHEN um.chr = 'chrY' THEN 24
        WHEN um.chr IN ('chrM','chrMT') THEN 25
        WHEN um.chr ~ '^chr[0-9]+$' THEN CAST(substr(um.chr, 4) AS int)
        ELSE 99
    END,
    um.start0;


----Experimental comma seperated genes ------
WITH sym_match AS (
  SELECT DISTINCT ON (pgx."Gene")
         pgx."Gene"        AS pgx_gene,
         g.chr,
         g.bp1 - 1         AS start0,  -- BED 0-based
         g.bp2             AS end1,    -- BED end
         g.gene_name,
         g.gene_id,
         'symbol'::text    AS match_rule
  FROM   prada.pgx_gene      pgx
  JOIN   prada.gencode_gene  g
         ON LOWER(g.gene_name) = LOWER(pgx."Gene")
  WHERE  g.chr LIKE 'chr%'
  ORDER  BY pgx."Gene", g.bp1
),
id_match AS (
  SELECT DISTINCT ON (pgx."Gene")
         pgx."Gene"        AS pgx_gene,
         g.chr,
         g.bp1 - 1         AS start0,
         g.bp2             AS end1,
         g.gene_name,
         g.gene_id,
         'ensembl'::text   AS match_rule
  FROM   prada.pgx_gene      pgx
  JOIN   cpic.gene           c  ON  c.symbol = pgx."Gene"
  JOIN   prada.gencode_gene  g  ON  g.gene_id = c.ensemblid
  WHERE  pgx."Gene" NOT IN (SELECT pgx_gene FROM sym_match)
    AND  g.chr LIKE 'chr%'
  ORDER  BY pgx."Gene", g.bp1
),
union_matches AS (           -- chr, start0, end1, pgx_gene
     SELECT * FROM sym_match
     UNION ALL
     SELECT * FROM id_match
),
ordered AS (
    SELECT
        chr,
        start0,
        end1,
        pgx_gene,
        MAX(end1) OVER (PARTITION BY chr
                        ORDER BY start0
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
            AS running_end
    FROM union_matches
),
flagged AS (
    SELECT
        chr,
        start0,
        end1,
        pgx_gene,
        CASE
            WHEN LAG(running_end) OVER (PARTITION BY chr ORDER BY start0)
                 IS NULL                                -- very first row
                 OR
                 start0 >
                 LAG(running_end) OVER (PARTITION BY chr ORDER BY start0)
            THEN 1                                      -- new cluster
            ELSE 0
        END AS new_cluster_flag
    FROM ordered
),
clustered AS (
    SELECT
        chr,
        start0,
        end1,
        pgx_gene,
        SUM(new_cluster_flag)
          OVER (PARTITION BY chr ORDER BY start0
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cluster_id
    FROM flagged
)SELECT
    chr,
    MIN(start0)                                  AS chromStart,
    MAX(end1)                                    AS chromEnd,
    STRING_AGG(DISTINCT pgx_gene, ',' ORDER BY pgx_gene) AS name
FROM   clustered
GROUP  BY chr, cluster_id
ORDER  BY
    CASE                                         -- nice chromosome order
        WHEN chr = 'chrX'                    THEN  23
        WHEN chr = 'chrY'                    THEN  24
        WHEN chr IN ('chrM','chrMT')         THEN  25
        WHEN chr ~  '^chr[0-9]+$'            THEN  CAST(substr(chr,4) AS int)
        ELSE  99
    END,
    chromStart;





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


--  BED file: extended columns -----------------------------------------------------------------
