-- The BED format: https://genome.ucsc.edu/FAQ/FAQformat.html#format1
-- Pharmgkb score => clinical annotation levels: https://www.pharmgkb.org/page/clinAnnLevels

CREATE OR REPLACE FUNCTION prada.get_coverage_regions
(
	paddingGeneBp integer DEFAULT 10000,
	paddingVariantCnvBp integer DEFAULT 10000,
	paddingVariantSnpBp integer DEFAULT 5000,
	nPrioritisedGene integer DEFAULT 300,
	nPrioritisedCnv integer DEFAULT 100,
	nPrioritisedSnp integer DEFAULT 200000,
	nPrioritisedTotal integer DEFAULT 25000,
	wGene double precision DEFAULT 1e20,
	wVariantCnv double precision DEFAULT 1e6,
	wVariantSnp double precision DEFAULT 1
) RETURNS int AS $$
DECLARE
    nid int = NULL;
BEGIN
	--use $ -notation if there is a collision between argument names and column names
	
	--attempt at unified handling of regions/variants
	DROP TABLE IF EXISTS t_coverage_region;
	CREATE TEMP TABLE IF NOT EXISTS t_coverage_region AS
	WITH v AS 
	(
		SELECT 
		v.type,
		v.label,
		v.id,
		v.chr,
		c.name chr_name,
		v.bp1,
		v.bp2,
		v.p,
		v.w,
		CASE 
			WHEN v.type=0 THEN (v.bp1-paddingGeneBp) --paddingGeneBp
			WHEN v.type=2 THEN (v.bp1-paddingVariantCnvBp) --paddingVariantCnvBp
			ELSE (v.bp1-paddingVariantSnpBp) --paddingVariantSnpBp
		END abp1,
		CASE 
			WHEN v.type=0 THEN (v.bp2+paddingGeneBp) --paddingGeneBp
			WHEN v.type=2 THEN (v.bp2+paddingVariantCnvBp) --paddingVariantCnvBp
			ELSE (v.bp2+paddingVariantSnpBp) --paddingVariantSnpBp
		END abp2,
		c.sizebp chromosome_sizebp
		FROM (
			(
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
				union_matches AS (
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
								 IS NULL
								 OR
								 start0 >
								 LAG(running_end) OVER (PARTITION BY chr ORDER BY start0)
							THEN 1
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
				),
				merged_genes AS (
					SELECT
						chr,
						MIN(start0)                                  AS chromStart,
						MAX(end1)                                    AS chromEnd,
						STRING_AGG(DISTINCT pgx_gene, ',' ORDER BY pgx_gene) AS name
					FROM   clustered
					GROUP  BY chr, cluster_id
				)
				SELECT
					0 AS type,
					mg.name AS label,
					mg.name AS id,
					(CASE
						WHEN mg.chr = 'chrX' THEN 23
						WHEN mg.chr = 'chrY' THEN 24
						WHEN mg.chr IN ('chrM', 'chrMT') THEN 25
						WHEN mg.chr ~ '^chr[0-9]+$' THEN CAST(substr(mg.chr, 4) AS integer)
						ELSE 99
					END) AS chr,
					mg.chromStart + 1 AS bp1, -- Convert from 0-based start
					mg.chromEnd AS bp2,
					NULL AS p,
					(wGene/1.0)::double precision AS w
				FROM merged_genes mg
				ORDER BY (mg.chromEnd - mg.chromStart) DESC -- Prioritize largest merged regions
				LIMIT nPrioritisedGene
			)
			UNION
			(
				SELECT 
				2 AS type,
				vcnv.snp AS label,
				vcnv.snp AS id,
				vcnv.chr,
				vcnv.bp AS bp1,
				vcnv.bp2,
				vcnv.mdd_p AS p,
				(wVariantCnv/vcnv.mdd_p)::double precision AS w  --wVariantCnv
				FROM prada.variant vcnv
				WHERE vcnv.type=2
				ORDER BY mdd_p ASC, (vcnv.bp2-vcnv.bp) DESC, snp
				LIMIT nPrioritisedCnv -- Corrected from nPrioritisedGene to nPrioritisedCnv
			)
			UNION
			(
				SELECT 
				1 AS type,
				vsnp.snp AS label,
				vsnp.snp AS id,
				vsnp.chr,
				vsnp.bp AS bp1,
				CASE 
					WHEN vsnp.bp2 IS NULL THEN vsnp.bp
					ELSE vsnp.bp2
				END AS bp2,
				vsnp.mdd_p AS p,
				(wVariantSnp/vsnp.mdd_p)::double precision AS w  --wVariantSnp
				FROM prada.variant vsnp
				WHERE vsnp.type=1
				ORDER BY mdd_p ASC, chr, snp
				LIMIT nPrioritisedSnp --nPrioritisedSnp
			)
			
		) v
		INNER JOIN prada.chromosome c ON v.chr=c.number
	), v2 AS (
		SELECT 
		v.type,
		v.label,
		v.id,
		v.chr,
		v.chr_name,
		v.bp1,
		v.bp2,
		v.p,
		v.w,
		(
		CASE
			WHEN abp1<0 THEN 0
			ELSE abp1
		END
		) abp1, --trimmed version
		(
		CASE
			WHEN abp2>chromosome_sizebp THEN chromosome_sizebp
			ELSE abp2
		END
		) abp2, --trimmed version
		v.chromosome_sizebp
		FROM v
	)
	SELECT
	ROW_NUMBER() OVER (ORDER BY w DESC, (v2.abp2-v2.abp1)::double precision DESC, chr, label) cid, 
	v2.*,
	(v2.abp2-v2.abp1)::double precision coveragebp,
	((v2.abp2-v2.abp1)::double precision/(chromosome_sizebp::double precision)) coveragecf
	FROM v2
	ORDER BY w DESC, coveragebp DESC, chr, label
	LIMIT nPrioritisedTotal; --nPrioritisedTotal


	UPDATE t_coverage_region 
	SET id= chr_name||':'||bp1||'-'||bp2
	WHERE id IS NULL;

	RETURN nid;
END;
$$ LANGUAGE plpgsql;
