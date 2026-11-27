// Middleware genérico de validación con Zod.
const validar = (schemas) => (req, res, next) => {
    const errores = [];

    for (const parte of ["params", "body"]) {
        const schema = schemas[parte];
        if (!schema) continue;

        const resultado = schema.safeParse(req[parte] ?? {});

        if (!resultado.success) {
            for (const issue of resultado.error.issues) {
                errores.push({
                    campo: issue.path.join(".") || parte,
                    mensaje: issue.message
                });
            }
        } else if (parte === "body") {
            req.body = resultado.data;
        } else {
            Object.assign(req.params, resultado.data);
        }
    }

    if (errores.length > 0)
        return res.status(400).json({ error: "Datos inválidos", detalles: errores });

    next();
};

module.exports = validar;
