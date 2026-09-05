import api from "../api.js";

const tablaEstudiantes = document.getElementById("tablaEstudiantes");

async function cargarEstudiantes() {

    try {

        const response = await api.get("/api/admin/exportar-estudiantes");

        const estudiantes = response.data;

        estudiantes.forEach(estudiante => {

            const fila = document.createElement("tr");

            fila.innerHTML = `
                <td>${estudiante.fechaInscripcion}</td>
                <td>${estudiante.correoElectronico}</td>
                <td>${estudiante.carreraInscripta}</td>
                <td>${estudiante.nombreApellido}</td>
                <td>${estudiante.dni}</td>
                <td>${estudiante.telefono}</td>
                <td>${estudiante.fechaNacimiento}</td>
                <td>${estudiante.edadActual}</td>
                <td>${estudiante.direccion}</td>
                <td>${estudiante.posee}</td>
                <td>${estudiante.tituloSecundario}</td>
                <td>${estudiante.añoEgreso}</td>
            `;

            tablaEstudiantes.appendChild(fila);
        });

    } catch (error) {

        console.error("Error al obtener estudiantes:", error);

        alert("No se pudieron cargar los estudiantes.");
    }
}

cargarEstudiantes();