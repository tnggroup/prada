BEGIN TRANSACTION;

-- DROP TABLE prada.chromosome;
CREATE TABLE prada.chromosome
(
    number integer NOT NULL,
    name text,
    sizebp integer NOT NULL,
    CONSTRAINT chromosome_pkey PRIMARY KEY (number)
);
COMMENT ON TABLE prada.chromosome IS 'Custom project data on chromosomes.';
CREATE UNIQUE INDEX chromosome_name_u ON prada.chromosome (name);


-- prada.gencode_gene
-- imported through R-script
CREATE INDEX gencode_gene_i ON prada.gencode_gene (chr,bp1,bp2,gene_name,gene_id);

-- prada.pgx_gene
-- imported manually from the ONT gene-list (as csv, values only from excel)
CREATE INDEX pgx_gene_i ON prada.pgx_gene ("Gene"); --Let's keep this non-unique for the future


-- DROP TABLE prada.variant;
CREATE TABLE prada.variant
(
	type smallint NOT NULL, --1: GWAS, 2: CNV
	snp text NOT NULL,
    chr smallint NOT NULL,
    bp integer NOT NULL,
    bp2 integer,
    mdd_p numeric,
    mdd_beta numeric,
    mdd_beta_se numeric,
    mdd_beta_n numeric,
    CONSTRAINT variant_pkey PRIMARY KEY (type,snp)
);
COMMENT ON TABLE prada.variant IS 'Custom project data on variants. To hold for example anchor information';
CREATE INDEX variant_i ON prada.variant (type,snp,chr,bp,bp2);
CREATE INDEX variant_i2 ON prada.variant (mdd_p,mdd_beta,mdd_beta_n,mdd_beta_se);

-- DROP TABLE prada.drug;
CREATE TABLE prada.drug
(
	rxnormid varchar(20), --should match the cpic rxnormid
	name varchar(100), --in case we don't have the id
    type text DEFAULT 'generic',
    weight double precision DEFAULT 1.0
    --CONSTRAINT drug_pkey PRIMARY KEY (rxnormid,name)
);
COMMENT ON TABLE prada.drug IS 'Custom project data on drugs. To prioritise drugs to include in the analyses.';
CREATE UNIQUE INDEX drug_u ON prada.drug (rxnormid,name);


COMMIT;