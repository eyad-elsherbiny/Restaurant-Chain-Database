USE RestaurantChainDB;
GO

-- Create Procurement schema tables to manage suppliers, purchase orders, pricing, and receipts
CREATE TABLE Procurement.Supplier (
    Supplier_ID INT IDENTITY(1,1) CONSTRAINT PK_Supplier PRIMARY KEY,
    Company_Name NVARCHAR(100) NOT NULL,
    Contact_Person NVARCHAR(100),
    Phone_Number PhoneType,
    Email_Address EmailType
) ON [FG_MasterData];

CREATE TABLE Procurement.Supplier_Pricing (
    Pricing_ID INT IDENTITY(1,1) CONSTRAINT PK_Pricing_ID PRIMARY KEY,
    Supplier_ID INT NOT NULL,
    Ingredient_ID INT NOT NULL,
    Valid_From_Date DATE NOT NULL,
    Valid_To_Date DATE,
    Agreed_Price MoneyType,
    CONSTRAINT CHK_Valid_Dates CHECK (Valid_To_Date IS NULL OR Valid_To_Date >= Valid_From_Date)
) ON [FG_MasterData];

CREATE TABLE Procurement.Purchase_Order (
    PO_ID INT IDENTITY(1,1) CONSTRAINT PK_Purchase_Order PRIMARY KEY,
    Supplier_ID INT NOT NULL,
    Branch_ID INT NOT NULL,
    Employee_ID INT NOT NULL, 
    Order_Date DATE DEFAULT GETDATE(),
    Expected_Delivery_Date DATE NOT NULL,
    Status VARCHAR(20) DEFAULT 'Pending',
    CONSTRAINT CHK_PO_Status CHECK (Status IN ('Pending', 'Approved', 'Shipped', 'Delivered', 'Cancelled')),
    CONSTRAINT CHK_Expected_Delivery CHECK (Expected_Delivery_Date >= Order_Date)
) ON [FG_MasterData];

CREATE TABLE Procurement.PO_Line (
    PO_Line_ID INT IDENTITY(1,1) CONSTRAINT PK_PO_Line PRIMARY KEY,
    PO_ID INT NOT NULL,
    Ingredient_ID INT NOT NULL,
    Requested_Quantity QuantityType,
    Unit_Price MoneyType,
    CONSTRAINT CHK_Requested_Quantity CHECK (Requested_Quantity > 0)
) ON [FG_MasterData];

CREATE TABLE Procurement.Receipt (
    Receipt_ID INT IDENTITY(1,1) CONSTRAINT PK_Receipt PRIMARY KEY,
    PO_Line_ID INT NOT NULL,
    Employee_ID INT NOT NULL, 
    Received_Quantity QuantityType,
    Receipt_Date DATETIME DEFAULT GETDATE()
) ON [FG_MasterData];
GO