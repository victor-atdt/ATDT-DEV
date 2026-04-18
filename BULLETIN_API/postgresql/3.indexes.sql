
CREATE INDEX idx_bull_name   		ON "db_Sirel".bulletin (bull_name);
CREATE INDEX idx_bulletin_acronym  	ON "db_Sirel".bulletin (bull_acronym);
CREATE INDEX idx_resource_desc     	ON "db_Sirel".bulletin_resource (resource_desc);
CREATE INDEX idx_bulsec_order 		ON "db_Sirel".bulletin_sections (bull_id, section_order);


