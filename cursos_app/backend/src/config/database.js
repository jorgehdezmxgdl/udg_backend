const { Sequelize, DataTypes } = require('sequelize');
const env = require('./env');

DataTypes.postgres.DECIMAL.parse = Number;

module.exports = new Sequelize(env.DB_NAME, env.DB_USER, env.DB_PASSWORD, {
  host: env.DB_HOST,
  port: env.DB_PORT,
  dialect: 'postgres',
  logging: false,
  define: { underscored: true, freezeTableName: true },
});
