BEGIN TRANSACTION;

-- DROP TABLE prada.chromosome;
CREATE TABLE prada.chromosome
(
    number integer NOT NULL,
    sizebp integer NOT NULL,
    CONSTRAINT reference_pkey PRIMARY KEY (number)
);
COMMENT ON TABLE prada.chromosome IS 'Custom project data on chromosomes.';
--CREATE UNIQUE INDEX chromosome_u ON prada.chromosome (number);


COMMIT;