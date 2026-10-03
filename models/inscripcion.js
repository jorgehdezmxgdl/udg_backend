const { DataTypes } = require("sequelize");
const sequelize = require("../db/conexionSeq");

const Inscripcion = sequelize.define(
    "Inscripcion",
    {
        inscripcion_id: {
            type: DataTypes.INTEGER,
            primaryKey: true
        },
        estudiante_id: DataTypes.INTEGER,
        curso_id: DataTypes.INTEGER,
        fecha_inscripcion: DataTypes.DATE,
        calificacion: DataTypes.DECIMAL(5, 2)
    },
    {
        tableName: "inscripciones",
        timestamps: false
    }
);

module.exports = Inscripcion;