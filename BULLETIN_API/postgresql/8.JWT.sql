-- 1. Crear la tabla
CREATE IF NOT EXISTS TABLE "db_Sirel".users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role VARCHAR(50) DEFAULT 'user'
);

-- 2. Insertar un usuario de prueba
-- La contraseña 'admin123' ya hasheada con bcrypt
INSERT INTO "db_Sirel".users (username, password_hash, role)
VALUES (
  'admin',
  '$2b$10$SZzJIlMlyUbcLC8o0c7qg.HnLcGYf.hQCF4qQqEHptweVMNINgrkS',
  'admin'
);