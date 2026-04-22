
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
	  bull_id INTEGER,
    resource_id INTEGER,
	  path_desc TEXT,
    section_order INTEGER,
    section_content TEXT,
    section_css INTEGER,
    section_htmltag CHAR VARYING(10),
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
   - bull_id            (INTEGER)       : Identificador del boletín al que pertenece la sección. Referencia a bulletin.bull_id.
   - resource_id        (INTEGER)       : Identificador del recurso asociado a la sección. Puede ser NULL si no tiene recurso.
   - path_desc          (TEXT)          : Descripción o ruta del recurso obtenida desde bulletin_path mediante JOIN.
   - section_order      (INTEGER)       : Orden de presentación de la sección dentro del boletín.
   - section_content    (TEXT)          : Contenido principal de la sección (texto, HTML u referencia a recurso).
   - section_css        (INTEGER)       : Identificador del estilo CSS aplicado a la sección.
   - section_htmltag    (VARCHAR(10))   : Etiqueta HTML usada para renderizar la sección. Ej: "div", "p", "h1".
   - section_status     (BOOLEAN)       : Estado activo/inactivo de la sección. TRUE = activa, FALSE = inactiva.

 USADO EN:
   - FUNCTION "db_Sirel".FNS_BULL_SECTIONS(p_bull_id INTEGER)

 NOTA:
   Cualquier modificación en este tipo requiere revisar y actualizar
   la función FNS_BULL_SECTIONS para mantener la compatibilidad.';
