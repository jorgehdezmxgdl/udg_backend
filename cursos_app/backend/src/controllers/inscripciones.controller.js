const { sequelize, Curso, Inscripcion, Pago } = require('../models');
const { PAISES, nombreDe } = require('../config/catalogos');
const HttpError = require('../utils/httpError');
const pasarela = require('../services/pasarela.service');
const { enviarCorreo } = require('../services/correo.service');
const { confirmacionTemplate } = require('../templates/confirmacion.template');

async function inscribir(req, res) {
  const datos = req.validated.body;
  const usuarioId = req.user.sub;

  const { curso, inscripcion, pago } = await sequelize.transaction(async (t) => {
    const curso = await Curso.findByPk(datos.cursoId, { transaction: t, lock: t.LOCK.UPDATE });
    if (!curso || !curso.activo) {
      throw new HttpError(404, 'El curso no existe o ya no está disponible', 'cursoId');
    }

    const yaInscrito = await Inscripcion.findOne({
      where: { usuarioId, cursoId: curso.id },
      transaction: t,
    });
    if (yaInscrito) throw new HttpError(409, 'Ya estás inscrito en este curso', 'cursoId');

    const ocupados = await Inscripcion.count({ where: { cursoId: curso.id }, transaction: t });
    if (ocupados >= curso.cupo) {
      throw new HttpError(409, 'Lo sentimos, el curso ya no tiene cupo disponible', 'cursoId');
    }

    const cobro = await pasarela.cobrar({ monto: curso.precio, pago: datos.pago });
    if (!cobro.aprobado) throw new HttpError(402, cobro.motivo, cobro.campo);

    const inscripcion = await Inscripcion.create(
      { usuarioId, cursoId: curso.id, progreso: 0 },
      { transaction: t }
    );

    const pago = await Pago.create(
      {
        inscripcionId: inscripcion.id,
        folio: cobro.folio,
        autorizacion: cobro.autorizacion,
        metodo: datos.pago.metodo,
        monto: curso.precio,
        moneda: cobro.moneda,
        montoBtc: cobro.montoBtc,
        referencia: cobro.referencia,
        nombrePagador: datos.nombre,
        pais: datos.pais,
        correoNotificacion: datos.correo,
      },
      { transaction: t }
    );

    return { curso, inscripcion, pago };
  });

  const paisNombre = nombreDe(PAISES, datos.pais);
  const plantilla = confirmacionTemplate({
    nombre: datos.nombre,
    paisNombre,
    curso,
    pago,
    fecha: pago.createdAt,
  });
  const correo = await enviarCorreo({
    para: datos.correo,
    asunto: plantilla.asunto,
    html: plantilla.html,
    texto: plantilla.texto,
    nombreArchivo: pago.folio,
  });
  if (correo.enviado) await pago.update({ correoEnviado: true });

  res.status(201).json({
    ok: true,
    mensaje: `¡Listo! Quedaste inscrito en "${curso.titulo}"`,
    inscripcion: {
      id: inscripcion.id,
      fechaInscripcion: inscripcion.fechaInscripcion,
      curso: { id: curso.id, titulo: curso.titulo, icono: curso.icono, instructor: curso.instructor },
    },
    pago: {
      folio: pago.folio,
      autorizacion: pago.autorizacion,
      metodo: pago.metodo,
      monto: pago.monto,
      moneda: pago.moneda,
      montoBtc: pago.montoBtc,
      referencia: pago.referencia,
      nombre: pago.nombrePagador,
      pais: paisNombre,
      fecha: pago.createdAt,
    },
    correo,
  });
}

module.exports = { inscribir };
