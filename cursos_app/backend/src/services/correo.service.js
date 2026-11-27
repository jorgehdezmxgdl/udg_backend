const fs = require('fs/promises');
const path = require('path');
const nodemailer = require('nodemailer');
const env = require('../config/env');

const CARPETA_CORREOS = path.join(__dirname, '..', '..', 'correos');
const modo = env.SMTP_HOST ? 'smtp' : 'archivo';

const transporte =
  modo === 'smtp'
    ? nodemailer.createTransport({
        host: env.SMTP_HOST,
        port: env.SMTP_PORT,
        secure: env.SMTP_SECURE,
        auth: env.SMTP_USER ? { user: env.SMTP_USER, pass: env.SMTP_PASS } : undefined,
      })
    : nodemailer.createTransport({ streamTransport: true, buffer: true, newline: 'unix' });

async function enviarCorreo({ para, asunto, html, texto, nombreArchivo = 'correo' }) {
  try {
    const info = await transporte.sendMail({
      from: env.MAIL_FROM,
      to: para,
      subject: asunto,
      html,
      text: texto,
    });

    if (modo === 'archivo') {
      await fs.mkdir(CARPETA_CORREOS, { recursive: true });
      const archivo = path.join(CARPETA_CORREOS, `${Date.now()}-${nombreArchivo}.eml`);
      await fs.writeFile(archivo, info.message);
      console.log(`Correo (modo archivo) para ${para} guardado en ${archivo}`);
      return {
        enviado: false,
        modo,
        destinatario: para,
        mensaje: 'Modo de prueba: el correo se generó pero no se envió porque el servidor no tiene SMTP configurado.',
      };
    }

    console.log(`Correo enviado a ${para} (${info.messageId})`);
    return { enviado: true, modo, destinatario: para, mensaje: `Te enviamos la confirmación a ${para}` };
  } catch (err) {
    console.error('Error al enviar correo:', err.message);
    return {
      enviado: false,
      modo,
      destinatario: para,
      mensaje: 'No pudimos enviar el correo de confirmación, pero tu inscripción sí quedó registrada.',
    };
  }
}

module.exports = { enviarCorreo, modoCorreo: modo };
