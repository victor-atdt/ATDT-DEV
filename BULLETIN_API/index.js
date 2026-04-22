const cors = require('cors');
const express = require('express');
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');
const bulletinRoutes = require('./routes/bulletin.routes');
const authRoutes = require('./routes/auth.routes');

const app = express();

const PORT = process.env.PORT || 3001;

app.use(cors({
  origin: 'http://localhost:5173',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Authorization', 'Content-Type'],
}));

const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'API de Bulletin',
      version: '1.0.0',
      description: 'Documentación de la API de Bulletin con PostgreSQL',
    },
    servers: [{ url: `http://localhost:${PORT}` }],
    //agregar el esquema de seguridad para Swagger UI
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
  },
  apis: ['./routes/*.js'], // 👈 ahora apunta a las rutas
};

const swaggerDocs = swaggerJsdoc(swaggerOptions);
app.use(express.json());
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));
app.use('/', authRoutes);
app.use('/', bulletinRoutes);

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
  console.log(`Documentación en http://localhost:${PORT}/api-docs`);
});