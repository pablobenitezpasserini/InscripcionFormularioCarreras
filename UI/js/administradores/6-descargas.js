import api from "./api.js";

document.getElementById("btnGenerarListado")
    .addEventListener("click", function () {

    if (!document.getElementById("btnExportarExcel")) {

        const nuevoBoton = document.createElement("button");
        nuevoBoton.textContent = "Exportar Datos a Excel";
        nuevoBoton.id = "btnExportarExcel";

        // Exportar datos a Excel
        nuevoBoton.addEventListener("click", async function () {

            try
            {
                const response = await api.get(`/api/admin/exportar-estudiantes`,
                    { responseType: "blob" }
                ); //Llamada a la API. Se espera un binario (en este caso, un archivo Excel)

                const url = window.URL.createObjectURL(new Blob([response.data])); //Se crea una URL temporal para el archivo recibido

                const link = document.createElement("a"); //Se crea un elemento <a> para descargar el archivo
                link.href = url; //Se asocia este elemento al URL creado anteriormente
                link.download = "Estudiantes.xlsx"; //Se le indica que es una descarga y el nombre por defecto
                link.click(); //Se simula un click en el enlace para iniciar la descarga
                window.URL.revokeObjectURL(url); //Se libera la URL temporal
            }
            catch (error)
            {

            if (error.response && error.response.status === 400) { //En caso de recibir un BadRequest o error 400 (generalmente cuando no hay alumons inscriptos)

                const text = await error.response.data.text();
                const errorObj = JSON.parse(text);
                alert(errorObj.message);

            } else { //Error generico. Normalmente sucede cuando el backend no está corriendo o hay un error inesperado
                alert("Error al exportar archivo");
            }
        }

        });

        document.querySelector(".botones")
            .appendChild(nuevoBoton);
    }

});