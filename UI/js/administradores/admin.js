import api from "../api.js";

// Usuarios por defecto
let administradores = [
    { email: "Admin", password: "1142", default: true } // No se puede eliminar
];

const home = document.getElementById("home");
const loginForm = document.getElementById("loginForm");
const registerForm = document.getElementById("registerForm");

// Botones home
document.getElementById("btnLogin").addEventListener("click", () => {
    home.style.display = "none";
    loginForm.style.display = "block";
});

document.getElementById("btnRegister").addEventListener("click", () => {
    home.style.display = "none";
    registerForm.style.display = "block";
});

// Cancel buttons
document.getElementById("cancelLogin").addEventListener("click", () => {
    loginForm.style.display = "none";
    home.style.display = "block";
});

document.getElementById("cancelRegister").addEventListener("click", () => {
    registerForm.style.display = "none";
    home.style.display = "block";
});

// Login
document.getElementById("loginForm").addEventListener("submit", async function (e) {
    e.preventDefault();

    // Obtengo los valores del formulario
    const usuario = document.getElementById("loginUser").value;
    const contrasena = document.getElementById("loginPassword").value;

    try {
        // Llamada a la API
        const response = await api.post(`/api/admin/login`, {
            usuario: usuario,
            contrasena: contrasena
        });

        console.log("Respuesta del servidor:", response.data);

        // Manejamos la respuesta
        if (response.data.mensaje === "Logueo exitoso.") {
            alert("✅ Logueo correcto");
            localStorage.setItem("logueado", "true");
            window.location.href = "menu.html";
        } else {
            alert("❌ " + response.data.mensaje);
        }

    } catch (error) 
    {
        console.error("Error al loguear:", error);

    if (error.response && error.response.data && error.response.data.mensaje) {
        alert("❌ " + error.response.data.mensaje);
    } else {
        alert("Error al comunicarse con el servidor");
    }
}
});

// Registro
registerForm.addEventListener("submit", function(e) {
    e.preventDefault();
    const email = document.getElementById("regUser").value;
    const password = document.getElementById("regPassword").value;

    if(administradores.some(u => u.email === email)) {
        alert("⚠️ El usuario ya existe.");
        return;
    }

    administradores.push({email, password});
    alert("✅ Administrador registrado con éxito.");
    registerForm.reset();
});
