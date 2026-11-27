const { Router } = require('express');
const validate = require('../middlewares/validate');
const { verificarToken } = require('../middlewares/auth');
const { loginSchema } = require('../schemas/auth.schema');
const ctrl = require('../controllers/auth.controller');

const router = Router();

router.post('/login', validate({ body: loginSchema }), ctrl.login);
router.get('/me', verificarToken, ctrl.perfil);

module.exports = router;
