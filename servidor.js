const express = require("express");
const env     = require("dotenv");
const cors    = require("cors");
const sequelize           = require("./db/conexionSeq");
const estudianteRoutes    = require("./routes/estudiante");
const estudianteSeqRoutes = require("./routes/estudianteSeq");
const authRoutes          = require("./routes/auth");
const verificarToken      = require("./middlewares/auth");

env.config();

if (!process.env.JWT_SECRET) {
  console.error("Falta JWT_SECRET en el archivo .env");
  process.exit(1);
}
const app = express();

app.use(cors());
app.use(express.json());

// Ruta pública para obtener el token
app.use("/api/auth", authRoutes);

app.use("/api/v1/estudiantes", verificarToken, estudianteRoutes);

app.use("/api/v2/estudiantes", verificarToken, estudianteSeqRoutes);

sequelize
  .authenticate()
  .then(() => {
    console.log("PostgreSQL conectado");
    app.listen(process.env.PORT, () => {
      console.log(`http://localhost:${process.env.PORT}`);
    });
  })
  .catch((error) => {
    console.error("Error de conexión:", error.message);
  });
