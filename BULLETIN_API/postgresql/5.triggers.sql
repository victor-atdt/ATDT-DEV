
--=======================TRIGGERS=========================
-- Trigger updated_at
CREATE TRIGGER trg_bulletin_updated_at
BEFORE UPDATE ON "db_Sirel".bulletin
FOR EACH ROW EXECUTE FUNCTION "db_Sirel".set_updated_at();

CREATE TRIGGER trg_bulletin_updated_at
BEFORE UPDATE ON "db_Sirel".bulletin_sections
FOR EACH ROW EXECUTE FUNCTION "db_Sirel".set_updated_at();
