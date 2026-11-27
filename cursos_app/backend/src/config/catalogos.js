const EMPRESA = {
  nombre: 'CurMex',
  slogan: 'Tus cursos al alcance de tu mano',
  correoSoporte: 'soporte@curmex.mx',
};

const PAISES = [
  { codigo: 'MX', nombre: 'México' },
  { codigo: 'AR', nombre: 'Argentina' },
  { codigo: 'BO', nombre: 'Bolivia' },
  { codigo: 'CL', nombre: 'Chile' },
  { codigo: 'CO', nombre: 'Colombia' },
  { codigo: 'CR', nombre: 'Costa Rica' },
  { codigo: 'CU', nombre: 'Cuba' },
  { codigo: 'EC', nombre: 'Ecuador' },
  { codigo: 'SV', nombre: 'El Salvador' },
  { codigo: 'ES', nombre: 'España' },
  { codigo: 'US', nombre: 'Estados Unidos' },
  { codigo: 'GT', nombre: 'Guatemala' },
  { codigo: 'HN', nombre: 'Honduras' },
  { codigo: 'NI', nombre: 'Nicaragua' },
  { codigo: 'PA', nombre: 'Panamá' },
  { codigo: 'PY', nombre: 'Paraguay' },
  { codigo: 'PE', nombre: 'Perú' },
  { codigo: 'PR', nombre: 'Puerto Rico' },
  { codigo: 'DO', nombre: 'República Dominicana' },
  { codigo: 'UY', nombre: 'Uruguay' },
  { codigo: 'VE', nombre: 'Venezuela' },
  { codigo: 'CA', nombre: 'Canadá' },
];

const METODOS_PAGO = [
  { codigo: 'transferencia', nombre: 'Transferencia SPEI' },
  { codigo: 'tarjeta', nombre: 'Tarjeta de crédito o débito' },
  { codigo: 'bitcoin', nombre: 'Bitcoin' },
];

const BANCOS = [
  { codigo: 'BBVA', nombre: 'BBVA México' },
  { codigo: 'BANORTE', nombre: 'Banorte' },
  { codigo: 'SANTANDER', nombre: 'Santander' },
  { codigo: 'BANAMEX', nombre: 'Banamex' },
  { codigo: 'HSBC', nombre: 'HSBC' },
  { codigo: 'SCOTIABANK', nombre: 'Scotiabank' },
  { codigo: 'AZTECA', nombre: 'Banco Azteca' },
  { codigo: 'BANCOPPEL', nombre: 'BanCoppel' },
  { codigo: 'INBURSA', nombre: 'Inbursa' },
  { codigo: 'NU', nombre: 'Nu México' },
  { codigo: 'OTRO', nombre: 'Otro banco' },
];

const PAGO = {
  moneda: 'MXN',
  tipoCambioBtcMxn: 1850000,
  clabeDestino: '012 180 00123456789 4',
  walletDestino: 'bc1qcurmex0demo0pago0ficticio0x7k9a2',

  tarjetasRechazo: {
    '4000000000000002': 'Tarjeta rechazada por el banco emisor',
    '4000000000009995': 'Fondos insuficientes',
  },
};

const codigos = (lista) => lista.map((x) => x.codigo);
const nombreDe = (lista, codigo) => lista.find((x) => x.codigo === codigo)?.nombre ?? codigo;

module.exports = { EMPRESA, PAISES, METODOS_PAGO, BANCOS, PAGO, codigos, nombreDe };
