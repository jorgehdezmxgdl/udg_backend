const env = require('./config/env');
const app = require('./app');
const { sequelize } = require('./models');

async function iniciar() {
  try {
    await sequelize.authenticate();
    console.log('Conectado a PostgreSQL');

    await sequelize.sync();

    app.listen(env.PORT, '0.0.0.0', () => {
      console.log(`API de CurMex en http://localhost:${env.PORT}/api`);
    });
  } catch (err) {
    console.error('No se pudo iniciar la API:', err.message);
    process.exit(1);
  }
}

iniciar();
