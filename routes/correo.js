const express = require("express");
const router = express.Router();

const { enviar } = require("../controllers/correo");

router.post("/enviar_correo", enviar);

module.exports = router;