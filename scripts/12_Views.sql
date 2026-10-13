USE [RestaurantChainDB];

GO

-- Create a kitchen display view to aggregate active orders, menu items, and custom modifiers
CREATE OR ALTER VIEW [BOH].[vw_KitchenDisplay]
WITH ENCRYPTION
AS
SELECT 
    O.Order_ID,
    O.Branch_ID,
    O.Order_Type,
    O.Placement_DateTime,
    MI.Name AS Item_Name,
    OI.Quantity,
    ISNULL(STRING_AGG(M.Instruction_Text, ' + '), 'No Modifiers') AS Modifiers
FROM [FOH].[Order] O INNER JOIN [BOH].[Order_Item] OI
ON O.Order_ID = OI.Order_ID
INNER JOIN [BOH].[Menu_Item] MI 
ON OI.Item_ID = MI.Item_ID
LEFT OUTER JOIN [BOH].[Order_Item_Modifier] OIM 
ON OI.Order_Item_ID = OIM.Order_Item_ID
LEFT OUTER JOIN [BOH].[Modifier] M 
ON OIM.Modifier_ID = M.Modifier_ID
WHERE O.Status IN ('Pending', 'Preparing')
GROUP BY 
    O.Order_ID,
    O.Branch_ID,
    O.Order_Type,
    O.Placement_DateTime,
    MI.Name,
    OI.Quantity;

GO

-- Create a customer invoice view to calculate item subtotals, applied promotions, and grand totals
CREATE OR ALTER VIEW [FOH].[vw_CustomerInvoice]
WITH ENCRYPTION
AS
WITH OrderSubTotals AS (
    SELECT 
        OI.Order_ID,
        SUM(OI.Quantity * MI.Current_Selling_Price) AS SubTotal
    FROM [BOH].[Order_Item] OI 
    JOIN [BOH].[Menu_Item] MI ON OI.Item_ID = MI.Item_ID
    GROUP BY OI.Order_ID
)
SELECT 
    O.Order_ID,
    O.Placement_DateTime,
    B.Branch_Name,
    CONCAT_WS(' ', C.First_Name, C.Middle_Name, C.Last_Name) AS Customer_Name,
    O.Status,
    ISNULL(OST.SubTotal, 0) AS SubTotal,
    ISNULL(P.Discount_Type, 'None') AS Discount_Type,
    ISNULL(P.Discount_Value, 0) AS Discount_Value,
    CAST(
        ISNULL(OST.SubTotal, 0) - 
        CASE 
            WHEN P.Discount_Type = 'Percentage' THEN ISNULL(OST.SubTotal, 0) * (P.Discount_Value / 100.0)
            WHEN P.Discount_Type = 'Fixed' THEN P.Discount_Value
            ELSE 0 
        END 
    AS DECIMAL(10,2)) AS Grand_Total

FROM [FOH].[Order] O JOIN [FOH].[Branch] B 
ON O.Branch_ID = B.Branch_ID
LEFT JOIN OrderSubTotals OST 
ON O.Order_ID = OST.Order_ID
LEFT JOIN [FOH].[Customer] C 
ON O.Membership_Number = C.Membership_Number
LEFT JOIN [FOH].[Order_Promotion] OP 
ON O.Order_ID = OP.Order_ID
LEFT JOIN [FOH].[Promotion] P 
ON OP.Promotion_ID = P.Promotion_ID;

GO

-- Create an indexed schema-bound view to aggregate daily branch sales and revenues
CREATE OR ALTER VIEW [FOH].[vw_DailyBranchSales]
WITH ENCRYPTION , SCHEMABINDING
AS
SELECT 
    O.Branch_ID,
    CONVERT(DATE, O.Placement_DateTime) AS Sales_Date,    
    COUNT_BIG(*) AS Total_Orders,    
    SUM(P.Amount_Paid) AS Total_Revenue
FROM [FOH].[Order] O  JOIN [FOH].[Payment] P 
ON O.Order_ID = P.Order_ID
GROUP BY 
    O.Branch_ID,
    CONVERT(DATE, O.Placement_DateTime);
GO

CREATE UNIQUE CLUSTERED INDEX CIX_vw_DailyBranchSales 
ON [FOH].[vw_DailyBranchSales] (Branch_ID, Sales_Date);

GO

-- Create a stock alert view to monitor ingredients falling below reorder thresholds
CREATE OR ALTER VIEW [Inventory].[vw_BranchStockAlerts]
WITH ENCRYPTION
AS
SELECT 
    B.Branch_Name,
    I.Name AS Ingredient_Name,
    BS.Current_Stock_Level,
    BS.Reorder_Threshold,
    (BS.Reorder_Threshold - BS.Current_Stock_Level) AS Shortage_Amount
FROM [Inventory].[Branch_Stock] BS JOIN [Inventory].[Ingredient] I 
ON BS.Ingredient_ID = I.Ingredient_ID
JOIN [FOH].[Branch] B 
ON BS.Branch_ID = B.Branch_ID
WHERE BS.Current_Stock_Level <= BS.Reorder_Threshold;

GO

-- Create an active employees view with check option validation on job titles
CREATE OR ALTER VIEW [HR].[vw_ActiveEmployees]
WITH ENCRYPTION
AS
SELECT 
    Employee_ID,
    Branch_ID,
    First_Name,
    Last_Name,
    Job_Title,
    Hire_Date
FROM [HR].[Employee]
WHERE Job_Title != 'Resigned'
WITH CHECK OPTION;

GO

-- Create a recursive CTE view to map out the employee management hierarchy
CREATE OR ALTER VIEW [HR].[vw_EmployeeHierarchy]
AS
WITH EmployeeTree AS (
    SELECT 
        Employee_ID,
        First_Name + ' ' + Last_Name AS Employee_Name,
        Job_Title,
        CAST('Top Management' AS NVARCHAR(100)) AS Manager_Name,
        1 AS Hierarchy_Level 
    FROM [HR].[Employee]
    WHERE Employee_ID IN (SELECT Employee_ID FROM [HR].[Manager])

    UNION ALL
    
    SELECT 
        E.Employee_ID,
        E.First_Name + ' ' + E.Last_Name AS Employee_Name,
        E.Job_Title,
        CAST(ET.Employee_Name AS NVARCHAR(100)) AS Manager_Name,
        ET.Hierarchy_Level + 1 AS Hierarchy_Level 
        FROM [HR].[Employee] E INNER JOIN [HR].[Employee_Supervision] ES 
        ON E.Employee_ID = ES.Employee_ID
        INNER JOIN EmployeeTree ET 
        ON ES.Supervisor_ID = ET.Employee_ID
)
SELECT 
    Employee_ID,
    Employee_Name,
    Job_Title,
    Manager_Name,
    Hierarchy_Level
FROM EmployeeTree;

GO

-- Create a pivot view to analyze monthly branch sales performance across the year
CREATE OR ALTER VIEW [FOH].[vw_MonthlySalesPivot]
AS
WITH MonthlySalesData AS (
    SELECT 
        B.Branch_Name,
        FORMAT(O.Placement_DateTime, 'MMM', 'en-US') AS SalesMonth,
        P.Amount_Paid
    FROM [FOH].[Order] O INNER JOIN [FOH].[Payment] P 
    ON O.Order_ID = P.Order_ID
    INNER JOIN [FOH].[Branch] B 
    ON O.Branch_ID = B.Branch_ID
)
SELECT 
    Branch_Name,
    ISNULL([Jan], 0) AS Jan_Sales,
    ISNULL([Feb], 0) AS Feb_Sales,
    ISNULL([Mar], 0) AS Mar_Sales,
    ISNULL([Apr], 0) AS Apr_Sales,
    ISNULL([May], 0) AS May_Sales,
    ISNULL([Jun], 0) AS Jun_Sales,
    ISNULL([Jul], 0) AS Jul_Sales,
    ISNULL([Aug], 0) AS Aug_Sales,
    ISNULL([Sep], 0) AS Sep_Sales,
    ISNULL([Oct], 0) AS Oct_Sales,
    ISNULL([Nov], 0) AS Nov_Sales,
    ISNULL([Dec], 0) AS Dec_Sales
FROM MonthlySalesData
PIVOT (
    SUM(Amount_Paid)
    FOR SalesMonth IN (
        [Jan], [Feb], [Mar], [Apr], [May], [Jun], 
        [Jul], [Aug], [Sep], [Oct], [Nov], [Dec]
    )
) AS PivotTable;

GO


