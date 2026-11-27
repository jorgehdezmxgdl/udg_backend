const query = require("../queries/estudiante");

const getAll = async (req, res) => {
    try {
        const result = await query.getAll();
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const getById = async (req, res) => {
    try {
        const result = await query.getById(req.params.id);

        if (result.rows.length === 0)
            return res.status(404).json({ error: "No encontrado" });

        res.json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const create = async (req, res) => {
    try {
        const result = await query.create(req.body);
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const update = async (req, res) => {
    try {
        const result =
            await query.update(req.params.id, req.body);

        if (result.rows.length === 0)
            return res.status(404).json({ error: "No encontrado" });

        res.json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const remove = async (req, res) => {
    try {
        const result =
            await query.remove(req.params.id);

        if (result.rows.length === 0)
            return res.status(404).json({ error: "No encontrado" });

        res.json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

module.exports = {
    getAll,
    getById,
    create,
    update,
    remove
};