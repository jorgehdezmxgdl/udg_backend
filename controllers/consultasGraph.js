
const { consultarGraphQL } = require("../db/graphSubase");

const selectGraph = async (req, res) => {
  try {
    const query = `
             query ObtenerCursos {
                courseCollection(first: 10) {
                    edges {
                        node {
                            course_id
                            code
                            status
                            duration_hours
                            created_at
                        }
                    }
                }
            }
        `;
    const data = await consultarGraphQL(query, { limite: 2 });
    res.json(data.courseCollection.edges.map((edge) => edge.node));
  } catch (error) {
    console.error("Error en selectGraph:", error);

    res.status(error.status || 500).json({
      error: error.message,
    });
  }
};

const habilitado = (req, res) => {
  res.json({ estado: "Express está funcionando" });
};

async function insertarCurso(req, res) {
  try {
    const query = `
      mutation InsertarCurso($curso: [courseInsertInput!]!) {
        insertIntocourseCollection(objects: $curso) {
          records {
            course_id
            code
            duration_hours
            status
          }
        }
      }
    `;

    const data = await consultarGraphQL(query, {
      curso: [{
        organization_id: req.body.organization_id,
        course_type_id: req.body.course_type_id,
        code: req.body.code,
        status: req.body.status || "DRAFT",
        duration_hours: req.body.duration_hours ?? null,
      }],
    });

    res.status(201).json(data.insertIntocourseCollection);
  } catch (error) {
    console.error("Error insertando curso:", error);
    res.status(error.status || 500).json({
      error: error.message,
    });
  }
}

async function actualizarCurso(req, res) {
  try {
    const query = `
      mutation ActualizarCurso(
        $filtro: CourseFilter!
        $cambios: CourseUpdateInput!
      ) {
        updateCourseCollection(
          filter: $filtro
          set: $cambios
        ) {
          records {
            courseId
            code
            status
            durationHours
          }
        }
      }
    `;

    const { courseId } = req.params;
    const { code, status, durationHours } = req.body;

    const cambios = {};
    if (code !== undefined) cambios.code = code;
    if (status !== undefined) cambios.status = status;
    if (durationHours !== undefined) {
      cambios.durationHours = durationHours;
    }

    if (Object.keys(cambios).length === 0) {
      return res.status(400).json({
        error: "Debes enviar al menos un campo para actualizar",
      });
    }

    const data = await consultarGraphQL(query, {
      filtro: { courseId: { eq: courseId } },
      cambios,
    });

    res.json(data);
  } catch (error) {
    console.error("Error actualizando curso:", error);
    res.status(error.status || 500).json({
      error: error.message,
    });
  }
}

async function eliminarCurso(req, res) {
  try {
    const query = `
      mutation EliminarCurso($filtro: CourseFilter!) {
        deleteFromCourseCollection(filter: $filtro) {
          records {
            courseId
            code
          }
        }
      }
    `;

    const data = await consultarGraphQL(query, {
      filtro: {
        courseId: { eq: req.params.courseId },
      },
    });

    res.json(data);
  } catch (error) {
    console.error("Error eliminando curso:", error);
    res.status(error.status || 500).json({
      error: error.message,
    });
  }
}

module.exports = {
  selectGraph,
  habilitado,
  insertarCurso,
  actualizarCurso,
  eliminarCurso,
};



