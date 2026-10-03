const pool = require("../db/conexion");

const getAll = () =>
    pool.query(`
        SELECT *
        FROM estudiantes
        ORDER BY estudiante_id
    `);

const getById = (id) =>
    pool.query(`
        SELECT *
        FROM estudiantes
        WHERE estudiante_id = $1
    `, [id]);

const create = ({ nombre, correo, edad }) =>
    pool.query(`
        INSERT INTO estudiantes (nombre, correo, edad)
        VALUES ($1, $2, $3)
        RETURNING *
    `, [nombre, correo, edad]);

const update = (id, { nombre, correo, edad }) =>
    pool.query(`
        UPDATE estudiantes
        SET nombre = $1,
            correo = $2,
            edad = $3
        WHERE estudiante_id = $4
        RETURNING *
    `, [nombre, correo, edad, id]);

const remove = (id) =>
    pool.query(`
        DELETE FROM estudiantes
        WHERE estudiante_id = $1
        RETURNING *
    `, [id]);

module.exports = {
    getAll,
    getById,
    create,
    update,
    remove
};