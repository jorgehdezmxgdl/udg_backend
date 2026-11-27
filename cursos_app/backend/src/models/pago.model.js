const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Pago = sequelize.define('pagos', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  inscripcionId: { type: DataTypes.INTEGER, allowNull: false, unique: true },
  folio: { type: DataTypes.STRING(30), allowNull: false, unique: true },
  autorizacion: { type: DataTypes.STRING(12), allowNull: false },
  metodo: { type: DataTypes.ENUM('transferencia', 'tarjeta', 'bitcoin'), allowNull: false },
  monto: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
  moneda: { type: DataTypes.STRING(3), allowNull: false, defaultValue: 'MXN' },
  montoBtc: { type: DataTypes.DECIMAL(16, 8), allowNull: true },
  referencia: { type: DataTypes.STRING(80), allowNull: false },
  nombrePagador: { type: DataTypes.STRING(100), allowNull: false },
  pais: { type: DataTypes.STRING(2), allowNull: false },
  correoNotificacion: { type: DataTypes.STRING(150), allowNull: false },
  estado: {
    type: DataTypes.ENUM('aprobado', 'rechazado'),
    allowNull: false,
    defaultValue: 'aprobado',
  },
  correoEnviado: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: false },
});

module.exports = Pago;
