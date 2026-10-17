const express = require("express");
const controller =  require("../controllers/estudiante");
const validar = require("../middlewares/validar");

const { idParamSchema, estudianteSchema } = require("../schemas/estudiante");

const router = express.Router();

router.get("/", controller.getAll);
router.get("/:id", validar({ params: idParamSchema }), controller.getById);
router.post("/", validar({ body: estudianteSchema }), controller.create);
router.put("/:id", validar({ params: idParamSchema, body: estudianteSchema }), controller.update);
router.delete("/:id", validar({ params: idParamSchema }), controller.remove);

module.exports = router;