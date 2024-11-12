
---------------- Grupo 17 Integrantes---------------
-- Collazo Ignacio Lahuel,  41537099
-- Cartasegna Nahuel Nicolas,  41645704
-- Schiaffino Lautaro Leonardo Nicolas,  41646380
-- Boero Caterina Milagros,  41693349
---------------------------------------------------

----------------------------------------------------
-------------------  CREACION DB -------------------
----------------------------------------------------

-- ## CONVENCIONES ##
-- DB: Com2900G17
-- SCHEMAS: Administracion, Productos, Ventas
-- TABLAS: UpperCamelCase 
-- CAMPOS: UpperCamelCase
-- ROLES: UpperCamelCase

BEGIN TRY    
    -- Elimina la base de datos si ya existe
    USE master;
	DROP DATABASE IF EXISTS Com2900G17;
    
    -- Crea la base de datos
    CREATE DATABASE Com2900G17;

    -- Mensaje de éxito
	PRINT('+ La base de datos [Com2900G17] se ha creado correctamente.');
END TRY
BEGIN CATCH
    -- Captura y muestra el error si ocurre uno
    DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
    RAISERROR('+ Error al crear la base de datos [Com2900G17]: %s', 16, 1, @ErrorMessage);
END CATCH;
GO

USE Com2900G17;
GO