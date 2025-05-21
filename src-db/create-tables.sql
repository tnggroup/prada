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
	type text NOT NULL,
    CHR integer NOT NULL,
    BP integer NOT NULL,
    W double precision,
    CONSTRAINT variant_pkey PRIMARY KEY (type,CHR,BP)
);
COMMENT ON TABLE prada.variant IS 'Custom project data on variants. To hold for example anchor information';


COMMIT;