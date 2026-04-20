const express = require('express');
const router = express.Router();
const { verifyToken } = require('../middleware/auth.middleware'); // 👈 importa el middleware
const {
  getBulletins,
  updateBulletin,
  createBulletin,
  getBulletinSections,
  createBulletinSectionsBatch,
  createBulletinSectionsBatchSP,
  createBulletinResources
} = require('../controllers/bulletin.controller');

/**
 * @openapi
 * /bulletins:
 *   get:
 *     summary: Get bulletins
 *     description: Retrieves one or all bulletins from the database via the FNS_BULLETINS function.
 *     tags:
 *       - Bulletins
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: bull_id
 *         required: false
 *         schema:
 *           type: integer
 *           example: 1
 *         description: Bulletin ID to filter. If omitted, returns all bulletins.
 *     responses:
 *       '200':
 *         description: List of bulletins retrieved successfully
 */
router.get('/bulletins', verifyToken, getBulletins);

/**
 * @openapi
 * /bulletins/{id}:
 *   patch:
 *     summary: Actualiza parcialmente un boletín
 *     tags:
 *       - Bulletins
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               bull_name:
 *                 type: string
 *               bull_acronym:
 *                 type: string
 *               bull_desc:
 *                 type: string
 *               bull_img_path:
 *                 type: string
 *               bull_active_ini:
 *                 type: string
 *                 format: date
 *               bull_active_end:
 *                 type: string
 *                 format: date
 *               bull_status:
 *                 type: boolean
 *               updated_by:
 *                 type: string
 *     responses:
 *       200:
 *         description: Registro actualizado con éxito
 *       404:
 *         description: Boletín no encontrado
 *       500:
 *         description: Error en el servidor
 */
router.patch('/bulletins/:id', updateBulletin);

/**
 * @openapi
 * /bulletin:
 *   post:
 *     summary: Crea un nuevo boletín
 *     tags:
 *       - Bulletins
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - bull_name
 *               - bull_acronym
 *               - bull_desc
 *               - bull_img_path
 *             properties:
 *               bull_name:
 *                 type: string
 *               bull_acronym:
 *                 type: string
 *               bull_desc:
 *                 type: string
 *               bull_img_path:
 *                 type: string
 *               bull_active_ini:
 *                 type: string
 *                 format: date
 *               bull_active_end:
 *                 type: string
 *                 format: date
 *               bull_status:
 *                 type: boolean
 *                 default: true
 *     responses:
 *       201:
 *         description: Boletín creado exitosamente
 *       400:
 *         description: Error en los datos de entrada
 *       500:
 *         description: Error en el servidor
 */
router.post('/bulletin', createBulletin);

/**
 * @openapi
 * /bulletin/sections/{id}:
 *   get:
 *     summary: Obtiene las secciones de un boletín
 *     tags:
 *       - Sections
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID del boletín
 *     responses:
 *       200:
 *         description: Lista de secciones obtenida con éxito
 *       404:
 *         description: No se encontraron secciones
 *       500:
 *         description: Error en el servidor
 */
router.get('/bulletin/sections/:id', getBulletinSections);

/**
 * @openapi
 * /bulletin/sections/batch:
 *   post:
 *     summary: Guarda múltiples secciones de un boletín
 *     tags:
 *       - Sections
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               data:
 *                 type: array
 *                 items:
 *                   type: object
 *                   required:
 *                     - section_segment
 *                     - section_subsegment
 *                     - bull_id
 *                     - section_order
 *                     - section_content
 *                     - section_css
 *                   properties:
 *                     section_segment:
 *                       type: integer
 *                     section_subsegment:
 *                       type: integer
 *                     bull_id:
 *                       type: integer
 *                     path_id:
 *                       type: integer
 *                       nullable: true
 *                     section_order:
 *                       type: integer
 *                     section_content:
 *                       type: string
 *                     section_css:
 *                       type: integer
 *                     section_htmltag:
 *                       type: string
 *                       maxLength: 10
 *                     section_status:
 *                       type: boolean
 *                       default: true
 *                     updated_by:
 *                       type: string
 *                       maxLength: 100
 *                       default: SISTEMA
 *     responses:
 *       201:
 *         description: Secciones guardadas correctamente
 *       400:
 *         description: Formato de datos inválido
 *       500:
 *         description: Error al guardar en la base de datos
 */
router.post('/bulletin/sections/batch', createBulletinSectionsBatch);

/**
 * @openapi
 * /bulletin/sections/batch-sp:
 *   post:
 *     summary: Guarda múltiples secciones usando un procedimiento almacenado
 *     tags:
 *       - Sections
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               data:
 *                 type: array
 *                 items:
 *                   type: object
 *                   required:
 *                     - section_segment
 *                     - section_subsegment
 *                     - bull_id
 *                     - section_order
 *                     - section_content
 *                     - section_css
 *                   properties:
 *                     section_segment:
 *                       type: integer
 *                     section_subsegment:
 *                       type: integer
 *                     bull_id:
 *                       type: integer
 *                     path_id:
 *                       type: integer
 *                       nullable: true
 *                     section_order:
 *                       type: integer
 *                     section_content:
 *                       type: string
 *                     section_css:
 *                       type: integer
 *                     section_htmltag:
 *                       type: string
 *                       maxLength: 10
 *                     section_status:
 *                       type: boolean
 *                       default: true
 *                     updated_by:
 *                       type: string
 *                       maxLength: 100
 *                       default: SISTEMA
 *     responses:
 *       201:
 *         description: Datos procesados por el procedimiento exitosamente
 *       400:
 *         description: Error de validación en los datos
 *       500:
 *         description: Error en la ejecución del procedimiento
 */
router.post('/bulletin/sections/batch-sp', createBulletinSectionsBatchSP);

/**
 * @openapi
 * /bulletin-resources:
 *   post:
 *     summary: Inserta múltiples recursos de boletín
 *     tags:
 *       - Resources
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: array
 *             items:
 *               type: object
 *               properties:
 *                 resource_desc:
 *                   type: string
 *     responses:
 *       201:
 *         description: Recursos insertados correctamente
 *       500:
 *         description: Error interno del servidor
 */
router.post('/bulletin-resources', createBulletinResources);

module.exports = router;