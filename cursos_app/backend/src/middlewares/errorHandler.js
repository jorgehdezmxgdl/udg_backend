const { ValidationError, UniqueConstraintError, ForeignKeyConstraintError } = require('sequelize');
const env = require('../config/env');
const HttpError = require('../utils/httpError');

function notFound(_req, res) {
  res.status(404).json({ ok: false, mensaje: 'Ruta no encontrada' });
}

function errorHandler(err, _req, res, _next) {
  if (err instanceof HttpError) {
    return res.status(err.status).json({
      ok: false,
      mensaje: err.message,
      ...(err.campo && { errores: [{ campo: err.campo, mensaje: err.message }] }),
    });
  }
  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({ ok: false, mensaje: 'JSON mal formado' });
  }
  if (err instanceof UniqueConstraintError) {
    return res.status(409).json({ ok: false, mensaje: 'El registro ya existe' });
  }
  if (err instanceof ForeignKeyConstraintError) {
    return res.status(409).json({ ok: false, mensaje: 'Referencia inválida' });
  }
  if (err instanceof ValidationError) {
    return res.status(422).json({
      ok: false,
      mensaje: err.errors[0]?.message || 'Datos inválidos',
      errores: err.errors.map((e) => ({ campo: e.path, mensaje: e.message })),
    });
  }

  console.error('Error:', err);
  res.status(err.status || 500).json({
    ok: false,
    mensaje: 'Error interno del servidor',
    ...(env.NODE_ENV === 'development' && { detalle: err.message }),
  });
}

module.exports = { notFound, errorHandler };
