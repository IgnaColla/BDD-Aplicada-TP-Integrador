-- ## CONVENCIONES ##
-- DB: Com2900G17
-- SCHEMA: ddbba
-- TABLAS: UpperCamelCase 
-- CAMPOS: camel_case+
-- ROLES: UpperCamelCase

----------------------------------------------------
-------------------  CREACION DB -------------------
----------------------------------------------------

BEGIN TRY    
    -- Elimina la base de datos si ya existe
    IF DB_ID('Com2900G17') IS NOT NULL
    BEGIN
        USE master;
		DROP DATABASE Com2900G17;
    END
    
    -- Crea la base de datos
    CREATE DATABASE Com2900G17 COLLATE SQL_Latin1_General_CP1_CI_AS;

    -- Mensaje de éxito
	RAISERROR('+ La base de datos [Com2900G17] se ha creado correctamente.', 0, 1);
END TRY
BEGIN CATCH
    -- Captura y muestra el error si ocurre uno
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('+ Error al crear la base de datos [Com2900G17]: %s', 16, 1, @ErrorMessage);
END CATCH;

USE Com2900G17
