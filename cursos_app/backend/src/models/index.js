const sequelize = require('../config/database');
const Usuario = require('./usuario.model');
const Curso = require('./curso.model');
const Inscripcion = require('./inscripcion.model');
const Pago = require('./pago.model');

Usuario.hasMany(Inscripcion, { foreignKey: 'usuarioId', as: 'inscripciones', onDelete: 'CASCADE' });
Inscripcion.belongsTo(Usuario, { foreignKey: 'usuarioId', as: 'usuario' });

Curso.hasMany(Inscripcion, { foreignKey: 'cursoId', as: 'inscripciones', onDelete: 'RESTRICT' });
Inscripcion.belongsTo(Curso, { foreignKey: 'cursoId', as: 'curso' });

Inscripcion.hasOne(Pago, { foreignKey: 'inscripcionId', as: 'pago', onDelete: 'CASCADE' });
Pago.belongsTo(Inscripcion, { foreignKey: 'inscripcionId', as: 'inscripcion' });

module.exports = { sequelize, Usuario, Curso, Inscripcion, Pago };
