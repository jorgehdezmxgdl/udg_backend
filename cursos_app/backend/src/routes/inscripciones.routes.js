const { Router } = require('express');
const validate = require('../middlewares/validate');
const { verificarToken } = require('../middlewares/auth');
const { inscripcionSchema } = require('../schemas/inscripcion.schema');
const ctrl = require('../controllers/inscripciones.controller');

const router = Router();

router.post('/', verificarToken, validate({ body: inscripcionSchema }), ctrl.inscribir);

module.exports = router;
