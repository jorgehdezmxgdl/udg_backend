const { z } = require('zod');
const { PAISES, BANCOS, codigos } = require('../config/catalogos');
const {
  luhnValido,
  clabeValida,
  vencimientoVigente,
  esAmex,
  REGEX_NOMBRE,
  REGEX_WALLET_BTC,
} = require('../utils/validadores');

const texto = (campo) =>
  z.string({ error: `${campo} es obligatorio` }).trim().min(1, `${campo} es obligatorio`);

const sinEspacios = (v) => (typeof v === 'string' ? v.replace(/[\s-]/g, '') : v);

const nombre = texto('El nombre')
  .min(5, 'El nombre es demasiado corto')
  .max(100, 'El nombre no puede exceder 100 caracteres')
  .regex(REGEX_NOMBRE, 'El nombre solo puede contener letras y espacios')
  .refine((v) => v.split(/\s+/).length >= 2, 'Escribe tu nombre y al menos un apellido')
  .transform((v) => v.replace(/\s+/g, ' '));

const correo = texto('El correo')
  .toLowerCase()
  .max(150, 'El correo no puede exceder 150 caracteres')
  .pipe(z.email({ error: 'Correo electrónico inválido (ej. nombre@dominio.com)' }));

const pais = z.enum(codigos(PAISES), { error: 'Selecciona un país de la lista' });

const pagoTarjeta = z
  .object({
    metodo: z.literal('tarjeta'),
    titular: texto('El titular')
      .min(3, 'Escribe el nombre como aparece en la tarjeta')
      .max(60, 'El titular no puede exceder 60 caracteres')
      .regex(REGEX_NOMBRE, 'El titular solo puede contener letras y espacios'),
    numero: z.preprocess(
      sinEspacios,
      z
        .string({ error: 'El número de tarjeta es obligatorio' })
        .min(1, 'El número de tarjeta es obligatorio')
        .regex(/^\d+$/, 'El número de tarjeta solo admite dígitos')
        .min(13, 'El número de tarjeta está incompleto')
        .max(19, 'El número de tarjeta tiene demasiados dígitos')
        .refine(luhnValido, 'Número de tarjeta inválido, revisa los dígitos')
    ),
    vencimiento: texto('El vencimiento')
      .regex(/^(0[1-9]|1[0-2])\/\d{2}$/, 'Usa el formato MM/AA')
      .refine((v) => vencimientoVigente(v), 'La tarjeta está vencida'),
    cvv: z
      .string({ error: 'El CVV es obligatorio' })
      .trim()
      .min(1, 'El CVV es obligatorio')
      .regex(/^\d{3,4}$/, 'El CVV debe tener 3 o 4 dígitos'),
  })
  .superRefine((p, ctx) => {
    if (typeof p.numero !== 'string' || typeof p.cvv !== 'string') return;
    const largo = esAmex(p.numero) ? 4 : 3;
    if (/^\d{3,4}$/.test(p.cvv) && p.cvv.length !== largo) {
      ctx.addIssue({
        code: 'custom',
        path: ['cvv'],
        message: `El CVV de esta tarjeta debe tener ${largo} dígitos`,
      });
    }
  });

const pagoTransferencia = z.object({
  metodo: z.literal('transferencia'),
  banco: z.enum(codigos(BANCOS), { error: 'Selecciona tu banco' }),
  clabe: z.preprocess(
    sinEspacios,
    z
      .string({ error: 'La CLABE es obligatoria' })
      .min(1, 'La CLABE es obligatoria')
      .regex(/^\d+$/, 'La CLABE solo admite dígitos')
      .length(18, 'La CLABE debe tener exactamente 18 dígitos')
      .refine(clabeValida, 'CLABE inválida: el dígito verificador no coincide')
  ),
});

const pagoBitcoin = z.object({
  metodo: z.literal('bitcoin'),
  wallet: texto('La dirección de tu wallet')
    .max(90, 'La dirección es demasiado larga')
    .regex(REGEX_WALLET_BTC, 'Dirección Bitcoin inválida (debe iniciar con bc1, 1 o 3)'),
});

const pago = z.discriminatedUnion('metodo', [pagoTarjeta, pagoTransferencia, pagoBitcoin], {
  error: 'Selecciona una forma de pago: transferencia, tarjeta o bitcoin',
});

const inscripcionSchema = z.object({
  cursoId: z.coerce
    .number({ error: 'El curso es obligatorio' })
    .int('Curso inválido')
    .positive('Curso inválido'),
  nombre,
  correo,
  pais,
  pago,
  aceptaTerminos: z.literal(true, { error: 'Debes aceptar los términos y condiciones' }),
});

module.exports = { inscripcionSchema };
