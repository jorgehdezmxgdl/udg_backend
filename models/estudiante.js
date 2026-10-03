const { DataTypes } = require("sequelize");
const sequelize = require("../db/conexionSeq");

const Estudiante = sequelize.define(
    "Estudiante",
    {
        estudiante_id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true
        },
        nombre: {
            type: DataTypes.STRING(100),
            allowNull: false
        },
        correo: {
            type: DataTypes.STRING(100),
            allowNull: false,
            unique: true
        },
        edad: {
            type: DataTypes.INTEGER
        }
    },
    {
        tableName: "estudiantes",
        timestamps: false
    }
);

module.exports = Estudiante;