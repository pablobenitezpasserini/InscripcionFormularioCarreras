USE master;
GO

ALTER DATABASE FormularioInscripcionCarreras 
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

DROP DATABASE FormularioInscripcionCarreras;
GO