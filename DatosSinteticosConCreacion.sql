/* ============================================================
   FORMULARIO INSCRIPCION CARRERAS
   Script completo: DB + tablas + FK/constraints + funciones
   + procedimientos + datos sinteticos
   ============================================================ */

USE master;
GO

IF DB_ID(N'FormularioInscripcionCarreras') IS NOT NULL
BEGIN
    ALTER DATABASE FormularioInscripcionCarreras SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FormularioInscripcionCarreras;
END;
GO

CREATE DATABASE FormularioInscripcionCarreras;
GO

USE FormularioInscripcionCarreras;
GO

/* ============================================================
   TABLAS
   ============================================================ */

CREATE TABLE Admins
(
    ID_Admin INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Admin_Nom_Ape NVARCHAR(100) NOT NULL,
    Admin_DNI CHAR(8) NOT NULL,
    Admin_Tipo_DNI VARCHAR(40) NOT NULL,
    Admin_Nom_Usuario NVARCHAR(30) NOT NULL UNIQUE,
    Admin_Contra VARCHAR(255) NOT NULL,
    CONSTRAINT UkdniUnico UNIQUE (Admin_DNI, Admin_Tipo_DNI)
);
GO

CREATE TABLE Carreras
(
    ID_Car INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Car_Nom NVARCHAR(80) NULL,
    Turno NVARCHAR(20) NOT NULL,
    Car_PlanEstudio CHAR(15) NOT NULL,
    CONSTRAINT UQ_Carreras UNIQUE (Car_Nom, Turno)
);
GO

CREATE TABLE Pais
(
    ID_Pais INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Pais_Nombre VARCHAR(50) NOT NULL UNIQUE
);
GO

CREATE TABLE Estudiantes
(
    ID_Est INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Est_Nom_Ape NVARCHAR(200) NOT NULL,
    Est_DNI INT NOT NULL UNIQUE,
    Est_Correo VARCHAR(50) NOT NULL UNIQUE,
    Est_Telefono VARCHAR(20) NOT NULL UNIQUE,
    Est_Fecha_Nac DATE NOT NULL,
    Est_Direccion NVARCHAR(80) NOT NULL,
    Est_Titulo_Sec VARCHAR(50) NOT NULL,
    Est_Año_Egreso DATE NULL,
    ID_Pais INT NOT NULL,
    CONSTRAINT FK_Estudiantes_Pais FOREIGN KEY (ID_Pais) REFERENCES Pais(ID_Pais)
);
GO

CREATE TABLE Habilitacion_Formulario
(
    ID_Hab_Form INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Hab_Form_Año INT NOT NULL UNIQUE,
    Hab_Form_Fecha_Inicio DATE NOT NULL,
    Hab_Form_Fecha_Cierre DATE NOT NULL
);
GO

CREATE TABLE Inf_Academica
(
    ID_Inf_Aca INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Inf_Aca_Descripcion NVARCHAR(50) NOT NULL UNIQUE,
    Inf_Aca_Fecha DATE NOT NULL,
    Inf_Aca_Estado VARCHAR(15) NOT NULL CONSTRAINT DF_Inf_Academica_Estado DEFAULT ('DESHABILITADO'),
    CONSTRAINT CK_Inf_Aca_Estado CHECK (Inf_Aca_Estado IN ('DESHABILITADO', 'HABILITADO'))
);
GO

CREATE TABLE Inf_Academica_Est
(
    ID_Inf_Academica_Est INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ID_Inf_Aca INT NOT NULL,
    ID_Est INT NOT NULL,
    CONSTRAINT UkEstInfAcaUnico UNIQUE (ID_Inf_Aca, ID_Est),
    CONSTRAINT FK_Inf_Academica_Est_ID_Est FOREIGN KEY (ID_Est)
        REFERENCES Estudiantes(ID_Est) ON DELETE CASCADE,
    CONSTRAINT FK_Inf_Academica_Est_ID_Inf FOREIGN KEY (ID_Inf_Aca)
        REFERENCES Inf_Academica(ID_Inf_Aca) ON DELETE CASCADE
);
GO

CREATE TABLE Inscripcion
(
    ID_Inscripcion INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ID_Est INT NOT NULL,
    ID_Car INT NOT NULL,
    ID_Hab_Form INT NOT NULL,
    CONSTRAINT ukIns UNIQUE (ID_Est, ID_Car),
    CONSTRAINT FK_Inscripcion_ID_Est FOREIGN KEY (ID_Est)
        REFERENCES Estudiantes(ID_Est),
    CONSTRAINT FK_Inscripcion_ID_Car FOREIGN KEY (ID_Car)
        REFERENCES Carreras(ID_Car) ON DELETE CASCADE,
    CONSTRAINT FK_Inscripcion_ID_Hab_Form FOREIGN KEY (ID_Hab_Form)
        REFERENCES Habilitacion_Formulario(ID_Hab_Form)
);
GO

/* ============================================================
   FUNCION DE EDAD
   ============================================================ */

CREATE FUNCTION Func_CalcularEdad
(
    @FechaNacimiento DATE,
    @FechaReferencia DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @Edad INT;

    SET @Edad = DATEDIFF(YEAR, @FechaNacimiento, @FechaReferencia);

    IF DATEADD(YEAR, @Edad, @FechaNacimiento) > @FechaReferencia
    BEGIN
        SET @Edad = @Edad - 1;
    END;

    RETURN @Edad;
END;
GO

/* ============================================================
   PROCEDIMIENTOS - ADMIN
   ============================================================ */

CREATE PROCEDURE Agregar_Admin
    @Admin_Nom_Ape VARCHAR(50),
    @Admin_DNI VARCHAR(8),
    @Admin_Tipo_DNI VARCHAR(40),
    @Admin_Nom_Usuario VARCHAR(30),
    @Admin_Contraseña VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Admins
        (Admin_Nom_Ape, Admin_DNI, Admin_Tipo_DNI, Admin_Nom_Usuario, Admin_Contra)
    VALUES
        (@Admin_Nom_Ape, @Admin_DNI, @Admin_Tipo_DNI, @Admin_Nom_Usuario, @Admin_Contraseña);
END;
GO

CREATE PROCEDURE Eliminar_Admin
    @ID_Admin INT,
    @Mensaje NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Admins WHERE ID_Admin = @ID_Admin)
        BEGIN
            DELETE FROM Admins WHERE ID_Admin = @ID_Admin;

            IF NOT EXISTS (SELECT 1 FROM Admins)
            BEGIN
                INSERT INTO Admins
                    (Admin_Nom_Ape, Admin_DNI, Admin_Tipo_DNI, Admin_Nom_Usuario, Admin_Contra)
                VALUES
                    ('Administrador General', '00000000', 'DNI', 'admin', 'admin123456');

                SET @Mensaje = N'Administrador eliminado. Se generó un usuario genérico (admin / admin123456).';
            END
            ELSE
                SET @Mensaje = N'Administrador eliminado exitosamente.';
        END
        ELSE
            SET @Mensaje = N'No se encontró ningún administrador con ese ID.';
    END TRY
    BEGIN CATCH
        SET @Mensaje = ERROR_MESSAGE();
    END CATCH
END;
GO

CREATE PROCEDURE Modificar_Admin
    @Admin_Nom_Usuario VARCHAR(30),
    @Nuevo_Admin_Nom_Ape VARCHAR(50),
    @Nuevo_Admin_DNI VARCHAR(8),
    @Nuevo_Admin_Nom_Usuario VARCHAR(30),
    @Nuevo_Admin_Contra VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Admins
    SET Admin_Nom_Ape = @Nuevo_Admin_Nom_Ape,
        Admin_DNI = @Nuevo_Admin_DNI,
        Admin_Nom_Usuario = @Nuevo_Admin_Nom_Usuario,
        Admin_Contra = @Nuevo_Admin_Contra
    WHERE Admin_Nom_Usuario = @Admin_Nom_Usuario;
END;
GO

CREATE PROCEDURE Logueo_Admin
    @Admin_Nom_Usuario VARCHAR(30),
    @Admin_Contra VARCHAR(30),
    @Mensaje NVARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM Admins
        WHERE Admin_Nom_Usuario = @Admin_Nom_Usuario
          AND Admin_Contra = @Admin_Contra
    )
        SET @Mensaje = N'Logueo exitoso.';
    ELSE
        SET @Mensaje = N'Nombre de usuario o contrasenia incorrectos.';
END;
GO

/* ============================================================
   PROCEDIMIENTOS - INSCRIPCION
   ============================================================ */

CREATE PROCEDURE Agregar_Inscripcion
    @ID_Est INT,
    @ID_Car INT,
    @ID_Hab_Form INT,
    @Mensaje NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS
        (
            SELECT 1
            FROM Inscripcion
            WHERE ID_Est = @ID_Est
              AND ID_Car = @ID_Car
              AND ID_Hab_Form = @ID_Hab_Form
        )
        BEGIN
            SET @Mensaje = N'La inscripción ya existe para este estudiante y carrera.';
        END
        ELSE
        BEGIN
            INSERT INTO Inscripcion (ID_Est, ID_Car, ID_Hab_Form)
            VALUES (@ID_Est, @ID_Car, @ID_Hab_Form);

            SET @Mensaje = N'Inscripción creada exitosamente.';
        END
    END TRY
    BEGIN CATCH
        SET @Mensaje = ERROR_MESSAGE();
    END CATCH
END;
GO

CREATE PROCEDURE Eliminar_Inscripcion
    @ID_Inscripcion INT,
    @Mensaje NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Inscripcion WHERE ID_Inscripcion = @ID_Inscripcion)
        BEGIN
            DELETE FROM Inscripcion WHERE ID_Inscripcion = @ID_Inscripcion;
            SET @Mensaje = N'Inscripción eliminada correctamente.';
        END
        ELSE
            SET @Mensaje = N'No se encontró la inscripción indicada.';
    END TRY
    BEGIN CATCH
        SET @Mensaje = ERROR_MESSAGE();
    END CATCH
END;
GO

/* ============================================================
   PROCEDIMIENTOS - ESTUDIANTE
   ============================================================ */

CREATE PROCEDURE Estudiantes_Insert
    @Est_Nom_Ape NVARCHAR(200),
    @Est_DNI INT,
    @Est_Correo VARCHAR(50),
    @Est_Telefono VARCHAR(20),
    @Est_Fecha_Nac DATE,
    @Est_Direccion NVARCHAR(80),
    @Est_Titulo_Sec VARCHAR(100),
    @Est_Año_Egreso DATE,
    @ID_Pais INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Estudiantes
    (
        Est_Nom_Ape,
        Est_DNI,
        Est_Correo,
        Est_Telefono,
        Est_Fecha_Nac,
        Est_Direccion,
        Est_Titulo_Sec,
        Est_Año_Egreso,
        ID_Pais
    )
    VALUES
    (
        @Est_Nom_Ape,
        @Est_DNI,
        @Est_Correo,
        @Est_Telefono,
        @Est_Fecha_Nac,
        @Est_Direccion,
        @Est_Titulo_Sec,
        @Est_Año_Egreso,
        @ID_Pais
    );
END;
GO

/* ============================================================
   PROCEDIMIENTOS - INFORMACION ACADEMICA
   ============================================================ */

CREATE PROCEDURE Inf_Academica_Insert
    @Inf_Aca_Descripcion VARCHAR(50),
    @Inf_Aca_Fecha DATE,
    @Inf_Aca_Estado VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Inf_Academica
        (Inf_Aca_Descripcion, Inf_Aca_Fecha, Inf_Aca_Estado)
    VALUES
        (@Inf_Aca_Descripcion, @Inf_Aca_Fecha, @Inf_Aca_Estado);
END;
GO

CREATE PROCEDURE Inf_Academica_Update
    @ID_Inf_Aca INT,
    @Nueva_Descripcion VARCHAR(100),
    @Nueva_Fecha DATE,
    @Nuevo_Estado VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Inf_Academica
    SET Inf_Aca_Descripcion = @Nueva_Descripcion,
        Inf_Aca_Fecha = @Nueva_Fecha,
        Inf_Aca_Estado = @Nuevo_Estado
    WHERE ID_Inf_Aca = @ID_Inf_Aca;
END;
GO

CREATE PROCEDURE Inf_Academica_Delete
    @ID_Inf_Aca INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Inf_Academica
    WHERE ID_Inf_Aca = @ID_Inf_Aca;

    PRINT 'Registro de información académica eliminado correctamente.';
END;
GO

CREATE PROCEDURE Inf_Academica_Est_Insert
    @ID_Inf_Aca INT,
    @ID_Est INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Inf_Academica_Est (ID_Inf_Aca, ID_Est)
    VALUES (@ID_Inf_Aca, @ID_Est);
END;
GO

/* ============================================================
   PROCEDIMIENTOS - PAIS
   ============================================================ */

CREATE PROCEDURE Pais_Insert
    @Pais_Nombre NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Pais (Pais_Nombre)
    VALUES (@Pais_Nombre);
END;
GO

CREATE PROCEDURE Pais_Update
    @ID_Pais INT,
    @Pais_Nombre NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Pais
    SET Pais_Nombre = @Pais_Nombre
    WHERE ID_Pais = @ID_Pais;
END;
GO

CREATE PROCEDURE Pais_Delete
    @ID_Pais INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Pais
    WHERE ID_Pais = @ID_Pais;

    PRINT 'País eliminado correctamente.';
END;
GO

/* ============================================================
   PROCEDIMIENTOS - HABILITACION DE FORMULARIO
   ============================================================ */

CREATE PROCEDURE sp_Insert_Habilitacion_Formulario
    @Hab_Form_Año INT,
    @Hab_Form_Fecha_Inicio DATE,
    @Hab_Form_Fecha_Cierre DATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Habilitacion_Formulario
        (Hab_Form_Año, Hab_Form_Fecha_Inicio, Hab_Form_Fecha_Cierre)
    VALUES
        (@Hab_Form_Año, @Hab_Form_Fecha_Inicio, @Hab_Form_Fecha_Cierre);
END;
GO

CREATE PROCEDURE sp_Update_Habilitacion_Formulario
    @ID_Hab_Form INT,
    @Hab_Form_Fecha_Inicio DATE,
    @Hab_Form_Fecha_Cierre DATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Habilitacion_Formulario
    SET Hab_Form_Fecha_Inicio = @Hab_Form_Fecha_Inicio,
        Hab_Form_Fecha_Cierre = @Hab_Form_Fecha_Cierre
    WHERE ID_Hab_Form = @ID_Hab_Form;
END;
GO

CREATE PROCEDURE sp_Delete_Habilitacion_Formulario
    @ID_Hab_Form INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Habilitacion_Formulario
    WHERE ID_Hab_Form = @ID_Hab_Form;
END;
GO

/* ============================================================
   PROCEDIMIENTOS - CARRERAS
   ============================================================ */

CREATE PROCEDURE sp_InsertarCarrera
    @Nombre NVARCHAR(60),
    @Turno NVARCHAR(20),
    @PlanEstudio CHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Carreras (Car_Nom, Turno, Car_PlanEstudio)
    VALUES (@Nombre, @Turno, @PlanEstudio);
END;
GO

CREATE PROCEDURE sp_Listar_Carreras_Turnos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Car_Nom AS Nombre_Carrera,
        Turno,
        Car_PlanEstudio AS Plan_Estudio
    FROM Carreras
    ORDER BY Car_Nom, Turno;
END;
GO

CREATE PROCEDURE sp_ModificarCarrera
    @ID_Car INT,
    @Nombre NVARCHAR(60),
    @Turno NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Carreras
    SET Car_Nom = @Nombre,
        Turno = @Turno
    WHERE ID_Car = @ID_Car;
END;
GO

/* ============================================================
   PROCEDIMIENTO DE EXPORTACION
   ============================================================ */

CREATE PROCEDURE SP_ExportacionDelExcel
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FechaReferencia DATE =
        DATEFROMPARTS(YEAR(GETDATE()), 6, 30);

    SELECT
        -- Pendiente: la tabla Inscripcion todavía no posee FechaInscripcion.
        -- i.FechaInscripcion AS FechaInscripcion,

        e.Est_Correo AS CorreoElectronico,
        e.Est_Nom_Ape AS NombreApellido,
        e.Est_DNI AS DNI,
        e.Est_Telefono AS Telefono,
        e.Est_Fecha_Nac AS FechaNacimiento,
        dbo.Func_CalcularEdad(e.Est_Fecha_Nac, @FechaReferencia) AS EdadActual,
        e.Est_Direccion AS Direccion,
        ia.Inf_Aca_Descripcion AS Posee,
        e.Est_Titulo_Sec AS TituloSecundario,
        e.Est_Año_Egreso AS AñoEgreso,
        CONCAT(c.Car_Nom, ' (', c.Turno, ')') AS CarreraInscripta
    FROM Inscripcion i
    INNER JOIN Estudiantes e
        ON e.ID_Est = i.ID_Est
    INNER JOIN Carreras c
        ON c.ID_Car = i.ID_Car
    INNER JOIN Inf_Academica_Est iae
        ON iae.ID_Est = i.ID_Est
    INNER JOIN Inf_Academica ia
        ON ia.ID_Inf_Aca = iae.ID_Inf_Aca;
END;
GO

/* ============================================================
   DATOS SINTETICOS
   ============================================================ */

-- Administrador para probar el login
EXEC Agregar_Admin
    'Administrador General',
    '00000001',
    'DNI',
    'Admin',
    '1142';
GO

-- Países
EXEC Pais_Insert 'Argentina';
EXEC Pais_Insert 'Uruguay';
EXEC Pais_Insert 'Bolivia';
EXEC Pais_Insert 'Chile';
EXEC Pais_Insert 'Paraguay';
EXEC Pais_Insert 'Brasil';
GO

-- IDs de países. No se asume que empiezan en 1.
DECLARE @Argentina INT = (SELECT ID_Pais FROM Pais WHERE Pais_Nombre = 'Argentina');
DECLARE @Uruguay INT = (SELECT ID_Pais FROM Pais WHERE Pais_Nombre = 'Uruguay');
DECLARE @Bolivia INT = (SELECT ID_Pais FROM Pais WHERE Pais_Nombre = 'Bolivia');
DECLARE @Chile INT = (SELECT ID_Pais FROM Pais WHERE Pais_Nombre = 'Chile');
DECLARE @Paraguay INT = (SELECT ID_Pais FROM Pais WHERE Pais_Nombre = 'Paraguay');
DECLARE @Brasil INT = (SELECT ID_Pais FROM Pais WHERE Pais_Nombre = 'Brasil');

IF @Argentina IS NULL OR @Uruguay IS NULL OR @Bolivia IS NULL OR
   @Chile IS NULL OR @Paraguay IS NULL OR @Brasil IS NULL
BEGIN
    THROW 50001, 'No se pudieron obtener los IDs de los países.', 1;
END;
GO

-- Carreras solicitadas
EXEC sp_InsertarCarrera N'PROFESORADO DE ECONOMIA', 'MAÑANA', '0001/11';
EXEC sp_InsertarCarrera N'PROFESORADO DE ELECTROMECONICA', 'VESPERTINO', '0002/22';
EXEC sp_InsertarCarrera N'PROFESORADO DE ELECTRONICA', 'VESPERTINO', '0003/33';
EXEC sp_InsertarCarrera N'PROFESORADO DE FISICA', 'TARDE', '0004/44';
EXEC sp_InsertarCarrera N'PROFESORADO DE MATEMATICA', 'MAÑANA', '0005/55';
EXEC sp_InsertarCarrera N'PROFESORADO DE MATEMATICA', 'VESPERTINO', '0005/55';
EXEC sp_InsertarCarrera N'TECNICATURA SUPERIOR EN ANALISIS DE SISTEMAS', 'VESPERTINO', '0006/66';
EXEC sp_InsertarCarrera N'TECNICATURA SUPERIOR EN BIBLIOTECOLOGIA', 'VESPERTINO', '0007/77';
EXEC sp_InsertarCarrera N'TECNICATURA SUPERIOR EN BIBLIOTECOLOGIA DE INSTITUCIONES EDUCATIVAS', 'VESPERTINO', '0008/88';
EXEC sp_InsertarCarrera N'TECNICATURA SUPERIOR EN MANTENIMIENTO INDUSTRIAL', 'VESPERTINO', '0009/99';
GO

-- Habilitación del formulario 2026
EXEC sp_Insert_Habilitacion_Formulario
    2026,
    '2026-01-01',
    '2026-12-31';
GO

DECLARE @ID_Hab_Form INT = (SELECT ID_Hab_Form FROM Habilitacion_Formulario WHERE Hab_Form_Año = 2026);

IF @ID_Hab_Form IS NULL
    THROW 50002, 'No se pudo obtener la habilitación del formulario 2026.', 1;
GO

-- Las únicas dos opciones de información académica solicitadas.
EXEC Inf_Academica_Insert N'Titulo', '2026-01-01', 'HABILITADO';
EXEC Inf_Academica_Insert N'Constancia de alumno regular', '2026-01-01', 'HABILITADO';
GO

/* ============================================================
   ESTUDIANTES
   ============================================================ */

DECLARE @Argentina INT = (SELECT ID_Pais FROM Pais WHERE Pais_Nombre = 'Argentina');
DECLARE @Uruguay INT = (SELECT ID_Pais FROM Pais WHERE Pais_Nombre = 'Uruguay');
DECLARE @Bolivia INT = (SELECT ID_Pais FROM Pais WHERE Pais_Nombre = 'Bolivia');
DECLARE @Chile INT = (SELECT ID_Pais FROM Pais WHERE Pais_Nombre = 'Chile');
DECLARE @Paraguay INT = (SELECT ID_Pais FROM Pais WHERE Pais_Nombre = 'Paraguay');
DECLARE @Brasil INT = (SELECT ID_Pais FROM Pais WHERE Pais_Nombre = 'Brasil');

EXEC Estudiantes_Insert N'Lucía Fernández', 40123456, 'lucia.fernandez@gmail.com', '1123456781', '2001-04-15', N'Av. Rivadavia 1234', 'Bachiller', '2019-12-01', @Argentina;
EXEC Estudiantes_Insert N'Martín González', 42123457, 'martin.gonzalez@gmail.com', '1123456782', '2003-08-22', N'Av. Belgrano 2456', 'Bachiller', '2021-12-01', @Argentina;
EXEC Estudiantes_Insert N'Sofía Martínez', 43123458, 'sofia.martinez@gmail.com', '1123456783', '2004-02-10', N'Calle Moreno 789', 'Bachiller', '2022-12-01', @Argentina;
EXEC Estudiantes_Insert N'Juan Pérez', 39123459, 'juan.perez@gmail.com', '1123456784', '1999-11-30', N'Calle Alsina 456', 'Bachiller', '2017-12-01', @Argentina;
EXEC Estudiantes_Insert N'Camila Rodríguez', 45123460, 'camila.rodriguez@gmail.com', '1123456785', '2005-06-05', N'Av. Santa Fe 3210', 'Bachiller', '2023-12-01', @Argentina;
EXEC Estudiantes_Insert N'Diego López', 38123461, 'diego.lopez@gmail.com', '1123456786', '1998-03-18', N'Av. Corrientes 1890', 'Bachiller', '2016-12-01', @Argentina;
EXEC Estudiantes_Insert N'Valentina Sánchez', 46123462, 'valentina.sanchez@gmail.com', '1123456787', '2006-09-12', N'Calle San Martín 555', 'Bachiller', '2024-12-01', @Argentina;
EXEC Estudiantes_Insert N'Facundo Romero', 41123463, 'facundo.romero@gmail.com', '1123456788', '2002-01-27', N'Av. Independencia 2222', 'Bachiller', '2020-12-01', @Argentina;
EXEC Estudiantes_Insert N'Agustina Torres', 44123464, 'agustina.torres@gmail.com', '1123456789', '2004-12-03', N'Calle Lavalle 876', 'Bachiller', '2022-12-01', @Argentina;
EXEC Estudiantes_Insert N'Bruno Castro', 37123465, 'bruno.castro@gmail.com', '1123456790', '1997-07-21', N'Av. Directorio 1450', 'Bachiller', '2015-12-01', @Argentina;
EXEC Estudiantes_Insert N'Carolina Silva', 42123466, 'carolina.silva@gmail.com', '1123456791', '2003-05-19', N'Calle Pueyrredón 640', 'Bachiller', '2021-12-01', @Uruguay;
EXEC Estudiantes_Insert N'Gonzalo Ramírez', 40123467, 'gonzalo.ramirez@gmail.com', '1123456792', '2001-10-08', N'Av. Caseros 930', 'Bachiller', '2019-12-01', @Bolivia;
EXEC Estudiantes_Insert N'Mariana Acosta', 43123468, 'mariana.acosta@gmail.com', '1123456793', '2004-07-14', N'Calle Perú 112', 'Bachiller', '2022-12-01', @Chile;
EXEC Estudiantes_Insert N'Federico Molina', 39123469, 'federico.molina@gmail.com', '1123456794', '1999-02-25', N'Av. Juan B. Justo 1800', 'Bachiller', '2017-12-01', @Argentina;
EXEC Estudiantes_Insert N'Natalia Herrera', 45123470, 'natalia.herrera@gmail.com', '1123456795', '2005-11-17', N'Calle Ecuador 345', 'Bachiller', '2023-12-01', @Paraguay;
EXEC Estudiantes_Insert N'Pablo Navarro', 41123471, 'pablo.navarro@gmail.com', '1123456796', '2002-06-30', N'Av. Gaona 2710', 'Bachiller', '2020-12-01', @Argentina;
EXEC Estudiantes_Insert N'Julieta Medina', 43123472, 'julieta.medina@gmail.com', '1123456797', '2004-01-05', N'Calle Tucumán 712', 'Bachiller', '2022-12-01', @Argentina;
EXEC Estudiantes_Insert N'Tomás Vega', 46123473, 'tomas.vega@gmail.com', '1123456798', '2006-03-28', N'Av. Scalabrini Ortiz 1560', 'Bachiller', '2024-12-01', @Argentina;
EXEC Estudiantes_Insert N'Florencia Ríos', 42123474, 'florencia.rios@gmail.com', '1123456799', '2003-09-09', N'Calle México 980', 'Bachiller', '2021-12-01', @Brasil;
EXEC Estudiantes_Insert N'Ignacio Duarte', 38123475, 'ignacio.duarte@gmail.com', '1123456800', '1998-12-12', N'Av. La Plata 450', 'Bachiller', '2016-12-01', @Argentina;
GO

/* ============================================================
   RELACIONAR ESTUDIANTES CON INFORMACION ACADEMICA
   ============================================================ */

DECLARE @ID_Titulo INT = (SELECT ID_Inf_Aca FROM Inf_Academica WHERE Inf_Aca_Descripcion = N'Titulo');
DECLARE @ID_Constancia INT = (SELECT ID_Inf_Aca FROM Inf_Academica WHERE Inf_Aca_Descripcion = N'Constancia de alumno regular');

IF @ID_Titulo IS NULL OR @ID_Constancia IS NULL
    THROW 50003, 'No se pudieron obtener las opciones de información académica.', 1;

DECLARE @ID_Est INT;

SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 40123456; EXEC Inf_Academica_Est_Insert @ID_Titulo, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 42123457; EXEC Inf_Academica_Est_Insert @ID_Constancia, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 43123458; EXEC Inf_Academica_Est_Insert @ID_Titulo, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 39123459; EXEC Inf_Academica_Est_Insert @ID_Constancia, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 45123460; EXEC Inf_Academica_Est_Insert @ID_Titulo, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 38123461; EXEC Inf_Academica_Est_Insert @ID_Constancia, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 46123462; EXEC Inf_Academica_Est_Insert @ID_Titulo, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 41123463; EXEC Inf_Academica_Est_Insert @ID_Constancia, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 44123464; EXEC Inf_Academica_Est_Insert @ID_Titulo, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 37123465; EXEC Inf_Academica_Est_Insert @ID_Constancia, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 42123466; EXEC Inf_Academica_Est_Insert @ID_Titulo, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 40123467; EXEC Inf_Academica_Est_Insert @ID_Constancia, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 43123468; EXEC Inf_Academica_Est_Insert @ID_Titulo, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 39123469; EXEC Inf_Academica_Est_Insert @ID_Constancia, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 45123470; EXEC Inf_Academica_Est_Insert @ID_Titulo, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 41123471; EXEC Inf_Academica_Est_Insert @ID_Constancia, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 43123472; EXEC Inf_Academica_Est_Insert @ID_Titulo, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 46123473; EXEC Inf_Academica_Est_Insert @ID_Constancia, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 42123474; EXEC Inf_Academica_Est_Insert @ID_Titulo, @ID_Est;
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 38123475; EXEC Inf_Academica_Est_Insert @ID_Constancia, @ID_Est;
GO

/* ============================================================
   INSCRIPCIONES
   ============================================================ */

DECLARE @ID_Hab_Form INT = (SELECT ID_Hab_Form FROM Habilitacion_Formulario WHERE Hab_Form_Año = 2026);
DECLARE @ID_Car INT;
DECLARE @Mensaje NVARCHAR(255);
DECLARE @ID_Est INT;

-- Lucía -> Economía
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 40123456;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'PROFESORADO DE ECONOMIA' AND Turno = N'MAÑANA';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

-- Martín -> Electromecánica
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 42123457;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'PROFESORADO DE ELECTROMECANICA' AND Turno = N'VESPERTINO';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

-- Sofía -> Electrónica
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 43123458;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'PROFESORADO DE ELECTRONICA' AND Turno = N'VESPERTINO';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

-- Juan -> Física
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 39123459;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'PROFESORADO DE FISICA' AND Turno = N'TARDE';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

-- Camila -> Matemática mañana
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 45123460;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'PROFESORADO DE MATEMATICA' AND Turno = N'MAÑANA';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

-- Diego -> Matemática vespertino
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 38123461;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'PROFESORADO DE MATEMATICA' AND Turno = N'VESPERTINO';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

-- Valentina -> Análisis de Sistemas
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 46123462;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'TECNICATURA SUPERIOR EN ANALISIS DE SISTEMAS' AND Turno = N'VESPERTINO';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

-- Facundo -> Bibliotecología
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 41123463;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'TECNICATURA SUPERIOR EN BIBLIOTECOLOGIA' AND Turno = N'VESPERTINO';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

-- Agustina -> Bibliotecología de Instituciones Educativas
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 44123464;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'TECNICATURA SUPERIOR EN BIBLIOTECOLOGIA DE INSTITUCIONES EDUCATIVAS' AND Turno = N'VESPERTINO';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

-- Bruno -> Mantenimiento Industrial
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 37123465;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'TECNICATURA SUPERIOR EN MANTENIMIENTO INDUSTRIAL' AND Turno = N'VESPERTINO';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

-- Los siguientes diez estudiantes tienen otras carreras para distribuir los datos.
SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 42123466;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'PROFESORADO DE ECONOMIA' AND Turno = N'MAÑANA';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 40123467;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'PROFESORADO DE MATEMATICA' AND Turno = N'VESPERTINO';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 43123468;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'TECNICATURA SUPERIOR EN ANALISIS DE SISTEMAS' AND Turno = N'VESPERTINO';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 39123469;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'PROFESORADO DE FISICA' AND Turno = N'TARDE';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 45123470;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'TECNICATURA SUPERIOR EN MANTENIMIENTO INDUSTRIAL' AND Turno = N'VESPERTINO';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 41123471;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'PROFESORADO DE ELECTRONICA' AND Turno = N'VESPERTINO';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 43123472;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'TECNICATURA SUPERIOR EN BIBLIOTECOLOGIA' AND Turno = N'VESPERTINO';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 46123473;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'PROFESORADO DE ECONOMIA' AND Turno = N'MAÑANA';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 42123474;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'TECNICATURA SUPERIOR EN BIBLIOTECOLOGIA DE INSTITUCIONES EDUCATIVAS' AND Turno = N'VESPERTINO';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;

SELECT @ID_Est = ID_Est FROM Estudiantes WHERE Est_DNI = 38123475;
SELECT @ID_Car = ID_Car FROM Carreras WHERE Car_Nom = N'PROFESORADO DE MATEMATICA' AND Turno = N'MAÑANA';
EXEC Agregar_Inscripcion @ID_Est, @ID_Car, @ID_Hab_Form, @Mensaje OUTPUT;
GO

/* ============================================================
   VERIFICACIONES
   ============================================================ */

SELECT 'Carreras' AS Tabla, COUNT(*) AS Cantidad FROM Carreras
UNION ALL
SELECT 'Paises', COUNT(*) FROM Pais
UNION ALL
SELECT 'Estudiantes', COUNT(*) FROM Estudiantes
UNION ALL
SELECT 'Informacion academica', COUNT(*) FROM Inf_Academica
UNION ALL
SELECT 'Relaciones info academica', COUNT(*) FROM Inf_Academica_Est
UNION ALL
SELECT 'Inscripciones', COUNT(*) FROM Inscripcion;
GO

SELECT * FROM Carreras ORDER BY ID_Car;
GO

SELECT
    e.ID_Est,
    e.Est_Nom_Ape,
    e.Est_DNI,
    p.Pais_Nombre,
    ia.Inf_Aca_Descripcion AS Posee,
    c.Car_Nom AS Carrera,
    c.Turno
FROM Inscripcion i
INNER JOIN Estudiantes e ON e.ID_Est = i.ID_Est
INNER JOIN Pais p ON p.ID_Pais = e.ID_Pais
INNER JOIN Inf_Academica_Est iae ON iae.ID_Est = e.ID_Est
INNER JOIN Inf_Academica ia ON ia.ID_Inf_Aca = iae.ID_Inf_Aca
INNER JOIN Carreras c ON c.ID_Car = i.ID_Car
ORDER BY e.ID_Est;
GO

-- Resultado que consumirá el endpoint de exportación.
EXEC SP_ExportacionDelExcel;
GO
