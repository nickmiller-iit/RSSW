.separator "|"

CREATE TABLE nodes ("tax_id" INTEGER, "parent_tax_id" INTEGER, "rank" TEXT, "EMBL" TEXT, "division" TEXT, "inh_division" INTEGER, "gencode" TEXT, "inh_gencode" INTEGER, "mt_gencode" TEXT, "inh_mt_gencode" INTEGER, "gb_hidden" INTEGER, "hidden_root" INTEGER, "comments" TEXT);

.import nodes.dmp nodes

CREATE TABLE names ("tax_id" INTEGER, "name" TEXT, "uniq_name" TEXT, "name_class" TEXT);

.import names.dmp names

DELETE FROM names WHERE name_class NOT LIKE '%scientific name%';

.separator "\t"

SELECT nodes.tax_id, nodes.rank, names.name, nodes.parent_tax_id FROM nodes LEFT JOIN names ON nodes.tax_id = names.tax_id;
