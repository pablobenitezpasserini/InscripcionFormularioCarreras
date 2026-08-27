---------------------------------------------------------------------------------------------------------------------------
-- CREACIÓN DE LA BASE DE DATOS: FormularioInscripcionCarreras
---------------------------------------------------------------------------------------------------------------------------

-- 1) Seleccionar base de datos del sistema
USE master;
GO

-- 2) Eliminar la base de datos si existe
IF EXISTS (
    SELECT * 
    FROM sys.sysdatabases 
    WHERE name = 'FormularioInscripcionCarreras'
)
    DROP DATABASE FormularioInscripcionCarreras;
GO

-- 3) Crear la base de datos
CREATE DATABASE FormularioInscripcionCarreras;
GO

-- 4) Usar la nueva base de datos
USE FormularioInscripcionCarreras;
GO

---------------------------------------------------------------------------------------------------------------------------
-- CREACIÓN DE LOGIN Y USUARIO
---------------------------------------------------------------------------------------------------------------------------

-- 5) Eliminar login si ya existe
IF EXISTS (
    SELECT * 
    FROM sys.sql_logins 
    WHERE name = 'logtestDBStub'
)
    DROP LOGIN logtestDBStub;
GO

-- 6) Crear login
CREATE LOGIN logtestDBStub 
WITH PASSWORD = 'Log123456$';
GO

-- 7) Crear usuario asociado al login
CREATE USER Usuario 
FOR LOGIN logtestDBStub;
GO

-- 8) Conceder permisos al usuario
GRANT EXEC TO Usuario;
GO
---------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------
-- CREACIÓN DE TABLAS
---------------------------------------------------------------------------------------------------------------------------

-- 1) Tabla: Estudiantes
CREATE TABLE Estudiantes (
    ID_Est INT IDENTITY(1,1) PRIMARY KEY,
    Est_Nom_Ape       NVARCHAR(200) NOT NULL,
    Est_Edad          INT NOT NULL,
    Est_DNI           INT NOT NULL UNIQUE,
    Est_Nacionalidad  VARCHAR(50) NOT NULL,
    Est_Correo        VARCHAR(50) NOT NULL UNIQUE,
    Est_Telefono      VARCHAR(20) NOT NULL UNIQUE, -- Se cambió de INT a VARCHAR
    Est_Fecha_Nac     DATE NOT NULL,
    Est_Direccion     NVARCHAR(80) NOT NULL,
    Est_Titulo_Sec    VARCHAR(50) NOT NULL,
    Est_Año_Egreso    DATE NULL
);
GO

---------------------------------------------------------------------------------------------------------------------------

-- 2) Tabla: Carreras
CREATE TABLE Carreras (
    ID_Car          INT IDENTITY(1,1) NOT NULL,
    Car_Nom         NVARCHAR(60) NOT NULL,
    Turno           NVARCHAR(20) NOT NULL,
    Car_PlanEstudio CHAR(15) NOT NULL,
    CONSTRAINT PK_Carreras PRIMARY KEY (Car_Nom, Turno)
);
GO

---------------------------------------------------------------------------------------------------------------------------

-- 3) Tabla: Admins
CREATE TABLE Admins (
    ID_Admin          INT IDENTITY(1,1) PRIMARY KEY,
    Admin_Nom_Ape     NVARCHAR(100) NOT NULL,
    Admin_DNI         CHAR(8) NOT NULL,
    Admin_Tipo_DNI    VARCHAR(40) NOT NULL,
    Admin_Nom_Usuario NVARCHAR(30) NOT NULL UNIQUE,
    Admin_Contra      VARCHAR(255) NOT NULL,

    CONSTRAINT UkdniUnico UNIQUE (Admin_DNI, Admin_Tipo_DNI),
    CONSTRAINT CkAdminDni CHECK (Admin_DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    -- Si SQL no acepta LIKE aquí, puede reemplazarse por una validación con LEN()
);
GO

---------------------------------------------------------------------------------------------------------------------------

-- 4) Tabla: Inscripcion (Relación M:N entre Estudiantes y Carreras)
    CREATE TABLE Inscripcion (
    ID_Inscripcion INT IDENTITY(1,1) PRIMARY KEY,
    ID_Est         INT NOT NULL,
    Car_Nom        NVARCHAR(60) NOT NULL,
    Turno          NVARCHAR(20) NOT NULL,

    CONSTRAINT ukIns UNIQUE (ID_Est, Car_Nom, Turno),

    CONSTRAINT FK_Inscripcion_ID_Est FOREIGN KEY (ID_Est)
        REFERENCES Estudiantes(ID_Est) ON DELETE CASCADE,

    CONSTRAINT FK_Inscripcion_ID_Car FOREIGN KEY (Car_Nom, Turno)
        REFERENCES Carreras(Car_Nom, Turno) ON DELETE CASCADE
);
GO

---------------------------------------------------------------------------------------------------------------------------

-- 5) Tabla: Inf_Academica
CREATE TABLE Inf_Academica (
    ID_Inf_Aca         INT IDENTITY(1,1) PRIMARY KEY,
    Inf_Aca_Descripcion NVARCHAR(50) UNIQUE NOT NULL,
    Inf_Aca_Fecha      DATE NOT NULL,   -- Fecha de creación o vigencia
    Inf_Aca_Estado     VARCHAR(15) NOT NULL DEFAULT 'DESHABILITADO',

    CONSTRAINT CK_Inf_Aca_Estado CHECK (Inf_Aca_Estado IN ('HABILITADO', 'DESHABILITADO'))
);
GO

---------------------------------------------------------------------------------------------------------------------------

-- 6) Tabla: Inf_Academica_Est (Relación M:N entre Estudiantes e Inf_Academica)
CREATE TABLE Inf_Academica_Est (
    ID_Inf_Academica_Est INT IDENTITY(1,1) PRIMARY KEY,
    ID_Inf_Aca            INT NOT NULL,
    ID_Est                INT NOT NULL,

    CONSTRAINT UkEstInfAcaUnico UNIQUE (ID_Inf_Aca, ID_Est),

    CONSTRAINT FK_Inf_Academica_Est_ID_Est FOREIGN KEY (ID_Est)
        REFERENCES Estudiantes(ID_Est) ON DELETE CASCADE,

    CONSTRAINT FK_Inf_Academica_Est_ID_Inf FOREIGN KEY (ID_Inf_Aca)
        REFERENCES Inf_Academica(ID_Inf_Aca) ON DELETE CASCADE
);
GO

---------------------------------------------------------------------------------------------------------------------------

-- 7) Tabla: Habilitacion_Formulario
CREATE TABLE Habilitacion_Formulario (
    ID_Hab_Form   INT IDENTITY(1,1) PRIMARY KEY,
    Hab_Form_Año  INT UNIQUE NOT NULL,
    Hab_Form_Fecha DATE NOT NULL  -- Fecha de apertura de inscripción para el próximo ciclo
);
GO
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
-- STORE PROCEDURES
---------------------------------------------------------------------------------------------------------------------------

-- =============================================
-- PROCEDIMIENTOS DEL ESTUDIANTE
-- =============================================

-- 1) PROCEDIMIENTO: Insertar Estudiante
CREATE PROCEDURE Estudiantes_Insert
    @Est_Nom_Ape      NVARCHAR(200),
    @Est_Edad         INT,
    @Est_DNI          INT,
    @Est_Nacionalidad VARCHAR(50),
    @Est_Correo       VARCHAR(50),
    @Est_Telefono     VARCHAR(20),
    @Est_Fecha_Nac    DATE,
    @Est_Direccion    NVARCHAR(80),
    @Est_Titulo_Sec   VARCHAR(100),
    @Est_Año_Egreso   DATE
AS
BEGIN
    INSERT INTO Estudiantes (
        Est_Nom_Ape,
        Est_Edad,
        Est_DNI,
        Est_Nacionalidad,
        Est_Correo,
        Est_Telefono,
        Est_Fecha_Nac,
        Est_Direccion,
        Est_Titulo_Sec,
        Est_Año_Egreso
    )
    VALUES (
        @Est_Nom_Ape,
        @Est_Edad,
        @Est_DNI,
        @Est_Nacionalidad,
        @Est_Correo,
        @Est_Telefono,
        @Est_Fecha_Nac,
        @Est_Direccion,
        @Est_Titulo_Sec,
        @Est_Año_Egreso
    );
END;
GO

---------------------------------------------------------------------------------------------------------------------------
-- JUEGO DE DATOS DE PRUEBA: ESTUDIANTES
---------------------------------------------------------------------------------------------------------------------------

-- Ejemplo 1
EXEC Estudiantes_Insert 
    'Laura Gómez', 
    18, 
    42789123, 
    'Argentina', 
    'lauragomez@gmail.com', 
    '1134567890', 
    '2007-12-03', 
    'Av. Corrientes 1245',
    'Secundario', 
    '2025-11-10';
GO

-- Ejemplo 2
EXEC Estudiantes_Insert 
    'Lucía Fernández', 
    19, 
    45812345, 
    'Argentina', 
    'lucia.fernandez@gmail.com', 
    '1123345566', 
    '2006-08-22', 
    'San Martín 234',
    'Secundario', 
    '2023-08-20';
GO

-- Ejemplo 3
EXEC Estudiantes_Insert 
    'Joaquín López', 
    20, 
    47256321, 
    'Argentina', 
    'joaquin.lopez@hotmail.com', 
    '1132214455', 
    '2004-11-05', 
    'Mitre 1200',
    'Secundario', 
    '2023-12-15';
GO

-- Ejemplo 4
EXEC Estudiantes_Insert 
    'Valentina Pérez', 
    20, 
    46987412, 
    'Argentina', 
    'valentina.perez@gmail.com', 
    '1145879955', 
    '2005-01-18', 
    'Belgrano 680',
    'Secundario', 
    '2023-06-10';
GO

-- Ejemplo 5
EXEC Estudiantes_Insert 
    'Santiago Romero', 
    20, 
    46652148, 
    'Argentina', 
    'santiago.romero@outlook.com', 
    '1129987744', 
    '2005-06-25', 
    'Rivadavia 1500',
    'Secundario', 
    '2023-12-20';
GO

-- Ejemplo 6
EXEC Estudiantes_Insert 
    'Camila Rodríguez', 
    19, 
    47123987, 
    'Argentina', 
    'camila.rodriguez@gmail.com', 
    '1165432233', 
    '2006-10-11', 
    'Moreno 800',
    'Secundario', 
    '2024-11-30';
GO

-- Ejemplo 7
EXEC Estudiantes_Insert 
    'Matías González', 
    20, 
    46897532, 
    'Argentina', 
    'matias.gonzalez@yahoo.com', 
    '1178996655', 
    '2005-02-09', 
    'Sarmiento 450',
    'Secundario', 
    '2023-09-12';
GO

---------------------------------------------------------------------------------------------------------------------------
-- VERIFICAR INSERCIÓN DE REGISTROS
---------------------------------------------------------------------------------------------------------------------------
SELECT * FROM Estudiantes;
GO
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
-- PROCEDIMIENTOS DE CARRERA
---------------------------------------------------------------------------------------------------------------------------

-- =============================================
-- 1) PROCEDIMIENTO: Insertar Carrera
-- =============================================
CREATE PROCEDURE sp_InsertarCarrera
    @Nombre       NVARCHAR(60),
    @Turno        NVARCHAR(20),
    @PlanEstudio  CHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Carreras (Car_Nom, Turno, Car_PlanEstudio)
    VALUES (@Nombre, @Turno, @PlanEstudio);
END;
GO

---------------------------------------------------------------------------------------------------------------------------
-- JUEGO DE DATOS DE PRUEBA: CARRERAS (INSERT)
---------------------------------------------------------------------------------------------------------------------------

EXEC sp_InsertarCarrera 'PROFESORADO DE ECONOMÍA', 'MAÑANA', '0001/11';
EXEC sp_InsertarCarrera 'PROFESORADO DE ELECTROMECÁNICA', 'VESPERTINO', '0002/22';
EXEC sp_InsertarCarrera 'PROFESORADO DE ELECTRÓNICA', 'VESPERTINO', '0003/33';
EXEC sp_InsertarCarrera 'PROFESORADO DE FÍSICA', 'TARDE', '0004/44';
EXEC sp_InsertarCarrera 'PROFESORADO DE MATEMÁTICA', 'MAÑANA', '0005/55';
EXEC sp_InsertarCarrera 'PROFESORADO DE MATEMÁTICA', 'VESPERTINO', '0005/55';
EXEC sp_InsertarCarrera 'TECNICATURA SUPERIOR EN ANÁLISIS DE SISTEMAS', 'VESPERTINO', '0006/66';
EXEC sp_InsertarCarrera 'TECNICATURA SUPERIOR EN BIBLIOTECOLOGÍA', 'VESPERTINO', '0007/77';
EXEC sp_InsertarCarrera 'TECNICATURA SUPERIOR EN BIBLIOTECOLOGÍA DE INSTITUCIONES EDUCATIVAS', 'VESPERTINO', '0008/88';
EXEC sp_InsertarCarrera 'TECNICATURA SUPERIOR EN MANTENIMIENTO INDUSTRIAL', 'VESPERTINO', '0009/99';
GO

-- Verificar inserciones
SELECT * FROM Carreras;
GO

---------------------------------------------------------------------------------------------------------------------------
-- 2) PROCEDIMIENTO: Modificar Carrera
-- =============================================
CREATE PROCEDURE sp_ModificarCarrera
    @ID_Car INT,
    @Nombre NVARCHAR(60),
    @Turno  NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Carreras
    SET Car_Nom = @Nombre,
        Turno   = @Turno
    WHERE ID_Car = @ID_Car;
END;
GO

---------------------------------------------------------------------------------------------------------------------------
-- JUEGO DE DATOS DE PRUEBA: CARRERAS (UPDATE)
---------------------------------------------------------------------------------------------------------------------------

EXEC sp_ModificarCarrera 1, 'PROFESORADO DE ECONOMÍA', 'VESPERTINO';
GO

-- Verificar actualización
SELECT * FROM Carreras;
GO

---------------------------------------------------------------------------------------------------------------------------
-- 3) PROCEDIMIENTO: Eliminar Carrera
-- =============================================
CREATE PROCEDURE sp_EliminarCarrera
    @ID_Car INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Carreras 
    WHERE ID_Car = @ID_Car;

    PRINT 'Carrera eliminada correctamente.';
END;
GO

---------------------------------------------------------------------------------------------------------------------------
-- JUEGO DE DATOS DE PRUEBA: CARRERAS (DELETE)
---------------------------------------------------------------------------------------------------------------------------

EXEC sp_EliminarCarrera 10;
GO

-- Verificar eliminación
SELECT * FROM Carreras;
GO
---------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------
-- PROCEDIMIENTOS DE INFORMACIÓN ACADÉMICA
---------------------------------------------------------------------------------------------------------------------------

-- =============================================
-- 1) PROCEDIMIENTO: Insertar Información Académica
-- =============================================
CREATE PROCEDURE Inf_Academica_Insert
    @Inf_Aca_Descripcion VARCHAR(50),
    @Inf_Aca_Fecha       DATE,
    @Inf_Aca_Estado      VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Inf_Academica (Inf_Aca_Descripcion, Inf_Aca_Fecha, Inf_Aca_Estado)
    VALUES (@Inf_Aca_Descripcion, @Inf_Aca_Fecha, @Inf_Aca_Estado);
END;
GO

---------------------------------------------------------------------------------------------------------------------------
-- JUEGO DE DATOS DE PRUEBA: INSERCIÓN DE INFORMACIÓN ACADÉMICA
---------------------------------------------------------------------------------------------------------------------------

EXEC Inf_Academica_Insert 'Título', '2025-11-01', 'HABILITADO';
EXEC Inf_Academica_Insert 'Título en trámite', '2025-11-01', 'HABILITADO';
EXEC Inf_Academica_Insert 'Constancia de materias adeudadas', '2025-11-01', 'HABILITADO';
EXEC Inf_Academica_Insert 'Constancia de alumno regular', '2025-11-01', 'HABILITADO';
EXEC Inf_Academica_Insert 'Primario', '2025-11-01', 'DESHABILITADO';
GO

-- Verificar inserciones
SELECT * FROM Inf_Academica;
GO

---------------------------------------------------------------------------------------------------------------------------
-- 2) PROCEDIMIENTO: Actualizar Información Académica
-- =============================================
CREATE PROCEDURE Inf_Academica_Update
    @ID_Inf_Aca        INT,
    @Nueva_Descripcion VARCHAR(100),
    @Nueva_Fecha       DATE,
    @Nuevo_Estado      VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Inf_Academica
    SET Inf_Aca_Descripcion = @Nueva_Descripcion,
        Inf_Aca_Fecha       = @Nueva_Fecha,
        Inf_Aca_Estado      = @Nuevo_Estado
    WHERE ID_Inf_Aca = @ID_Inf_Aca;
END;
GO

---------------------------------------------------------------------------------------------------------------------------
-- JUEGO DE DATOS DE PRUEBA: ACTUALIZACIÓN DE INFORMACIÓN ACADÉMICA
---------------------------------------------------------------------------------------------------------------------------

EXEC Inf_Academica_Update 1, 'Título', '2025-11-01', 'DESHABILITADO';
EXEC Inf_Academica_Update 2, 'Título en trámite', '2025-11-01', 'DESHABILITADO';
EXEC Inf_Academica_Update 3, 'Constancia de materias adeudadas', '2025-11-01', 'DESHABILITADO';
EXEC Inf_Academica_Update 4, 'Constancia de alumno regular', '2025-11-01', 'DESHABILITADO';
EXEC Inf_Academica_Update 5, 'Primario', '2025-11-01', 'HABILITADO';
GO

-- Verificar actualizaciones
SELECT * FROM Inf_Academica;
GO

---------------------------------------------------------------------------------------------------------------------------
-- 3) PROCEDIMIENTO: Eliminar Información Académica
-- =============================================
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

---------------------------------------------------------------------------------------------------------------------------
-- JUEGO DE DATOS DE PRUEBA: ELIMINACIÓN DE INFORMACIÓN ACADÉMICA
---------------------------------------------------------------------------------------------------------------------------

EXEC Inf_Academica_Delete 1;
EXEC Inf_Academica_Delete 2;
GO

-- Verificar eliminación
SELECT * FROM Inf_Academica;
GO
---------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------
-- PROCEDIMIENTOS DE INFORMACIÓN ACADÉMICA - ESTUDIANTE
---------------------------------------------------------------------------------------------------------------------------

-- =============================================
-- 1) PROCEDIMIENTO: Insertar Relación Info Académica ? Estudiante
-- =============================================
CREATE PROCEDURE Inf_Academica_Est_Insert
    @ID_Inf_Aca INT,
    @ID_Est     INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Inf_Academica_Est (ID_Inf_Aca, ID_Est)
    VALUES (@ID_Inf_Aca, @ID_Est);
END;
GO

---------------------------------------------------------------------------------------------------------------------------
-- JUEGO DE DATOS DE PRUEBA: INSERTAR RELACIONES INFO ACADÉMICA - ESTUDIANTE
---------------------------------------------------------------------------------------------------------------------------

EXEC Inf_Academica_Est_Insert @ID_Inf_Aca = 3, @ID_Est = 1;
EXEC Inf_Academica_Est_Insert @ID_Inf_Aca = 5, @ID_Est = 4;
EXEC Inf_Academica_Est_Insert @ID_Inf_Aca = 4, @ID_Est = 5;
EXEC Inf_Academica_Est_Insert @ID_Inf_Aca = 3, @ID_Est = 6;
EXEC Inf_Academica_Est_Insert @ID_Inf_Aca = 5, @ID_Est = 7;
GO

-- Verificar inserciones
SELECT * FROM Inf_Academica_Est;
GO
---------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------
-- PROCEDIMIENTOS DE INSCRIPCIÓN
---------------------------------------------------------------------------------------------------------------------------

-- =============================================
-- 1) PROCEDIMIENTO: Agregar Inscripción
-- =============================================
CREATE PROCEDURE Agregar_Inscripcion
    @ID_Est    INT,
    @Car_Nom   NVARCHAR(60),
    @Turno     NVARCHAR(20),
    @Mensaje   NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Verificar si ya existe la inscripción
        IF EXISTS (
            SELECT 1 
            FROM Inscripcion 
            WHERE ID_Est = @ID_Est 
              AND Car_Nom = @Car_Nom 
              AND Turno = @Turno
        )
        BEGIN
            SET @Mensaje = N'La inscripción ya existe para este estudiante y carrera.';
        END
        ELSE
        BEGIN
            -- Insertar nueva inscripción
            INSERT INTO Inscripcion (ID_Est, Car_Nom, Turno)
            VALUES (@ID_Est, @Car_Nom, @Turno);

            SET @Mensaje = N'Inscripción creada exitosamente.';
        END
    END TRY
    BEGIN CATCH
        SET @Mensaje = ERROR_MESSAGE();
    END CATCH
END;
GO

---------------------------------------------------------------------------------------------------------------------------
-- JUEGO DE DATOS DE PRUEBA: INSERTAR INSCRIPCIONES
---------------------------------------------------------------------------------------------------------------------------

DECLARE @Resultado1 NVARCHAR(255);
EXEC Agregar_Inscripcion 1, 'PROFESORADO DE ECONOMÍA', 'VESPERTINO', @Resultado1 OUTPUT;
SELECT @Resultado1 AS Mensaje;

DECLARE @Resultado2 NVARCHAR(255);
EXEC Agregar_Inscripcion 4, 'PROFESORADO DE ECONOMÍA', 'VESPERTINO', @Resultado2 OUTPUT;
SELECT @Resultado2 AS Mensaje;

DECLARE @Resultado3 NVARCHAR(255);
EXEC Agregar_Inscripcion 5, 'PROFESORADO DE MATEMÁTICA', 'MAÑANA', @Resultado3 OUTPUT;
SELECT @Resultado3 AS Mensaje;

DECLARE @Resultado4 NVARCHAR(255);
EXEC Agregar_Inscripcion 6, 'PROFESORADO DE ELECTRÓNICA', 'VESPERTINO', @Resultado4 OUTPUT;
SELECT @Resultado4 AS Mensaje;

DECLARE @Resultado5 NVARCHAR(255);
EXEC Agregar_Inscripcion 7, 'TECNICATURA SUPERIOR EN ANÁLISIS DE SISTEMAS', 'VESPERTINO', @Resultado5 OUTPUT;
SELECT @Resultado5 AS Mensaje;

DECLARE @Resultado6 NVARCHAR(255);
EXEC Agregar_Inscripcion 8, 'PROFESORADO DE ELECTROMECÁNICA', 'VESPERTINO', @Resultado6 OUTPUT;
SELECT @Resultado6 AS Mensaje;

DECLARE @Resultado7 NVARCHAR(255);
EXEC Agregar_Inscripcion 9, 'PROFESORADO DE FÍSICA', 'TARDE', @Resultado7 OUTPUT;
SELECT @Resultado7 AS Mensaje;

DECLARE @Resultado8 NVARCHAR(255);
EXEC Agregar_Inscripcion 10, 'TECNICATURA SUPERIOR EN BIBLIOTECOLOGÍA', 'VESPERTINO', @Resultado8 OUTPUT;
SELECT @Resultado8 AS Mensaje;
GO

-- Verificar inscripciones
SELECT * FROM Inscripcion;
GO

---------------------------------------------------------------------------------------------------------------------------
-- 2) PROCEDIMIENTO: Eliminar Inscripción
-- =============================================
CREATE PROCEDURE Eliminar_Inscripcion
    @ID_Inscripcion INT,
    @Mensaje         NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Inscripcion WHERE ID_Inscripcion = @ID_Inscripcion)
        BEGIN
            DELETE FROM Inscripcion
            WHERE ID_Inscripcion = @ID_Inscripcion;

            SET @Mensaje = N'Inscripción eliminada correctamente.';
        END
        ELSE
        BEGIN
            SET @Mensaje = N'No se encontró la inscripción indicada.';
        END
    END TRY
    BEGIN CATCH
        SET @Mensaje = ERROR_MESSAGE();
    END CATCH
END;
GO

---------------------------------------------------------------------------------------------------------------------------
-- JUEGO DE DATOS DE PRUEBA: ELIMINAR INSCRIPCIÓN
---------------------------------------------------------------------------------------------------------------------------

DECLARE @ResultadoElim NVARCHAR(255);
EXEC Eliminar_Inscripcion 1, @ResultadoElim OUTPUT;
SELECT @ResultadoElim AS Mensaje;
GO

---------------------------------------------------------------------------------------------------------------------------
-- 3) PROCEDIMIENTO: Modificar Inscripción
-- =============================================
CREATE PROCEDURE Modificar_Inscripcion
    @ID_Inscripcion INT,
    @ID_Est         INT,
    @Car_Nom        NVARCHAR(60),
    @Turno          NVARCHAR(20),
    @Mensaje        NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Inscripcion WHERE ID_Inscripcion = @ID_Inscripcion)
        BEGIN
            -- Validar duplicado
            IF EXISTS (
                SELECT 1
                FROM Inscripcion
                WHERE ID_Est = @ID_Est
                  AND Car_Nom = @Car_Nom
                  AND Turno = @Turno
                  AND ID_Inscripcion <> @ID_Inscripcion
            )
            BEGIN
                SET @Mensaje = N'Ya existe otra inscripción con los mismos datos.';
            END
            ELSE
            BEGIN
                UPDATE Inscripcion
                SET ID_Est  = @ID_Est,
                    Car_Nom = @Car_Nom,
                    Turno   = @Turno
                WHERE ID_Inscripcion = @ID_Inscripcion;

                SET @Mensaje = N'Inscripción modificada correctamente.';
            END
        END
        ELSE
        BEGIN
            SET @Mensaje = N'No se encontró la inscripción indicada.';
        END
    END TRY
    BEGIN CATCH
        SET @Mensaje = ERROR_MESSAGE();
    END CATCH
END;
GO

---------------------------------------------------------------------------------------------------------------------------
-- JUEGO DE DATOS DE PRUEBA: MODIFICAR INSCRIPCIÓN
---------------------------------------------------------------------------------------------------------------------------

DECLARE @ResultadoMod NVARCHAR(255);
EXEC Modificar_Inscripcion 
    2, 
    4, 
    'PROFESORADO DE ELECTROMECÁNICA', 
    'VESPERTINO',  
    @ResultadoMod OUTPUT;

SELECT @ResultadoMod AS Mensaje;
GO

-- Verificar modificaciones
SELECT * FROM Inscripcion;
GO
---------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------
-- PROCEDIMIENTOS DE ADMINISTRADORES
---------------------------------------------------------------------------------------------------------------------------

-- =============================================
-- 1) PROCEDIMIENTO: Logueo de Administrador
-- =============================================
CREATE PROCEDURE Logueo_Admin
    @Admin_Nom_Usuario VARCHAR(30),
    @Admin_Contra       VARCHAR(30),
    @Mensaje            NVARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM Admins
        WHERE Admin_Nom_Usuario = @Admin_Nom_Usuario
          AND Admin_Contra = @Admin_Contra
    )
        SET @Mensaje = N'Logueo exitoso.';
    ELSE
        SET @Mensaje = N'Nombre de usuario o contraseña incorrectos.';
END;
GO

---------------------------------------------------------------------------------------------------------------------------
-- JUEGO DE DATOS DE PRUEBA: LOGUEO DE ADMINISTRADOR
---------------------------------------------------------------------------------------------------------------------------
DECLARE @ResultadoLog1 NVARCHAR(100);
EXEC Logueo_Admin 'juanp', 'pass123', @ResultadoLog1 OUTPUT;
SELECT @ResultadoLog1 AS Mensaje;

DECLARE @ResultadoLog2 NVARCHAR(100);
EXEC Logueo_Admin 'mariag', 'wrongpass', @ResultadoLog2 OUTPUT;
SELECT @ResultadoLog2 AS Mensaje;
GO

---------------------------------------------------------------------------------------------------------------------------
-- 2) PROCEDIMIENTO: Agregar Administrador
-- =============================================
CREATE PROCEDURE Agregar_Admin
    @Admin_Nom_Ape      VARCHAR(50),
    @Admin_DNI          VARCHAR(8),
    @Admin_Tipo_DNI     VARCHAR(40),
    @Admin_Nom_Usuario  VARCHAR(30),
    @Admin_Contraseña   VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Admins (Admin_Nom_Ape, Admin_DNI, Admin_Tipo_DNI, Admin_Nom_Usuario, Admin_Contra)
    VALUES (@Admin_Nom_Ape, @Admin_DNI, @Admin_Tipo_DNI, @Admin_Nom_Usuario, @Admin_Contraseña);
END;
GO

---------------------------------------------------------------------------------------------------------------------------
-- JUEGO DE DATOS DE PRUEBA: INSERTAR ADMINISTRADORES
---------------------------------------------------------------------------------------------------------------------------
EXEC Agregar_Admin 'Juan Pérez', '11111111', 'DNI', 'juanp', 'pass123';
EXEC Agregar_Admin 'María Gómez', '22222222', 'DNI', 'mariag', 'pass456';

SELECT * FROM Admins;
GO

---------------------------------------------------------------------------------------------------------------------------
-- 3) PROCEDIMIENTO: Modificar Administrador
-- =============================================
CREATE PROCEDURE Modificar_Admin
    @Admin_Nom_Usuario      VARCHAR(30),
    @Nuevo_Admin_Nom_Ape    VARCHAR(50),
    @Nuevo_Admin_DNI        VARCHAR(8),
    @Nuevo_Admin_Nom_Usuario VARCHAR(30),
    @Nuevo_Admin_Contra     VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Admins
    SET
        Admin_Nom_Ape     = @Nuevo_Admin_Nom_Ape,
        Admin_DNI         = @Nuevo_Admin_DNI,
        Admin_Nom_Usuario = @Nuevo_Admin_Nom_Usuario,
        Admin_Contra      = @Nuevo_Admin_Contra
    WHERE Admin_Nom_Usuario = @Admin_Nom_Usuario;
END;
GO

---------------------------------------------------------------------------------------------------------------------------
-- JUEGO DE DATOS DE PRUEBA: MODIFICAR ADMINISTRADOR
---------------------------------------------------------------------------------------------------------------------------
EXEC Modificar_Admin 'juanp', 'Juan P. Pérez', '11111111', 'juanp1', 'newpass123';
EXEC Modificar_Admin 'mariag', 'María G. Gómez', '22222222', 'mariag1', 'newpass456';

SELECT * FROM Admins;
GO

---------------------------------------------------------------------------------------------------------------------------
-- 4) PROCEDIMIENTO: Eliminar Administrador
-- =============================================
CREATE PROCEDURE Eliminar_Admin
    @ID_Admin INT,
    @Mensaje  NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Admins WHERE ID_Admin = @ID_Admin)
        BEGIN
            DELETE FROM Admins
            WHERE ID_Admin = @ID_Admin;

            -- Si ya no quedan administradores, crear uno genérico
            IF NOT EXISTS (SELECT 1 FROM Admins)
            BEGIN
                INSERT INTO Admins (Admin_Nom_Ape, Admin_DNI, Admin_Tipo_DNI, Admin_Nom_Usuario, Admin_Contra)
                VALUES ('Administrador General', '00000000', 'DNI', 'admin', 'admin123456');

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

---------------------------------------------------------------------------------------------------------------------------
-- JUEGO DE DATOS DE PRUEBA: ELIMINAR ADMINISTRADOR
---------------------------------------------------------------------------------------------------------------------------
DECLARE @ResultadoDel1 NVARCHAR(255);
EXEC Eliminar_Admin 1, @ResultadoDel1 OUTPUT;
SELECT @ResultadoDel1 AS Mensaje;

DECLARE @ResultadoDel2 NVARCHAR(255);
EXEC Eliminar_Admin 2, @ResultadoDel2 OUTPUT;
SELECT @ResultadoDel2 AS Mensaje;

SELECT * FROM Admins;
GO
---------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------
-- PROCEDIMIENTOS DE HABILITACIÓN DE FORMULARIO
---------------------------------------------------------------------------------------------------------------------------

-- =============================================
-- 1) PROCEDIMIENTO: Insertar habilitación de formulario
-- =============================================
CREATE PROCEDURE sp_Insert_Habilitacion_Formulario
    @Hab_Form_Año   INT,
    @Hab_Form_Fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Habilitacion_Formulario (Hab_Form_Año, Hab_Form_Fecha)
    VALUES (@Hab_Form_Año, @Hab_Form_Fecha);
END;
GO

-- JUEGO DE DATOS: INSERTAR HABILITACIONES
EXEC sp_Insert_Habilitacion_Formulario 2026, '2025-11-15';
EXEC sp_Insert_Habilitacion_Formulario 2027, '2026-11-20';

SELECT * FROM Habilitacion_Formulario;
GO

---------------------------------------------------------------------------------------------------------------------------
-- 2) PROCEDIMIENTO: Actualizar fecha de habilitación de formulario
-- =============================================
CREATE PROCEDURE sp_Update_Habilitacion_Formulario
    @ID_Hab_Form    INT,
    @Hab_Form_Fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Habilitacion_Formulario
    SET Hab_Form_Fecha = @Hab_Form_Fecha
    WHERE ID_Hab_Form = @ID_Hab_Form;
END;
GO

-- JUEGO DE DATOS: ACTUALIZAR FECHA
EXEC sp_Update_Habilitacion_Formulario 1, '2025-11-10';
EXEC sp_Update_Habilitacion_Formulario 2, '2026-12-01';

SELECT * FROM Habilitacion_Formulario;
GO

---------------------------------------------------------------------------------------------------------------------------
-- 3) PROCEDIMIENTO: Eliminar habilitación de formulario
-- =============================================
CREATE PROCEDURE sp_Delete_Habilitacion_Formulario
    @ID_Hab_Form INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Habilitacion_Formulario
    WHERE ID_Hab_Form = @ID_Hab_Form;
END;
GO

-- JUEGO DE DATOS: ELIMINAR HABILITACIÓN
EXEC sp_Delete_Habilitacion_Formulario 1;

SELECT * FROM Habilitacion_Formulario;
GO
---------------------------------------------------------------------------------------------------------------------------

--LISTA DE CARRERAS CON SUS TURNOS Y PLAN DE ESTUDIO

CREATE PROCEDURE sp_Listar_Carreras_Turnos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Car_Nom AS [Nombre_Carrera],
        Turno AS [Turno],
        Car_PlanEstudio AS [Plan_Estudio]
    FROM Carreras
    ORDER BY Car_Nom, Turno;
END;
GO

EXEC sp_Listar_Carreras_Turnos;
GO

--LISTA DE ESTUDIANTES CON SU CARRERA Y SU INFO ACADÉMICA

CREATE PROCEDURE sp_Listar_Estudiantes_Carreras_InfAca
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        E.ID_Est,
        E.Est_Nom_Ape AS [Nombre_Apellido],
        E.Est_DNI AS [DNI],
        E.Est_Correo AS [Correo],
        C.Car_Nom AS [Carrera],
        C.Turno AS [Turno],
        IA.Inf_Aca_Descripcion AS [Info_Academica],
        IA.Inf_Aca_Fecha AS [Fecha_Info],
        IA.Inf_Aca_Estado AS [Estado_Info]
    FROM Estudiantes E
    INNER JOIN Inscripcion I 
        ON E.ID_Est = I.ID_Est
    INNER JOIN Carreras C 
        ON I.Car_Nom = C.Car_Nom AND I.Turno = C.Turno
    LEFT JOIN Inf_Academica_Est IAE 
        ON E.ID_Est = IAE.ID_Est
    LEFT JOIN Inf_Academica IA 
        ON IAE.ID_Inf_Aca = IA.ID_Inf_Aca
    ORDER BY E.Est_Nom_Ape, C.Car_Nom;
END;
GO

EXEC sp_Listar_Estudiantes_Carreras_InfAca;
GO

--DESCOMENTAR Y USAR PARA PROBAR LA VERIFICACION DE QUE SI HAY DATOS PARA HACER UN EXCEL

--DELETE FROM Estudiantes;
--DELETE FROM Carreras;
--DELETE FROM Inf_Academica;
--TRUNCATE TABLE Inscripcion;
--TRUNCATE TABLE Inf_Academica_Est;
--GO
