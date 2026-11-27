const express = require("express");

const controller = require("../controllers/auth");
const validar = require("../middlewares/validar");
const { loginSchema } = require("../schemas/auth");

const router = express.Router();

router.post("/login", validar({ body: loginSchema }), controller.login);

module.exports = router;
