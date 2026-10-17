const crypto = require("crypto");
const jwt = require("jsonwebtoken");


const sonIguales = (a, b) => {
    const ha = crypto.createHash("sha256").update(String(a)).digest();
    const hb = crypto.createHash("sha256").update(String(b)).digest();
    return crypto.timingSafeEqual(ha, hb);
};

const login = (req, res) => {
    const { usuario, password } = req.body;

    const usuarioOk = sonIguales(usuario, process.env.API_USER ?? "");
    const passwordOk = sonIguales(password, process.env.API_PASSWORD ?? "");

    if (!usuarioOk || !passwordOk)
        return res.status(401).json({ error: "Credenciales inválidas" });

    const expiraEn = process.env.JWT_EXPIRES_IN || "1h";

    const token = jwt.sign(
        { sub: usuario },
        process.env.JWT_SECRET,
        { algorithm: "HS256", expiresIn: expiraEn }
    );

    res.json({ token, tipo: "Bearer", expiraEn });
};

module.exports = { login };
