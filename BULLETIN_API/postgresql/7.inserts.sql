
INSERT INTO "db_Sirel".bulletin(bull_name, bull_acronym, bull_desc, bull_img_path, bull_active_ini, bull_active_end, bull_status, updated_by)
	VALUES ('Boletín 1', 'Acro1', 'Descripcion del boletin', 'servidor/ruta/imagen1.png','1/05/2026','30-05-2026',true, 'vhcruz');
INSERT INTO "db_Sirel".bulletin(bull_name, bull_acronym, bull_desc, bull_img_path, bull_active_ini, bull_active_end, bull_status, updated_by)
	VALUES ('Boletín 2', 'Acro2', 'Descripcion del boletin', 'servidor/ruta/imagen2.png','1-05-2026','30-05-2026', true, 'vhcruz');
INSERT INTO "db_Sirel".bulletin(bull_name, bull_acronym, bull_desc, bull_img_path, bull_active_ini, bull_active_end, bull_status, updated_by)
	VALUES ('Boletín 3', 'Acro3', 'Descripcion del boletin', 'servidor/ruta/imagen1.png','1-05-2026','30-05-2026',true, 'vhcruz');
INSERT INTO "db_Sirel".bulletin(bull_name, bull_acronym, bull_desc, bull_img_path, bull_active_ini, bull_active_end, bull_status, updated_by)
	VALUES ('Boletín 4', 'Acro4', 'Descripcion del boletin', 'servidor/ruta/imagen2.png','1-05-2026','30-05-2026', true, 'vhcruz');

INSERT INTO "db_Sirel".bulletin_resource(resource_desc) VALUES ('C:\Users\Hugo\Pictures\imagen1.jpg');
INSERT INTO "db_Sirel".bulletin_resource(resource_desc) VALUES ('C:\Users\Hugo\Pictures\imagen2.jpg');
INSERT INTO "db_Sirel".bulletin_resource(resource_desc) VALUES ('C:\Users\Hugo\Pictures\imagen3.jpg');
INSERT INTO "db_Sirel".bulletin_resource(resource_desc) VALUES ('C:\Users\Hugo\Pictures\imagen4.jpg');
INSERT INTO "db_Sirel".bulletin_resource(resource_desc) VALUES ('C:\Users\Hugo\Pictures\imagen5.jpg');
INSERT INTO "db_Sirel".bulletin_resource(resource_desc) VALUES ('C:\Users\Hugo\Pictures\imagen6.jpg');
INSERT INTO "db_Sirel".bulletin_resource(resource_desc) VALUES ('C:\Users\Hugo\Pictures\imagen7.jpg');

INSERT INTO "db_Sirel".bulletin_sections (
    section_segment, section_subsegment, section_subsegment_num, bull_id, resource_id,
    section_order, section_content, section_format, section_css, section_htmltag,
    section_status, updated_by
) VALUES (
    1, 1, 3,1, 1,
    1, 'Bienvenidos al Boletín Informativo SIREL - Primer Trimestre 2026',
	'<div Contacto: comunicaciones@sirel.gob />',
    1, 'h1',
    true, 'ADMIN'
);

-- 2. Subtítulo de sección
INSERT INTO "db_Sirel".bulletin_sections (
    section_segment, section_subsegment, section_subsegment_num, bull_id, resource_id,
    section_order, section_content, section_format, section_css, section_htmltag,
    section_status, updated_by
) VALUES (
    1, 1, 3, 1, 2,
    2, 'Avances en el Registro Electoral Nacional',
	'<div Contacto: comunicaciones@sirel.gob />',
    2, 'h2',
    true, 'EDITOR01'
);

-- 3. Párrafo de contenido informativo
INSERT INTO "db_Sirel".bulletin_sections (
    section_segment, section_subsegment, section_subsegment_num, bull_id, resource_id,
    section_order, section_content, section_format, section_css, section_htmltag,
    section_status, updated_by
) VALUES (
    1, 2, 3, 1, 3,
    3, 'Durante el primer trimestre se registraron 45,320 nuevos ciudadanos en el padrón electoral, representando un incremento del 12% respecto al periodo anterior.',
	'<div Contacto: comunicaciones@sirel.gob />',
    11, 'p',
    true, 'EDITOR01'
);

-- 4. Imagen con path referenciado
INSERT INTO "db_Sirel".bulletin_sections (
    section_segment, section_subsegment, section_subsegment_num, bull_id, resource_id,
    section_order, section_content, section_format, section_css, section_htmltag,
    section_status, updated_by
) VALUES (
    2, 1, 3, 1, 4,
    4, 'grafica_crecimiento_padron_q1_2026.png',
	'<div Contacto: comunicaciones@sirel.gob />',
    3, 'img',
    true, 'DISEÑO'
);

-- 5. Lista de puntos clave
INSERT INTO "db_Sirel".bulletin_sections (
    section_segment, section_subsegment, section_subsegment_num, bull_id, resource_id,
    section_order, section_content, section_format, section_css, section_htmltag,
    section_status, updated_by
) VALUES (
    2, 2, 3, 1, NULL,
    5, 'Apertura de 15 nuevas oficinas regionales | Digitalización del 80% de los trámites | Reducción del 30% en tiempos de atención',
	'<div Contacto: comunicaciones@sirel.gob />',
    2, 'ul',
    true, 'EDITOR02'
);

-- 6. Tabla de estadísticas en segundo boletín
INSERT INTO "db_Sirel".bulletin_sections (
    section_segment, section_subsegment, section_subsegment_num, bull_id, resource_id,
    section_order, section_content, section_format, section_css, section_htmltag,
    section_status, updated_by
) VALUES (
    2, 2, 3, 1, NULL,
    1, 'Región | Registros | Variación % || Norte | 14,200 | +8% || Centro | 21,800 | +15% || Sur | 9,320 | +6%',
	'<div Contacto: comunicaciones@sirel.gob />',
    5, 'table',
    true, 'SISTEMA'
);

-- 7. Cita destacada (sin path, valores por defecto en status y updated_by)
INSERT INTO "db_Sirel".bulletin_sections (
    section_segment, section_subsegment, section_subsegment_num, bull_id, resource_id,
    section_order, section_content, section_format, section_css, section_htmltag
) VALUES (
    2, 2, 3, 1, 5,
    2, 'La modernización del sistema electoral es un compromiso con la ciudadanía y la democracia.',
	'<div Contacto: comunicaciones@sirel.gob />',
    22, 'blockquote'
);

-- 8. Video embebido con path
INSERT INTO "db_Sirel".bulletin_sections (
	section_segment, section_subsegment, section_subsegment_num, bull_id, resource_id,
    section_order, section_content, section_format, section_css, section_htmltag,
    section_status, updated_by
) VALUES (
    3, 0, 3, 1, NULL,
    3, 'resumen_actividades_sirel_2026.mp4',
	'<div Contacto: comunicaciones@sirel.gob />',
    4, 'span',
    true, 'MULTIMEDIA'
);

-- 9. Sección inactiva (borrador sin publicar)
INSERT INTO "db_Sirel".bulletin_sections (
    section_segment, section_subsegment, section_subsegment_num, bull_id, resource_id,
    section_order, section_content, section_format, section_css, section_htmltag,
    section_status, updated_by
) VALUES (
    3, 1, 3, 1, NULL,
    4, 'Contenido en revisión: Resultados pendientes de validación por el área jurídica.',
	'<div Contacto: comunicaciones@sirel.gob />',
    6, 'p',
    false, 'EDITOR01'
);

-- 10. Pie de boletín con datos de contacto
INSERT INTO "db_Sirel".bulletin_sections (
    section_segment, section_subsegment, section_subsegment_num, bull_id, resource_id,
    section_order, section_content, section_format, section_css, section_htmltag,
    section_status, updated_by
) VALUES (
    4, 0, 3, 1, NULL,
    99, 'Contacto: comunicaciones@sirel.gob | Tel: (55) 1234-5678 | Av. Reforma 123, CDMX',
	'<div Contacto: comunicaciones@sirel.gob />',
    8, 'footer',
    true, 'ADMIN'
);


INSERT INTO "db_Sirel".cat_area (area) SELECT 'Servicios Generales' WHERE NOT EXISTS (
    SELECT 1 FROM "db_Sirel".cat_area WHERE area = 'Servicios Generales');
INSERT INTO "db_Sirel".cat_area (area) SELECT 'Servicios Integrales' WHERE NOT EXISTS (
    SELECT 1 FROM "db_Sirel".cat_area WHERE area = 'Servicios Integrales');
INSERT INTO "db_Sirel".cat_area (area) SELECT 'Recursos Humanos' WHERE NOT EXISTS (
    SELECT 1 FROM "db_Sirel".cat_area WHERE area = 'Recursos Humanos');
INSERT INTO "db_Sirel".cat_area (area) SELECT 'Desarrollo' WHERE NOT EXISTS (
    SELECT 1 FROM "db_Sirel".cat_area WHERE area = 'Desarrollo');
INSERT INTO "db_Sirel".cat_area (area) SELECT 'Calidad' WHERE NOT EXISTS (
    SELECT 1 FROM "db_Sirel".cat_area WHERE area = 'Calidad');
INSERT INTO "db_Sirel".cat_area (area) SELECT 'Monac' WHERE NOT EXISTS (
    SELECT 1 FROM "db_Sirel".cat_area WHERE area = 'Monac');
INSERT INTO "db_Sirel".cat_area (area) SELECT 'Mantenimiento' WHERE NOT EXISTS (
    SELECT 1 FROM "db_Sirel".cat_area WHERE area = 'Mantenimiento');
INSERT INTO "db_Sirel".cat_area (area) SELECT 'Soporte Técnico' WHERE NOT EXISTS (
    SELECT 1 FROM "db_Sirel".cat_area WHERE area = 'Soporte Técnico');

INSERT INTO "db_Sirel".catalogos_jerarquia (valor) SELECT 'Agente' WHERE NOT EXISTS (
    SELECT 1 FROM "db_Sirel".catalogos_jerarquia WHERE valor = 'Agente');
INSERT INTO "db_Sirel".catalogos_jerarquia (valor) SELECT 'Supervisor' WHERE NOT EXISTS (
    SELECT 1 FROM "db_Sirel".catalogos_jerarquia WHERE valor = 'Supervisor');
INSERT INTO "db_Sirel".catalogos_jerarquia (valor) SELECT 'Administrativo' WHERE NOT EXISTS (
    SELECT 1 FROM "db_Sirel".catalogos_jerarquia WHERE valor = 'Administrativo');
INSERT INTO "db_Sirel".catalogos_jerarquia (valor) SELECT 'Externo' WHERE NOT EXISTS (
    SELECT 1 FROM "db_Sirel".catalogos_jerarquia WHERE valor = 'Externo');
INSERT INTO "db_Sirel".catalogos_jerarquia (valor) SELECT 'Desarrollo' WHERE NOT EXISTS (
    SELECT 1 FROM "db_Sirel".catalogos_jerarquia WHERE valor = 'Desarrollo');
INSERT INTO "db_Sirel".catalogos_jerarquia (valor) SELECT 'Soporte' WHERE NOT EXISTS (
    SELECT 1 FROM "db_Sirel".catalogos_jerarquia WHERE valor = 'Soporte');

