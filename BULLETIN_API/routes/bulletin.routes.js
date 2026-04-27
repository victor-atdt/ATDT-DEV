const express = require('express');
const router = express.Router();
const { verifyToken } = require('../middleware/auth.middleware'); 
const {
  getBulletins,
  updateBulletin,
  createBulletin,
  getBulletinsByWord,
  getBulletinSections,
  createBulletinSectionsBatch,
  createBulletinSectionsBatchSP,
  createBulletinResources
} = require('../controllers/bulletin.controller');

/**
 * @openapi
 * /bulletins/search/{keyword}:
 *   get:
 *     summary: Get bulletins by keyword
 *     description: Retrieves one or all bulletins from the database via the FNS_BULLETINES_BYWORD function.
 *     tags:
 *       - Bulletins
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: keyword
 *         required: true
 *         schema:
 *           type: string
 *           example: 'keyword'
 *         description: Bulletin keyword to filter.
 *     responses:
 *       '200':
 *         description: List of bulletins retrieved successfully
 */
router.get('/bulletins/search/:keyword', verifyToken, getBulletinsByWord)

/**
 * @openapi
 * /bulletins/{id}/{status}:
 *   get:
 *     summary: Get bulletins
 *     description: Retrieves one or all bulletins from the database via the FNS_BULLETINS function.
 *     tags:
 *       - Bulletins
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: id
 *         required: false
 *         schema:
 *           type: integer
 *           example: 1
 *         description: Bulletin ID to filter. If omitted, returns all bulletins.
 *       - in: query
 *         name: status
 *         required: false
 *         schema:
 *           type: boolean
 *           example: true
 *         description: Bulletin ID to filter, if ommited returns all bulletins otherwise returns active or inactive bulletins.
 *     responses:
 *       '200':
 *         description: List of bulletins retrieved successfully
 */
router.get('/bulletins/:id/:status', verifyToken, getBulletins);

/**
 * @openapi
 * /bulletins/{id}:
 *   patch:
 *     summary: Update all or part of a bulletin
 *     tags:
 *       - Bulletins
 *     security:
 *       - bearerAuth: []
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
router.patch('/bulletins/:id', verifyToken, updateBulletin);

/**
 * @openapi
 * /bulletin:
 *   post:
 *     summary: Creates a bulletin
 *     tags:
 *       - Bulletins
 *     security:
 *       - bearerAuth: []
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
 *               updated_by:
 *                 type: string
 *                 default: 'API_USER'
 *     responses:
 *       201:
 *         description: Boletín creado exitosamente
 *       400:
 *         description: Error en los datos de entrada
 *       500:
 *         description: Error en el servidor
 */
router.post('/bulletin', verifyToken, createBulletin);

/**
 * @openapi
 * /bulletin/sections/{id}:
 *   get:
 *     summary: Get bulletin sections
 *     tags:
 *       - Sections
 *     security:
 *       - bearerAuth: []
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
router.get('/bulletin/sections/:id', verifyToken, getBulletinSections);

/**
 * @openapi
 * /bulletin/sections/batch:
 *   post:
 *     summary: Save bulletin sections
 *     tags:
 *       - Sections
 *     security:
 *       - bearerAuth: []
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
 *                     - section_subsegment_num
 *                     - bull_id
 *                     - section_order
 *                     - section_content
 *                     - section_format
 *                     - section_css
 *                   properties:
 *                     section_segment:
 *                       type: integer
 *                     section_subsegment:
 *                       type: integer
 *                     section_subsegment_num:
 *                       type: integer
 *                     bull_id:
 *                       type: integer
 *                     resource_id:
 *                       type: integer
 *                       nullable: true
 *                     section_order:
 *                       type: integer
 *                     section_content:
 *                       type: string
 *                     section_format:
 *                       type: string
 *                     section_css:
 *                       type: string
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
router.post('/bulletin/sections/batch', verifyToken, createBulletinSectionsBatch);

/**
 * @openapi
 * /bulletin/sections/batch-sp:
 *   post:
 *     summary: Save bulltin sections in batch mode
 *     tags:
 *       - Sections
 *     security:
 *       - bearerAuth: [] 
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
 *                     resource_id:
 *                       type: integer
 *                       nullable: true
 *                     section_order:
 *                       type: integer
 *                     section_content:
 *                       type: string
 *                     section_css:
 *                       type: string
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
router.post('/bulletin/sections/batch-sp', verifyToken, createBulletinSectionsBatchSP);

/**
 * @openapi
 * /bulletin-resources:
 *   post:
 *     summary: Inserta múltiples recursos de boletín
 *     tags:
 *       - Resources
 *     security:
 *       - bearerAuth: []
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
router.post('/bulletin-resources', verifyToken, createBulletinResources);

module.exports = router;