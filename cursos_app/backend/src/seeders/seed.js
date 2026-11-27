const { sequelize, Usuario, Curso, Inscripcion } = require('../models');

const cursos = [
  { titulo: 'Fundamentos de Dart', precio: 899, instructor: 'Mtra. Ana López', duracionHoras: 20, nivel: 'Básico', categoria: 'Programación', icono: 'code', descripcion: 'Variables, tipos, funciones, clases y null safety.' },
  { titulo: 'Flutter desde cero', precio: 1499, instructor: 'Ing. Carlos Ruiz', duracionHoras: 40, nivel: 'Intermedio', categoria: 'Móvil', icono: 'phone', descripcion: 'Widgets, layouts, navegación y consumo de APIs REST.' },
  { titulo: 'PostgreSQL para desarrolladores', precio: 1299, instructor: 'Dr. Luis Pérez', duracionHoras: 30, nivel: 'Intermedio', categoria: 'Datos', icono: 'storage', descripcion: 'Modelado, SQL, índices, vistas y funciones.' },
  { titulo: 'APIs REST con Node.js', precio: 1199, instructor: 'Ing. Sofía Díaz', duracionHoras: 25, nivel: 'Intermedio', categoria: 'Backend', icono: 'api', descripcion: 'Express, Sequelize, Zod, JWT y buenas prácticas.' },
  { titulo: 'Diseño UI/UX', precio: 799, instructor: 'Lic. Marta Gil', duracionHoras: 15, nivel: 'Básico', categoria: 'Diseño', icono: 'palette', descripcion: 'Color, tipografía, prototipos y usabilidad.' },
  { titulo: 'Visualización de datos', precio: 1399, instructor: 'Dr. Jorge Hernández', duracionHoras: 30, nivel: 'Avanzado', categoria: 'Datos', icono: 'chart', descripcion: 'Dashboards, gráficas y storytelling con datos.' },
  { titulo: 'Seguridad en aplicaciones web', precio: 1299, instructor: 'Ing. Pablo Mora', duracionHoras: 20, nivel: 'Avanzado', categoria: 'Seguridad', icono: 'security', descripcion: 'OWASP Top 10, autenticación, hashing y CORS.' },
  { titulo: 'Git y trabajo colaborativo', precio: 499, instructor: 'Mtro. Raúl Vega', duracionHoras: 10, nivel: 'Básico', categoria: 'Herramientas', icono: 'git', descripcion: 'Ramas, merge, pull requests y flujo de trabajo.' },
];

async function seed() {
  await sequelize.sync({ force: true });
  console.log('Tablas recreadas');

  const creados = await Curso.bulkCreate(cursos);
  const porTitulo = Object.fromEntries(creados.map((c) => [c.titulo, c.id]));

  const hash = await Usuario.hashPassword('123456');
  const [mariana, jorge] = await Usuario.bulkCreate([
    { clave: 'mramirez', nombre: 'Mariana Ramírez Soto', correo: 'mariana.ramirez@example.com', passwordHash: hash },
    { clave: 'jorge', nombre: 'Jorge Hernández Andrade', correo: 'jorge.hernandez@example.com', passwordHash: hash },
  ]);

  await Inscripcion.bulkCreate([
    { usuarioId: mariana.id, cursoId: porTitulo['Fundamentos de Dart'], progreso: 100, calificacion: 95, fechaInscripcion: '2026-08-10' },
    { usuarioId: mariana.id, cursoId: porTitulo['Flutter desde cero'], progreso: 65, fechaInscripcion: '2026-09-15' },
    { usuarioId: mariana.id, cursoId: porTitulo['APIs REST con Node.js'], progreso: 20, fechaInscripcion: '2026-11-02' },
    { usuarioId: mariana.id, cursoId: porTitulo['Git y trabajo colaborativo'], progreso: 100, calificacion: 88, fechaInscripcion: '2026-07-01' },
    { usuarioId: jorge.id, cursoId: porTitulo['PostgreSQL para desarrolladores'], progreso: 100, calificacion: 100, fechaInscripcion: '2026-06-01' },
    { usuarioId: jorge.id, cursoId: porTitulo['Visualización de datos'], progreso: 80, fechaInscripcion: '2026-10-01' },
  ]);

  console.log(`${creados.length} cursos, 2 usuarios (mramirez / jorge, contraseña: 123456) e inscripciones de ejemplo`);
}

seed()
  .catch((err) => {
    console.error('Error en seed:', err);
    process.exitCode = 1;
  })
  .finally(() => sequelize.close());
