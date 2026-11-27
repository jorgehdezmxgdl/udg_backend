const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const NIVELES = ['Básico', 'Intermedio', 'Avanzado'];

const Curso = sequelize.define('cursos', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  titulo: { type: DataTypes.STRING(150), allowNull: false },
  descripcion: { type: DataTypes.TEXT, allowNull: false },
  instructor: { type: DataTypes.STRING(120), allowNull: false },
  duracionHoras: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: { min: 1 },
  },
  nivel: { type: DataTypes.ENUM(...NIVELES), allowNull: false, defaultValue: 'Básico' },
  categoria: { type: DataTypes.STRING(60), allowNull: false },

  icono: { type: DataTypes.STRING(30), allowNull: false, defaultValue: 'school' },
  cupo: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 30 },
  precio: { type: DataTypes.DECIMAL(10, 2), allowNull: false, defaultValue: 0 },
  activo: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true },
});

Curso.NIVELES = NIVELES;

module.exports = Curso;
