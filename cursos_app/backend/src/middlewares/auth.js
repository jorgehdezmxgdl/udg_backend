const jwt = require('jsonwebtoken');
const env = require('../config/env');

function verificarToken(req, res, next) {
  const [tipo, token] = (req.headers.authorization || '').split(' ');

  if (tipo !== 'Bearer' || !token) {
    return res.status(401).json({ ok: false, mensaje: 'Debes iniciar sesión' });
  }

  try {
    req.user = jwt.verify(token, env.JWT_SECRET);
    next();
  } catch {
    return res.status(401).json({ ok: false, mensaje: 'Sesión inválida o expirada' });
  }
}

function firmarToken(usuario) {
  return jwt.sign({ sub: usuario.id, clave: usuario.clave }, env.JWT_SECRET, {
    expiresIn: env.JWT_EXPIRES_IN,
  });
}

module.exports = { verificarToken, firmarToken };
