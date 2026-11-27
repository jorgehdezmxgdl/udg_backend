const { Usuario } = require('../models');
const { firmarToken } = require('../middlewares/auth');

async function login(req, res) {
  const { clave, password } = req.validated.body;

  const usuario = await Usuario.scope('conPassword').findOne({ where: { clave, activo: true } });

  if (!usuario || !(await usuario.validarPassword(password))) {
    return res.status(401).json({ ok: false, mensaje: 'Clave o contraseña incorrectas' });
  }

  res.json({
    ok: true,
    token: firmarToken(usuario),
    usuario: usuario.toPublic(),
  });
}

async function perfil(req, res) {
  const usuario = await Usuario.findByPk(req.user.sub);
  if (!usuario || !usuario.activo) {
    return res.status(401).json({ ok: false, mensaje: 'Usuario no disponible' });
  }
  res.json({ ok: true, usuario: usuario.toPublic() });
}

module.exports = { login, perfil };
