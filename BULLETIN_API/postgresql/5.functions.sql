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
    , S.section_subsegment_num
		, S.bull_id
		, S.resource_id
		, P.resource_desc
		, S.section_order
		, S.section_content
    , S.section_format
		, S.section_css
		, S.section_htmltag
		, S.section_status
    FROM "db_Sirel".bulletin_sections S
    LEFT JOIN "db_Sirel".bulletin_resource P ON S.resource_id = P.resource_id
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

CREATE OR REPLACE FUNCTION "db_Sirel".FNS_BULLETINS(p_bull_id INTEGER DEFAULT NULL, p_bull_status BOOLEAN DEFAULT NULL)
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
	WHERE (p_bull_id IS NULL OR b.bull_id = p_bull_id)
    AND (p_bull_status IS NULL OR b.bull_status = p_bull_status)
    ORDER BY b.bull_id;
END;
$$;
COMMENT ON FUNCTION "db_Sirel".FNS_BULLETINS(INTEGER, BOOLEAN) IS 
'CONSULTA: Retorna la información de uno o todos los boletines registrados según estado activos = true, todos = NULL.

 PARÁMETROS:
   - p_bull_id (INTEGER, opcional): Identificador del boletín a consultar.
     Si se omite o se pasa NULL, retorna todos los boletines.
   - p_bull_status (BOOLEAN, opcional): Todos o activos o inactivos
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
   SELECT * FROM "db_Sirel".FNS_BULLETINS(null,null

   -- Obtener un boletín específico
   SELECT * FROM "db_Sirel".FNS_BULLETINS(3,true);';

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
	   OR (unaccent(lower(bs.section_content)) like '%' || unaccent(lower(keyword)) || '%')
    group by b.bull_id
		order by b.bull_id;
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
CREATE OR REPLACE FUNCTION "db_Sirel".FNI_BULLETIN_SECTIONS(
    p_data JSON
)
RETURNS TABLE (
    section_id      INTEGER,
    section_segment INTEGER,
    section_subsegment INTEGER,
    bull_id         INTEGER,
    status          TEXT,
    mensaje         TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_item          JSON;
    v_new_id        INTEGER;
    v_segment       INTEGER;
    v_subsegment    INTEGER;
    v_bull_id       INTEGER;
BEGIN
    FOR v_item IN SELECT * FROM json_array_elements(p_data)
    LOOP
        BEGIN
            v_bull_id    := (v_item->>'bull_id')::INTEGER;
            v_segment    := COALESCE((v_item->>'section_segment')::INTEGER, 1);
            v_subsegment := COALESCE((v_item->>'section_subsegment')::INTEGER, 0);

            -- Generar section_id por bull_id
            SELECT COALESCE(MAX(bs.section_id), 0) + 1
            INTO v_new_id
            FROM "db_Sirel".bulletin_sections bs
            WHERE bs.bull_id = v_bull_id;

            INSERT INTO "db_Sirel".bulletin_sections (
                 section_id
                ,section_segment
                ,section_subsegment
                ,bull_id
                ,resource_id
                ,section_order
                ,section_content
                ,section_css
                ,section_htmltag
                ,section_status
                ,updated_by
                ,updated_at
            )
            VALUES (
                 v_new_id
                ,v_segment
                ,v_subsegment
                ,v_bull_id
                ,NULLIF(v_item->>'resource_id', '')::INTEGER
                ,(v_item->>'section_order')::INTEGER
                ,v_item->>'section_content'
                ,COALESCE((v_item->>'section_css')::INTEGER, 0)
                ,COALESCE(v_item->>'section_htmltag', 'p')
                ,COALESCE((v_item->>'section_status')::BOOLEAN, TRUE)
                ,COALESCE(v_item->>'updated_by', 'SISTEMA')
                ,NOW()
            );

            -- Retornar fila exitosa
            section_id         := v_new_id;
            section_segment    := v_segment;
            section_subsegment := v_subsegment;
            bull_id            := v_bull_id;
            status             := 'OK';
            mensaje            := 'Registro insertado correctamente';
            RETURN NEXT;

        EXCEPTION
            WHEN foreign_key_violation THEN
                section_id         := NULL;
                section_segment    := v_segment;
                section_subsegment := v_subsegment;
                bull_id            := v_bull_id;
                status             := 'ERROR';
                mensaje            := 'Clave foránea inválida: bull_id o resource_id no existe.';
                RETURN NEXT;

            WHEN unique_violation THEN
                section_id         := NULL;
                section_segment    := v_segment;
                section_subsegment := v_subsegment;
                bull_id            := v_bull_id;
                status             := 'ERROR';
                mensaje            := 'Registro duplicado: ya existe la misma clave primaria.';
                RETURN NEXT;

            WHEN OTHERS THEN
                section_id         := NULL;
                section_segment    := v_segment;
                section_subsegment := v_subsegment;
                bull_id            := v_bull_id;
                status             := 'ERROR';
                mensaje            := 'Error inesperado: ' || SQLERRM;
                RETURN NEXT;
        END;
    END LOOP;

    RETURN;
END;
$$;

COMMENT ON FUNCTION "db_Sirel".FNI_BULLETIN_SECTIONS(JSON) IS
'Función batch para inserción de secciones de boletines.
Retorna una fila por cada ítem procesado indicando OK o ERROR.
Campos requeridos: bull_id, section_content, section_order.';

CREATE OR REPLACE FUNCTION "db_Sirel".FNI_BULLETIN(
  p_bull_name       CHARACTER VARYING(100),
  p_bull_acronym    CHARACTER VARYING(100),
  p_bull_desc       TEXT,
  p_bull_img_path   TEXT,
  p_bull_active_ini DATE,
  p_bull_active_end DATE,
  p_bull_status     BOOLEAN,
  p_updated_by      CHARACTER VARYING(100)
)
RETURNS "db_Sirel"."bulletin_type"
LANGUAGE plpgsql
AS $$
DECLARE
  v_result        "db_Sirel"."bulletin_type";
  v_bull_id       INTEGER;
  v_img_extension TEXT;
  v_img_path      TEXT;
BEGIN
  INSERT INTO "db_Sirel".bulletin (
    bull_name, bull_acronym, bull_desc, bull_img_path,
    bull_active_ini, bull_active_end, bull_status, updated_by
  )
  VALUES (
    p_bull_name, p_bull_acronym, p_bull_desc, p_bull_img_path,
    p_bull_active_ini, p_bull_active_end, COALESCE(p_bull_status, TRUE), p_updated_by
  )
  RETURNING bull_id INTO v_bull_id;

	IF p_bull_img_path IS NOT NULL THEN	
		v_img_extension := (regexp_matches(p_bull_img_path, '\.([^.]+)$'))[1];
		v_img_path      := substring(p_bull_img_path FROM '^(.*/)');
		
		UPDATE "db_Sirel".bulletin
		SET bull_img_path = v_img_path || 'Logo' || v_bull_id || '.' || v_img_extension
		WHERE bull_id = v_bull_id;
		
	END IF;
	
	SELECT bull_id, bull_name, bull_acronym, bull_desc, bull_img_path,
	bull_active_ini, bull_active_end, bull_status, updated_by, updated_at
	INTO v_result
	FROM "db_Sirel".bulletin
	WHERE bull_id = v_bull_id;

  RETURN v_result;
END;
$$;
COMMENT ON FUNCTION "db_Sirel".FNI_BULLETIN(
  CHARACTER VARYING(100),
  CHARACTER VARYING(100),
  TEXT,
  TEXT,
  DATE,
  DATE,
  BOOLEAN,
  CHARACTER VARYING(100)
) IS
'FUNCIÓN: FNI_BULLETIN
ESQUEMA: db_Sirel
TIPO: Inserción
RETORNA: bulletin_type

DESCRIPCIÓN:
  Inserta un nuevo registro en la tabla bulletin y retorna el registro completo
  recién creado como tipo compuesto bulletin_type. Si se proporciona una ruta
  de imagen, estandariza el nombre del archivo usando el formato:
  <ruta_original>Logo<bull_id>.<extensión>

PARÁMETROS:
  p_bull_name       VARCHAR(100) - Nombre del boletín (requerido)
  p_bull_acronym    VARCHAR(100) - Acrónimo identificador del boletín (requerido)
  p_bull_desc       TEXT         - Descripción detallada del boletín
  p_bull_img_path   TEXT         - Ruta de la imagen del boletín (opcional)
  p_bull_active_ini DATE         - Fecha de inicio de vigencia del boletín
  p_bull_active_end DATE         - Fecha de fin de vigencia del boletín
  p_bull_status     BOOLEAN      - Estado activo/inactivo (default: TRUE si es NULL)
  p_updated_by      VARCHAR(100) - Usuario que realiza la inserción

RETORNO:
  Registro completo de tipo bulletin_type con los campos:
    - bull_id         : ID generado automáticamente
    - bull_name       : Nombre del boletín
    - bull_acronym    : Acrónimo del boletín
    - bull_desc       : Descripción
    - bull_img_path   : Ruta final de la imagen (renombrada si aplica)
    - bull_active_ini : Fecha inicio de vigencia
    - bull_active_end : Fecha fin de vigencia
    - bull_status     : Estado del boletín
    - updated_by      : Usuario que realizó la operación
    - updated_at      : Fecha y hora de la operación

LÓGICA INTERNA:
  1. Inserta el registro en la tabla bulletin obteniendo el bull_id generado.
  2. Si p_bull_img_path no es NULL, extrae la extensión y la ruta base
     del archivo y actualiza bull_img_path con el formato estandarizado:
     <ruta_base>Logo<bull_id>.<extensión>
  3. Retorna el registro completo desde la tabla.

EJEMPLO DE USO:
  SELECT * FROM "db_Sirel".FNI_BULLETIN(
    ''Boletín Mensual'',
    ''BLT-MEN'',
    ''Boletín informativo mensual de la organización'',
    ''/img/boletines/imagen.png'',
    ''2024-01-01''::DATE,
    ''2024-12-31''::DATE,
    TRUE,
    ''admin''
  );

NOTAS:
  - Si p_bull_status es NULL, se asigna TRUE por defecto (COALESCE).
  - La ruta de imagen resultante seguirá el formato: /img/boletines/Logo1.png
  - El campo updated_at es gestionado automáticamente por la tabla.

AUTOR:        [nombre del autor]
FECHA:        [fecha de creación]
VERSIÓN:      1.0
MODIFICACIONES:
  [YYYY-MM-DD] [autor] - [descripción del cambio]';


ALTER FUNCTION "db_Sirel".FNS_BULLETINS(p_bull_id INTEGER)
    OWNER TO postgres;
ALTER FUNCTION "db_Sirel".FNI_BULLETIN( CHARACTER VARYING(100),
                                        CHARACTER VARYING(100),
                                        TEXT,
                                        TEXT,
                                        DATE,
                                        DATE,
                                        BOOLEAN,
                                        CHARACTER VARYING(100)
                                      ) 
    OWNER TO postgres;
ALTER FUNCTION "db_Sirel".FNI_BULLETIN_RESOURCES(p_data JSONB)
    OWNER TO postgres;
ALTER FUNCTION "db_Sirel".FNI_BULLETIN_SECTIONS(p_data JSON)
    OWNER TO postgres;
ALTER FUNCTION "db_Sirel".FNS_BULL_SECTIONS(p_bull_id INTEGER)
OWNER TO postgres;
ALTER FUNCTION "db_Sirel".FNS_BULLETINES_BYWORD(keyword character varying)
    OWNER TO postgres;
ALTER FUNCTION "db_Sirel".fnu_bulletin(integer, character varying, character varying, text, text, date, date, boolean, character varying)
    OWNER TO postgres;

