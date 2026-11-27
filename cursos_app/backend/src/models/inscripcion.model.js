const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Inscripcion = sequelize.define(
  'inscripciones',
  {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    usuarioId: { type: DataTypes.INTEGER, allowNull: false },
    cursoId: { type: DataTypes.INTEGER, allowNull: false },
    progreso: {
      type: DataTypes.SMALLINT,
      allowNull: false,
      defaultValue: 0,
      validate: { min: 0, max: 100 },
    },
    calificacion: { type: DataTypes.DECIMAL(5, 2), allowNull: true, validate: { min: 0, max: 100 } },
    fechaInscripcion: {
      type: DataTypes.DATEONLY,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    indexes: [{ unique: true, fields: ['usuario_id', 'curso_id'] }],
  }
);

module.exports = Inscripcion;
