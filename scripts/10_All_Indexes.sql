USE RestaurantChainDB;

GO

-- Create nonclustered and filtered indexes to optimize query performance and search speeds
CREATE NONCLUSTERED INDEX IX_Order_Membership 
ON FOH.[Order](Membership_Number) 
ON ps_OrderDate(Placement_Date);

CREATE NONCLUSTERED INDEX IX_Order_Branch 
ON FOH.[Order](Branch_ID) 
ON ps_OrderDate(Placement_Date);

CREATE NONCLUSTERED INDEX IX_DeliveryOrder_Order 
ON FOH.Delivery_Order(Order_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_Payment_Order 
ON FOH.Payment(Order_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_Reservation_Membership 
ON FOH.Reservation(Membership_Number) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_DiningTable_Branch 
ON FOH.Dining_Table(Branch_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_Review_Order 
ON FOH.Review(Order_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_Review_Membership 
ON FOH.Review(Membership_Number) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_Customer_Email 
ON FOH.Customer(Email) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_Customer_Name
ON FOH.Customer(First_Name, Last_Name)
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_Order_ActiveStatus 
ON FOH.[Order](Status) 
INCLUDE (Order_Type, Placement_DateTime)
WHERE Status IN ('Pending', 'Preparing') 
ON ps_OrderDate(Placement_Date);

CREATE NONCLUSTERED INDEX IX_Reservation_Pending 
ON FOH.Reservation(Status) 
INCLUDE (Reservation_Date, Reservation_Time, Expected_Guests)
WHERE Status = 'Pending' 
ON [FG_MasterData];

GO

CREATE NONCLUSTERED INDEX IX_Employee_Branch 
ON HR.Employee(Branch_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_ShiftAssign_Employee 
ON HR.Shift_Assignment(Employee_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_ShiftAssign_Shift 
ON HR.Shift_Assignment(Shift_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_Attendance_Emp_Date 
ON HR.Attendance_Log(Employee_ID, Clock_In_DateTime)
INCLUDE (Status, Clock_Out_DateTime) 
ON ps_OrderDate(Clock_In_Date); 

CREATE NONCLUSTERED INDEX IX_Employee_Name 
ON HR.Employee(First_Name, Last_Name) 
ON [FG_MasterData];

GO

CREATE NONCLUSTERED INDEX IX_MenuItem_Category 
ON BOH.Menu_Item(Category_ID) 
INCLUDE (Name) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_Recipe_MenuItem 
ON BOH.Recipe(Item_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_Recipe_Ingredient 
ON BOH.Recipe(Ingredient_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_OrderItem_Order 
ON BOH.Order_Item(Order_ID) 
ON ps_OrderDate(Order_Date);

CREATE NONCLUSTERED INDEX IX_OrderItem_MenuItem 
ON BOH.Order_Item(Item_ID) 
ON ps_OrderDate(Order_Date);

CREATE NONCLUSTERED INDEX IX_MenuItem_Name 
ON BOH.Menu_Item(Name) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_OrderItemMod_OrderItem 
ON BOH.Order_Item_Modifier(Order_Item_ID) 
ON ps_OrderDate(Order_Date);

CREATE NONCLUSTERED INDEX IX_OrderItemMod_Modifier 
ON BOH.Order_Item_Modifier(Modifier_ID) 
ON ps_OrderDate(Order_Date);

GO

CREATE NONCLUSTERED INDEX IX_BranchStock_Branch 
ON Inventory.Branch_Stock(Branch_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_BranchStock_Ingredient 
ON Inventory.Branch_Stock(Ingredient_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_StockTransfer_Sending 
ON Inventory.Stock_Transfer(Sending_Branch_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_StockTransfer_Receiving 
ON Inventory.Stock_Transfer(Receiving_Branch_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_WasteLog_Branch 
ON Inventory.Waste_Log(Branch_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_WasteLog_Ingredient 
ON Inventory.Waste_Log(Ingredient_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_Ingredient_Name 
ON Inventory.Ingredient(Name) 
ON [FG_MasterData];

GO

CREATE NONCLUSTERED INDEX IX_SupplierPricing_Supplier 
ON Procurement.Supplier_Pricing(Supplier_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_SupplierPricing_Ingredient 
ON Procurement.Supplier_Pricing(Ingredient_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_PO_Supplier 
ON Procurement.Purchase_Order(Supplier_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_PO_Branch 
ON Procurement.Purchase_Order(Branch_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_POLine_PO 
ON Procurement.PO_Line(PO_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_POLine_Ingredient 
ON Procurement.PO_Line(Ingredient_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_Receipt_POLine 
ON Procurement.Receipt(PO_Line_ID) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_Supplier_Name
ON Procurement.Supplier(Company_Name) 
ON [FG_MasterData];

CREATE NONCLUSTERED INDEX IX_PO_PendingStatus 
ON Procurement.Purchase_Order(Status) 
INCLUDE (Supplier_ID, Branch_ID)
WHERE Status IN ('Pending', 'Partially Received') 
ON [FG_MasterData];

GO