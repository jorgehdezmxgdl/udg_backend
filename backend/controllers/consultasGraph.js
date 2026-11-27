
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
            organization_id
            course_type_id
            code
            duration_hours
            status
          }
        }
      }
    `;

    const entrada = Array.isArray(req.body.curso)
      ? req.body.curso[0]
      : req.body.curso || req.body;

    if (!entrada || !entrada.organization_id) {
      return res.status(400).json({
        error: "Falta organization_id en el cuerpo de la petición",
        recibido: entrada ?? null
      });
    }

    if (entrada.course_type_id == null || !entrada.code) {
      return res.status(400).json({
        error: "course_type_id y code son obligatorios"
      });
    }

    const curso = {
      organization_id: entrada.organization_id,
      course_type_id: entrada.course_type_id,
      code: entrada.code,
      status: entrada.status || "DRAFT",
      duration_hours: entrada.duration_hours ?? null,
      certificate_enabled: entrada.certificate_enabled ?? true
    };

    const data = await consultarGraphQL(query, {
      curso: [curso]
    });

    res.status(201).json(data.insertIntocourseCollection);
  } catch (error) {
    console.error("Error insertando curso:", error);
    res.status(error.status || 500).json({
      error: error.message
    });
  }
}

async function actualizarCurso(req, res) {
  try {
    const query = `
       mutation ActualizarCurso(
          $filtro: courseFilter!
          $cambios: courseUpdateInput!
        ) {
          updatecourseCollection(
            filter: $filtro
            set: $cambios
          ) {
            records {
              course_id
              code
              duration_hours
              status
            }
          }
        }
      `;
    const courseId = req.params.courseId;
    const entrada = req.body;

    if (!courseId) {
      return res.status(400).json({
        error: "Debes proporcionar el identificador del curso"
      });
    }

    const cambios = {};

    if (entrada.code !== undefined) {
      cambios.code = entrada.code;
    }

    if (entrada.status !== undefined) {
      cambios.status = entrada.status;
    }

    if (entrada.duration_hours !== undefined) {
      cambios.duration_hours =
        entrada.duration_hours === null
          ? null
          : String(entrada.duration_hours);
    }

    if (entrada.course_type_id !== undefined) {
      cambios.course_type_id = entrada.course_type_id;
    }

    if (entrada.organization_id !== undefined) {
      cambios.organization_id = entrada.organization_id;
    }

    if (entrada.certificate_enabled !== undefined) {
      cambios.certificate_enabled = entrada.certificate_enabled;
    }

    if (entrada.min_age !== undefined) {
      cambios.min_age = entrada.min_age;
    }

    if (entrada.max_age !== undefined) {
      cambios.max_age = entrada.max_age;
    }

    if (entrada.default_language_id !== undefined) {
      cambios.default_language_id = entrada.default_language_id;
    }

    if (entrada.academic_level_id !== undefined) {
      cambios.academic_level_id = entrada.academic_level_id;
    }

    if (Object.keys(cambios).length === 0) {
      return res.status(400).json({
        error: "Debes enviar al menos un campo válido para actualizar"
      });
    }

    const data = await consultarGraphQL(query, {
      filtro: {
        course_id: { eq: req.params.courseId }
      },
      cambios: {
        code: req.body.code,
        status: req.body.status,
        duration_hours: req.body.duration_hours == null
          ? undefined
          : String(req.body.duration_hours)
      }
    });

    const resultado = data.updatecourseCollection.records;

    if (!resultado || resultado.length === 0) {
      return res.status(404).json({
        error: "No se encontró el curso o no se pudo actualizar"
      });
    }

    res.json({
      mensaje: "Curso actualizado correctamente",
      curso: resultado[0]
    });
  } catch (error) {
    console.error("Error actualizando curso:", error);
    res.status(error.status || 500).json({
      error: error.message
    });
  }
}

async function eliminarCurso(req, res) {
  try {
    const query = `
     mutation EliminarCurso($filtro: courseFilter!) {
        deleteFromcourseCollection(filter: $filtro) {
          records {
            course_id
            code
            status
          }
        }
      }
    `;
    const { courseId } = req.params;
    if (!courseId) {
      return res.status(400).json({
        error: "Debes proporcionar el identificador del curso"
      });
    }
    const data = await consultarGraphQL(query, {
      filtro: {
        course_id: {
          eq: courseId
        }
      }
    });
    const records = data.deleteFromcourseCollection.records;
    if (!records || records.length === 0) {
      return res.status(404).json({
        error: "No se encontró el curso para eliminar"
      });
    }
    res.json({
      mensaje: "Curso eliminado correctamente",
      curso: records[0]
    });
  } catch (error) {
    console.error("Error eliminando curso:", error);

    res.status(error.status || 500).json({
      error: error.message
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



