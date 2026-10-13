USE [RestaurantChainDB];

GO

-- Create temporary views to enable bulk data insertion into tables containing computed columns
CREATE OR ALTER VIEW [dbo].[vw_Load_Employee] AS 
SELECT Employee_ID, Branch_ID, First_Name, Middle_Name, Last_Name, Date_Of_Birth, Hire_Date, Job_Title 
FROM [HR].[Employee];

GO

CREATE OR ALTER VIEW [dbo].[vw_Load_Attendance_Log] AS 
SELECT Log_ID, Employee_ID, Clock_In_DateTime, Clock_Out_DateTime, Status, Manager_Notes 
FROM [HR].[Attendance_Log];

GO

CREATE OR ALTER VIEW [dbo].[vw_Load_Order] AS 
SELECT Order_ID, Membership_Number, Branch_ID, Order_Type, Placement_DateTime, Ready_DateTime, Status 
FROM [FOH].[Order];

GO

-- Populate system tables using bulk data insertion from CSV source files
BULK INSERT [FOH].[Branch]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\FOH.Branch.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [FOH].[Branch_Phone]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\FOH.Branch_Phone.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [BOH].[Menu]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\BOH.Menu.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [BOH].[Menu_Category]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\BOH.Menu_Category.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [BOH].[Menu_Item]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\BOH.Menu_Item.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [BOH].[Menu_Contains_Item]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\BOH.Menu_Contains_Item.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [BOH].[Available_Menu]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\BOH.Available_Menu.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [BOH].[Modifier]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\BOH.Modifier.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [Inventory].[Ingredient]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\Inventory.Ingredient.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [BOH].[Recipe]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\BOH.Recipe.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [FOH].[Allergy]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\FOH.Allergy.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [FOH].[Customer]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\FOH.Customer.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [FOH].[Customer_Address]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\FOH.Customer_Address.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [FOH].[Customer_Phone]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\FOH.Customer_Phone.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [FOH].[Customer_Allergy]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\FOH.Customer_Allergy.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [dbo].[vw_Load_Employee]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\HR.Employee.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [HR].[Manager]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\HR.Manager.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [HR].[Employee_Supervision]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\HR.Employee_Supervision.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [HR].[Driver]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\HR.Driver.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [HR].[Kitchen_Staff]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\HR.Kitchen_Staff.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [HR].[Shift]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\HR.Shift.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [HR].[Shift_Assignment]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\HR.Shift_Assignment.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [dbo].[vw_Load_Attendance_Log]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\HR.Attendance_Log.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [FOH].[Dining_Table]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\FOH.Dining_Table.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [FOH].[Reservation]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\FOH.Reservation.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [FOH].[Table_Reservation]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\FOH.Table_Reservation.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [FOH].[Promotion]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\FOH.Promotion.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [dbo].[vw_Load_Order]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\FOH.Order.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [FOH].[Delivery_Order]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\FOH.Delivery_Order.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [FOH].[Order_Driver_Assignment]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\FOH.Order_Driver_Assignment.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [BOH].[Order_Item]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\BOH.Order_Item.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [BOH].[Order_Item_Modifier]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\BOH.Order_Item_Modifier.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [FOH].[Order_Promotion]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\FOH.Order_Promotion.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [FOH].[Payment]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\FOH.Payment.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [FOH].[Review]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\FOH.Review.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [Procurement].[Supplier]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\Procurement.Supplier.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [Procurement].[Supplier_Pricing]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\Procurement.Supplier_Pricing.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [Procurement].[Purchase_Order]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\Procurement.Purchase_Order.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [Procurement].[PO_Line]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\Procurement.PO_Line.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [Procurement].[Receipt]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\Procurement.Receipt.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [Inventory].[Branch_Stock]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\Inventory.Branch_Stock.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [Inventory].[Stock_Transfer]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\Inventory.Stock_Transfer.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

BULK INSERT [Inventory].[Waste_Log]
FROM 'C:\Users\Eyad Adel\OneDrive\Desktop\csv\Inventory.Waste_Log.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', CODEPAGE = '65001', KEEPIDENTITY, KEEPNULLS, CHECK_CONSTRAINTS);

GO

-- Drop temporary loading views after completing data insertion
DROP VIEW [dbo].[vw_Load_Employee];
DROP VIEW [dbo].[vw_Load_Attendance_Log];
DROP VIEW [dbo].[vw_Load_Order];

GO
