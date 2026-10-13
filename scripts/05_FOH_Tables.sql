USE RestaurantChainDB;
GO

-- Create Front of House (FOH) tables to manage branches, customers, orders, payments, and reviews
CREATE TABLE FOH.Branch (
    Branch_ID INT IDENTITY(1,1) CONSTRAINT PK_Branch PRIMARY KEY,
    Branch_Name NVARCHAR(100) NOT NULL,
    Opening_Time TIME NOT NULL,
    Closing_Time TIME NOT NULL,
    Street NVARCHAR(255),
    City NVARCHAR(100),
    Postal_Code VARCHAR(20) SPARSE,
    CONSTRAINT CHK_Branch_Hours CHECK (Opening_Time <> Closing_Time)
) ON [FG_MasterData];

CREATE TABLE FOH.Branch_Phone (
    Branch_ID INT NOT NULL,
    Contact_Numbers PhoneType,
    CONSTRAINT PK_Branch_Phone PRIMARY KEY (Branch_ID, Contact_Numbers)
) ON [FG_MasterData];

CREATE TABLE FOH.Dining_Table (
    DT_Number INT CONSTRAINT PK_Dining_Table PRIMARY KEY,
    Branch_ID INT NOT NULL, 
    Seating_Capacity INT NOT NULL,
    Status VARCHAR(20) DEFAULT 'Available',
    CONSTRAINT CHK_Seating_Capacity CHECK (Seating_Capacity > 0)
) ON [FG_MasterData];

CREATE TABLE FOH.Customer (
    Membership_Number INT IDENTITY(1,1) CONSTRAINT PK_Customer PRIMARY KEY,
    First_Name NVARCHAR(50) NOT NULL,
    Middle_Name NVARCHAR(50) SPARSE,
    Last_Name NVARCHAR(50) NOT NULL,
    Loyalty_Points INT DEFAULT 0,
    Email EmailType,
    Registration_Date DATE DEFAULT GETDATE(),
    Date_Of_Birth DATE SPARSE,
    CONSTRAINT CHK_Loyalty_Points CHECK (Loyalty_Points >= 0)
) ON [FG_MasterData];

CREATE TABLE FOH.Customer_Phone (
    Membership_Number INT NOT NULL,
    Phone_Numbers PhoneType,
    CONSTRAINT PK_Customer_Phone PRIMARY KEY (Membership_Number, Phone_Numbers)
) ON [FG_MasterData];

CREATE TABLE FOH.Customer_Address (
    Membership_Number INT NOT NULL,
    City NVARCHAR(100) NOT NULL,
    Street NVARCHAR(255) NOT NULL,
    Postal_Code VARCHAR(20) SPARSE,
    Delivery_Instructions NVARCHAR(255) SPARSE,
    CONSTRAINT PK_Customer_Address PRIMARY KEY (Membership_Number, City, Street)
) ON [FG_MasterData];

CREATE TABLE FOH.Allergy (
    Allergy_ID INT IDENTITY(1,1) CONSTRAINT PK_Allergy PRIMARY KEY,
    Allergy_Name NVARCHAR(100) NOT NULL,
    Category NVARCHAR(50),
    Severity_Level NVARCHAR(20) NOT NULL,
    CONSTRAINT CHK_Severity CHECK (Severity_Level IN ('Low', 'Medium', 'High', 'Severe'))
) ON [FG_MasterData];

CREATE TABLE FOH.Customer_Allergy (
    Membership_Number INT NOT NULL,
    Allergy_ID INT NOT NULL,
    CONSTRAINT PK_Customer_Allergy PRIMARY KEY (Membership_Number, Allergy_ID)
) ON [FG_MasterData];

CREATE TABLE FOH.Reservation (
    Reservation_ID INT IDENTITY(1,1) CONSTRAINT PK_Reservation PRIMARY KEY,
    Membership_Number INT NOT NULL, 
    Reservation_Date DATE NOT NULL,
    Reservation_Time TIME NOT NULL,
    Expected_Guests INT NOT NULL,
    Status VARCHAR(20) DEFAULT 'Pending',
    CONSTRAINT CHK_Expected_Guests CHECK (Expected_Guests > 0)
) ON [FG_MasterData];

CREATE TABLE FOH.Table_Reservation (
    Reservation_ID INT NOT NULL,
    DT_Number INT NOT NULL,
    CONSTRAINT PK_Table_Reservation PRIMARY KEY (Reservation_ID, DT_Number)
) ON [FG_MasterData];

CREATE TABLE FOH.Promotion (
    Promotion_ID INT IDENTITY(1,1) CONSTRAINT PK_Promotion PRIMARY KEY,
    Promotion_Name NVARCHAR(100) NOT NULL,
    Application_Scope NVARCHAR(50) NOT NULL, 
    Discount_Type NVARCHAR(20) NOT NULL,    
    Discount_Value DECIMAL(10,2) NOT NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE NOT NULL,
    CONSTRAINT CHK_Promotion_Dates CHECK (End_Date >= Start_Date),
    CONSTRAINT CHK_Discount_Value CHECK (Discount_Value > 0)
) ON [FG_MasterData];

CREATE TABLE FOH.Review (
    Review_ID INT IDENTITY(1,1) CONSTRAINT PK_Review PRIMARY KEY,
    Order_ID INT NOT NULL,
    Membership_Number INT NOT NULL,
    Review_Date DATETIME DEFAULT GETDATE(),
    Comments NVARCHAR(MAX) SPARSE,
    Rating DECIMAL(2,1) NOT NULL, 
    CONSTRAINT CHK_Rating CHECK (Rating >= 1.0 AND Rating <= 5.0)
) ON [FG_MasterData];

CREATE TABLE FOH.[Order] (
    Order_ID INT IDENTITY(1,1),
    Membership_Number INT NOT NULL, 
    Branch_ID INT NOT NULL,
    Order_Type VARCHAR(20) NOT NULL, 
    Placement_DateTime DATETIME NOT NULL,
    Ready_DateTime DATETIME SPARSE,
    Status VARCHAR(20) DEFAULT 'Pending',
    Placement_Date AS CAST(Placement_DateTime AS DATE) PERSISTED,
    CONSTRAINT PK_Order PRIMARY KEY (Order_ID, Placement_Date)
    WITH (FILLFACTOR = 90) ON ps_OrderDate(Placement_Date),
    CONSTRAINT UQ_Order_ID UNIQUE NONCLUSTERED (Order_ID) ON [FG_MasterData],
    CONSTRAINT CHK_Order_Type CHECK (Order_Type IN ('Dine-In', 'Takeaway', 'Delivery'))
);

CREATE TABLE FOH.Delivery_Order (
    Order_ID INT NOT NULL CONSTRAINT PK_Delivery_Order PRIMARY KEY,
    Postal_Code VARCHAR(20) SPARSE,
    Street NVARCHAR(255) NOT NULL,
    City NVARCHAR(100) NOT NULL
) ON [FG_MasterData];

CREATE TABLE FOH.Order_Driver_Assignment (
    Order_ID INT NOT NULL CONSTRAINT PK_Order_Driver PRIMARY KEY,
    Driver_ID INT NOT NULL
) ON [FG_MasterData];

CREATE TABLE FOH.Order_Promotion (
    Order_ID INT NOT NULL,
    Promotion_ID INT NOT NULL,
    CONSTRAINT PK_Order_Promotion PRIMARY KEY (Order_ID, Promotion_ID)
) ON [FG_MasterData];

CREATE TABLE FOH.Payment (
    Payment_ID INT IDENTITY(1,1) CONSTRAINT PK_Payment PRIMARY KEY,
    Order_ID INT NOT NULL,
    Payment_Method VARCHAR(50) NOT NULL,
    Amount_Paid MoneyType,
    Status VARCHAR(20) DEFAULT 'Completed',
    Payment_Date DATETIME DEFAULT GETDATE()
) ON [FG_MasterData];
GO