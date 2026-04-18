
--
-- Name: bulletin; Type: SEQUENCE; Schema: db_Sirel; Owner: postgres
--
ALTER TABLE "db_Sirel".bulletin ALTER COLUMN bull_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "db_Sirel".bull_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
--
-- Name: bulletin_resource; Type: SEQUENCE; Schema: db_Sirel; Owner: postgres
--
ALTER TABLE "db_Sirel".bulletin_resource ALTER COLUMN resource_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "db_Sirel".resource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
--
-- Name: bulletin_sections; Type: SEQUENCE; Schema: db_Sirel; Owner: postgres
--
ALTER TABLE "db_Sirel".bulletin_sections ALTER COLUMN section_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "db_Sirel".bull_section_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);