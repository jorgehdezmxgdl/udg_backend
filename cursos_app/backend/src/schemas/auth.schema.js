const { z } = require('zod');

const loginSchema = z.object({
  clave: z
    .string({ error: 'La clave es obligatoria' })
    .trim()
    .min(3, 'La clave debe tener al menos 3 caracteres')
    .max(30, 'La clave no puede exceder 30 caracteres')
    .regex(/^[a-zA-Z0-9._-]+$/, 'La clave solo admite letras, números, punto, guion y guion bajo')
    .transform((v) => v.toLowerCase()),
  password: z
    .string({ error: 'La contraseña es obligatoria' })
    .min(6, 'La contraseña debe tener al menos 6 caracteres')
    .max(72, 'La contraseña no puede exceder 72 caracteres'),
});

module.exports = { loginSchema };
