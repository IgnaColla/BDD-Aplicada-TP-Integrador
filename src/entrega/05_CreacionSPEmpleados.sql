-------------------------------------------------------------------
-------------------  Stored Procedures EMPLEADO -------------------
-------------------------------------------------------------------

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

		INSERT Administracion.Empleado
		SELECT		em.Legajo, 
					REPLACE(em.Nombre, '"', ''), 
					em.Apellido, 
					em.DNI,
					em.Direccion, 
					REPLACE(REPLACE(REPLACE(REPLACE(em.EmailPersonal, '"', ''), ' ', ''), CHAR(9), ''), CHAR(160), ''),
					REPLACE(REPLACE(REPLACE(REPLACE(em.EmailEmpresa, '"', ''), ' ', ''), CHAR(9), ''), CHAR(160), ''),
					em.CUIL, ca.Id, su.Id, em.Turno, 'A'
		FROM #Empleado em 
		INNER JOIN Administracion.Sucursal su ON em.Sucursal = su.Ciudad 
		INNER JOIN Administracion.Cargo ca ON em.Cargo = ca.Cargo 
		WHERE NOT EXISTS (
            SELECT 1 
            FROM Administracion.Empleado e
            WHERE em.Legajo = e.Legajo
        );

        PRINT '+ Importación de empleados completada exitosamente.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la importación de empleados: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

/*

CREATE OR ALTER PROCEDURE Administracion.InsertarEmpleado
    @IdEmpleado INT,
	@Nombre VARCHAR(50),
    @Apellido VARCHAR(50),
    @DNI CHAR(8),
    @Direccion VARCHAR(255),
    @EmailPersonal VARCHAR(100) = NULL,
    @EmailEmpresa VARCHAR(100) = NULL,
    @CUIL CHAR(11) = NULL,
    @Cargo VARCHAR(30),
    @Sucursal VARCHAR(20),
    @Turno VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

        -- Verificar si el empleado ya existe
        IF EXISTS (SELECT 1 FROM Administracion.Empleado WHERE DNI = @DNI)	
        BEGIN
            RAISERROR('+ El empleado ya existe. Terminando el procedimiento.', 16, 1);
            RETURN;
        END

        -- Insertar nuevo registro
        INSERT INTO Administracion.Empleado (IdEmpleado, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Cargo, Sucursal, Turno)
        VALUES (@IdEmpleado, @Nombre, @Apellido, @DNI, @Direccion, @EmailPersonal, @EmailEmpresa, @CUIL, @Cargo, @Sucursal, @Turno);

        COMMIT TRANSACTION;  -- Confirmar transacción

        PRINT('+ Empleado insertado con éxito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la inserción del empleado: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE Administracion.ActualizarEmpleado
    @IdEmpleado INT,
    @Nombre VARCHAR(50),
    @Apellido VARCHAR(50),
    @DNI CHAR(8),
    @Direccion VARCHAR(255),
    @EmailPersonal VARCHAR(100) = NULL,
    @EmailEmpresa VARCHAR(100) = NULL,
    @CUIL CHAR(11) = NULL,
    @Cargo VARCHAR(30),
    @Sucursal VARCHAR(20),
    @Turno VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

        -- Verificar si el empleado existe
        IF NOT EXISTS (SELECT 1 FROM Administracion.Empleado WHERE IdEmpleado = @IdEmpleado)	
        BEGIN
            RAISERROR('+ El empleado ingresado no existe. Utilizar el procedimiento "InsertarEmpleado" para agregar un nuevo empleado.', 16, 1);
            RETURN;
        END

        -- Actualizar empleado
        UPDATE Administracion.Empleado
        SET Nombre = @Nombre,
            Apellido = @Apellido,
            DNI = @DNI,
            Direccion = @Direccion,
            EmailPersonal = @EmailPersonal,
            EmailEmpresa = @EmailEmpresa,
            CUIL = @CUIL,
            Cargo = @Cargo,
            Sucursal = @Sucursal,
            Turno = @Turno
        WHERE IdEmpleado = @IdEmpleado;

        COMMIT TRANSACTION;  -- Confirmar transacción

        PRINT('+ Empleado actualizado con �xito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la actualización del empleado: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE Administracion.EliminarEmpleado
    @IdEmpleado INT = NULL, -- Parámetro opcional para buscar por IdEmpleado
    @DNI CHAR(8) = NULL     -- Parámetro opcional para buscar por DNI
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si se proporcionó algún parámetro válido
    IF @IdEmpleado IS NULL AND @DNI IS NULL
    BEGIN
        RAISERROR('+ Debe proporcionar el IdEmpleado o el DNI para eliminar un empleado.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

        -- Buscar empleado y eliminar
        DELETE FROM Administracion.Empleado 
        WHERE (IdEmpleado = @IdEmpleado OR DNI = @DNI);

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

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la eliminación del empleado: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE Administracion.InsertarOActualizarEmpleado
    @IdEmpleado INT,
    @Nombre VARCHAR(50),
    @Apellido VARCHAR(50),
    @DNI CHAR(8),
    @Direccion VARCHAR(255),
    @EmailPersonal VARCHAR(100) = NULL,
    @EmailEmpresa VARCHAR(100) = NULL,
    @CUIL CHAR(11) = NULL,
    @Cargo VARCHAR(30),
    @Sucursal VARCHAR(20),
    @Turno VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el empleado ya existe
    IF EXISTS (SELECT 1 FROM Administracion.Empleado WHERE IdEmpleado = @IdEmpleado)
    BEGIN
        -- Si existe, hacer un UPDATE
        UPDATE Administracion.Empleado
        SET Nombre = @Nombre,
            Apellido = @Apellido,
            DNI = @DNI,
            Direccion = @Direccion,
            EmailPersonal = @EmailPersonal,
            EmailEmpresa = @EmailEmpresa,
            CUIL = @CUIL,
            Cargo = @Cargo,
            Sucursal = @Sucursal,
            Turno = @Turno
        WHERE IdEmpleado = @IdEmpleado;
    END
    ELSE
    BEGIN
        -- Si no existe, calcular el nuevo IdEmpleado como el m�s grande de la tabla m�s 1
        DECLARE @NuevoIdEmpleado INT;
        SELECT @NuevoIdEmpleado = ISNULL(MAX(IdEmpleado), 0) + 1 FROM Administracion.Empleado;

        -- Insertar nuevo registro
        INSERT INTO Administracion.Empleado (IdEmpleado, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Cargo, Sucursal, Turno)
        VALUES (@NuevoIdEmpleado, @Nombre, @Apellido, @DNI, @Direccion, @EmailPersonal, @EmailEmpresa, @CUIL, @Cargo, @Sucursal, @Turno);
    END
END; 
GO
CREATE OR ALTER PROCEDURE Administracion.EliminarEmpleado
    @IdEmpleado INT = NULL,        -- Par�metro opcional para buscar por IdEmpleado
    @DNI CHAR(8) = NULL            -- Par�metro opcional para buscar por DNI
AS
BEGIN
    -- Verificar si se proporcion� alg�n par�metro v�lido (IdEmpleado o DNI)
    IF @IdEmpleado IS NULL AND @DNI IS NULL
    BEGIN
        RAISERROR('Debe proporcionar el IdEmpleado o el DNI para eliminar un empleado.', 16, 1);
        RETURN;
    END

    -- Intentar encontrar al empleado
    IF EXISTS (SELECT 1 FROM Administracion.Empleado WHERE (IdEmpleado = @IdEmpleado OR DNI = @DNI))
    BEGIN
        -- Eliminar el empleado si existe
        DELETE FROM Administracion.Empleado 
        WHERE (IdEmpleado = @IdEmpleado OR DNI = @DNI);
        
        PRINT 'Empleado eliminado exitosamente.';
    END
    ELSE
    BEGIN
        -- Mostrar mensaje de error si no se encuentra al empleado
        RAISERROR('Empleado inexistente.', 16, 1);
    END
END;
*/