USE Com2900G17
GO

CREATE OR ALTER PROCEDURE Administracion.ImportarEmpleadosDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'BULK INSERT Administracion.Empleado
                FROM ''' + @RutaArchivo + ''' 
                WITH (
                    FIELDTERMINATOR = '';'',  -- Cambia el separador según sea necesario
                    ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila según sea necesario
                    FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
					KEEPNULLS,
					CODEPAGE = ''ACP'',
					TABLOCK
				);';
    EXEC sp_executesql @SQL;
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
        -- Si no existe, calcular el nuevo IdEmpleado como el más grande de la tabla más 1
        DECLARE @NuevoIdEmpleado INT;
        SELECT @NuevoIdEmpleado = ISNULL(MAX(IdEmpleado), 0) + 1 FROM Administracion.Empleado;

        -- Insertar nuevo registro
        INSERT INTO Administracion.Empleado (IdEmpleado, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Cargo, Sucursal, Turno)
        VALUES (@NuevoIdEmpleado, @Nombre, @Apellido, @DNI, @Direccion, @EmailPersonal, @EmailEmpresa, @CUIL, @Cargo, @Sucursal, @Turno);
    END
END; 
GO
CREATE OR ALTER PROCEDURE Administracion.EliminarEmpleado
    @IdEmpleado INT = NULL,        -- Parámetro opcional para buscar por IdEmpleado
    @DNI CHAR(8) = NULL            -- Parámetro opcional para buscar por DNI
AS
BEGIN
    -- Verificar si se proporcionó algún parámetro válido (IdEmpleado o DNI)
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
