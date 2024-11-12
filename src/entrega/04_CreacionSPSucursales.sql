--------------------------------------------------------------------
-------------------  Stored Procedures SUCURSAL  -------------------
--------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17;
GO

CREATE OR ALTER PROCEDURE Administracion.ImportarSucursalesDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @SQL NVARCHAR(MAX);

		CREATE TABLE #Sucursal (
			Ciudad VARCHAR(20) NOT NULL,
			Reemplazo VARCHAR(20) NOT NULL,
			Direccion VARCHAR(100) NOT NULL,
			Horario VARCHAR(45) NOT NULL,
			Telefono VARCHAR(10) NOT NULL
    );

        SET @SQL = N'BULK INSERT #Sucursal
                    FROM ''' + @RutaArchivo + ''' 
                    WITH (
                        FIELDTERMINATOR = '';'',  -- Cambia el separador según sea necesario
                        ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila según sea necesario
                        FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
                        CODEPAGE = ''65001''
                    );';
        
        EXEC sp_executesql @SQL;

		INSERT Administracion.Sucursal(Ciudad, Nombre, Direccion, Telefono, Horario)
		SELECT	su.Reemplazo,
				su.Ciudad,
				TRIM(REPLACE(su.Direccion, CHAR(160), '')), 
				su.Telefono, 
				REPLACE(su.Horario, '"', '') 
		FROM #Sucursal su
		WHERE NOT EXISTS (
            SELECT 1 
            FROM Administracion.Sucursal s
            WHERE s.Ciudad = su.Reemplazo 
              AND s.Direccion = TRIM(REPLACE(su.Direccion, CHAR(160), ''))
        );

		DROP TABLE #Sucursal

		PRINT('+ Importación de sucursales completada exitosamente.');
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la importación de sucursales: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Administracion.InsertarSucursal
	@Ciudad VARCHAR(20),
	@Nombre VARCHAR(20),
	@Direccion VARCHAR(100),
    @Horario VARCHAR(45),
    @Telefono VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

	-- Verificar si esa sucursal ya existe
	IF EXISTS (SELECT 1 FROM Administracion.Sucursal WHERE Direccion = @Direccion and Ciudad = @Ciudad)	
        BEGIN
            RAISERROR('+ La sucursal  ya existe. Terminando el procedimiento.', 16, 1);
            RETURN;
    END

	-- Insertar nuevo registro
	INSERT INTO Administracion.Sucursal VALUES (@Ciudad,@Nombre,@Direccion,@Horario,@Telefono);

	COMMIT TRANSACTION;  -- Confirmar transacción

        PRINT('+ Sucursal insertada con éxito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la inserción de la sucursal: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Administracion.ActualizarSucursal
	@Ciudad VARCHAR(20)=NULL,
	@Nombre VARCHAR(20)=NULL,
	@Direccion VARCHAR(100)=NULL,
    @Horario VARCHAR(45)=NULL,
    @Telefono VARCHAR(10)=NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

	-- Verificar si esa sucursal ya existe
	IF NOT EXISTS (SELECT 1 FROM Administracion.Sucursal WHERE Direccion = @Direccion and Ciudad=@Ciudad)	
        BEGIN
            RAISERROR('+ La sucursal no existe. Terminando el procedimiento.', 16, 1);
            RETURN;
    END

	-- Insertar nuevo registro
	UPDATE Administracion.Sucursal
	SET	Horario =  CASE WHEN @Horario IS NOT NULL THEN @Horario ELSE (SELECT Horario FROM Administracion.Sucursal WHERE Direccion=@Direccion and Ciudad=@Ciudad) END,
	Nombre = CASE WHEN @Nombre IS NOT NULL THEN @Nombre ELSE (SELECT Nombre FROM Administracion.Sucursal WHERE Direccion=@Direccion and Ciudad=@Ciudad) END,
	Telefono = CASE WHEN @Telefono IS NOT NULL THEN @Telefono ELSE (SELECT Telefono FROM Administracion.Sucursal WHERE Direccion=@Direccion and Ciudad=@Ciudad) END
	WHERE Direccion=@Direccion and Ciudad=@Ciudad
	COMMIT TRANSACTION;  -- Confirmar transacción

        PRINT('+ Sucursal actualizada con éxito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la actualización de la sucursal: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarSucursal
	@Ciudad VARCHAR(20)=NULL,
    @Direccion VARCHAR(100)=NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si se proporcionó algún parámetro válido
    IF @Ciudad IS NULL OR @Direccion IS NULL
    BEGIN
        RAISERROR('+ Debe proporcionar la ciudad y la dirección para eliminar una sucursal.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

        -- Buscar empleado y eliminar
        DELETE FROM Administracion.Sucursal 
        WHERE (Ciudad = @Ciudad AND Direccion = @Direccion);

        IF @@ROWCOUNT = 0  -- Verificar si se eliminó algún registro
        BEGIN
            RAISERROR('+ Sucursal inexistente.', 16, 1);
            RETURN;
        END

        COMMIT TRANSACTION;  -- Confirmar transacción

        PRINT('+ Sucurusal eliminada con éxito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la eliminación de la sucursal: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO