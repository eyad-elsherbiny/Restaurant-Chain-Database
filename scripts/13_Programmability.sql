USE [RestaurantChainDB];

GO

-- Create a scalar function to calculate the grand total for a specific order including taxes and promotions
CREATE OR ALTER FUNCTION [FOH].[fn_CalcOrderGrandTotal]  ( @OrderID INT )
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @SubTotal DECIMAL(10,2) = 0;
    DECLARE @DiscountAmount DECIMAL(10,2) = 0;
    DECLARE @GrandTotal DECIMAL(10,2) = 0;
    DECLARE @TaxRate DECIMAL(4,2) = 0.14; 

    SELECT @SubTotal = ISNULL(SUM(OI.Quantity * MI.Current_Selling_Price), 0)
    FROM [BOH].[Order_Item] OI
    JOIN [BOH].[Menu_Item] MI ON OI.Item_ID = MI.Item_ID
    WHERE OI.Order_ID = @OrderID;

    SELECT @DiscountAmount = 
        CASE 
            WHEN P.Discount_Type = 'Percentage' THEN @SubTotal * (P.Discount_Value / 100.0)
            WHEN P.Discount_Type = 'Fixed' THEN P.Discount_Value
            ELSE 0 
        END
    FROM [FOH].[Order_Promotion] OP
    JOIN [FOH].[Promotion] P ON OP.Promotion_ID = P.Promotion_ID
    WHERE OP.Order_ID = @OrderID;

    SET @DiscountAmount = ISNULL(@DiscountAmount, 0);

    SET @GrandTotal = (@SubTotal - @DiscountAmount) * (1 + @TaxRate);

    RETURN @GrandTotal;
END;

GO

-- Create an inline table-valued function to retrieve all available menu items for a specific branch
CREATE OR ALTER FUNCTION [BOH].[fn_GetBranchAvailableItems] ( @BranchID INT )
RETURNS TABLE 
AS
RETURN 
(
    SELECT DISTINCT
        MI.Item_ID,
        MI.Name AS Item_Name,
        MI.Current_Selling_Price,
        MC.Category_Name AS Category_Name
    FROM [BOH].[Available_Menu] AM JOIN [BOH].[Menu] M 
    ON AM.Menu_ID = M.Menu_ID
    JOIN [BOH].[Menu_Contains_Item] MCI 
    ON M.Menu_ID = MCI.Menu_ID
    JOIN [BOH].[Menu_Item] MI 
    ON MCI.Item_ID = MI.Item_ID
    JOIN [BOH].[Menu_Category] MC 
    ON MI.Category_ID = MC.Category_ID
    WHERE AM.Branch_ID = @BranchID
);

GO

-- Create a multi-statement table-valued function to generate an inventory restock list with urgency levels
CREATE OR ALTER FUNCTION [Inventory].[fn_GetInventoryRestockList] ( @BranchID INT )
RETURNS @RestockList TABLE 
(
    Ingredient_Name NVARCHAR(100),
    Current_Quantity DECIMAL(10,2),
    Required_Quantity DECIMAL(10,2),
    Urgency_Level NVARCHAR(20)
)
AS
BEGIN
    INSERT INTO @RestockList (Ingredient_Name, Current_Quantity, Required_Quantity)
    SELECT 
        I.Name,
        BS.Current_Stock_Level,
        (BS.Reorder_Threshold * 2) - BS.Current_Stock_Level 
    FROM [Inventory].[Branch_Stock] BS JOIN [Inventory].[Ingredient] I 
    ON BS.Ingredient_ID = I.Ingredient_ID
    WHERE BS.Branch_ID = @BranchID 
      AND BS.Current_Stock_Level <= BS.Reorder_Threshold;

    UPDATE @RestockList
    SET Urgency_Level = 
        CASE 
            WHEN Current_Quantity <= 0 THEN 'Critical (Out of Stock)'
            WHEN Current_Quantity <= 10 THEN 'High'
            ELSE 'Medium'
        END;

    RETURN;
END;

GO

-- Create an audit table to track changes made to menu item pricing
CREATE TABLE [BOH].[Audit_Menu_Prices] (
    Audit_ID INT IDENTITY(1,1) PRIMARY KEY,
    Item_ID INT,
    Old_Price DECIMAL(10,2),
    New_Price DECIMAL(10,2),
    Modified_By NVARCHAR(100), 
    Modified_Date DATETIME DEFAULT GETDATE() 
);

GO

-- Create a DML trigger to log price updates on menu items into the audit table
CREATE OR ALTER TRIGGER [BOH].[trg_AuditMenuPrice]
ON [BOH].[Menu_Item]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(Current_Selling_Price)
    BEGIN
        INSERT INTO [BOH].[Audit_Menu_Prices] (Item_ID, Old_Price, New_Price, Modified_By)
        SELECT 
            i.Item_ID,
            d.Current_Selling_Price AS Old_Price, 
            i.Current_Selling_Price AS New_Price, 
            SUSER_NAME() 
        FROM inserted i INNER JOIN deleted d 
        ON i.Item_ID = d.Item_ID
        WHERE i.Current_Selling_Price <> d.Current_Selling_Price; 
    END
END;

GO

-- Create an INSTEAD OF DELETE trigger to safely handle order deletions or archive completed orders
CREATE OR ALTER TRIGGER [FOH].[trg_SafeDeleteOrder]
ON [FOH].[Order]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE O
    SET O.Status = 'Archived'
    FROM [FOH].[Order] O INNER JOIN deleted d 
    ON O.Order_ID = d.Order_ID
    WHERE d.Status = 'Completed';

    DELETE O
    FROM [FOH].[Order] O INNER JOIN deleted d 
    ON O.Order_ID = d.Order_ID
    WHERE d.Status <> 'Completed';
END;

GO

-- Create a stored procedure to handle order placement, validation, inventory deduction, and error handling
CREATE OR ALTER PROCEDURE [FOH].[sp_PlaceOrder]
(
    @Branch_ID INT,
    @Membership_Number INT = NULL, 
    @Order_Type NVARCHAR(50),     
    @Item_ID INT,              
    @Quantity INT,            
    @NewOrderID INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @InsertedOrder TABLE (OrderID INT);

    BEGIN TRY
        IF @Membership_Number IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM [FOH].[Customer] WHERE Membership_Number = @Membership_Number)
            BEGIN
                THROW 50001, 'Error: Customer membership number does not exist.', 1;
            END
        END

        IF NOT EXISTS (
            SELECT 1 
            FROM [BOH].[Available_Menu] AM INNER JOIN [BOH].[Menu_Contains_Item] MCI 
            ON AM.Menu_ID = MCI.Menu_ID
            WHERE AM.Branch_ID = @Branch_ID AND MCI.Item_ID = @Item_ID
        )
        BEGIN
            THROW 50002, 'Error: This item is currently not available at the selected branch.', 1;
        END

        BEGIN TRAN;

            INSERT INTO [FOH].[Order] (Membership_Number, Branch_ID, Order_Type, Placement_DateTime, Status)
            OUTPUT inserted.Order_ID INTO @InsertedOrder 
            VALUES (@Membership_Number, @Branch_ID, @Order_Type, GETDATE(), 'Pending');

            SELECT TOP 1 @NewOrderID = OrderID FROM @InsertedOrder;

            INSERT INTO [BOH].[Order_Item] (Order_ID, Item_ID, Quantity)
            VALUES (@NewOrderID, @Item_ID, @Quantity);

            UPDATE BS
            SET BS.Current_Stock_Level = BS.Current_Stock_Level - (R.Quantity_Required * @Quantity)
            FROM [Inventory].[Branch_Stock] BS INNER JOIN [BOH].[Recipe] R 
            ON BS.Ingredient_ID = R.Ingredient_ID
            WHERE R.Item_ID = @Item_ID AND BS.Branch_ID = @Branch_ID;

            IF EXISTS (SELECT 1 FROM [Inventory].[Branch_Stock] WHERE Branch_ID = @Branch_ID AND Current_Stock_Level < 0)
            BEGIN
                THROW 50003, 'Error: Insufficient inventory stock to fulfill this order.', 1;
            END

        COMMIT TRAN;

    END TRY
    BEGIN CATCH
        
        IF @@TRANCOUNT > 0 
            ROLLBACK TRAN;
        
        THROW;
    END CATCH
END;

GO

