const Estudiante = require("./estudiante");
const Curso = require("./curso");
const Inscripcion = require("./inscripcion");

Estudiante.hasMany(Inscripcion, {
    foreignKey: "estudiante_id"
});

Inscripcion.belongsTo(Estudiante, {
    foreignKey: "estudiante_id"
});

Curso.hasMany(Inscripcion, {
    foreignKey: "curso_id"
});

Inscripcion.belongsTo(Curso, {
    foreignKey: "curso_id"
});

module.exports = {
    Estudiante,
    Curso,
    Inscripcion
};