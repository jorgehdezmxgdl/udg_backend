const { Router } = require('express');
const { EMPRESA, PAISES, METODOS_PAGO, BANCOS, PAGO } = require('../config/catalogos');

const router = Router();

router.get('/', (_req, res) => {
  res.json({
    ok: true,
    empresa: EMPRESA,
    paises: PAISES,
    metodosPago: METODOS_PAGO,
    bancos: BANCOS,
    pago: {
      moneda: PAGO.moneda,
      tipoCambioBtcMxn: PAGO.tipoCambioBtcMxn,
      clabeDestino: PAGO.clabeDestino,
      walletDestino: PAGO.walletDestino,
    },
  });
});

module.exports = router;
