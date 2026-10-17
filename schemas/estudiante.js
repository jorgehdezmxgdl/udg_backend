const { z } = require("zod");

// Parámetro :id de la URL (llega como texto, se convierte a número)
const idParamSchema = z.object({
    id: z.coerce
        .number({ error: "El id debe ser numérico" })
        .int("El id debe ser un número entero")
        .positive("El id debe ser mayor a 0")
});

// Cuerpo para crear / reemplazar (POST y PUT) un estudiante
// z.object descarta campos no definidos (p. ej. estudiante_id) para que no se puedan sobrescribir
const estudianteSchema = z.object({
    nombre: z
        .string({ error: (iss) => iss.input === undefined ? "El nombre es obligatorio" : "El nombre debe ser texto" })
        .trim()
        .min(2, "El nombre debe tener al menos 2 caracteres")
        .max(100, "El nombre no puede exceder 100 caracteres"),

    correo: z
        .email({ error: (iss) => iss.input === undefined ? "El correo es obligatorio" : "El correo no es válido" })
        .max(100, "El correo no puede exceder 100 caracteres")
        .transform((c) => c.toLowerCase()),

    edad: z
        .number({ error: "La edad debe ser un número" })
        .int("La edad debe ser un número entero")
        .min(15, "La edad mínima es 15")
        .max(100, "La edad máxima es 100")
        .nullable()
        .optional()
});

module.exports = {
    idParamSchema,
    estudianteSchema
};
