const { pool } = require('../db');
const fs = require('fs');
const path = require('path');

const createBulletin = async (req, res) => {
  // 1. Validar imagen PRIMERO, antes de tocar la BD
  if (!req.file) {
    return res.status(400).json({ error: 'No se recibió ninguna imagen.' });
  }

  const { bull_name, bull_acronym, bull_desc, bull_active_ini, bull_active_end, bull_status, updated_by } = req.body;

  try {
    // 2. Generar el path de imagen a partir del acrónimo
    const v_bull_image = req.file.originalname;
    // 3. Guardar el boletín en la BD con el path generado
    const queryText = `SELECT * FROM "db_Sirel".FNI_BULLETIN($1, $2, $3, $4, $5, $6, COALESCE($7, true), $8)`;
    const result = await pool.query(queryText, [
      bull_name, bull_acronym, bull_desc, v_bull_image,
      bull_active_ini || null, bull_active_end || null,
      bull_status, updated_by
    ]);

    const bulletinInfo = result.rows[0].bull_img_path;
    // 4. Guardar la imagen en disco solo si la BD fue exitosa
    const destPath = path.join(__dirname, '../public/images/', `${bulletinInfo}`);
    fs.writeFileSync(destPath, req.file.buffer);

    return res.status(201).json({
      message: 'Boletín creado exitosamente.'
    });

  } catch (err) {
    console.error('Error al crear boletín con imagen:', err);
    if (err.code === '23505') {
      return res.status(400).json({ error: 'El ID o el Acrónimo ya existen.' });
    }
    return res.status(500).json({ error: 'Error interno del servidor', details: err.message });
  }
};

const getBulletins = async (req, res) => {
  try {
    const { id, status } = req.query;
    const queryText = 'SELECT * FROM "db_Sirel".FNS_BULLETINS($1, $2)';
    const result = await pool.query(queryText, [id || null, status || null]);

    return res.status(200).json(result.rows);
  } catch (err) {
    console.error("Error en la ruta /bulletins:", err);
    return res.status(500).json({ error: "Error al obtener datos", message: err.message });
  }
};

const getBulletinsByWord = async (req, res) => {
  try {
    const { keyword } = req.query;
    console.log("keyword", keyword);
    const queryText = 'SELECT * FROM "db_Sirel".FNS_BULLETINES_BYWORD($1)';
    const result = await pool.query(queryText, [keyword || null]);

    console.log("Filas enviando al navegador:", result.rowCount);
    return res.status(200).json(result.rows);
  } catch (err) {
    console.error("Error en la ruta /bulletins:", err);
    return res.status(500).json({ error: "Error al obtener datos", message: err.message });
  }
};

const updateBulletin = async (req, res) => {
  const { id } = req.params;
  const { bull_name, bull_acronym, bull_desc, bull_img_path, bull_active_ini, bull_active_end, bull_status, updated_by } = req.body;

  try {
    const queryText = `SELECT * FROM "db_Sirel".FNU_BULLETIN($1, $2, $3, $4, $5, $6, $7, $8, $9)`;
    const values = [
      id,
      bull_name || null,
      bull_acronym || null,
      bull_desc || null,
      bull_img_path !== undefined ? (bull_img_path === '' ? null : bull_img_path) : null,
      bull_active_ini || null,
      bull_active_end || null,
      bull_status !== undefined ? bull_status : null,
      updated_by || 'API_USER'
    ];

    const result = await pool.query(queryText, values);

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Boletín no encontrado" });
    }

    return res.status(200).json({ message: "Actualización exitosa", bull_id: id });
  } catch (err) {
    console.error("Error en PATCH /bulletins:", err);
    return res.status(500).json({ error: "Error al actualizar", message: err.message });
  }
};

const getBulletinSections = async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM "db_Sirel".FNS_BULL_SECTIONS($1)', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ mensaje: "No se encontraron secciones para este boletín" });
    }

    return res.json({ data: result.rows });
  } catch (err) {
    console.error("Error al ejecutar FNS_BULL_SECTIONS:", err);
    return res.status(500).json({ error: "Error interno al consultar las secciones" });
  }
};

const createBulletinSectionsBatch = async (req, res) => {
  const { data } = req.body;

  if (!data || !Array.isArray(data)) {
    return res.status(400).json({ error: "Formato de datos inválido" });
  }

  try {
    await pool.query('BEGIN');
    const queryText = `
      INSERT INTO "db_Sirel".bulletin_sections (
        section_segment, section_subsegment, section_subsegment_num, bull_id, 
        resource_id, section_order, section_content, section_format, 
        section_css, section_htmltag, section_status, updated_by
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
      RETURNING *
    `;

    const insertedRows = [];

    for (const item of data) {
      const result = await pool.query(queryText, [
        item.section_segment, item.section_subsegment, item.section_subsegment_num, item.bull_id, item.resource_id,
        item.section_order, item.section_content, item.section_format, item.section_css, item.section_htmltag,
        item.section_status, item.updated_by
      ]);
      insertedRows.push(result.rows[0]);
    }

    await pool.query('COMMIT');
    return res.status(201).json({ 
      mensaje: "Todas las secciones fueron guardadas exitosamente",
      total: insertedRows.length,
      data: insertedRows  // JSON con todos los registros insertados
    });
  } catch (err) {
    await pool.query('ROLLBACK');
    console.error("Error en inserción masiva:", err);
    return res.status(500).json({ error: err.message + "Error al procesar el guardado masivo" });
  }
};

const createBulletinSectionsBatchSP = async (req, res) => {
  const { data } = req.body;

  if (!data || !Array.isArray(data) || data.length === 0) {
    return res.status(400).json({ error: "Se requiere un arreglo 'data' con al menos un elemento." });
  }

  const errores = [];
  data.forEach((item, index) => {
    if (!item.bull_id || typeof item.bull_id !== 'number') errores.push(`Fila ${index + 1}: bull_id es obligatorio y debe ser numérico.`);
    if (item.section_content === undefined || item.section_content === null) errores.push(`Fila ${index + 1}: section_content no puede estar vacío.`);
    if (typeof item.section_order !== 'number') errores.push(`Fila ${index + 1}: section_order debe ser un número.`);
  });

  if (errores.length > 0) {
    return res.status(400).json({ mensaje: "Errores de validación encontrados", detalles: errores });
  }

  try {
    await pool.query('SELECT * FROM "db_Sirel".FNI_BULLETIN_SECTIONS($1)', [JSON.stringify(data)]);
    return res.status(201).json({ mensaje: "Procedimiento ejecutado correctamente", registros_procesados: data.length });
  } catch (err) {
    console.error("Error al ejecutar SPI_BULLETIN_SECTIONS:", err);
    return res.status(500).json({ error: "Error interno al ejecutar el procedimiento almacenado", detalle: err.message });
  }
};

const createBulletinResources = async (req, res) => {
  try {
    const data = req.body;
    const result = await pool.query('SELECT * FROM "db_Sirel".FNI_BULLETIN_RESOURCES($1::jsonb)', [JSON.stringify(data)]);
    return res.status(201).json({ success: true, inserted_ids: result.rows.map(row => row.resource_id) });
  } catch (err) {
    console.error('Error al insertar recursos:', err.message);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
};

const updateBulletinResources  = async (req, res) => {
  const data = req.body; // [{ resource_id: 1, resource_desc: "..." }, ...]

  // Validación básica
  if (!Array.isArray(data) || data.length === 0) {
    return res.status(400).json({
      success: false,
      message: 'El body debe ser un arreglo con al menos un elemento.',
    });
  }

  const isValid = data.every(
    (item) =>
      typeof item.resource_id === 'number' &&
      typeof item.resource_desc === 'string' &&
      item.resource_desc.trim() !== ''
  );

  if (!isValid) {
    return res.status(400).json({
      success: false,
      message: 'Cada elemento debe tener resource_id (number) y resource_desc (string).',
    });
  }

  try {
    const query = `SELECT "db_Sirel".FNU_SECTION_RESOURCES($1::JSONB) AS result`;
    const { rows } = await pool.query(query, [JSON.stringify(data)]);

    return res.status(200).json({
      success: true,
      message: rows[0].result,
    });
  } catch (error) {
    console.error('Error en updateBulletinResources:', error);
    return res.status(500).json({
      success: false,
      message: 'Error interno del servidor.',
      detail: error.message,
    });
  }
};

const updateBulletinSections = async (req, res) => {
  const sections = req.body.sections;

  // Validar que venga un array con al menos un elemento
  if (!Array.isArray(sections) || sections.length === 0) {
    return res.status(400).json({
      error: 'El campo "sections" debe ser un arreglo con al menos un elemento.',
    });
  }

  // Validar que cada elemento tenga los campos de la PK
  const invalidItems = sections
    .map((s, i) => ({ index: i, s }))
    .filter(({ s }) =>
      s.section_id        == null ||
      s.section_segment   == null ||
      s.section_subsegment == null ||
      s.bull_id           == null
    );

  if (invalidItems.length > 0) {
    return res.status(400).json({
      error: 'Todos los registros deben incluir section_id, section_segment, section_subsegment y bull_id.',
      invalid_indexes: invalidItems.map(({ index }) => index),
    });
  }

  try {
    // Construir el array de ROW(...) para PostgreSQL
    // Cada elemento se mapea a un parámetro $N
    const rowLiterals = sections.map((_, i) => {
      const base = i * 13;
      return `ROW(
        $${base + 1},  -- section_id
        $${base + 2},  -- section_segment
        $${base + 3},  -- section_subsegment
        $${base + 4},  -- section_subsegment_num
        $${base + 5},  -- bull_id
        $${base + 6},  -- resource_id
        $${base + 7},  -- section_order
        $${base + 8},  -- section_content
        $${base + 9},  -- section_format
        $${base + 10}, -- section_css
        $${base + 11}, -- section_htmltag
        $${base + 12}, -- section_status
        $${base + 13}  -- updated_by
      )`;
    });

    const values = sections.flatMap((s) => [
      s.section_id,
      s.section_segment,
      s.section_subsegment,
      s.section_subsegment_num  ?? null,
      s.bull_id,
      s.resource_id             ?? null,
      s.section_order           ?? null,
      s.section_content         ?? null,
      s.section_format          ?? null,
      s.section_css             ?? null,
      s.section_htmltag         ?? null,
      s.section_status          ?? null,
      s.updated_by              ?? null,
    ]);

    const queryText = `
      SELECT section_id, section_segment, section_subsegment, bull_id,
             success, message, rows_affected
      FROM "db_Sirel".FNU_BULLETIN_SECTIONS(
        ARRAY[
          ${rowLiterals.join(',\n          ')}
        ]::"db_Sirel".section_input_type[]
      )
    `;

    const result = await pool.query(queryText, values);

    // Separar exitosos y fallidos para dar una respuesta clara
    const succeeded = result.rows.filter((r) => r.success);
    const failed    = result.rows.filter((r) => !r.success);

    const httpStatus = failed.length === 0 ? 200        // todo OK
                     : succeeded.length === 0 ? 404     // todo falló
                     : 207;                             // parcial (Multi-Status)

    return res.status(httpStatus).json({
      total:     result.rows.length,
      succeeded: succeeded.length,
      failed:    failed.length,
      results:   result.rows,
    });

  } catch (err) {
    console.error('Error en updateBulletinSections:', err);
    return res.status(500).json({ error: 'Error interno del servidor', details: err.message });
  }
};

module.exports = {
  createBulletin,
  getBulletins,
  updateBulletin,
  getBulletinsByWord,
  getBulletinSections,
  createBulletinSectionsBatch,
  createBulletinSectionsBatchSP,
  createBulletinResources,
  updateBulletinResources,
  updateBulletinSections
};