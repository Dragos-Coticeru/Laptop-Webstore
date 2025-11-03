IF DB_ID(N'Website_Database') IS NOT NULL
BEGIN
    ALTER DATABASE Website_Database SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Website_Database;
END
GO
CREATE DATABASE Website_Database;
GO
USE Website_Database;
GO


CREATE TABLE dbo.Users (
    UserID       INT IDENTITY(1,1) PRIMARY KEY,
    FirstName    NVARCHAR(100)  NOT NULL,
    LastName     NVARCHAR(100)  NOT NULL,
    Email        NVARCHAR(255)  NOT NULL,
    [Password]   NVARCHAR(255)  NOT NULL,
    PhoneNumber  NVARCHAR(50)       NULL,
    UserType     CHAR(1)        NOT NULL,  -- 'A' admin, 'C' customer
    CreatedAt    DATETIME2(0)   NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT UQ_Users_Email UNIQUE (Email),
    CONSTRAINT CK_Users_UserType CHECK (UserType IN ('A','C'))
);
GO


CREATE TABLE dbo.Addresses (
    AddressID  INT IDENTITY(1,1) PRIMARY KEY,
    UserID     INT            NOT NULL,
    Street     NVARCHAR(200)  NOT NULL,
    [Number]   NVARCHAR(20)       NULL,
    City       NVARCHAR(100)  NOT NULL,
    PostalCode NVARCHAR(20)   NOT NULL,
    CONSTRAINT FK_Addresses_User
        FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID)
        ON UPDATE NO ACTION ON DELETE CASCADE
);
GO
CREATE NONCLUSTERED INDEX IX_Addresses_UserID ON dbo.Addresses(UserID);
GO


CREATE TABLE dbo.Brands (
    BrandID           INT IDENTITY(1,1) PRIMARY KEY,
    BrandName         NVARCHAR(200) NOT NULL,
    CollaborationDate DATE              NULL,
    CONSTRAINT UQ_Brands_BrandName UNIQUE (BrandName)
);
GO


CREATE TABLE dbo.Categories (
    CategoryID   INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(200) NOT NULL,
    [Description] NVARCHAR(MAX)    NULL,
    CONSTRAINT UQ_Categories_Name UNIQUE (CategoryName)
);
GO


CREATE TABLE dbo.Laptops (
    LaptopID      INT IDENTITY(1,1) PRIMARY KEY,
    BrandID       INT            NOT NULL,
    CategoryID    INT            NOT NULL,
    ModelName     NVARCHAR(200)  NOT NULL,
    Price         DECIMAL(12,2)  NOT NULL CONSTRAINT CK_Laptops_Price CHECK (Price >= 0),
    StockQuantity INT            NOT NULL CONSTRAINT CK_Laptops_Stock CHECK (StockQuantity >= 0),
    Processor     NVARCHAR(200)  NOT NULL,
    RAM           INT            NOT NULL CONSTRAINT CK_Laptops_RAM CHECK (RAM > 0),
    Storage       INT            NOT NULL CONSTRAINT CK_Laptops_Storage CHECK (Storage > 0),
    GraphicsCard  NVARCHAR(200)      NULL,
    ScreenSize    DECIMAL(5,2)       NULL CONSTRAINT CK_Laptops_Screen CHECK (ScreenSize IS NULL OR ScreenSize > 0),
    [Description] NVARCHAR(MAX)      NULL,
    CONSTRAINT UQ_Laptops_Model UNIQUE (ModelName),
    CONSTRAINT FK_Laptops_Brand
        FOREIGN KEY (BrandID) REFERENCES dbo.Brands(BrandID)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_Laptops_Category
        FOREIGN KEY (CategoryID) REFERENCES dbo.Categories(CategoryID)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO
CREATE NONCLUSTERED INDEX IX_Laptops_BrandID ON dbo.Laptops(BrandID);
CREATE NONCLUSTERED INDEX IX_Laptops_CategoryID ON dbo.Laptops(CategoryID);
GO


CREATE TABLE dbo.ShoppingCart (
    CartID       INT IDENTITY(1,1) PRIMARY KEY,
    UserID       INT          NOT NULL,
    CreationDate DATETIME2(0) NOT NULL CONSTRAINT DF_ShoppingCart_CreationDate DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_ShoppingCart_User
        FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID)
        ON UPDATE NO ACTION ON DELETE CASCADE
);
GO
CREATE NONCLUSTERED INDEX IX_ShoppingCart_UserID ON dbo.ShoppingCart(UserID);
GO


CREATE TABLE dbo.CartLaptops (
    CartID    INT NOT NULL,
    LaptopID  INT NOT NULL,
    Quantity  INT NOT NULL CONSTRAINT CK_CartLaptops_Qty CHECK (Quantity > 0),
    CONSTRAINT PK_CartLaptops PRIMARY KEY (CartID, LaptopID),
    CONSTRAINT FK_CartLaptops_Cart
        FOREIGN KEY (CartID) REFERENCES dbo.ShoppingCart(CartID)
        ON UPDATE NO ACTION ON DELETE CASCADE,
    CONSTRAINT FK_CartLaptops_Laptop
        FOREIGN KEY (LaptopID) REFERENCES dbo.Laptops(LaptopID)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO
CREATE NONCLUSTERED INDEX IX_CartLaptops_LaptopID ON dbo.CartLaptops(LaptopID);
GO


CREATE TABLE dbo.Orders (
    OrderID           INT IDENTITY(1,1) PRIMARY KEY,
    UserID            INT           NOT NULL,
    OrderDate         DATETIME2(0)  NOT NULL CONSTRAINT DF_Orders_OrderDate DEFAULT (SYSUTCDATETIME()),
    TotalAmount       DECIMAL(14,2) NOT NULL CONSTRAINT CK_Orders_Total CHECK (TotalAmount >= 0),
    ShippingAddressID INT           NOT NULL,
    CONSTRAINT FK_Orders_User
        FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_Orders_Address
        FOREIGN KEY (ShippingAddressID) REFERENCES dbo.Addresses(AddressID)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO
CREATE NONCLUSTERED INDEX IX_Orders_UserID ON dbo.Orders(UserID);
CREATE NONCLUSTERED INDEX IX_Orders_ShippingAddressID ON dbo.Orders(ShippingAddressID);
CREATE NONCLUSTERED INDEX IX_Orders_OrderDate ON dbo.Orders(OrderDate);
GO

CREATE TABLE dbo.OrderLaptops (
    OrderID   INT NOT NULL,
    LaptopID  INT NOT NULL,
    Quantity  INT NOT NULL CONSTRAINT CK_OrderLaptops_Qty CHECK (Quantity > 0),
    Price     DECIMAL(12,2) NOT NULL CONSTRAINT CK_OrderLaptops_Price CHECK (Price >= 0), -- unit price at time of order
    CONSTRAINT PK_OrderLaptops PRIMARY KEY (OrderID, LaptopID),
    CONSTRAINT FK_OrderLaptops_Order
        FOREIGN KEY (OrderID) REFERENCES dbo.Orders(OrderID)
        ON UPDATE NO ACTION ON DELETE CASCADE,
    CONSTRAINT FK_OrderLaptops_Laptop
        FOREIGN KEY (LaptopID) REFERENCES dbo.Laptops(LaptopID)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO
CREATE NONCLUSTERED INDEX IX_OrderLaptops_LaptopID ON dbo.OrderLaptops(LaptopID);
GO


CREATE TABLE dbo.Payments (
    PaymentID     INT IDENTITY(1,1) PRIMARY KEY,
    OrderID       INT            NOT NULL,
    PaymentDate   DATETIME2(0)   NOT NULL CONSTRAINT DF_Payments_Date DEFAULT (SYSUTCDATETIME()),
    PaymentAmount DECIMAL(14,2)  NOT NULL CONSTRAINT CK_Payments_Amount CHECK (PaymentAmount >= 0),
    PaymentMethod NVARCHAR(30)   NOT NULL CONSTRAINT DF_Payments_Method DEFAULT ('Card'),
    CONSTRAINT CK_Payments_Method CHECK (PaymentMethod IN ('Card','Cash','Transfer')),
    CONSTRAINT FK_Payments_Order
        FOREIGN KEY (OrderID) REFERENCES dbo.Orders(OrderID)
        ON UPDATE NO ACTION ON DELETE CASCADE
);
GO
CREATE NONCLUSTERED INDEX IX_Payments_OrderID ON dbo.Payments(OrderID);
CREATE NONCLUSTERED INDEX IX_Payments_Date ON dbo.Payments(PaymentDate);
GO

