class HttpError extends Error {
  constructor(status, mensaje, campo = null) {
    super(mensaje);
    this.status = status;
    this.campo = campo;
  }
}

module.exports = HttpError;
