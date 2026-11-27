const { Op } = require('sequelize');
const { Curso, Inscripcion } = require('../models');

const ATRIBUTOS_CURSO = [
  'id', 'titulo', 'descripcion', 'instructor', 'duracionHoras',
  'nivel', 'categoria', 'icono', 'cupo', 'precio',
];

async function listar(req, res) {
  const { q, nivel, categoria } = req.validated.query;

  const where = { activo: true };
  if (nivel) where.nivel = nivel;
  if (categoria) where.categoria = { [Op.iLike]: categoria };
  if (q) {
    where[Op.or] = [
      { titulo: { [Op.iLike]: `%${q}%` } },
      { descripcion: { [Op.iLike]: `%${q}%` } },
      { instructor: { [Op.iLike]: `%${q}%` } },
    ];
  }

  const cursos = await Curso.findAll({ where, attributes: ATRIBUTOS_CURSO, order: [['titulo', 'ASC']] });
  res.json({ ok: true, total: cursos.length, cursos });
}

async function detalle(req, res) {
  const curso = await Curso.findOne({
    where: { id: req.validated.params.id, activo: true },
    attributes: ATRIBUTOS_CURSO,
  });
  if (!curso) return res.status(404).json({ ok: false, mensaje: 'Curso no encontrado' });
  res.json({ ok: true, curso });
}

async function misCursos(req, res) {
  const inscripciones = await Inscripcion.findAll({
    where: { usuarioId: req.user.sub },
    include: [{ model: Curso, as: 'curso', attributes: ATRIBUTOS_CURSO }],
    order: [['fechaInscripcion', 'DESC']],
  });

  const cursos = inscripciones.map((i) => ({
    ...i.curso.toJSON(),
    inscripcionId: i.id,
    progreso: i.progreso,
    calificacion: i.calificacion,
    fechaInscripcion: i.fechaInscripcion,
    completado: i.progreso >= 100,
  }));

  const completados = cursos.filter((c) => c.completado);
  const calificados = completados.filter((c) => c.calificacion !== null);

  const resumen = {
    total: cursos.length,
    completados: completados.length,
    enCurso: cursos.length - completados.length,
    horasCompletadas: completados.reduce((s, c) => s + c.duracionHoras, 0),
    promedio: calificados.length
      ? Number((calificados.reduce((s, c) => s + c.calificacion, 0) / calificados.length).toFixed(1))
      : null,
  };

  res.json({ ok: true, resumen, cursos });
}

module.exports = { listar, detalle, misCursos };
