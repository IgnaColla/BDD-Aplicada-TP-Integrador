-------------------------------------------------------------------
-------------------  Stored Procedures EMPLEADO -------------------
-------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17
GO

CREATE OR ALTER PROCEDURE Administracion.ImportarEmpleadosDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
		DECLARE @SQL NVARCHAR(MAX);

		SET @SQL = N'BULK INSERT Administracion.Empleado
					FROM ''' + @RutaArchivo + ''' 
					WITH (
						FIELDTERMINATOR = '';'',			-- Cambia el separador seg�n sea necesario
						ROWTERMINATOR = ''\n'',				-- Cambia el terminador de fila seg�n sea necesario
						FIRSTROW = 2,						-- Si el archivo tiene encabezados, comienza desde la segunda fila
						KEEPNULLS,
						CODEPAGE = ''ACP'',
						TABLOCK
					);';
		EXEC sp_executesql @SQL;

		PRINT '+ Importaci�n de empleados completada exitosamente.';
	END TRY
	BEGIN CATCH -- En caso de error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR('+ Error durante la importaci�n de empleados: %s', 16, 1, @ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;


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
        BEGIN TRANSACTION;  -- Iniciar transacci�n

        -- Verificar si el empleado ya existe
        IF EXISTS (SELECT 1 FROM Administracion.Empleado WHERE DNI = @DNI)	
        BEGIN
            RAISERROR('+ El empleado ya existe. Terminando el procedimiento.', 16, 1);
            RETURN;
        END

        -- Insertar nuevo registro
        INSERT INTO Administracion.Empleado (IdEmpleado, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Cargo, Sucursal, Turno)
        VALUES (@IdEmpleado, @Nombre, @Apellido, @DNI, @Direccion, @EmailPersonal, @EmailEmpresa, @CUIL, @Cargo, @Sucursal, @Turno);

        COMMIT TRANSACTION;  -- Confirmar transacci�n

        PRINT('+ Empleado insertado con �xito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacci�n en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la inserci�n del empleado: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;


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
        BEGIN TRANSACTION;  -- Iniciar transacci�n

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

        COMMIT TRANSACTION;  -- Confirmar transacci�n

        PRINT('+ Empleado actualizado con �xito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacci�n en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la actualizaci�n del empleado: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;


CREATE OR ALTER PROCEDURE Administracion.EliminarEmpleado
    @IdEmpleado INT = NULL, -- Par�metro opcional para buscar por IdEmpleado
    @DNI CHAR(8) = NULL -- Par�metro opcional para buscar por DNI
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si se proporcion� alg�n par�metro v�lido
    IF @IdEmpleado IS NULL AND @DNI IS NULL
    BEGIN
        RAISERROR('+ Debe proporcionar el IdEmpleado o el DNI para eliminar un empleado.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacci�n

        -- Buscar empleado y eliminar
        DELETE FROM Administracion.Empleado 
        WHERE (IdEmpleado = @IdEmpleado OR DNI = @DNI);

        IF @@ROWCOUNT = 0  -- Verificar si se elimin� alg�n registro
        BEGIN
            RAISERROR('+ Empleado inexistente.', 16, 1);
            RETURN;
        END

        COMMIT TRANSACTION;  -- Confirmar transacci�n

        PRINT('+ Empleado eliminado con �xito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacci�n en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la eliminaci�n del empleado: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;


-- #################### Ejecucion ####################

EXEC Administracion.ImportarEmpleadosDesdeCSV @RutaArchivo = '<Path_al_archivo>'

EXEC Administracion.InsertarEmpleado
    @IdEmpleado = 257035,
    @Nombre = 'Juan Carlos',
    @Apellido = 'P�rez',
    @DNI = '12345678',
    @Direccion = 'Calle Falsa 123, Buenos Aires',
    @EmailPersonal = 'juan.perez@gmail.com',
    @EmailEmpresa = 'juan.perez@empresa.com',
    @CUIL = '20123456789',
    @Cargo = 'Cajero',
    @Sucursal = 'San Justo',
    @Turno = 'TM';

EXEC Administracion.EliminarEmpleado @IdEmpleado = 257035
EXEC Administracion.EliminarEmpleado @DNI = 12345678
