

-- =============================================
-- TYPE: section_result_type
-- =============================================
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'section_result_type') THEN
    CREATE TYPE "db_Sirel".section_result_type AS (
    section_id INTEGER,
    section_segment INTEGER,
    section_subsegment INTEGER,
    section_subsegment_num INTEGER,
	bull_id INTEGER,
    resource_id INTEGER,
    resource_desc TEXT, 
    section_order INTEGER,
    section_content TEXT,
    section_format TEXT,
    section_css CHARACTER VARYING(50),
    section_htmltag CHARACTER VARYING(10),
    section_status BOOLEAN
	);

    END IF;
END $$;
COMMENT ON TYPE "db_Sirel".section_result_type IS 
'Tipo de dato compuesto utilizado como estructura de retorno de la función FNS_BULL_SECTIONS.
 Define los campos que conforman una sección de boletín enriquecida con información del recurso asociado.

 CAMPOS:
   - section_id         (INTEGER)       : Identificador de la sección.
   - section_segment    (INTEGER)       : Segmento principal al que pertenece la sección.
   - section_subsegment (INTEGER)       : Subsegmento dentro del segmento, para organización jerárquica de segundo nivel.
   - section_subsegment_num (INTEGER)   : Subsegmento dentro del segmento, para organización jerárquica de segundo nivel.
   - bull_id            (INTEGER)       : Identificador del boletín al que pertenece la sección. Referencia a bulletin.bull_id.
   - resource_id        (INTEGER)       : Identificador del recurso asociado a la sección. Puede ser NULL si no tiene recurso.
   - path_desc          (TEXT)          : Descripción o ruta del recurso obtenida desde bulletin_path mediante JOIN.
   - section_order      (INTEGER)       : Orden de presentación de la sección dentro del boletín.
   - section_content    (TEXT)          : Contenido principal de la sección (texto, HTML u referencia a recurso).
   - section_format     (TEXT)          : Contenido principal de la sección (texto, HTML u referencia a recurso).
   - section_css        (VARCHAR(50))   : Identificador del estilo CSS aplicado a la sección.
   - section_htmltag    (VARCHAR(10))   : Etiqueta HTML usada para renderizar la sección. Ej: "div", "p", "h1".
   - section_status     (BOOLEAN)       : Estado activo/inactivo de la sección. TRUE = activa, FALSE = inactiva.

 USADO EN:
   - FUNCTION "db_Sirel".FNS_BULL_SECTIONS(p_bull_id INTEGER)

 NOTA:
   Cualquier modificación en este tipo requiere revisar y actualizar
   la función FNS_BULL_SECTIONS para mantener la compatibilidad.';

   CREATE TYPE "db_Sirel"."bulletin_type" AS (
     bull_id          INTEGER
    ,bull_name        CHARACTER VARYING(100)
    ,bull_acronym     CHARACTER VARYING(100)
    ,bull_desc        TEXT
    ,bull_img_path    TEXT
    ,bull_active_ini  DATE
    ,bull_active_end  DATE
    ,bull_status      BOOLEAN
    ,updated_by       CHARACTER VARYING(100)
    ,updated_at       TIMESTAMP WITHOUT TIME ZONE
);
COMMENT ON TYPE "db_Sirel"."bulletin_type" IS 
'Tipo compuesto que representa la estructura de un boletín en el sistema SIREL.
CAMPOS:
  -bull_id         INTEGER   Identificador único del boletín.
  -bull_name       VARCHAR   Nombre completo del boletín (máximo 100 caracteres)
  -bull_acronym    VARCHAR   Acrónimo o abreviatura única del boletín (máximo 100 caracteres)
  -bull_desc       TEXT      Descripción detallada del contenido o propósito del boletín
  -bull_img_path   TEXT      Ruta o URL de la imagen asociada al boletín
  -bull_active_ini DATE      Fecha de inicio del período de vigencia del boletín
  -bull_active_end DATE      Fecha de fin del período de vigencia del boletín
  -bull_status     BOOLEAN   Estado del boletín: TRUE = activo, FALSE = inactivo
  -updated_by      VARCHAR   Usuario que realizó la última actualización del registro
  -updated_at      TIMESTAMP Fecha y hora de la última actualización del registro.';
-- =============================================
-- TYPE: SECTION_RESOURCE_TYPE
-- =============================================
DO $$ 
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type t
							JOIN pg_namespace n ON n.oid = t.typnamespace 
							WHERE n.nspname = 'db_Sirel' AND t.typname = 'section_resource_type'
				  ) THEN
		CREATE TYPE "db_Sirel".section_resource_type AS(
			resource_id INTEGER,
			resource_desc TEXT
		);
	ELSE
		RAISE NOTICE 'section_resource_type ya fue creado...';
	END IF;
END $$;
COMMENT ON TYPE "db_Sirel".section_resource_type IS 
'Tipo de dato compuesto utilizado como estructura de retorno de la función FNU_BULLETIN_RESOURCES.
 Define los campos que conforman un recurso (imagen o hyperlink) asociado a una sección.
 CAMPOS:
   - resource_id      (INTEGER)    : Identificador del recurso.
   - resource_desc    (TEXT)       : Segmento principal al que pertenece la sección.'

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'section_input_type') THEN
-- =============================================
-- TYPE: section_result_type
-- =============================================
        CREATE TYPE "db_Sirel".section_input_type AS
		(	
			 section_id INTEGER 
			,section_segment INTEGER 
			,section_subsegment INTEGER 
			,section_subsegment_num INTEGER 
			,bull_id INTEGER
			,resource_id INTEGER 
			,section_order INTEGER
		  ,section_content TEXT
			,section_format TEXT
			,section_css CHARACTER VARYING(50)
			,section_htmltag CHARACTER VARYING(10)
		  ,section_status boolean
			,updated_by character varying(100)
		);
    END IF;
END
$$;
COMMENT ON TYPE "db_Sirel".section_input_type IS 
'Tipo de dato compuesto utilizado como estructura de retorno de la función FNU_BULLETIN_SECTIONS.
 Define los campos que conforman una sección de boletín enriquecida con información del recurso asociado.

 CAMPOS:
   - section_id         (INTEGER)       : Identificador de la sección.
   - section_segment    (INTEGER)       : Segmento principal al que pertenece la sección.
   - section_subsegment (INTEGER)       : Subsegmento dentro del segmento, para organización jerárquica de segundo nivel.
   - section_subsegment_num (INTEGER)   : Subsegmento dentro del segmento, para organización jerárquica de segundo nivel.
   - bull_id            (INTEGER)       : Identificador del boletín al que pertenece la sección. Referencia a bulletin.bull_id.
   - resource_id        (INTEGER)       : Identificador del recurso asociado a la sección. Puede ser NULL si no tiene recurso.
   - section_order      (INTEGER)       : Orden de presentación de la sección dentro del boletín.
   - section_content    (TEXT)          : Contenido principal de la sección (texto, HTML u referencia a recurso).
   - section_format     (TEXT)          : Contenido principal de la sección (texto, HTML u referencia a recurso).
   - section_css        (VARCHAR(50))   : Identificador del estilo CSS aplicado a la sección.
   - section_htmltag    (VARCHAR(10))   : Etiqueta HTML usada para renderizar la sección. Ej: "div", "p", "h1".
   - section_status     (BOOLEAN)       : Estado activo/inactivo de la sección. TRUE = activa, FALSE = inactiva.

 USADO EN:
   - FUNCTION "db_Sirel".FNU_BULLETIN_SECTIONS(p_bull_id "db_Sirel".section_input_type)

 NOTA:
   Cualquier modificación en este tipo requiere revisar y actualizar
   la función FNU_BULLETIN_SECTIONS para mantener la compatibilidad.';
