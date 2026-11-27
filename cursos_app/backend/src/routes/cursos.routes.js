const { Router } = require('express');
const validate = require('../middlewares/validate');
const { verificarToken } = require('../middlewares/auth');
const { listarCursosQuery, idParam } = require('../schemas/curso.schema');
const ctrl = require('../controllers/cursos.controller');

const router = Router();

router.get('/cursos', validate({ query: listarCursosQuery }), ctrl.listar);
router.get('/cursos/:id', validate({ params: idParam }), ctrl.detalle);

router.get('/mis-cursos', verificarToken, ctrl.misCursos);

module.exports = router;
