USE RestaurantChainDB;
GO

-- Define custom data types, rules, and defaults for database-wide standardization
EXEC sp_addtype 'MoneyType', 'DECIMAL(10,2)', 'NOT NULL';
EXEC sp_addtype 'QuantityType', 'DECIMAL(10,3)', 'NOT NULL';
EXEC sp_addtype 'PhoneType', 'VARCHAR(20)', 'NOT NULL';
EXEC sp_addtype 'EmailType', 'NVARCHAR(100)', 'NULL';
GO

CREATE RULE rl_Positive_Value AS @Value >= 0;
CREATE RULE rl_Valid_Phone AS LEN(@Phone) >= 8;
CREATE RULE rl_Email_Format  AS @Email IS NULL OR @Email LIKE '%_@__%.__%';
CREATE DEFAULT df_Zero_Money AS 0.00;
CREATE DEFAULT df_Zero_Quantity AS 0.000;
GO

-- Bind rules and defaults to the custom data types
EXEC sp_bindrule 'rl_Positive_Value', 'MoneyType';
EXEC sp_bindrule 'rl_Positive_Value', 'QuantityType';
EXEC sp_bindrule 'rl_Valid_Phone', 'PhoneType';
EXEC sp_bindrule 'rl_Email_Format', 'EmailType';
GO

EXEC sp_bindefault 'df_Zero_Money', 'MoneyType';
EXEC sp_bindefault 'df_Zero_Quantity', 'QuantityType';
GO