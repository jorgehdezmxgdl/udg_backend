const { EMPRESA } = require('../config/catalogos');

const esc = (v) =>
  String(v ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');

const dinero = (n) =>
  `$${Number(n).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} MXN`;

const METODOS = {
  tarjeta: 'Tarjeta de crédito / débito',
  transferencia: 'Transferencia SPEI',
  bitcoin: 'Bitcoin',
};

function confirmacionTemplate({ nombre, paisNombre, curso, pago, fecha }) {
  const fechaTxt = fecha.toLocaleString('es-MX', {
    dateStyle: 'long',
    timeStyle: 'short',
    timeZone: 'America/Mexico_City',
  });

  const filas = [
    ['Folio', pago.folio],
    ['Autorización', pago.autorizacion],
    ['Fecha', fechaTxt],
    ['Forma de pago', METODOS[pago.metodo]],
    ['Referencia', pago.referencia],
    ['Monto', dinero(pago.monto) + (pago.montoBtc ? ` (≈ ${pago.montoBtc} BTC)` : '')],
    ['Alumno', nombre],
    ['País', paisNombre],
  ];

  const asunto = `✅ Inscripción confirmada: ${curso.titulo} · Folio ${pago.folio}`;

  const html = `<!DOCTYPE html>
<html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width"></head>
<body style="margin:0;background:#F8F7F2;font-family:'Plus Jakarta Sans',Segoe UI,Arial,sans-serif;color:#1F3F41">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="padding:24px 12px">
    <tr><td align="center">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:560px;background:#fff;border-radius:20px;overflow:hidden;border:1px solid #DCE3DE">
        <tr><td style="background:linear-gradient(135deg,#C4E0EE,#E8E4D6);background-color:#C4E0EE;padding:28px 28px 22px">
          <div style="font-size:26px;font-weight:800">🎓 ${esc(EMPRESA.nombre)}</div>
          <div style="font-size:14px;opacity:.8">${esc(EMPRESA.slogan)}</div>
        </td></tr>
        <tr><td style="padding:28px">
          <h1 style="margin:0 0 8px;font-size:20px">¡Hola, ${esc(nombre)}!</h1>
          <p style="margin:0 0 18px;line-height:1.5">Recibimos tu pago y tu inscripción quedó <b>confirmada</b> en el curso:</p>
          <div style="background:#E7F2F7;border-radius:14px;padding:16px 18px;margin-bottom:20px">
            <div style="font-size:18px;font-weight:800">${esc(curso.titulo)}</div>
            <div style="font-size:13px;color:#5B7270;margin-top:4px">${esc(curso.instructor)} · ${esc(curso.duracionHoras)} h · ${esc(curso.nivel)}</div>
          </div>
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="font-size:14px;border-collapse:collapse">
            ${filas
              .map(
                ([k, v]) => `<tr>
              <td style="padding:8px 0;color:#5B7270;border-bottom:1px solid #EEF1EE">${esc(k)}</td>
              <td style="padding:8px 0;text-align:right;font-weight:700;border-bottom:1px solid #EEF1EE">${esc(v)}</td></tr>`
              )
              .join('')}
          </table>
          <p style="margin:20px 0 0;font-size:13px;color:#5B7270;line-height:1.5">
            Ya puedes ver el curso en tu panel de ${esc(EMPRESA.nombre)}. ¿Dudas? Escríbenos a ${esc(EMPRESA.correoSoporte)}.
          </p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body></html>`;

  const texto = [
    `${EMPRESA.nombre} — ${EMPRESA.slogan}`,
    '',
    `¡Hola, ${nombre}!`,
    `Tu inscripción al curso "${curso.titulo}" quedó confirmada.`,
    '',
    ...filas.map(([k, v]) => `${k}: ${v}`),
    '',
    `Soporte: ${EMPRESA.correoSoporte}`,
  ].join('\n');

  return { asunto, html, texto };
}

module.exports = { confirmacionTemplate };
