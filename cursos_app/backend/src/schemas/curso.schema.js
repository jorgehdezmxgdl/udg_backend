const { z } = require('zod');
const { NIVELES } = require('../models/curso.model');

const listarCursosQuery = z.object({
  q: z.string().trim().max(60).optional(),
  nivel: z.enum(NIVELES, { error: `Nivel inválido. Usa: ${NIVELES.join(', ')}` }).optional(),
  categoria: z.string().trim().max(60).optional(),
});

const idParam = z.object({
  id: z.coerce.number({ error: 'El id debe ser numérico' }).int().positive('El id debe ser positivo'),
});

module.exports = { listarCursosQuery, idParam };
