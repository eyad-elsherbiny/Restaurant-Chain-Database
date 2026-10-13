USE RestaurantChainDB;

GO

-- Add foreign key constraints to establish relational integrity across schemas
ALTER TABLE HR.Employee
ADD CONSTRAINT FK_Employee_Branch FOREIGN KEY (Branch_ID) REFERENCES FOH.Branch(Branch_ID) 
ON DELETE NO ACTION;

GO

ALTER TABLE HR.Manager
ADD CONSTRAINT FK_Manager_Employee FOREIGN KEY (Employee_ID) REFERENCES HR.Employee(Employee_ID) 
ON DELETE CASCADE;

GO

ALTER TABLE HR.Kitchen_Staff
ADD CONSTRAINT FK_KitchenStaff_Employee FOREIGN KEY (Employee_ID) REFERENCES HR.Employee(Employee_ID) 
ON DELETE CASCADE;

GO

ALTER TABLE HR.Driver
ADD CONSTRAINT FK_Driver_Employee FOREIGN KEY (Employee_ID) REFERENCES HR.Employee(Employee_ID) 
ON DELETE CASCADE;

GO

ALTER TABLE HR.Employee_Supervision
ADD CONSTRAINT FK_EmpSup_Employee FOREIGN KEY (Employee_ID) REFERENCES HR.Employee(Employee_ID) 
ON DELETE CASCADE ,
CONSTRAINT FK_EmpSup_Manager FOREIGN KEY (Supervisor_ID) REFERENCES HR.Manager(Employee_ID) 
ON DELETE NO ACTION;

GO

ALTER TABLE HR.Shift_Assignment
ADD CONSTRAINT FK_ShiftAssign_Employee FOREIGN KEY (Employee_ID) REFERENCES HR.Employee(Employee_ID) 
ON DELETE CASCADE ,
CONSTRAINT FK_ShiftAssign_Shift FOREIGN KEY (Shift_ID) REFERENCES HR.Shift(Shift_ID) 
ON DELETE CASCADE;

GO

ALTER TABLE HR.Attendance_Log
ADD CONSTRAINT FK_AttendanceLog_Employee FOREIGN KEY (Employee_ID) REFERENCES HR.Employee(Employee_ID) 
ON DELETE CASCADE;

GO

ALTER TABLE FOH.Branch_Phone
ADD CONSTRAINT FK_BranchPhone_Branch FOREIGN KEY (Branch_ID) REFERENCES FOH.Branch(Branch_ID) 
ON DELETE CASCADE;

GO

ALTER TABLE FOH.Dining_Table
ADD CONSTRAINT FK_DiningTable_Branch FOREIGN KEY (Branch_ID) REFERENCES FOH.Branch(Branch_ID) 
ON DELETE CASCADE;

GO

ALTER TABLE FOH.Customer_Phone
ADD CONSTRAINT FK_CustomerPhone_Customer FOREIGN KEY (Membership_Number) REFERENCES FOH.Customer(Membership_Number) 
ON DELETE CASCADE;

GO

ALTER TABLE FOH.Customer_Address
ADD CONSTRAINT FK_CustomerAddress_Customer FOREIGN KEY (Membership_Number) REFERENCES FOH.Customer(Membership_Number) 
ON DELETE CASCADE;

GO

ALTER TABLE FOH.Customer_Allergy
ADD CONSTRAINT FK_CustAllergy_Customer FOREIGN KEY (Membership_Number) REFERENCES FOH.Customer(Membership_Number) 
ON DELETE CASCADE,
CONSTRAINT FK_CustAllergy_Allergy FOREIGN KEY (Allergy_ID) REFERENCES FOH.Allergy(Allergy_ID) 
ON DELETE CASCADE;

GO

ALTER TABLE FOH.Reservation
ADD CONSTRAINT FK_Reservation_Customer FOREIGN KEY (Membership_Number) REFERENCES FOH.Customer(Membership_Number) 
ON DELETE CASCADE;

GO

ALTER TABLE FOH.Table_Reservation
ADD CONSTRAINT FK_TableRes_Reservation FOREIGN KEY (Reservation_ID) REFERENCES FOH.Reservation(Reservation_ID) 
ON DELETE CASCADE ,
CONSTRAINT FK_TableRes_DiningTable FOREIGN KEY (DT_Number) REFERENCES FOH.Dining_Table(DT_Number) 
ON DELETE NO ACTION;

GO

ALTER TABLE FOH.[Order]
ADD CONSTRAINT FK_Order_Customer FOREIGN KEY (Membership_Number) REFERENCES FOH.Customer(Membership_Number) 
ON DELETE NO ACTION ,
CONSTRAINT FK_Order_Branch FOREIGN KEY (Branch_ID) REFERENCES FOH.Branch(Branch_ID) 
ON DELETE NO ACTION;

GO

ALTER TABLE FOH.Delivery_Order
ADD CONSTRAINT FK_DeliveryOrder_Order FOREIGN KEY (Order_ID) REFERENCES FOH.[Order](Order_ID) 
ON DELETE CASCADE;

GO

ALTER TABLE FOH.Order_Driver_Assignment
ADD CONSTRAINT FK_OrderDriver_Order FOREIGN KEY (Order_ID) REFERENCES FOH.[Order](Order_ID) 
ON DELETE CASCADE ,
CONSTRAINT FK_OrderDriver_Driver FOREIGN KEY (Driver_ID) REFERENCES HR.Driver(Employee_ID) 
ON DELETE NO ACTION;

GO

ALTER TABLE FOH.Order_Promotion
ADD CONSTRAINT FK_OrderPromo_Order FOREIGN KEY (Order_ID) REFERENCES FOH.[Order](Order_ID) 
ON DELETE CASCADE ,
CONSTRAINT FK_OrderPromo_Promotion FOREIGN KEY (Promotion_ID) REFERENCES FOH.Promotion(Promotion_ID) 
ON DELETE CASCADE;

GO

ALTER TABLE FOH.Review
ADD CONSTRAINT FK_Review_Order FOREIGN KEY (Order_ID) REFERENCES FOH.[Order](Order_ID) 
ON DELETE CASCADE ,
CONSTRAINT FK_Review_Customer FOREIGN KEY (Membership_Number) REFERENCES FOH.Customer(Membership_Number) 
ON DELETE NO ACTION;

GO

ALTER TABLE FOH.Payment
ADD CONSTRAINT FK_Payment_Order FOREIGN KEY (Order_ID) REFERENCES FOH.[Order](Order_ID) 
ON DELETE CASCADE;

GO

-- Configure remaining constraints for BOH, Inventory, and Procurement entities
ALTER TABLE BOH.Menu_Category
ADD CONSTRAINT FK_MenuCategory_Parent FOREIGN KEY (Parent_Category_ID) REFERENCES BOH.Menu_Category(Category_ID) 
ON DELETE NO ACTION;

GO

ALTER TABLE BOH.Menu_Item
ADD CONSTRAINT FK_MenuItem_Category FOREIGN KEY (Category_ID) REFERENCES BOH.Menu_Category(Category_ID) 
ON DELETE NO ACTION;

GO

ALTER TABLE BOH.Available_Menu
ADD CONSTRAINT FK_AvailableMenu_Menu FOREIGN KEY (Menu_ID) REFERENCES BOH.Menu(Menu_ID) 
ON DELETE CASCADE,
CONSTRAINT FK_AvailableMenu_Branch FOREIGN KEY (Branch_ID) REFERENCES FOH.Branch(Branch_ID) 
ON DELETE CASCADE;

GO

ALTER TABLE BOH.Menu_Contains_Item
ADD CONSTRAINT FK_MenuContains_Menu FOREIGN KEY (Menu_ID) REFERENCES BOH.Menu(Menu_ID) 
ON DELETE CASCADE,
CONSTRAINT FK_MenuContains_Item FOREIGN KEY (Item_ID) REFERENCES BOH.Menu_Item(Item_ID) 
ON DELETE CASCADE;

GO

ALTER TABLE BOH.Recipe
ADD CONSTRAINT FK_Recipe_MenuItem FOREIGN KEY (Item_ID) REFERENCES BOH.Menu_Item(Item_ID) 
ON DELETE CASCADE,
CONSTRAINT FK_Recipe_Ingredient FOREIGN KEY (Ingredient_ID) REFERENCES Inventory.Ingredient(Ingredient_ID) 
ON DELETE CASCADE;

GO

ALTER TABLE BOH.Order_Item
ADD CONSTRAINT FK_OrderItem_MenuItem FOREIGN KEY (Item_ID) REFERENCES BOH.Menu_Item(Item_ID) 
ON DELETE NO ACTION,
CONSTRAINT FK_OrderItem_Order FOREIGN KEY (Order_ID, Order_Date) REFERENCES FOH.[Order](Order_ID, Placement_Date) 
ON DELETE CASCADE;

GO

ALTER TABLE BOH.Order_Item_Modifier
ADD CONSTRAINT FK_OrderItemMod_OrderItem FOREIGN KEY (Order_Item_ID, Order_Date) REFERENCES BOH.Order_Item(Order_Item_ID, Order_Date) 
ON DELETE CASCADE,
CONSTRAINT FK_OrderItemMod_Modifier FOREIGN KEY (Modifier_ID) REFERENCES BOH.Modifier(Modifier_ID) 
ON DELETE NO ACTION;

GO

ALTER TABLE Inventory.Branch_Stock
ADD CONSTRAINT FK_BranchStock_Branch FOREIGN KEY (Branch_ID) REFERENCES FOH.Branch(Branch_ID) 
ON DELETE CASCADE,
CONSTRAINT FK_BranchStock_Ingredient FOREIGN KEY (Ingredient_ID) REFERENCES Inventory.Ingredient(Ingredient_ID) 
ON DELETE CASCADE;

GO

ALTER TABLE Inventory.Stock_Transfer
ADD CONSTRAINT FK_StockTransfer_SendingBranch FOREIGN KEY (Sending_Branch_ID) REFERENCES FOH.Branch(Branch_ID) 
ON DELETE NO ACTION,
CONSTRAINT FK_StockTransfer_ReceivingBranch FOREIGN KEY (Receiving_Branch_ID) REFERENCES FOH.Branch(Branch_ID) 
ON DELETE NO ACTION,
CONSTRAINT FK_StockTransfer_Ingredient FOREIGN KEY (Ingredient_ID) REFERENCES Inventory.Ingredient(Ingredient_ID) 
ON DELETE NO ACTION;

GO

ALTER TABLE Inventory.Waste_Log
ADD CONSTRAINT FK_WasteLog_Branch FOREIGN KEY (Branch_ID) REFERENCES FOH.Branch(Branch_ID) 
ON DELETE NO ACTION,
CONSTRAINT FK_WasteLog_Ingredient FOREIGN KEY (Ingredient_ID) REFERENCES Inventory.Ingredient(Ingredient_ID) 
ON DELETE NO ACTION,
CONSTRAINT FK_WasteLog_Employee FOREIGN KEY (Employee_ID) REFERENCES HR.Employee(Employee_ID) 
ON DELETE NO ACTION;

GO

ALTER TABLE Procurement.Supplier_Pricing
ADD CONSTRAINT FK_SupplierPricing_Supplier FOREIGN KEY (Supplier_ID) REFERENCES Procurement.Supplier(Supplier_ID) 
ON DELETE CASCADE,
CONSTRAINT FK_SupplierPricing_Ingredient FOREIGN KEY (Ingredient_ID) REFERENCES Inventory.Ingredient(Ingredient_ID) 
ON DELETE CASCADE;

GO

ALTER TABLE Procurement.Purchase_Order
ADD CONSTRAINT FK_PO_Supplier FOREIGN KEY (Supplier_ID) REFERENCES Procurement.Supplier(Supplier_ID) 
ON DELETE NO ACTION,
CONSTRAINT FK_PO_Branch FOREIGN KEY (Branch_ID) REFERENCES FOH.Branch(Branch_ID) 
ON DELETE NO ACTION,
CONSTRAINT FK_PO_Employee FOREIGN KEY (Employee_ID) REFERENCES HR.Employee(Employee_ID) 
ON DELETE NO ACTION;

GO

ALTER TABLE Procurement.PO_Line
ADD CONSTRAINT FK_POLine_PO FOREIGN KEY (PO_ID) REFERENCES Procurement.Purchase_Order(PO_ID) 
ON DELETE CASCADE,
CONSTRAINT FK_POLine_Ingredient FOREIGN KEY (Ingredient_ID) REFERENCES Inventory.Ingredient(Ingredient_ID) 
ON DELETE NO ACTION;

GO

ALTER TABLE Procurement.Receipt
ADD CONSTRAINT FK_Receipt_POLine FOREIGN KEY (PO_Line_ID) REFERENCES Procurement.PO_Line(PO_Line_ID) 
ON DELETE CASCADE,
CONSTRAINT FK_Receipt_Employee FOREIGN KEY (Employee_ID) REFERENCES HR.Employee(Employee_ID) 
ON DELETE NO ACTION;

GO
