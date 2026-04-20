const express = require('express');
const router = express.Router();
const { login } = require('../controllers/auth.controller');

/**
 * @openapi
 * /auth/login:
 *   post:
 *     summary: Iniciar sesión
 *     tags:
 *       - Auth
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               username:
 *                 type: string
 *               password:
 *                 type: string
 *     responses:
 *       '200':
 *         description: Token JWT generado
 *       '401':
 *         description: Credenciales inválidas
 */
router.post('/auth/login', login);

module.exports = router;