

-- Pharmgkb score => clinical annotation levels: https://www.pharmgkb.org/page/clinAnnLevels

-- Suggestion for the quantitative side: cpic/pharmgkb scores + PRS weighted into PETRUSHKA 'domain' scores

-- The BED format: https://genome.ucsc.edu/FAQ/FAQformat.html#format1

--DROP FUNCTION prada.get_coverage_regions;

CREATE OR REPLACE FUNCTION prada.get_coverage_regions
(
	paddingGeneBp integer DEFAULT 10000,
	paddingVariantCnvBp integer DEFAULT 10000,
	paddingVariantSnpBp integer DEFAULT 10000,
	nPrioritisedGene integer DEFAULT 300,
	nPrioritisedCnv integer DEFAULT 100,
	nPrioritisedSnp integer DEFAULT 200000,
	nPrioritisedTotal integer DEFAULT 25000,
	wGene double precision DEFAULT 1e20,
	wVariantCnv double precision DEFAULT 1e7,
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
				SELECT 
				0 AS type,
				g.gene_name AS label,
				g.gene_id AS id,
				(g.chr::integer) AS chr,
				g.bp1,
				g.bp2,
				NULL AS p,
				(wGene/1.0)::double precision AS w  --wGene
				FROM prada.harmonised_combined_pgx_gene g
				ORDER BY prada_gene_score DESC, (g.bp2-g.bp1) DESC, gene_name
				LIMIT nPrioritisedGene --nPrioritisedGene
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
				LIMIT nPrioritisedCnv --nPrioritisedCnv
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


--SELECT DISTINCT r.id FROM t_coverage_region r;

--SELECT * FROM prada.get_coverage_regions(nPrioritisedTotal=>25000);
--SELECT * FROM t_coverage_region;
--SELECT * FROM t_coverage_region WHERE type=2;
--SELECT g.chr, sum(g.coveragecf), sum(g.coveragebp) FROM t_coverage_region g GROUP BY g.chr; -- per chromosome
--WITH c AS (SELECT sum(sizebp) gsize FROM prada.chromosome c)
--SELECT sum(g.coveragebp) totalbp, sum(g.coveragebp::double precision)/c.gsize totalf
--FROM t_coverage_region g INNER JOIN c ON TRUE
--GROUP BY c.gsize
--;

--SELECT * FROM prada.get_coverage_regions();
--SELECT * FROM t_coverage_gene;
--SELECT g.chr, sum(g.coveragecf), sum(g.coveragebp) FROM t_coverage_gene g GROUP BY g.chr; -- per chromosome
--WITH c AS (SELECT sum(sizebp) gsize FROM prada.chromosome c)
--SELECT sum(g.coveragebp) totalbp, sum(g.coveragebp)/c.gsize totalf
--FROM t_coverage_gene g INNER JOIN c ON TRUE
--GROUP BY c.gsize --gsize = 3088269832
--; --20541620bp, 0.00665149780215189435

--SELECT * FROM prada.get_coverage_regions();
--SELECT * FROM t_coverage_variant_cnv;
--SELECT g.chr, sum(g.coveragecf), sum(g.coveragebp) FROM t_coverage_variant_cnv g GROUP BY g.chr; -- per chromosome
--WITH c AS (SELECT sum(sizebp) gsize FROM prada.chromosome c)
--SELECT sum(g.coveragebp) totalbp, sum(g.coveragebp::double precision)/c.gsize totalf
--FROM t_coverage_variant_cnv g INNER JOIN c ON TRUE
--GROUP BY c.gsize --gsize = 3088269832
--; --46356338bp, 0.0150104558609696



--SELECT * FROM prada.get_coverage_regions(nPrioritisedTotal=>5000);
--SELECT * FROM t_coverage_region;
CREATE OR REPLACE FUNCTION prada.filter_coverage_regions() RETURNS int AS $$
DECLARE
    nid int = NULL;
	overlap_record RECORD = NULL;
BEGIN

	DROP TABLE IF EXISTS t_coverage_region_filtered;
	CREATE TEMP TABLE IF NOT EXISTS t_coverage_region_filtered AS
	SELECT 
	--ROW_NUMBER() OVER (ORDER BY w DESC, coveragebp DESC, chr, label) cid,
	t_coverage_region.* 
	FROM t_coverage_region;
	CREATE UNIQUE INDEX t_coverage_region_filtered_u ON t_coverage_region_filtered(cid);
	CREATE INDEX i_coverage_region_filtered_i ON t_coverage_region_filtered(abp1,abp2,coveragebp);


	-- any overlap whatsoever
	LOOP
		DROP TABLE IF EXISTS t_coverage_region_difficult_overlaps;
		CREATE TEMP TABLE IF NOT EXISTS t_coverage_region_difficult_overlaps AS
		SELECT
			r1.chr,
			r1.cid r1_cid,
			r1.bp1 r1_bp1,
			r1.bp2 r1_bp2,
			r1.abp1 r1_abp1,
			r1.abp2 r1_abp2,
			r1.coveragebp r1_coveragebp,
			r2.cid r2_cid,
			r2.bp1 r2_bp1,
			r2.bp2 r2_bp2,
			r2.abp1 r2_abp1,
			r2.abp2 r2_abp2,
			r2.coveragebp r2_coveragebp,
			CASE
				WHEN r1.coveragebp>r2.coveragebp THEN r1.coveragebp
				ELSE r2.coveragebp
			END max_coveragebp
		FROM
		t_coverage_region_filtered r1 INNER JOIN t_coverage_region_filtered r2 ON r1.chr=r2.chr AND ((r1.abp2>=r2.abp1 AND r1.abp1<=r2.abp2) OR (r2.abp2>=r1.abp1 AND r2.abp1<=r1.abp2))
		AND (
				r1.cid<r2.cid OR r1.coveragebp>r2.coveragebp
		) --AND r1.abp1<=r2.abp1
		ORDER BY max_coveragebp DESC, r1_cid;
		CREATE UNIQUE INDEX t_coverage_region_difficult_overlaps_u ON t_coverage_region_difficult_overlaps(r1_cid,r2_cid);
		CREATE INDEX t_coverage_region_difficult_overlaps_i ON t_coverage_region_difficult_overlaps(r1_abp1,r1_abp2,r1_coveragebp,r2_abp1,r2_abp2,r2_coveragebp,max_coveragebp);

--		SELECT * FROM t_coverage_region_difficult_overlaps;
--		SELECT chr, r1_cid, MIN(r2_abp1) min_r2_abp1, MAX(r2_abp2) max_r2_abp2  --r1_abp1, r1_abp2, r1_coveragebp
--		FROM t_coverage_region_difficult_overlaps o
--		--WHERE o.r1_coveragebp > o.r2_coveragebp OR (o.r1_coveragebp = o.r2_coveragebp AND o.r1_cid<o.r2_cid)
--		GROUP BY o.chr, o.r1_cid; --, o.r1_abp1, o.r1_abp2, o.r1_coveragebp
		--SELECT * FROM t_coverage_region_difficult_overlaps WHERE r1_cid=477 OR r2_cid=477;
		--SELECT * FROM t_coverage_region_difficult_overlaps WHERE r1_cid=350 OR r2_cid=350;

		SELECT INTO overlap_record * FROM
		(
			SELECT * FROM t_coverage_region_difficult_overlaps
			LIMIT 1
		) s;

		IF NOT FOUND
		THEN
			EXIT; -- exit loop
		END IF;


		IF overlap_record.r1_cid IS NULL
		THEN
			EXIT;
		END IF;

		--RAISE NOTICE '>%', overlap_record.r1_id;

		--SELECT * FROM t_coverage_region_difficult_overlaps;
		--SELECT * FROM t_coverage_region_filtered;

		RAISE NOTICE '>%', (SELECT COUNT(*) FROM t_coverage_region_filtered);

		--region 1 is the primary region, to avoid duplicate processing
		DROP TABLE IF EXISTS t_difficult_overlap_updates;
		CREATE TEMP TABLE IF NOT EXISTS t_difficult_overlap_updates AS
		WITH u AS (
		UPDATE t_coverage_region_filtered f
		SET
		bp1 =	CASE 
					WHEN min_r2_bp1 < bp1 THEN min_r2_bp1
					ELSE bp1
				END,
		bp2 =	CASE 
					WHEN max_r2_bp2 > bp2 THEN max_r2_bp2
					ELSE bp2
				END,
		abp1 =	CASE 
					WHEN min_r2_abp1 < abp1 THEN min_r2_abp1
					ELSE abp1
				END,
		abp2 =	CASE 
					WHEN max_r2_abp2 > abp2 THEN max_r2_abp2
					ELSE abp2
				END
		FROM (
				SELECT chr, r1_cid, MIN(r2_bp1) min_r2_bp1, MAX(r2_bp2) max_r2_bp2, MIN(r2_abp1) min_r2_abp1, MAX(r2_abp2) max_r2_abp2  --r1_abp1, r1_abp2, r1_coveragebp
				FROM t_coverage_region_difficult_overlaps o
				--WHERE o.r1_coveragebp > o.r2_coveragebp OR (o.r1_coveragebp = o.r2_coveragebp AND o.r1_cid<o.r2_cid)
				GROUP BY o.chr, o.r1_cid --, o.r1_abp1, o.r1_abp2, o.r1_coveragebp
			) AS o
		WHERE f.chr=o.chr AND f.cid=o.r1_cid
		RETURNING f.chr, f.cid, f.abp1, f.abp2)
		SELECT * FROM u;

		--SELECT * FROM t_difficult_overlap_updates;

		-- This needs to happen before deleting clusters, because they may have been updated
		UPDATE t_coverage_region_filtered
		SET coveragebp = (abp2-abp1)::double precision,coveragecf = ((abp2-abp1)::double precision/(chromosome_sizebp::double precision)); 

		--SELECT * FROM t_coverage_region_filtered;


		DELETE FROM t_coverage_region_filtered f
		USING t_coverage_region_difficult_overlaps o, t_difficult_overlap_updates u, t_coverage_region_filtered fu
		WHERE f.chr=o.chr AND u.cid=o.r1_cid AND f.cid=o.r2_cid AND u.cid=fu.cid AND ((fu.abp1<f.abp1 AND fu.abp2>f.abp2) OR (fu.abp1<=f.abp1 AND fu.abp2>=f.abp2 AND fu.cid<f.cid));
		--SELECT * FROM t_coverage_region_filtered;
--		SELECT f.cid, f.abp1, f.abp2, fu.cid, fu.abp1, fu.abp2 FROM t_coverage_region_filtered f, t_coverage_region_difficult_overlaps o, t_difficult_overlap_updates u, t_coverage_region_filtered fu
--		WHERE f.chr=o.chr AND u.cid=o.r1_cid AND f.cid=o.r2_cid AND u.cid=fu.cid AND ((fu.abp1<f.abp1 AND fu.abp2>f.abp2) OR (fu.abp1<=f.abp1 AND fu.abp2>=f.abp2 AND fu.cid<f.cid));
--	
	END LOOP;

	RETURN nid;

END;
$$ LANGUAGE plpgsql;

--SELECT * FROM prada.filter_coverage_regions();
--SELECT * FROM t_coverage_region_filtered;

--sanity check
--SELECT r.cid,r.chr,r.id,r.abp1,r.abp2,r.coveragebp,f.cid,f.abp1,f.abp2,f.coveragebp
--FROM t_coverage_region r LEFT OUTER JOIN t_coverage_region_filtered f 
--ON r.chr=f.chr AND ((r.abp1 >=f.abp1 AND r.abp1<=f.abp2) OR (r.abp2<=f.abp2 AND r.abp2 >=f.abp1))
----WHERE f.cid IS NULL
--ORDER BY f.coveragebp DESC;




--AND f.id IS NULL;


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

