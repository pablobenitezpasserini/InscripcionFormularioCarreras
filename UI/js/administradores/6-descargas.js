import api from "../api.js";

document.getElementById("btnGenerarListado")
    .addEventListener("click", function () {

        if (!document.getElementById("btnExportarExcel")) {

            const nuevoBoton = document.createElement("button");

            nuevoBoton.textContent = "Exportar Datos a Excel";
            nuevoBoton.id = "btnExportarExcel";

            nuevoBoton.addEventListener("click", async function () {

                try {

                    // Obtener los datos desde la API
                    const response = await api.get("/api/admin/exportar-estudiantes");

                    const estudiantes = response.data;

                    // Crear libro de Excel
                    const workbook = new ExcelJS.Workbook();

                    // Crear hoja
                    const worksheet = workbook.addWorksheet("Estudiantes");

                    // Encabezados
                    worksheet.columns = [
                        { header: "Marca temporal", key: "fechaInscripcion", width: 30 },
                        { header: "Correo electrónico", key: "correoElectronico", width: 30 },
                        { header: "Carrera inscripta", key: "carreraInscripta", width: 35 },
                        { header: "Nombre y apellido", key: "nombreApellido", width: 30 },
                        { header: "DNI", key: "dni", width: 15 },
                        { header: "Teléfono", key: "telefono", width: 20 },
                        { header: "Fecha de nacimiento", key: "fechaNacimiento", width: 20 },
                        { header: "Edad al 30/06/2026", key: "edadActual"},
                        { header: "Dirección", key: "direccion", width: 35 },
                        { header: "Posee", key: "posee", width: 25 },
                        { header: "Título secundario", key: "tituloSecundario", width: 30 },
                        { header: "Año de egreso", key: "añoEgreso", width: 18 }
                    ];

                    // Agregar estudiantes
                    estudiantes.forEach(estudiante => {
                        worksheet.addRow(estudiante);
                    });

                    // Generar archivo
                    const buffer = await workbook.xlsx.writeBuffer();

                    // Crear descarga
                    const blob = new Blob(
                        [buffer],
                        {
                            type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                        }
                    );

                    const url = window.URL.createObjectURL(blob);

                    const link = document.createElement("a");

                    link.href = url;
                    link.download = "Estudiantes.xlsx";

                    link.click();

                    window.URL.revokeObjectURL(url);

                }
                catch (error) {

                    console.error("Error al exportar:", error);

                    alert("Error al exportar archivo");
                }

            });

            document.querySelector(".botones")
                .appendChild(nuevoBoton);
        }
    });