--Fecha de entrega: []/[]
--Número de grupo: 17
--Materia: BASES DE DATOS APLICADAS
--Alumnos:


--Trabajo práctico Integrador

--Se detalla a continuación el proceso de instalación y configuración aplicada para Microsoft SQL Server.
--Ubicación de los Medios: C:\SQL2022
--Nombre de la instancia SQLEXPRESS

--Se utilizara para administrar el motor de base de datos SQL Server Management Studio v19.1.
--En la unidad C:\Program Files (x86)\Microsoft SQL Server Management Studio 19.
--Configuración Aplicada:
--Server Name: DESKTOP-707ICIM\MSSQL
--Lenguaje: Inglés (Estados Unidos)
--Memoria asignada: 7569 MB
--Processors: 12
--Server Collation: SQL_Latin1_General_CP1_CI_AS
--TCP Port: 49172

-- ## CONVENCIONES ##

-- DB: Com2900G17
-- SCHEMA: ddbba
-- TABLAS: UpperCamelCase 
-- CAMPOS: camel_case+
-- ROLES: UpperCamelCase

--------------------------------------------------
------  CREACION DB
--------------------------------------------------
USE master
GO
DROP DATABASE IF EXISTS Com2900G17
GO
CREATE DATABASE Com2900G17 COLLATE SQL_Latin1_General_CP1_CI_AS
GO
USE Com2900G17
GO