const { Router } = require('express');
const authRoutes = require('./auth.routes');
const cursosRoutes = require('./cursos.routes');
const inscripcionesRoutes = require('./inscripciones.routes');
const catalogosRoutes = require('./catalogos.routes');

const router = Router();

router.get('/health', (_req, res) => res.json({ ok: true, servicio: 'curmex-api' }));
router.use('/auth', authRoutes);
router.use('/catalogos', catalogosRoutes);
router.use('/inscripciones', inscripcionesRoutes);
router.use('/', cursosRoutes);

module.exports = router;
