-- =============================================
-- TABLA: bulletin, almacena los datos de los boletines
-- =============================================
CREATE TABLE IF NOT EXISTS "db_Sirel"."bulletin"(
	 bull_id integer NOT NULL 
	,bull_name character varying(100) NOT NULL
	,bull_acronym character varying(100) NOT NULL
	,bull_desc TEXT NOT NULL
	,bull_img_path TEXT NOT NULL
    ,bull_active_ini DATE
    ,bull_active_end DATE
	,bull_status boolean DEFAULT true NOT NULL
	,updated_by character varying(100) DEFAULT 'SISTEMA'::character varying
	,updated_at timestamp without time zone DEFAULT now()
	,CONSTRAINT pk_bulletin          PRIMARY KEY (bull_id)
    ,CONSTRAINT uq_bulletin_acronym  UNIQUE      (bull_acronym)
);
-- Comentario sobre la tabla
COMMENT ON TABLE "db_Sirel"."bulletin" IS 
'Catálogo de boletines del sistema SIREL. Almacena la información principal de cada boletín, incluyendo su vigencia, estado y datos.';
-- Comentarios sobre cada columna
COMMENT ON COLUMN "db_Sirel"."bulletin".bull_id IS 
'Identificador único del boletín. Clave primaria, se asigna mediante secuencia.';
COMMENT ON COLUMN "db_Sirel"."bulletin".bull_name IS 
'Nombre completo del boletín. Máximo 100 caracteres. Ej: "Boletín Mensual de Seguridad Informática".';
COMMENT ON COLUMN "db_Sirel"."bulletin".bull_acronym IS 
'Acrónimo o código corto único que identifica al boletín. Máximo 100 caracteres. Ej: "BMSV-2024". Tiene restricción UNIQUE.';
COMMENT ON COLUMN "db_Sirel"."bulletin".bull_desc IS 
'Descripción detallada del boletín, su propósito y contenido general.';
COMMENT ON COLUMN "db_Sirel"."bulletin".bull_img_path IS 
'Ruta o URL de la imagen representativa del boletín. Puede ser una ruta relativa del servidor o una URL absoluta.';
COMMENT ON COLUMN "db_Sirel"."bulletin".bull_active_ini IS 
'Fecha de inicio de vigencia del boletín. Si es NULL, el boletín no tiene fecha de inicio definida.';
COMMENT ON COLUMN "db_Sirel"."bulletin".bull_active_end IS 
'Fecha de fin de vigencia del boletín. Si es NULL, el boletín se considera sin fecha de expiración.';
COMMENT ON COLUMN "db_Sirel"."bulletin".bull_status IS 
'Estado activo/inactivo del boletín. TRUE = activo, FALSE = inactivo. Valor por defecto: TRUE.';
COMMENT ON COLUMN "db_Sirel"."bulletin".updated_by IS 
'Usuario que realizó la última modificación del registro. Por defecto se asigna "SISTEMA" para registros creados automáticamente.';
COMMENT ON COLUMN "db_Sirel"."bulletin".updated_at IS 
'Fecha y hora de la última modificación del registro. Se asigna automáticamente con now() al insertar. Debe actualizarse manualmente en cada UPDATE.';

-- =============================================
-- TABLA: bulletin_resource
-- =============================================
CREATE TABLE IF NOT EXISTS "db_Sirel".bulletin_resource
(
	 resource_id integer NOT NULL
	,resource_desc TEXT NOT NULL
    ,CONSTRAINT pk_bulletin_resource PRIMARY KEY (resource_id)
);
COMMENT ON TABLE "db_Sirel"."bulletin_resource" IS 
'Catálogo de tipos de recursos disponibles para las secciones de los boletines. Define los recursos que pueden asociarse al contenido (imágenes, links, etc.).';
COMMENT ON COLUMN "db_Sirel"."bulletin_resource".resource_id IS 
'Identificador único del tipo de recurso. Clave primaria, asignado mediante secuencia.';
COMMENT ON COLUMN "db_Sirel"."bulletin_resource".resource_desc IS 
'Descripción del recurso. Ej: "Rutas", "Links"';

-- =============================================
-- TABLA: bulletin_sections
-- =============================================
CREATE TABLE IF NOT EXISTS "db_Sirel".bulletin_sections 
(	
	 section_id INTEGER NOT NULL
	,section_segment INTEGER NOT NULL
	,section_subsegment INTEGER NOT NULL
	,section_subsegment_num INTEGER NOT NULL
	,bull_id INTEGER NOT NULL
	,resource_id INTEGER NULL
	,section_order INTEGER NOT NULL
    ,section_content TEXT NOT NULL
	,section_format TEXT NOT NULL
	,section_css INTEGER NOT NULL
	,section_htmltag character varying(10)
    ,section_status boolean DEFAULT true NOT NULL
	,updated_by character varying(100) DEFAULT 'SISTEMA'::character varying
    ,updated_at timestamp without time zone DEFAULT now()
    ,CONSTRAINT pk_bulletin_sections
        PRIMARY KEY (section_id,section_segment, section_subsegment,bull_id)
		
    ,CONSTRAINT fk_buldoc_bulletin_sections
        FOREIGN KEY (bull_id)
        REFERENCES  "db_Sirel".bulletin (bull_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
	
    ,CONSTRAINT fk_buldoc_resource
        FOREIGN KEY (resource_id)
        REFERENCES  "db_Sirel".bulletin_resource (resource_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
COMMENT ON TABLE "db_Sirel"."bulletin_sections" IS 
'Almacena las secciones que conforman cada boletín. Cada sección representa un bloque de contenido organizado jerárquicamente por segmento y subsegmento dentro del boletín.';
COMMENT ON COLUMN "db_Sirel"."bulletin_sections".section_id IS 
'Identificador de la sección. Parte de la clave primaria compuesta junto con section_segment, section_subsegment y bull_id.';
COMMENT ON COLUMN "db_Sirel"."bulletin_sections".section_segment IS 
'Número de segmento principal al que pertenece la sección. Permite agrupar secciones en bloques mayores dentro del boletín. Parte de la clave primaria compuesta.';
COMMENT ON COLUMN "db_Sirel"."bulletin_sections".section_subsegment IS 
'Número de subsegmento dentro del segmento. Permite una organización jerárquica de segundo nivel. Parte de la clave primaria compuesta.';
COMMENT ON COLUMN "db_Sirel"."bulletin_sections".section_subsegment_num IS
'Número de divisiones o columnas visibles al usuario, dentro de un segmento';
COMMENT ON COLUMN "db_Sirel"."bulletin_sections".bull_id IS 
'Identificador del boletín al que pertenece la sección. Clave foránea hacia bulletin.bull_id. Si el boletín es eliminado, sus secciones se eliminan en cascada.';
COMMENT ON COLUMN "db_Sirel"."bulletin_sections".resource_id IS 
'Identificador del tipo de recurso asociado a la sección. Clave foránea hacia bulletin_resource.resource_id. Nullable: si el recurso es eliminado, este campo se establece en NULL.';
COMMENT ON COLUMN "db_Sirel"."bulletin_sections".section_order IS 
'Orden de presentación de la sección dentro del boletín. Determina la secuencia visual en que se muestran las secciones al renderizar el boletín.';
COMMENT ON COLUMN "db_Sirel"."bulletin_sections".section_content IS 
'Contenido principal de la sección. Puede contener texto plano, HTML o referencia a un recurso según el tipo de sección definido.';
COMMENT ON COLUMN "db_Sirel"."bulletin_sections".section_format IS 
'Contenido principal de la sección. Con identificadores para interpretarse en html.';
COMMENT ON COLUMN "db_Sirel"."bulletin_sections".section_css IS 
'Identificador o código de estilos CSS aplicados a la sección. Permite personalizar la apariencia visual de cada bloque de contenido.';
COMMENT ON COLUMN "db_Sirel"."bulletin_sections".section_htmltag IS 
'Etiqueta HTML utilizada para renderizar la sección. Máximo 10 caracteres. Ej: "div", "p", "h1", "section", "article".';
COMMENT ON COLUMN "db_Sirel"."bulletin_sections".section_status IS 
'Estado activo/inactivo de la sección. TRUE = activa y visible, FALSE = inactiva u oculta. Valor por defecto: TRUE.';
COMMENT ON COLUMN "db_Sirel"."bulletin_sections".updated_by IS 
'Usuario que realizó la última modificación del registro. Por defecto se asigna "SISTEMA" para registros creados automáticamente.';
COMMENT ON COLUMN "db_Sirel"."bulletin_sections".updated_at IS 
'Fecha y hora de la última modificación del registro. Se asigna automáticamente con now() al insertar. Debe actualizarse manualmente en cada UPDATE.';

ALTER TABLE "db_Sirel".bulletin OWNER TO postgres;
ALTER TABLE "db_Sirel".bulletin_resource OWNER TO postgres;
ALTER TABLE "db_Sirel".bulletin_sections OWNER TO postgres;
