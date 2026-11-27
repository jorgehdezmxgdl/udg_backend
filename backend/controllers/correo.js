
const { enviarCorreo } = require("../services/correo");

async function enviar(req, res) {
  try {
    const { para, asunto, mensaje } = req.body;

    if (!para || !asunto || !mensaje) {
      return res.status(400).json({
        error: "Debes proporcionar para, asunto y mensaje",
      });
    }

    const resultado = await enviarCorreo({
      para,
      asunto,
      mensaje,
    });

    res.status(200).json({
      mensaje: "Correo enviado correctamente",
      messageId: resultado.messageId,
    });
  } catch (error) {
    console.error("Error al enviar correo:", error.message);

    res.status(500).json({
      error: "No fue posible enviar el correo",
    });
  }
}

module.exports = { enviar };
