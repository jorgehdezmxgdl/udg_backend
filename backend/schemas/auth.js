const { z } = require("zod");

const loginSchema = z.object({
    usuario: z
        .string({ error: (iss) => iss.input === undefined ? "El usuario es obligatorio" : "El usuario debe ser texto" })
        .trim()
        .min(1, "El usuario es obligatorio")
        .max(50, "El usuario no puede exceder 50 caracteres"),

    password: z
        .string({ error: (iss) => iss.input === undefined ? "La contraseña es obligatoria" : "La contraseña debe ser texto" })
        .min(1, "La contraseña es obligatoria")
        .max(128, "La contraseña no puede exceder 128 caracteres")
});

module.exports = { loginSchema };
