--genes from gencode not on cpic 
SELECT g.* FROM prada.gencode_gene g LEFT JOIN cpic.gene c ON g.gene_id  = c.genesequenceid WHERE c.genesequenceid  IS NULL;
SELECT COUNT(g.gene_id) FROM prada.gencode_gene g LEFT JOIN cpic.gene c ON g.gene_id  = c.genesequenceid WHERE c.genesequenceid  IS NULL;

  --ruling out undocumented genes 
  SELECT g.* FROM prada.gencode_gene g LEFT JOIN cpic.gene c ON g.gene_id  = c.genesequenceid WHERE c.genesequenceid  IS null and g.gene_id NOT LIKE 'ENSG%';
  -- null