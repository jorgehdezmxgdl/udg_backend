function validate(schemas) {
  return (req, res, next) => {
    req.validated = {};
    const errores = [];

    for (const origen of ['params', 'query', 'body']) {
      const schema = schemas[origen];
      if (!schema) continue;

      const result = schema.safeParse(req[origen] ?? {});
      if (result.success) {
        req.validated[origen] = result.data;
      } else {
        for (const issue of result.error.issues) {
          const campo = issue.path.join('.') || origen;

          if (!errores.some((e) => e.campo === campo)) {
            errores.push({ campo, mensaje: issue.message });
          }
        }
      }
    }

    if (errores.length) {
      return res.status(422).json({
        ok: false,
        mensaje: errores[0].mensaje,
        errores,
      });
    }
    next();
  };
}

module.exports = validate;
