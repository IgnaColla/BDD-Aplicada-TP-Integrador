-------------------------------------------------------------------
-------------------  Stored Procedures ENCRIPTACION -------------------
-------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17;
GO
/*
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Boquitaelmasgrande';
GO

-- Crear un certificado para encriptación
CREATE CERTIFICATE CertEmpleado WITH SUBJECT = 'Encriptacion_empleados';
GO

-- Crear la clave simétrica, encriptada por el certificado
CREATE SYMMETRIC KEY SimmKeyEmpleado
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE CertEmpleado;
GO
*/

CREATE OR ALTER PROCEDURE Administracion.AgregarColumnasEncriptadasEmpleado
    @Columnas NVARCHAR(MAX)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @Columna NVARCHAR(128);
    DECLARE @Posicion INT = 1;

    -- Recorrer las columnas que llegan como parámetro
    WHILE @Posicion > 0
    BEGIN
        -- Obtener la columna a partir de la posición actual
        SET @Posicion = CHARINDEX(',', @Columnas);

        IF @Posicion > 0
        BEGIN
            SET @Columna = SUBSTRING(@Columnas, 1, @Posicion - 1);
            SET @Columnas = SUBSTRING(@Columnas, @Posicion + 1, LEN(@Columnas));
        END
        ELSE
        BEGIN
            SET @Columna = @Columnas;
        END

        -- Verificar si la columna ya existe en la tabla
        IF NOT EXISTS (
            SELECT * 
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_NAME = 'Administracion.Empleado'
            AND COLUMN_NAME = @Columna
        )
        BEGIN
            -- Se agrega la columna que va a contener los datos encriptados
            SET @sql = 'ALTER TABLE Administracion.Empleado ADD ' + @Columna + ' VARBINARY(MAX);';

            EXEC sp_executesql @sql;
        END
    END
END
GO


CREATE OR ALTER PROCEDURE Administracion.EncriptarDatosEmpleado
    @Columnas NVARCHAR(MAX)  -- Lista de columnas separadas por comas
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX) = N'';
    DECLARE @Columna NVARCHAR(128);
    DECLARE @EncriptarColumna NVARCHAR(128);
    DECLARE @Posicion INT;

    -- Abrir la clave simétrica para encriptar
    OPEN SYMMETRIC KEY SimmKeyEmpleado
        DECRYPTION BY CERTIFICATE CertEmpleado;

    -- Procesar cada columna
    WHILE LEN(@Columnas) > 0
    BEGIN
        SET @Posicion = CHARINDEX(',', @Columnas);
        IF @Posicion > 0
        BEGIN
            SET @Columna = LTRIM(RTRIM(SUBSTRING(@Columnas, 1, @Posicion - 1)));
            SET @Columnas = LTRIM(SUBSTRING(@Columnas, @Posicion + 1, LEN(@Columnas)));
        END
        ELSE
        BEGIN
            SET @Columna = LTRIM(RTRIM(@Columnas));
            SET @Columnas = '';
        END

        SET @EncriptarColumna = @Columna + 'Encriptado';

        -- Encriptar los datos
        SET @sql += 'UPDATE Administracion.Empleado SET ' + @EncriptarColumna + 
                    ' = ENCRYPTBYKEY(KEY_GUID(''SimmKeyEmpleado''), CAST(' + @Columna + ' AS VARCHAR(255))) WHERE ' + @Columna + ' IS NOT NULL; ';
        
        -- Eliminar la columna original después de encriptar
        SET @sql += 'ALTER TABLE Administracion.Empleado DROP COLUMN ' + @Columna + '; ';
    END

    EXEC sp_executesql @sql;

    -- Cerrar la clave simétrica
    CLOSE SYMMETRIC KEY SimmKeyEmpleado;
END
GO


CREATE OR ALTER PROCEDURE Administracion.VerEmpleadoDesencriptado
    @Columnas NVARCHAR(MAX)  -- Lista de columnas separadas por comas
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX) = N'SELECT ';
    DECLARE @Columna NVARCHAR(128);
    DECLARE @EncriptarColumna NVARCHAR(128);
    DECLARE @Posicion INT;

    -- Abrir la clave simétrica para desencriptar
    OPEN SYMMETRIC KEY SimmKeyEmpleado
        DECRYPTION BY CERTIFICATE CertEmpleado;

    -- Procesar cada columna
    WHILE LEN(@Columnas) > 0
    BEGIN
        SET @Posicion = CHARINDEX(',', @Columnas);
        IF @Posicion > 0
        BEGIN
            SET @Columna = LTRIM(RTRIM(SUBSTRING(@Columnas, 1, @Posicion - 1)));
            SET @Columnas = LTRIM(SUBSTRING(@Columnas, @Posicion + 1, LEN(@Columnas)));
        END
        ELSE
        BEGIN
            SET @Columna = LTRIM(RTRIM(@Columnas));
            SET @Columnas = '';
        END

        -- Definir el nombre de la columna encriptada
        SET @EncriptarColumna = @Columna + 'Encriptado';

        SET @sql += 'CONVERT(VARCHAR(255), DECRYPTBYKEY(' + @EncriptarColumna + ')) AS ' + @Columna + ', ';
    END

    -- Eliminar la última coma y espacio
    SET @sql = LEFT(@sql, LEN(@sql) - 1);
    SET @sql += ' FROM Administracion.Empleado;';

    EXEC sp_executesql @sql;

    -- Cerrar la clave simétrica
    CLOSE SYMMETRIC KEY SimmKeyEmpleado;
END
GO