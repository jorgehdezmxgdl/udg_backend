const express = require("express");
const controller =  require("../controllers/estudianteSeq");
const validar = require("../middlewares/validar");

const { idParamSchema, estudianteSchema } = require("../schemas/estudiante");

const router = express.Router();

router.get("/", controller.listar);
router.get("/:id", validar({ params: idParamSchema }), controller.obtener);
router.post("/", validar({ body: estudianteSchema }), controller.crear);
router.put("/:id", validar({ params: idParamSchema, body: estudianteSchema }), controller.actualizar);
router.delete("/:id", validar({ params: idParamSchema }), controller.eliminar);
router.get("/:id/cursos", validar({ params: idParamSchema }), controller.cursosDelEstudiante);

module.exports = router;

