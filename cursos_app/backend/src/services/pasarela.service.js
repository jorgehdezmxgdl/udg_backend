const crypto = require('crypto');
const { PAGO, BANCOS, nombreDe } = require('../config/catalogos');
const { marcaTarjeta } = require('../utils/validadores');

const esperar = (ms) => new Promise((r) => setTimeout(r, ms));

function generarFolio(fecha = new Date()) {
  const ymd = fecha.toLocaleDateString('en-CA', { timeZone: 'America/Mexico_City' }).replace(/-/g, '');
  return `CMX-${ymd}-${crypto.randomBytes(3).toString('hex').toUpperCase()}`;
}

function referenciaEnmascarada(pago) {
  switch (pago.metodo) {
    case 'tarjeta':
      return `${marcaTarjeta(pago.numero)} •••• ${pago.numero.slice(-4)}`;
    case 'transferencia':
      return `${nombreDe(BANCOS, pago.banco)} · CLABE •••• ${pago.clabe.slice(-4)}`;
    case 'bitcoin':
      return `BTC ${pago.wallet.slice(0, 6)}…${pago.wallet.slice(-4)}`;
    default:
      return '—';
  }
}

async function cobrar({ monto, pago }) {
  await esperar(600);

  if (pago.metodo === 'tarjeta' && PAGO.tarjetasRechazo[pago.numero]) {
    return {
      aprobado: false,
      motivo: `${PAGO.tarjetasRechazo[pago.numero]}. Usa otra tarjeta.`,
      campo: 'pago.numero',
    };
  }

  return {
    aprobado: true,
    folio: generarFolio(),
    autorizacion: String(crypto.randomInt(100000, 999999)),
    referencia: referenciaEnmascarada(pago),
    moneda: PAGO.moneda,
    montoBtc:
      pago.metodo === 'bitcoin' ? Number((monto / PAGO.tipoCambioBtcMxn).toFixed(8)) : null,
  };
}

module.exports = { cobrar };
