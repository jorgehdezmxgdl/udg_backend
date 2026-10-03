const express = require("express");
const env     = require("dotenv");
const cors    = require("cors");
const sequelize           = require("./db/conexionSeq");
const estudianteRoutes    = require("./routes/estudiante");
const estudianteSeqRoutes = require("./routes/estudianteSeq");

env.config();
const app = express();

app.use(cors());
app.use(express.json());

app.use("/api/v1/estudiantes", estudianteRoutes);

app.use("/api/v2/estudiantes", estudianteSeqRoutes);

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
