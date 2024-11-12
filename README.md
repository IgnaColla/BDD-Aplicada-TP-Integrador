# BDD-Aplicada-TP-Integrador
## Descripción
- En este repositorio se encuentra la resolución del TP Integrador de Base de Datos Aplicada. Se realizó un sistema de base de datos para un supermercado minorista, con el cual se pueden gestionar empleados, ventas, sucursales, cargos y productos.

## Motor utilizado
- SQL Server v22

## Guía de instalación/configuración

| Característica               | Configuración                                                                                                                             |
|------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| **Sistema Operativo**        | - Windows Server 2019 o superior                                                                                                          |
| **Versión**                  | - SQL Server 2022                                                                                                                         |
| **Ruta de Instalación**      | - `C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER`                                                                             |
| **Ruta de Datos**            | - `C:\Program Files\Microsoft SQL Server\MSSQL16.SQLPC\MSSQL\DATA`                                                                        |
| **Ruta de Log**              | - `C:\Program Files\Microsoft SQL Server\MSSQL16.SQLPC\MSSQL\Logs`                                                                        |
| **Ruta de Backups**          | - `C:\Program Files\Microsoft SQL Server\MSSQL16.SQLPC\MSSQL\Backups`                                                                     |
| **Política de Backups**      | - **Diarios**: Backup diferencial diario a las 23:00 p.m.<br>- **Semanales**: Backup de consistencia semanal los domingos a las 07:00 a.m.|
| **Memoria Asignada**         | - 75-80% de la memoria física total                                                                                                       |
| **Modo de Autenticación**    | - Modo mixto (Autenticación de Windows y SQL Server)                                                                                      |
| **Configuración de Puertos** | - Puerto TCP predeterminado: `1433`                                                                                                       |
| **Cifrado de Datos**         | - Uso de claves simétricas para encriptar datos personales                                                                                |
| **Supervisión y Alertas**    | - Configuración de alertas para fallos en copias de seguridad, uso de CPU, y crecimiento de archivos de logs                              |
| **Prácticas de Seguridad de la Base** | - Implementación de roles `Empleado` y `Supervisor` para manipulación de notas de crédito                                        |
| **Política de Mantenimiento** | - Ejecución de mantenimiento mensual para optimización de rendimiento y verificación de integridad                                       |
