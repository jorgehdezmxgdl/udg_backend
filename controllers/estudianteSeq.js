const { Estudiante, Inscripcion, Curso } = require("../models");

const listar = async (req, res) => {
    const estudiantes =  await Estudiante.findAll();
    res.json(estudiantes);
};


const obtener = async (req, res) => {
    const estudiante = await Estudiante.findByPk(req.params.id);
    if (!estudiante)
        return res.status(404).json({
            error: "No encontrado"
        });
    res.json(estudiante);
};


const crear = async (req, res) => {
    const estudiante =  await Estudiante.create(req.body);
    res.status(201).json(estudiante);
};


const actualizar = async (req, res) => {
    const estudiante =
        await Estudiante.findByPk(req.params.id);
    if (!estudiante)
        return res.status(404).json({
            error: "No encontrado"
        });
    await estudiante.update(req.body);
    res.json(estudiante);
};


const eliminar = async (req, res) => {
    const estudiante =
        await Estudiante.findByPk(req.params.id);
    if (!estudiante)
        return res.status(404).json({
            error: "No encontrado"
        });

    await estudiante.destroy();
    res.json({
        mensaje: "Estudiante eliminado"
    });
};


const cursosDelEstudiante = async (req, res) => {
    const estudiante =
        await Estudiante.findByPk(
            req.params.id,
            {
                include: {
                    model: Inscripcion,
                    include: {
                        model: Curso
                    }
                }
            }
        );
    if (!estudiante)
        return res.status(404).json({
            error: "No encontrado"
        });
    res.json(estudiante);
};


module.exports = {
    listar,
    obtener,
    crear,
    actualizar,
    eliminar,
    cursosDelEstudiante
};