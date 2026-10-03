const { DataTypes } = require("sequelize");
const sequelize = require("../db/conexionSeq");

const Curso = sequelize.define(
    "Curso",
    {
        curso_id: {
            type: DataTypes.INTEGER,
            primaryKey: true
        },
        nombre: DataTypes.STRING,
        creditos: DataTypes.INTEGER,
        profesor: DataTypes.STRING
    },
    {
        tableName: "cursos",
        timestamps: false
    }
);

module.exports = Curso;