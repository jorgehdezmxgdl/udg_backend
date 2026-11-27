function luhnValido(numero) {
  if (!/^\d{13,19}$/.test(numero)) return false;
  let suma = 0;
  let doble = false;
  for (let i = numero.length - 1; i >= 0; i--) {
    let d = Number(numero[i]);
    if (doble) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    suma += d;
    doble = !doble;
  }
  return suma % 10 === 0;
}

function clabeValida(clabe) {
  if (!/^\d{18}$/.test(clabe)) return false;
  const pesos = [3, 7, 1];
  let suma = 0;
  for (let i = 0; i < 17; i++) suma += (Number(clabe[i]) * pesos[i % 3]) % 10;
  return (10 - (suma % 10)) % 10 === Number(clabe[17]);
}

function vencimientoVigente(mmaa, hoy = new Date()) {
  const m = /^(0[1-9]|1[0-2])\/(\d{2})$/.exec(mmaa);
  if (!m) return false;
  const mes = Number(m[1]);
  const anio = 2000 + Number(m[2]);
  const finDeMes = new Date(anio, mes, 0, 23, 59, 59);
  return finDeMes >= hoy;
}

function marcaTarjeta(numero) {
  if (/^4/.test(numero)) return 'Visa';
  if (/^(5[1-5]|2[2-7])/.test(numero)) return 'Mastercard';
  if (/^3[47]/.test(numero)) return 'American Express';
  return 'Tarjeta';
}

const esAmex = (numero) => /^3[47]/.test(numero);

const REGEX_NOMBRE = /^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ' -]+$/;

const REGEX_WALLET_BTC = /^(bc1[a-z0-9]{25,59}|[13][a-km-zA-HJ-NP-Z1-9]{25,34})$/;

module.exports = {
  luhnValido,
  clabeValida,
  vencimientoVigente,
  marcaTarjeta,
  esAmex,
  REGEX_NOMBRE,
  REGEX_WALLET_BTC,
};
