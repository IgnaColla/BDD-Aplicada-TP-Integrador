--------------------------------------------------------------------
-------------------  Stored Procedures EMPLEADO  -------------------
--------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17;
GO

CREATE OR ALTER PROCEDURE Administracion.ImportarEmpleadosDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @SQL NVARCHAR(MAX);

		CREATE TABLE #Empleado (
			Legajo INT PRIMARY KEY,
			Nombre VARCHAR(50) NOT NULL,
			Apellido VARCHAR(50) NOT NULL,
			DNI CHAR(8) NOT NULL,
			Direccion VARCHAR(255) NOT NULL,
			EmailPersonal VARCHAR(100),
			EmailEmpresa VARCHAR(100),
			CUIL CHAR(11),
			Cargo VARCHAR(20),
			Sucursal VARCHAR(20),
			Turno VARCHAR(20)
		)

        SET @SQL = N'BULK INSERT #Empleado
                    FROM ''' + @RutaArchivo + ''' 
                    WITH (
                        FIELDTERMINATOR = '';'',  -- Cambia el separador seg�n sea necesario
                        ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila seg�n sea necesario
                        FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
                        KEEPNULLS,
                        CODEPAGE = ''ACP'',
                        TABLOCK
                    );';

        EXEC sp_executesql @SQL;

		INSERT Administracion.Cargo
		SELECT DISTINCT em.Cargo FROM #Empleado em
		WHERE NOT EXISTS (
            SELECT 1 
            FROM Administracion.Cargo c
            WHERE em.Cargo = c.Cargo
        );

		WITH EmpleadoUnico AS (
			SELECT 
				em.Legajo,
				REPLACE(em.Nombre, '"', '') AS Nombre,
				REPLACE(em.Apellido, '"', '') AS Apellido,
				em.DNI,
				em.Direccion,
				REPLACE(REPLACE(REPLACE(REPLACE(em.EmailPersonal, '"', ''), ' ', ''), CHAR(9), ''), CHAR(160), '') AS EmailPersonal,
				REPLACE(REPLACE(REPLACE(REPLACE(em.EmailEmpresa, '"', ''), ' ', ''), CHAR(9), ''), CHAR(160), '') AS EmailEmpresa,
				em.CUIL,
				ca.Id AS CargoId,
				su.Id AS SucursalId,
				em.Turno,
				'A' AS Estado,
				ROW_NUMBER() OVER (PARTITION BY em.Legajo ORDER BY su.Id) AS RowNum
			FROM #Empleado em
			INNER JOIN Administracion.Sucursal su ON em.Sucursal = su.Ciudad
			INNER JOIN Administracion.Cargo ca ON em.Cargo = ca.Cargo
			WHERE NOT EXISTS (
				SELECT 1 
				FROM Administracion.Empleado e
				WHERE em.Legajo = e.Legajo
			)
		)
		INSERT Administracion.Empleado
		SELECT 
			Legajo, 
			Nombre, 
			Apellido, 
			DNI, 
			Direccion, 
			EmailPersonal, 
			EmailEmpresa, 
			CUIL, 
			CargoId, 
			SucursalId, 
			Turno, 
			Estado
		FROM EmpleadoUnico
		WHERE RowNum = 1;

        PRINT '+ Importación de empleados completada exitosamente.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la importación de empleados: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Administracion.InsertarEmpleado
    @Legajo INT,
    @Nombre VARCHAR(50),
	@Apellido VARCHAR(50),
    @DNI CHAR(8),
    @Direccion VARCHAR(255),
    @EmailPersonal VARCHAR(100) = NULL,
    @EmailEmpresa VARCHAR(100) = NULL,
    @CUIL CHAR(11) = NULL,
    @Cargo VARCHAR(30),
    @Sucursal VARCHAR(20) = NULL,
    @Turno VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

        -- Verificar si el empleado ya existe
        IF EXISTS (SELECT 1 FROM Administracion.Empleado WHERE Legajo = @Legajo)	
        BEGIN
            RAISERROR('+ El empleado ya existe. Terminando el procedimiento.', 16, 1);
            RETURN;
        END

		DECLARE @IdCargo INT = CASE WHEN @Cargo IS NOT NULL THEN (SELECT Id FROM Administracion.Cargo WHERE Cargo = @Cargo)END;
		IF @IdCargo = NULL
			RAISERROR('+ El cargo no existe o no fue insertado. Terminando el procedimiento.', 16, 1);
		DECLARE @IdSucursal INT = CASE WHEN @Sucursal IS NOT NULL THEN (SELECT Id FROM Administracion.Sucursal WHERE Ciudad = @Sucursal) END;

        -- Insertar nuevo registro
        INSERT INTO Administracion.Empleado (Legajo, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, IdCargo, IdSucursal, Turno, Estado)
        VALUES (@Legajo, @Nombre, @Apellido, @DNI, @Direccion, @EmailPersonal, @EmailEmpresa, @CUIL, @IdCargo, @IdSucursal, @Turno, 'A');

        COMMIT TRANSACTION;  -- Confirmar transacción

        PRINT('+ Empleado insertado con éxito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la inserción del empleado: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE Administracion.ActualizarEmpleado
    @Legajo INT = NULL,
    @Nombre VARCHAR(50) = NULL,
	@Apellido VARCHAR(50) = NULL,
    @DNI CHAR(8) = NULL,
    @Direccion VARCHAR(255) = NULL,
    @EmailPersonal VARCHAR(100) = NULL,
    @EmailEmpresa VARCHAR(100) = NULL,
    @CUIL CHAR(11) = NULL,
    @Cargo VARCHAR(30) = NULL,
    @Sucursal VARCHAR(20) = NULL,
    @Turno VARCHAR(20) = NULL,
	@Estado CHAR(1) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

        -- Verificar si el empleado existe
        IF NOT EXISTS (SELECT 1 FROM Administracion.Empleado WHERE Legajo = @Legajo or DNI = @DNI)	
        BEGIN
            RAISERROR('+ El empleado ingresado no existe. Utilizar el procedimiento "InsertarEmpleado" para agregar un nuevo empleado.', 16, 1);
            RETURN;
        END

		DECLARE @IdCargo INT = CASE WHEN @Cargo IS NOT NULL THEN (SELECT Id FROM Administracion.Cargo WHERE Cargo = @Cargo)ELSE NULL END;
		DECLARE @IdSucursal INT = CASE WHEN @Sucursal IS NOT NULL THEN (SELECT Id FROM Administracion.Sucursal WHERE Ciudad = @Sucursal)ELSE NULL END;

        -- Actualizar empleado
        UPDATE Administracion.Empleado
        SET Nombre = CASE WHEN @Nombre IS NOT NULL THEN @Nombre ELSE (SELECT Nombre FROM Administracion.Empleado WHERE Legajo = @Legajo or DNI = @DNI) END,
            Apellido = CASE WHEN @Apellido IS NOT NULL THEN @Apellido ELSE (SELECT Apellido FROM Administracion.Empleado WHERE Legajo = @Legajo or DNI = @DNI) END,
            Direccion = CASE WHEN @Direccion IS NOT NULL THEN @Direccion ELSE (SELECT Direccion FROM Administracion.Empleado WHERE Legajo = @Legajo or DNI = @DNI) END,
            EmailPersonal = CASE WHEN @EmailPersonal IS NOT NULL THEN @EmailPersonal ELSE (SELECT EmailPersonal FROM Administracion.Empleado WHERE Legajo = @Legajo or DNI = @DNI) END,
            EmailEmpresa = CASE WHEN @EmailEmpresa IS NOT NULL THEN @EmailEmpresa ELSE (SELECT EmailEmpresa FROM Administracion.Empleado WHERE Legajo = @Legajo or DNI = @DNI) END,
            CUIL = CASE WHEN @CUIL IS NOT NULL THEN @CUIL ELSE (SELECT CUIL FROM Administracion.Empleado WHERE Legajo = @Legajo or DNI = @DNI) END,
            IdCargo = CASE WHEN @IdCargo IS NOT NULL THEN @IdCargo ELSE (SELECT IdCargo FROM Administracion.Empleado WHERE Legajo = @Legajo or DNI = @DNI) END,
            IdSucursal = CASE WHEN @IdSucursal IS NOT NULL THEN @IdSucursal ELSE (SELECT IdSucursal FROM Administracion.Empleado WHERE Legajo = @Legajo or DNI = @DNI) END,
            Turno = CASE WHEN @Turno IS NOT NULL THEN @Turno ELSE (SELECT Turno FROM Administracion.Empleado WHERE Legajo = @Legajo or DNI = @DNI) END,
			Estado = CASE WHEN @Estado IS NOT NULL THEN @Estado ELSE (SELECT Estado FROM Administracion.Empleado WHERE Legajo = @Legajo or DNI = @DNI) END
        WHERE Legajo = @Legajo or DNI = @DNI;

        COMMIT TRANSACTION;  -- Confirmar transacción

        PRINT('+ Empleado actualizado con exito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la actualización del empleado: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarEmpleado
    @Legajo INT = NULL, -- Parámetro opcional para buscar por IdEmpleado
    @DNI CHAR(8) = NULL     -- Parámetro opcional para buscar por DNI
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si se proporcionó algún parámetro válido
    IF @Legajo IS NULL AND @DNI IS NULL
    BEGIN
        RAISERROR('+ Debe proporcionar el legajo o el DNI para eliminar un empleado.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

        -- Buscar empleado y eliminar
        UPDATE Administracion.Empleado 
		SET Estado = 'I'
        WHERE (Legajo = @Legajo OR DNI = @DNI);

        IF @@ROWCOUNT = 0  -- Verificar si se eliminó algún registro
        BEGIN
            RAISERROR('+ Empleado inexistente.', 16, 1);
            RETURN;
        END

        COMMIT TRANSACTION;  -- Confirmar transacción

        PRINT('+ Empleado eliminado con éxito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la eliminación del empleado: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO