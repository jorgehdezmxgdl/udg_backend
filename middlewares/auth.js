const jwt = require("jsonwebtoken");

// Verifica el encabezado "Authorization: Bearer <token>"
const verificarToken = (req, res, next) => {
    const header = req.headers.authorization || "";
    const [tipo, token] = header.split(" ");

    if (tipo !== "Bearer" || !token)
        return res.status(401).json({ error: "Token requerido" });

    try {
        // Se fija el algoritmo para evitar ataques de tipo "alg: none"
        req.usuario = jwt.verify(token, process.env.JWT_SECRET, {
            algorithms: ["HS256"]
        });
        next();
    } catch (error) {
        const mensaje = error.name === "TokenExpiredError"
            ? "Token expirado"
            : "Token inválido";
        return res.status(401).json({ error: mensaje });
    }
};

module.exports = verificarToken;
