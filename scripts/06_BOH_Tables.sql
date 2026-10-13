USE RestaurantChainDB;
GO

-- Create Back of House (BOH) tables to manage menus, items, recipes, and order details
CREATE TABLE BOH.Menu_Category (
    Category_ID INT IDENTITY(1,1) CONSTRAINT PK_Menu_Category PRIMARY KEY,
    Category_Name NVARCHAR(100) NOT NULL,
    Parent_Category_ID INT SPARSE 
) ON [FG_MasterData];

CREATE TABLE BOH.Menu (
    Menu_ID INT IDENTITY(1,1) CONSTRAINT PK_Menu PRIMARY KEY,
    Menu_Name NVARCHAR(100) NOT NULL
) ON [FG_MasterData];

CREATE TABLE BOH.Available_Menu (
    Menu_ID INT NOT NULL,
    Branch_ID INT NOT NULL,
    Is_Active BIT DEFAULT 1,
    Activation_Date DATE NOT NULL,
    CONSTRAINT PK_Available_Menu PRIMARY KEY (Menu_ID, Branch_ID)
) ON [FG_MasterData];

CREATE TABLE BOH.Menu_Item (
    Item_ID INT IDENTITY(1,1) CONSTRAINT PK_Menu_Item PRIMARY KEY,
    Category_ID INT NOT NULL, 
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX) SPARSE,
    Caloric_Content INT SPARSE,
    Preparation_Instructions NVARCHAR(MAX) SPARSE,
    Current_Selling_Price MoneyType
) ON [FG_MasterData];

CREATE TABLE BOH.Menu_Contains_Item (
    Menu_ID INT NOT NULL,
    Item_ID INT NOT NULL,
    CONSTRAINT PK_Menu_Contains_Item PRIMARY KEY (Menu_ID, Item_ID)
) ON [FG_MasterData];

CREATE TABLE BOH.Recipe (
    Recipe_ID INT IDENTITY(1,1) CONSTRAINT PK_Recipe PRIMARY KEY,
    Item_ID INT NOT NULL,
    Ingredient_ID INT NOT NULL,
    Quantity_Required QuantityType,
    CONSTRAINT CHK_Recipe_Quantity CHECK (Quantity_Required > 0)
) ON [FG_MasterData];

CREATE TABLE BOH.Modifier (
    Modifier_ID INT IDENTITY(1,1) CONSTRAINT PK_Modifier PRIMARY KEY,
    Instruction_Text NVARCHAR(100) NOT NULL,
    Additional_Cost MoneyType
) ON [FG_MasterData];

CREATE TABLE BOH.Order_Item (
    Order_Item_ID INT IDENTITY(1,1),
    Order_ID INT NOT NULL,
    Item_ID INT NOT NULL,
    Quantity INT NOT NULL,
    Unit_Price MoneyType, 
    Order_Date DATE NOT NULL, 
    CONSTRAINT PK_Order_Item PRIMARY KEY CLUSTERED (Order_Item_ID, Order_Date)
    WITH (FILLFACTOR = 90) ON ps_OrderDate(Order_Date),
    CONSTRAINT CHK_Order_Quantity CHECK (Quantity > 0)
);

CREATE TABLE BOH.Order_Item_Modifier (
    Order_Item_ID INT NOT NULL,
    Modifier_ID INT NOT NULL,
    Order_Date DATE NOT NULL, 
    CONSTRAINT PK_Order_Item_Modifier PRIMARY KEY CLUSTERED (Order_Item_ID, Modifier_ID, Order_Date)
    WITH (FILLFACTOR = 90) ON ps_OrderDate(Order_Date)
);
GO