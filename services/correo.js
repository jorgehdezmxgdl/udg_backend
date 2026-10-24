
const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.GMAIL_USER,
    pass: process.env.GMAIL_APP_PASSWORD,
  },
});

async function enviarCorreo({ para, asunto, mensaje }) {
  return transporter.sendMail({
    from: `"Jorge Fausto Hernandez" <${process.env.GMAIL_USER}>`,
    to: para,
    subject: asunto,
    text: mensaje,
  });
}

module.exports = { enviarCorreo };
