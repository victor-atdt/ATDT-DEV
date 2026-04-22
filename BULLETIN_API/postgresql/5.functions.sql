-- ── Función reutilizable para auto-actualizar updated_at ──
CREATE OR REPLACE FUNCTION "db_Sirel".set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- FUNCIÓN: FNS_BULL_SECTIONS
-- =============================================
CREATE OR REPLACE FUNCTION "db_Sirel".FNS_BULL_SECTIONS(p_bull_id INTEGER)
RETURNS SETOF "db_Sirel".section_result_type 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT S.section_id
		, S.section_segment
		, S.section_subsegment
		, S.bull_id
		, S.resource_id
		, P.path_desc
		, S.section_order
		, S.section_content
		, S.section_css
		, S.section_htmltag
		, S.section_status
    FROM "db_Sirel".bulletin_sections S
    LEFT JOIN "db_Sirel".bulletin_path P ON S.resource_id = P.resource_id
    WHERE S.bull_id = p_bull_id;
END;
$$;
COMMENT ON FUNCTION "db_Sirel".FNS_BULL_SECTIONS(INTEGER) IS 
'CONSULTA: Retorna todas las secciones asociadas a un boletín específico.

 PARÁMETROS:
   - p_bull_id (INTEGER): Identificador del boletín a consultar.

 RETORNA:
   SETOF section_result_type con los campos:
   - section_id, section_segment, section_subsegment: Identificadores jerárquicos de la sección.
   - bull_id: Identificador del boletín al que pertenece.
   - resource_id: Identificador del recurso asociado (puede ser NULL).
   - path_desc: Descripción o ruta del recurso obtenida desde bulletin_path (LEFT JOIN).
   - section_order: Orden de presentación de la sección.
   - section_content: Contenido de la sección.
   - section_css: Identificador de estilos aplicados.
   - section_htmltag: Etiqueta HTML usada para renderizar la sección.
   - section_status: Estado activo/inactivo de la sección.

 TABLAS QUE CONSULTA:
   - bulletin_sections: Fuente principal de las secciones.
   - bulletin_path: JOIN opcional para obtener la descripción del recurso.

 EJEMPLO DE USO:
   SELECT * FROM "db_Sirel".FNS_BULL_SECTIONS(1);';

CREATE OR REPLACE FUNCTION "db_Sirel".FNS_BULLETINS(p_bull_id INTEGER DEFAULT NULL)
RETURNS TABLE (
    bull_id integer,
    bull_name character varying(100),
    bull_acronym character varying(100),
    bull_desc TEXT,
    bull_img_path TEXT,
    bull_active_ini DATE,
    bull_active_end DATE,
    bull_status boolean,
    updated_by character varying(100),
    updated_at timestamp without time zone
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        b.bull_id, 
        b.bull_name, 
        b.bull_acronym, 
        b.bull_desc, 
        b.bull_img_path, 
        b.bull_active_ini, 
        b.bull_active_end, 
        b.bull_status, 
        b.updated_by, 
        b.updated_at
    FROM "db_Sirel"."bulletin" b
	WHERE (p_bull_id IS NULL OR b.bull_id = p_bull_id);
END;
$$;
COMMENT ON FUNCTION "db_Sirel".FNS_BULLETINS(INTEGER) IS 
'CONSULTA: Retorna la información de uno o todos los boletines registrados.

 PARÁMETROS:
   - p_bull_id (INTEGER, opcional): Identificador del boletín a consultar.
     Si se omite o se pasa NULL, retorna todos los boletines.

 RETORNA:
   TABLE con los campos de la tabla bulletin:
   - bull_id: Identificador único del boletín.
   - bull_name: Nombre completo del boletín.
   - bull_acronym: Acrónimo único del boletín.
   - bull_desc: Descripción del boletín.
   - bull_img_path: Ruta o URL de la imagen del boletín.
   - bull_active_ini / bull_active_end: Rango de fechas de vigencia.
   - bull_status: Estado activo/inactivo del boletín.
   - updated_by / updated_at: Datos de auditoría de última modificación.

 TABLAS QUE CONSULTA:
   - bulletin: Fuente principal de los boletines.

 EJEMPLOS DE USO:
   -- Obtener todos los boletines
   SELECT * FROM "db_Sirel".FNS_BULLETINS();

   -- Obtener un boletín específico
   SELECT * FROM "db_Sirel".FNS_BULLETINS(3);';

-- =============================================
-- FUNCIÓN: FNI_BULLETIN_RESOURCES
-- =============================================

CREATE OR REPLACE FUNCTION "db_Sirel".FNI_BULLETIN_RESOURCES(p_data JSONB)
RETURNS TABLE(resource_id INTEGER) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    INSERT INTO "db_Sirel".bulletin_resource (
       resource_desc
    )
    SELECT 
        resource_desc
    FROM jsonb_to_recordset(p_data) AS x(
        resource_desc TEXT
    )
    RETURNING "db_Sirel".bulletin_resource.resource_id;
END;
$$;
COMMENT ON FUNCTION "db_Sirel".FNI_BULLETIN_RESOURCES(JSONB) IS 
'INSERCIÓN: Inserta uno o múltiples recursos en la tabla bulletin_resource
 a partir de un arreglo JSON, retornando los IDs generados.

 PARÁMETROS:
   - p_data (JSONB): Arreglo JSON con los recursos a insertar.
     Estructura esperada:
     [
       { "resource_desc": "Imagen principal" },
       { "resource_desc": "Algún path" }
     ]

 RETORNA:
   TABLE con:
   - resource_id (INTEGER): ID generado por cada recurso insertado.

 TABLAS QUE MODIFICA:
   - bulletin_resource: Inserta los nuevos registros de recursos.

 NOTAS:
   - Permite inserción masiva mediante un solo llamado.
   - Utiliza jsonb_to_recordset para descomponer el JSON en filas.
   - Retorna los IDs mediante RETURNING para uso inmediato en el cliente.

 EJEMPLO DE USO:
   SELECT * FROM "db_Sirel".FNI_BULLETIN_RESOURCES(
     ''[{"resource_desc": "Imagen principal"}, {"resource_desc": "Archivo PDF"}]''::JSONB
   );';

-- =============================================
-- FUNCIÓN: FNS_BULLETINES_BYWORD
-- =============================================
CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE OR REPLACE FUNCTION "db_Sirel".FNS_BULLETINES_BYWORD(keyword character varying)
RETURNS TABLE (
    bull_id integer,
    bull_name character varying(100),
    bull_acronym character varying(100),
    bull_desc TEXT,
    bull_img_path TEXT,
    bull_active_ini DATE,
    bull_active_end DATE,
    bull_status boolean,
    updated_by character varying(100),
    updated_at timestamp without time zone
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY 
     SELECT b.bull_id, 
			b.bull_name, 
			b.bull_acronym, 
			b.bull_desc, 
			b.bull_img_path, 
			b.bull_active_ini, 
			b.bull_active_end, 
			b.bull_status, 
			b.updated_by, 
			b.updated_at
	 FROM "db_Sirel".bulletin b
LEFT JOIN "db_Sirel".bulletin_sections bs on b.bull_id = bs.bull_id
	WHERE (unaccent(lower(b.bull_desc)) like '%' || unaccent(lower(keyword)) || '%')
	   OR (unaccent(lower(b.bull_name)) like '%' || unaccent(lower(keyword)) || '%')
	   OR (unaccent(lower(bs.section_content)) like '%' || unaccent(lower(keyword)) || '%');
END;
$$;
COMMENT ON FUNCTION "db_Sirel".FNS_BULLETINES_BYWORD(character varying) IS 
'CONSULTA: Retorna la información de uno o todos los boletines registrados que contengan una palabra específica.

 PARÁMETROS:
   - p_bull_desc (character varyingcharacter varying): palabra o frase en el boletín a consultar.

 RETORNA:
   TABLE con los campos de la tabla bulletin:
   - bull_id: Identificador único del boletín.
   - bull_name: Nombre completo del boletín.
   - bull_acronym: Acrónimo único del boletín.
   - bull_desc: Descripción del boletín.
   - bull_img_path: Ruta o URL de la imagen del boletín.
   - bull_active_ini / bull_active_end: Rango de fechas de vigencia.
   - bull_status: Estado activo/inactivo del boletín.
   - updated_by / updated_at: Datos de auditoría de última modificación.

 TABLAS QUE CONSULTA:
   - bulletin: Fuente principal de los boletines.
   - bulletin_sections: almacena el documento asociado al boletín
 EJEMPLOS DE USO:
   -- Obtener todos los boletines
   SELECT * FROM "db_Sirel".FNS_BULLETINES_BYWORD(''descr'')';


CREATE OR REPLACE FUNCTION "db_Sirel".fnu_bulletin(
	p_bull_id integer,
	p_bull_name character varying DEFAULT (NULL::boolean),
	p_bull_acronym character varying DEFAULT ( NULL::boolean),
	p_bull_desc text DEFAULT (NULL::boolean),
	p_bull_img_path text DEFAULT (NULL::boolean),
	p_bull_active_ini date DEFAULT NULL::date,
	p_bull_active_end date DEFAULT NULL::date,
	p_bull_status boolean DEFAULT (NOT NULL::boolean),
	p_updated_by character varying DEFAULT 'SISTEMA'::character varying)
    RETURNS TABLE(id_actualizado integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    UPDATE "db_Sirel"."bulletin"
    SET 
        bull_name        = COALESCE(p_bull_name,       bull_name),
        bull_acronym     = COALESCE(p_bull_acronym,    bull_acronym),
        bull_desc        = COALESCE(p_bull_desc,       bull_desc),
        bull_img_path    = COALESCE(p_bull_img_path,   bull_img_path),
        bull_active_ini  = COALESCE(p_bull_active_ini, bull_active_ini),
        bull_active_end  = COALESCE(p_bull_active_end, bull_active_end),
        bull_status      = p_bull_status,
        updated_by       = p_updated_by,
        updated_at       = NOW()
    WHERE bull_id = p_bull_id;

    RETURN QUERY SELECT p_bull_id;
END;
$BODY$;


ALTER FUNCTION "db_Sirel".FNS_BULLETINS(p_bull_id INTEGER)
    OWNER TO postgres;
ALTER FUNCTION "db_Sirel".FNI_BULLETIN_RESOURCES(p_data JSONB)
    OWNER TO postgres;
ALTER FUNCTION "db_Sirel".FNS_BULLETINS(p_bull_id INTEGER)
    OWNER TO postgres;
ALTER FUNCTION "db_Sirel".FNS_BULLETINES_BYWORD(keyword character varying)
    OWNER TO postgres;
ALTER FUNCTION "db_Sirel".fnu_bulletin(integer, character varying, character varying, text, text, date, date, boolean, character varying)
    OWNER TO postgres;
