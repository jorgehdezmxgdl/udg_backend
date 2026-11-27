const express = require("express");

const controller = require("../controllers/consultasGraph");

const router = express.Router();

router.get("/ping",   controller.habilitado);
router.get("/select", controller.selectGraph);
router.post("/courses", controller.insertarCurso);
router.patch("/courses/:courseId", controller.actualizarCurso);
router.delete("/courses/:courseId", controller.eliminarCurso);

module.exports = router;