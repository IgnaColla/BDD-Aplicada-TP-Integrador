-------------------------------------------------------------------
-------------------  Stored Procedures VENTAS  --------------------
-------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17;
GO

CREATE OR ALTER PROCEDURE Ventas.ImportarMediosDePagoDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @SQL NVARCHAR(MAX);

        SET @SQL = N'BULK INSERT Ventas.MedioDePago
                    FROM ''' + @RutaArchivo + ''' 
                    WITH (
                        FIELDTERMINATOR = '';'',  -- Cambia el separador seg�n sea necesario
                        ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila seg�n sea necesario
                        FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
                        CODEPAGE = ''65001'',
                        KEEPNULLS
                    );';
        
        EXEC sp_executesql @SQL;

        PRINT('+ Importación de Medios de Pago completada exitosamente.');
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la importación de Medios de Pago: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE Ventas.ImportarVentasDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @SQL NVARCHAR(MAX);

        SET @SQL = N'BULK INSERT Ventas.Venta
                    FROM ''' + @RutaArchivo + ''' 
                    WITH (
                        FIELDTERMINATOR = '';'',  -- Cambia el separador seg�n sea necesario
                        ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila seg�n sea necesario
                        FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
                        CODEPAGE = ''65001''
                    );';
        
        EXEC sp_executesql @SQL;

        -- Reemplazamos los valores '--' en la columna IdentificadorPago por NULL
        UPDATE Ventas.Venta
        SET IdentificadorPago = NULL
        WHERE IdentificadorPago = '--';

        PRINT('+ Importación de Ventas completada exitosamente.');
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la importación de Ventas: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Ventas.InsertarVenta
	@Sucursal VARCHAR(20),
    @TipoCliente VARCHAR(10),
    @Genero CHAR(1),                      
	@LegajoEmpleado INT,
	@NumeroFactura VARCHAR(15),
	@TipoFactura CHAR(1),
	@Fecha DATE,                         
    @Hora TIME,                            
	@MedioPago VARCHAR(15),           
	@IdentificadorPago VARCHAR(40) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

	-- Verificar si esa venta ya existe
	IF EXISTS (SELECT 1 FROM Ventas.Factura WHERE NumeroFactura=@NumeroFactura)
        BEGIN
            RAISERROR('+ La venta ya existe. Terminando el procedimiento.', 16, 1);
            RETURN;
		END
	IF NOT EXISTS (SELECT Id FROM Ventas.MedioPago WHERE Codigo=@MedioPago)
		BEGIN
            RAISERROR('+ El medio de pago no existe. Terminando el procedimiento.', 16, 1);
            RETURN;
		END
	DECLARE @IdMedioPago INT =  (SELECT Id FROM Ventas.MedioPago WHERE Codigo=@MedioPago);
	-- Insertar nuevo registro
	INSERT Ventas.Factura VALUES (@NumeroFactura,@TipoFactura,@Fecha,@Hora,@IdMedioPago,0,0,@IdentificadorPago);

	IF NOT EXISTS (SELECT Id FROM Administracion.Sucursal WHERE Nombre=@Sucursal)
		BEGIN
            RAISERROR('+ La sucursal no existe. Terminando el procedimiento.', 16, 1);
            RETURN;
		END
	DECLARE @IdSucursal INT =  (SELECT Id FROM Administracion.Sucursal WHERE Nombre=@Sucursal);

	IF NOT EXISTS (SELECT Legajo FROM Administracion.Empleado WHERE Legajo=@LegajoEmpleado)
		BEGIN
            RAISERROR('+ El empleado no existe. Terminando el procedimiento.', 16, 1);
            RETURN;
		END
	DECLARE @IdFactura INT = SELECT MAX(ID) FROM Ventas.Factura;

	INSERT Ventas.Venta VALUES(@IdFactura,@IdSucursal,@TipoCliente,@Genero,@LegajoEmpleado);

	COMMIT TRANSACTION;  -- Confirmar transacción

        PRINT('+ Venta insertada con éxito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la inserción de la Venta: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO