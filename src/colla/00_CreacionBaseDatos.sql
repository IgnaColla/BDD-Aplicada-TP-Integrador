----------------------------------------------------
-------------------  CREACION DB -------------------
----------------------------------------------------

BEGIN TRY    
    -- Elimina la base de datos si ya existe

    USE master;
	DROP DATABASE IF EXISTS Com2900G17;

    -- Crea la base de datos
    CREATE DATABASE Com2900G17 COLLATE SQL_Latin1_General_CP1_CI_AS;

    -- Mensaje de éxito
	PRINT('+ La base de datos [Com2900G17] se ha creado correctamente.');
END TRY

BEGIN CATCH
    -- Captura y muestra el error si ocurre uno
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('+ Error al crear la base de datos [Com2900G17]: %s', 16, 1, @ErrorMessage);
END CATCH;

USE Com2900G17
