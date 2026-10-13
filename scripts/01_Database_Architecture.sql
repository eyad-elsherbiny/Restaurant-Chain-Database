-- Create the database and allocate filegroups for data separation and archiving
CREATE DATABASE RestaurantChainDB
ON PRIMARY (
    NAME = N'RestChain_Primary',
    FILENAME = N'D:\PROJECTS\DB\RestaurantDB\Data\RestChain_Primary.mdf',
    SIZE = 64MB,
    FILEGROWTH = 32MB
),
FILEGROUP FG_MasterData (
    NAME = N'RestChain_MasterData',
    FILENAME = N'D:\PROJECTS\DB\RestaurantDB\Data\RestChain_MasterData.ndf',
    SIZE = 128MB,
    FILEGROWTH = 32MB
),
FILEGROUP FG_Archive (
    NAME = N'RestChain_Archive',
    FILENAME = N'D:\PROJECTS\DB\RestaurantDB\Data\RestChain_Archive.ndf',
    SIZE = 512MB,
    FILEGROWTH = 128MB          
),
FILEGROUP FG_2025 (
    NAME = N'RestChain_2025',
    FILENAME = N'D:\PROJECTS\DB\RestaurantDB\Data\RestChain_2025.ndf',
    SIZE = 128MB,
    FILEGROWTH = 32MB
),
FILEGROUP FG_2026 (
    NAME = N'RestChain_2026',
    FILENAME = N'D:\PROJECTS\DB\RestaurantDB\Data\RestChain_2026.ndf',
    SIZE = 128MB,
    FILEGROWTH = 32MB
),
FILEGROUP FG_2027 (
    NAME = N'RestChain_2027',
    FILENAME = N'D:\PROJECTS\DB\RestaurantDB\Data\RestChain_2027.ndf',
    SIZE = 128MB,
    FILEGROWTH = 32MB
)
LOG ON (
    NAME = N'RestChain_Log',
    FILENAME = N'D:\PROJECTS\DB\RestaurantDB\Log\RestChain_Log.ldf',
    SIZE = 128MB,
    FILEGROWTH = 32MB
);
GO

ALTER DATABASE RestaurantChainDB MODIFY FILEGROUP FG_MasterData DEFAULT;
GO

USE RestaurantChainDB;
GO

-- Set up table partitioning to distribute order data across years
CREATE PARTITION FUNCTION pf_OrderDate (date)
AS RANGE RIGHT
FOR VALUES ('2025-01-01', '2026-01-01', '2027-01-01');
GO

CREATE PARTITION SCHEME ps_OrderDate
AS PARTITION pf_OrderDate
TO (FG_Archive, FG_2025, FG_2026, FG_2027);
GO