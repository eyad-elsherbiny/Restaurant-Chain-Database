USE RestaurantChainDB;
GO

-- Create HR schema tables to manage employees, roles, shifts, and attendance logs
CREATE TABLE HR.Employee (
    Employee_ID INT IDENTITY(1,1) CONSTRAINT PK_Employee PRIMARY KEY,
    Branch_ID INT NOT NULL,  
    First_Name NVARCHAR(50) NOT NULL,
    Middle_Name NVARCHAR(50) SPARSE,
    Last_Name NVARCHAR(50) NOT NULL,
    Date_Of_Birth DATE NOT NULL,
    Hire_Date DATE NOT NULL,
    Job_Title NVARCHAR(50) NOT NULL, 
    
    Age AS (DATEDIFF(YEAR, Date_Of_Birth, GETDATE())),
    Years_Of_Service AS (DATEDIFF(YEAR, Hire_Date, GETDATE())),
    
    CONSTRAINT CHK_Employee_HireDate CHECK (Hire_Date >= DATEADD(YEAR, 18, Date_Of_Birth))
) ON [FG_MasterData];
GO

CREATE TABLE HR.Manager (
    Employee_ID INT CONSTRAINT PK_Manager PRIMARY KEY,
    Annual_Bonus_Percentage DECIMAL(5,2)
) ON [FG_MasterData];

CREATE TABLE HR.Employee_Supervision (
    Employee_ID INT CONSTRAINT PK_Employee_Supervision PRIMARY KEY,
    Supervisor_ID INT NOT NULL
) ON [FG_MasterData];

CREATE TABLE HR.Kitchen_Staff (
    Employee_ID INT CONSTRAINT PK_Kitchen_Staff PRIMARY KEY,
    Culinary_School NVARCHAR(100),
    Certificate_Expiry_Date DATE NOT NULL,
    Health_Certificate_Number VARCHAR(50) NOT NULL
) ON [FG_MasterData];

CREATE TABLE HR.Driver (
    Employee_ID INT CONSTRAINT PK_Driver PRIMARY KEY,
    License_Expiry_Date DATE NOT NULL,
    Plate_Number VARCHAR(20) NOT NULL,
    Vehicle_Make NVARCHAR(50),
    License_Number VARCHAR(50) NOT NULL
) ON [FG_MasterData];

CREATE TABLE HR.Shift (
    Shift_ID INT IDENTITY(1,1) CONSTRAINT PK_Shift PRIMARY KEY,
    Scheduled_Start_Time TIME NOT NULL,
    Scheduled_End_Time TIME NOT NULL
) ON [FG_MasterData];

CREATE TABLE HR.Shift_Assignment (
    Employee_ID INT NOT NULL,
    Shift_ID INT NOT NULL,
    Date DATE NOT NULL,
    CONSTRAINT PK_Shift_Assignment PRIMARY KEY (Employee_ID, Shift_ID, Date)
) ON [FG_MasterData];

CREATE TABLE HR.Attendance_Log (
    Log_ID INT IDENTITY(1,1),
    Employee_ID INT NOT NULL,
    Clock_In_DateTime DATETIME NOT NULL,
    Clock_Out_DateTime DATETIME,
    Status VARCHAR(20),
    Manager_Notes NVARCHAR(255) SPARSE, 
    
    Clock_In_Date AS CAST(Clock_In_DateTime AS DATE) PERSISTED,
    
    CONSTRAINT PK_Attendance_Log PRIMARY KEY CLUSTERED (Log_ID, Clock_In_Date)
    WITH (FILLFACTOR = 90) ON ps_OrderDate(Clock_In_Date),
    
    CONSTRAINT CHK_Attendance_Status CHECK (Status IN ('Present', 'Missing_Out', 'Late', 'Absent'))
);
GO