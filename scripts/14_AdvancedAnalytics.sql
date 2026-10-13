USE [RestaurantChainDB];

GO

-- Create a stored procedure for comprehensive sales analytics using grouping sets, rollups, and cubes
CREATE OR ALTER PROCEDURE [FOH].[sp_ComprehensiveSalesAnalytics]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        'Grouping Sets' AS Report_Type,
        ISNULL(B.Branch_Name, '---') AS Branch_Name,
        ISNULL(CAST(YEAR(O.Placement_DateTime) AS VARCHAR(4)), '---') AS Sales_Year,
        SUM(P.Amount_Paid) AS Total_Revenue
    FROM [FOH].[Order] O INNER JOIN [FOH].[Payment] P 
    ON O.Order_ID = P.Order_ID
    JOIN [FOH].[Branch] B 
    ON O.Branch_ID = B.Branch_ID
    GROUP BY GROUPING SETS (
        (B.Branch_Name),              
        (YEAR(O.Placement_DateTime)), 
        ()                          
    );

    SELECT 
        'Rollup (Hierarchy)' AS Report_Type,
        CASE WHEN GROUPING(B.Branch_Name) = 1 THEN '** GRAND TOTAL **' ELSE B.Branch_Name END AS Branch_Name,
        CASE WHEN GROUPING(YEAR(O.Placement_DateTime)) = 1 THEN 'All Years' ELSE CAST(YEAR(O.Placement_DateTime) AS VARCHAR(4)) END AS Sales_Year,
        CASE WHEN GROUPING(MONTH(O.Placement_DateTime)) = 1 THEN 'All Months' ELSE CAST(MONTH(O.Placement_DateTime) AS VARCHAR(2)) END AS Sales_Month,
        SUM(P.Amount_Paid) AS Total_Revenue
    FROM [FOH].[Order] O INNER JOIN [FOH].[Payment] P 
    ON O.Order_ID = P.Order_ID
    INNER JOIN [FOH].[Branch] B 
    ON O.Branch_ID = B.Branch_ID
    GROUP BY ROLLUP (
        B.Branch_Name, 
        YEAR(O.Placement_DateTime), 
        MONTH(O.Placement_DateTime)
    );

    SELECT 
        'Cube (Cross-Tab)' AS Report_Type,
        CASE WHEN GROUPING(B.Branch_Name) = 1 THEN 'Any Branch' ELSE B.Branch_Name END AS Branch_Name,
        CASE WHEN GROUPING(O.Order_Type) = 1 THEN 'Any Type' ELSE O.Order_Type END AS Order_Type,
        COUNT(O.Order_ID) AS Total_Orders,
        SUM(P.Amount_Paid) AS Total_Revenue
    FROM [FOH].[Order] O INNER JOIN [FOH].[Payment] P 
    ON O.Order_ID = P.Order_ID
    INNER JOIN [FOH].[Branch] B 
    ON O.Branch_ID = B.Branch_ID
    GROUP BY CUBE (
        B.Branch_Name, 
        O.Order_Type
    );

END;

GO

-- Create a stored procedure for branch performance time-series analysis with running totals and growth percentages
CREATE OR ALTER PROCEDURE [FOH].[sp_BranchPerformanceTimeSeries]
AS
BEGIN
    SET NOCOUNT ON;

    WITH DailyBranchSales AS (
        SELECT 
            B.Branch_Name,
            CONVERT(DATE, O.Placement_DateTime) AS Sales_Date,
            SUM(P.Amount_Paid) AS Daily_Revenue
        FROM [FOH].[Order] O INNER JOIN [FOH].[Payment] P 
        ON O.Order_ID = P.Order_ID
        INNER JOIN [FOH].[Branch] B 
        ON O.Branch_ID = B.Branch_ID
        GROUP BY B.Branch_Name, CONVERT(DATE, O.Placement_DateTime)
    )
    
    SELECT 
        Branch_Name,
        Sales_Date,
        Daily_Revenue,
       
        SUM(Daily_Revenue) OVER (
            PARTITION BY Branch_Name 
            ORDER BY Sales_Date
        ) AS Monthly_Running_Total,

      
        ISNULL(
            LAG(Daily_Revenue) OVER (
                PARTITION BY Branch_Name 
                ORDER BY Sales_Date
            ), 0
        ) AS Previous_Day_Revenue,

        CASE 
            WHEN LAG(Daily_Revenue) OVER (PARTITION BY Branch_Name ORDER BY Sales_Date) IS NULL THEN 0
            ELSE 
                CAST(
                    ((Daily_Revenue - LAG(Daily_Revenue) OVER (PARTITION BY Branch_Name ORDER BY Sales_Date)) 
                    / 
                    LAG(Daily_Revenue) OVER (PARTITION BY Branch_Name ORDER BY Sales_Date)) * 100 
                AS DECIMAL(10,2))
        END AS Growth_Percentage

    FROM DailyBranchSales
    ORDER BY Branch_Name, Sales_Date;

END;

GO

-- Create a stored procedure to generate a paginated customer loyalty leaderboard using window functions
CREATE OR ALTER PROCEDURE [FOH].[sp_GetCustomerLeaderboard]
(
    @PageNumber INT = 1, 
    @PageSize INT = 10   
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    WITH CustomerTotals AS (
        SELECT 
            C.Membership_Number,
            CONCAT_WS(' ', C.First_Name, C.Last_Name) AS Customer_Name,
            SUM(P.Amount_Paid) AS Total_Spent
        FROM [FOH].[Customer] C INNER JOIN [FOH].[Order] O 
        ON C.Membership_Number = O.Membership_Number
        INNER JOIN [FOH].[Payment] P 
        ON O.Order_ID = P.Order_ID
        GROUP BY C.Membership_Number, C.First_Name, C.Last_Name
    ),
    
    RankedCustomers AS (
        SELECT 
            Membership_Number,
            Customer_Name,
            Total_Spent,
            
            DENSE_RANK() OVER (ORDER BY Total_Spent DESC) AS Rank_Position,
            
            NTILE(4) OVER (ORDER BY Total_Spent DESC) AS Customer_Tier_Number
        FROM CustomerTotals
    )
    
    SELECT 
        Rank_Position,
        Membership_Number,
        Customer_Name,
        Total_Spent,
        CASE Customer_Tier_Number
            WHEN 1 THEN 'Diamond (VIP)'
            WHEN 2 THEN 'Gold'
            WHEN 3 THEN 'Silver'
            WHEN 4 THEN 'Bronze'
        END AS Loyalty_Tier
    FROM RankedCustomers
    ORDER BY Rank_Position 
    
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;

END;

GO

-- Create a stored procedure to compare branch sales using relational operators and unpivot monthly data
CREATE OR ALTER PROCEDURE [FOH].[sp_CompareBranchesAndUnpivot]
(
    @BranchA_ID INT = 1,
    @BranchB_ID INT = 2
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 'Sold in BOTH Branches' AS Comparison_Result, MI.Name AS MenuItem
    FROM [BOH].[Order_Item] OI INNER JOIN [FOH].[Order] O 
    ON OI.Order_ID = O.Order_ID 
    INNER JOIN [BOH].[Menu_Item] MI 
    ON OI.Item_ID = MI.Item_ID
    WHERE O.Branch_ID = @BranchA_ID

    INTERSECT

    SELECT 'Sold in BOTH Branches', MI.Name
    FROM [BOH].[Order_Item] OI INNER JOIN [FOH].[Order] O 
    ON OI.Order_ID = O.Order_ID 
    INNER JOIN [BOH].[Menu_Item] MI 
    ON OI.Item_ID = MI.Item_ID
    WHERE O.Branch_ID = @BranchB_ID;

    SELECT CONCAT('Sold in Branch ', @BranchA_ID, ' ONLY') AS Comparison_Result, MI.Name AS MenuItem
    FROM [BOH].[Order_Item] OI INNER JOIN [FOH].[Order] O 
    ON OI.Order_ID = O.Order_ID 
    INNER JOIN [BOH].[Menu_Item] MI 
    ON OI.Item_ID = MI.Item_ID
    WHERE O.Branch_ID = @BranchA_ID

    EXCEPT

    SELECT CONCAT('Sold in Branch ', @BranchA_ID, ' ONLY'), MI.Name
    FROM [BOH].[Order_Item] OI INNER JOIN [FOH].[Order] O 
    ON OI.Order_ID = O.Order_ID 
    INNER JOIN [BOH].[Menu_Item] MI 
    ON OI.Item_ID = MI.Item_ID
    WHERE O.Branch_ID = @BranchB_ID;

  
    SELECT 
        Branch_Name,
        Sales_Month,
        Monthly_Revenue
    FROM 
        (
            SELECT 
                Branch_Name, 
                Jan_Sales, Feb_Sales, Mar_Sales, Apr_Sales, May_Sales, Jun_Sales, 
                Jul_Sales, Aug_Sales, Sep_Sales, Oct_Sales, Nov_Sales, Dec_Sales 
            FROM [FOH].[vw_MonthlySalesPivot]
        ) AS PivotTable
    UNPIVOT
    (
        Monthly_Revenue FOR Sales_Month IN 
        (
            Jan_Sales, Feb_Sales, Mar_Sales, Apr_Sales, May_Sales, Jun_Sales, 
            Jul_Sales, Aug_Sales, Sep_Sales, Oct_Sales, Nov_Sales, Dec_Sales
        )
    ) AS UnpivotTable;

END;

GO

