const { DataTypes } = require('sequelize');
const bcrypt = require('bcryptjs');
const sequelize = require('../config/database');

const Usuario = sequelize.define(
  'usuarios',
  {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },

    clave: {
      type: DataTypes.STRING(30),
      allowNull: false,
      unique: true,
      set(valor) {
        this.setDataValue('clave', String(valor).trim().toLowerCase());
      },
    },
    nombre: { type: DataTypes.STRING(120), allowNull: false },
    correo: {
      type: DataTypes.STRING(150),
      allowNull: false,
      unique: true,
      validate: { isEmail: true },
    },
    passwordHash: { type: DataTypes.STRING(100), allowNull: false },
    activo: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true },
  },
  {
    defaultScope: { attributes: { exclude: ['passwordHash'] } },
    scopes: { conPassword: { attributes: { include: ['passwordHash'] } } },
  }
);

Usuario.hashPassword = (plano) => bcrypt.hash(plano, 10);
Usuario.prototype.validarPassword = function (plano) {
  return bcrypt.compare(plano, this.passwordHash);
};

Usuario.prototype.toPublic = function () {
  const { id, clave, nombre, correo } = this;
  return { id, clave, nombre, correo };
};

module.exports = Usuario;
