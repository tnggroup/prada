BEGIN TRANSACTION;

-- DROP TABLE prada.chromosome;
CREATE TABLE prada.chromosome
(
    number integer NOT NULL,
    sizebp integer NOT NULL,
    CONSTRAINT chromosome_pkey PRIMARY KEY (number)
);
COMMENT ON TABLE prada.chromosome IS 'Custom project data on chromosomes.';
--CREATE UNIQUE INDEX chromosome_u ON prada.chromosome (number);


-- prada.gencode_gene
-- imported through R-script

-- prada.pgx_gene
-- imported manually from the ONT gene-list (as csv, values only from excel)


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