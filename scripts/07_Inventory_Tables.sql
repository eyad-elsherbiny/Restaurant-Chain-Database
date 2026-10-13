USE RestaurantChainDB;
GO

-- Create Inventory schema tables to track ingredients, branch stock levels, transfers, and waste logs
CREATE TABLE Inventory.Ingredient (
    Ingredient_ID INT IDENTITY(1,1) CONSTRAINT PK_Ingredient PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Unit_of_Measurement NVARCHAR(50) NOT NULL 
) ON [FG_MasterData];

CREATE TABLE Inventory.Branch_Stock (
    Stock_ID INT IDENTITY(1,1) CONSTRAINT PK_Branch_Stock PRIMARY KEY,
    Branch_ID INT NOT NULL,
    Ingredient_ID INT NOT NULL,
    Current_Stock_Level QuantityType,
    Last_Physical_Count DATE,
    Reorder_Threshold QuantityType
) ON [FG_MasterData];

CREATE TABLE Inventory.Stock_Transfer (
    Transfer_ID INT IDENTITY(1,1) CONSTRAINT PK_Stock_Transfer PRIMARY KEY,
    Sending_Branch_ID INT NOT NULL,
    Receiving_Branch_ID INT NOT NULL,
    Ingredient_ID INT NOT NULL,
    Transfer_Date DATETIME DEFAULT GETDATE(),
    Quantity_Transferred QuantityType,
    CONSTRAINT CHK_Transfer_Quantity CHECK (Quantity_Transferred > 0),
    CONSTRAINT CHK_Different_Branches CHECK (Sending_Branch_ID <> Receiving_Branch_ID)
) ON [FG_MasterData];

CREATE TABLE Inventory.Waste_Log (
    Log_ID INT IDENTITY(1,1) CONSTRAINT PK_Waste_Log PRIMARY KEY,
    Branch_ID INT NOT NULL,
    Ingredient_ID INT NOT NULL,
    Employee_ID INT NOT NULL,
    Log_Date DATETIME DEFAULT GETDATE(),
    Reason NVARCHAR(255) NOT NULL,
    Quantity_Lost QuantityType,
    CONSTRAINT CHK_Waste_Quantity CHECK (Quantity_Lost > 0)
) ON [FG_MasterData];
GO