USE Website_Database;
GO

/* ========== USERS ========== */
IF OBJECT_ID('dbo.sp_AddUser', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_AddUser;
GO
CREATE PROCEDURE dbo.sp_AddUser
  @FirstName    NVARCHAR(100),
  @LastName     NVARCHAR(100),
  @Email        NVARCHAR(255),
  @Password     NVARCHAR(255),
  @PhoneNumber  NVARCHAR(50) = NULL,
  @UserType     CHAR(1)
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO Users (FirstName, LastName, Email, Password, PhoneNumber, UserType)
  VALUES (@FirstName, @LastName, @Email, @Password, @PhoneNumber, @UserType);
END;
GO

IF OBJECT_ID('dbo.sp_RemoveUser', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_RemoveUser;
GO
CREATE PROCEDURE dbo.sp_RemoveUser
  @Email NVARCHAR(255)
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM Users WHERE Email = @Email;
END;
GO

IF OBJECT_ID('dbo.sp_ModifyUser', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ModifyUser;
GO
CREATE PROCEDURE dbo.sp_ModifyUser
  @Email        NVARCHAR(255),
  @FirstName    NVARCHAR(100) = NULL,
  @LastName     NVARCHAR(100) = NULL,
  @Password     NVARCHAR(255) = NULL,
  @PhoneNumber  NVARCHAR(50)  = NULL,
  @UserType     CHAR(1)       = NULL
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE Users
     SET FirstName   = ISNULL(@FirstName, FirstName),
         LastName    = ISNULL(@LastName,  LastName),
         Password    = ISNULL(@Password,  Password),
         PhoneNumber = ISNULL(@PhoneNumber, PhoneNumber),
         UserType    = ISNULL(@UserType,  UserType)
   WHERE Email = @Email;
END;
GO

/* ========== CATEGORIES ========== */
IF OBJECT_ID('dbo.sp_AddCategory', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_AddCategory;
GO
CREATE PROCEDURE dbo.sp_AddCategory
  @CategoryName NVARCHAR(200),
  @Description  NVARCHAR(MAX) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO Categories (CategoryName, Description)
  VALUES (@CategoryName, @Description);
END;
GO

IF OBJECT_ID('dbo.sp_RemoveCategory', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_RemoveCategory;
GO
CREATE PROCEDURE dbo.sp_RemoveCategory
  @CategoryName NVARCHAR(200)
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM Categories WHERE CategoryName = @CategoryName;
END;
GO

IF OBJECT_ID('dbo.sp_UpdateCategory', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_UpdateCategory;
GO
CREATE PROCEDURE dbo.sp_UpdateCategory
  @CategoryName   NVARCHAR(200),
  @NewDescription NVARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE Categories
     SET Description = @NewDescription
   WHERE CategoryName = @CategoryName;
END;
GO

/* ========== LAPTOPS ========== */
IF OBJECT_ID('dbo.sp_AddLaptop', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_AddLaptop;
GO
CREATE PROCEDURE dbo.sp_AddLaptop
  @ModelName     NVARCHAR(200),
  @Price         DECIMAL(18,2),
  @StockQuantity INT,
  @Processor     NVARCHAR(200),
  @RAM           INT,
  @Storage       INT,
  @GraphicsCard  NVARCHAR(200) = NULL,
  @ScreenSize    DECIMAL(5,2)  = NULL,
  @Description   NVARCHAR(MAX) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO Laptops (ModelName, Price, StockQuantity, Processor, RAM, Storage, GraphicsCard, ScreenSize, Description)
  VALUES (@ModelName, @Price, @StockQuantity, @Processor, @RAM, @Storage, @GraphicsCard, @ScreenSize, @Description);
END;
GO

/* Optional (your JS calls /admin/remove_laptop) */
IF OBJECT_ID('dbo.sp_RemoveLaptopByModel', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_RemoveLaptopByModel;
GO
CREATE PROCEDURE dbo.sp_RemoveLaptopByModel
  @ModelName NVARCHAR(200)
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM Laptops WHERE ModelName = @ModelName;
END;
GO

/* ========== REPORTS (replace your inline queries) ========== */

/* Simple */
IF OBJECT_ID('dbo.rpt_LaptopsByBrand', 'P') IS NOT NULL DROP PROCEDURE dbo.rpt_LaptopsByBrand;
GO
CREATE PROCEDURE dbo.rpt_LaptopsByBrand
  @BrandName NVARCHAR(200)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT L.ModelName, B.BrandName
  FROM Laptops L
  JOIN Brands B ON L.BrandID = B.BrandID
  WHERE B.BrandName = @BrandName;
END;
GO

IF OBJECT_ID('dbo.rpt_PopularBrands', 'P') IS NOT NULL DROP PROCEDURE dbo.rpt_PopularBrands;
GO
CREATE PROCEDURE dbo.rpt_PopularBrands
  @MinCount INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT B.BrandName, COUNT(L.LaptopID) AS LaptopCount
  FROM Brands B
  JOIN Laptops L ON B.BrandID = L.BrandID   -- fixed join
  GROUP BY B.BrandName
  HAVING COUNT(L.LaptopID) >= @MinCount;
END;
GO

IF OBJECT_ID('dbo.rpt_TotalOrdersByUser', 'P') IS NOT NULL DROP PROCEDURE dbo.rpt_TotalOrdersByUser;
GO
CREATE PROCEDURE dbo.rpt_TotalOrdersByUser
  @MinTotalAmount DECIMAL(18,2)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT U.FirstName, U.LastName,
         COUNT(O.OrderID)    AS OrderCount,
         SUM(O.TotalAmount)  AS TotalAmount
  FROM Users U
  JOIN Orders O ON U.UserID = O.UserID
  GROUP BY U.FirstName, U.LastName
  HAVING SUM(O.TotalAmount) >= @MinTotalAmount;
END;
GO

IF OBJECT_ID('dbo.rpt_TotalStockByBrand', 'P') IS NOT NULL DROP PROCEDURE dbo.rpt_TotalStockByBrand;
GO
CREATE PROCEDURE dbo.rpt_TotalStockByBrand
  @BrandName NVARCHAR(200)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT B.BrandName,
         SUM(L.Price * L.StockQuantity) AS TotalStockValue
  FROM Laptops L
  JOIN Brands B ON L.BrandID = B.BrandID
  WHERE B.BrandName = @BrandName
  GROUP BY B.BrandName;
END;
GO

IF OBJECT_ID('dbo.rpt_AveragePriceByCategory', 'P') IS NOT NULL DROP PROCEDURE dbo.rpt_AveragePriceByCategory;
GO
CREATE PROCEDURE dbo.rpt_AveragePriceByCategory
  @CategoryName NVARCHAR(200)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT C.CategoryName, AVG(L.Price) AS AverageLaptopPrice
  FROM Laptops L
  JOIN Categories C ON L.CategoryID = C.CategoryID
  WHERE C.CategoryName = @CategoryName
  GROUP BY C.CategoryName;
END;
GO

IF OBJECT_ID('dbo.rpt_PopularCategories', 'P') IS NOT NULL DROP PROCEDURE dbo.rpt_PopularCategories;
GO
CREATE PROCEDURE dbo.rpt_PopularCategories
  @MinCount INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT C.CategoryName, COUNT(L.LaptopID) AS LaptopCount
  FROM Categories C
  JOIN Laptops L ON C.CategoryID = L.CategoryID
  GROUP BY C.CategoryName
  HAVING COUNT(L.LaptopID) >= @MinCount;
END;
GO

/* Complex */
IF OBJECT_ID('dbo.rpt_MostExpensiveLaptopByBrand', 'P') IS NOT NULL DROP PROCEDURE dbo.rpt_MostExpensiveLaptopByBrand;
GO
CREATE PROCEDURE dbo.rpt_MostExpensiveLaptopByBrand
  @BrandName NVARCHAR(200)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT TOP (1) L.ModelName, L.Price
  FROM Laptops L
  JOIN Brands B ON L.BrandID = B.BrandID
  WHERE B.BrandName = @BrandName
  ORDER BY L.Price DESC;
END;
GO

IF OBJECT_ID('dbo.rpt_UsersWithHighSpending', 'P') IS NOT NULL DROP PROCEDURE dbo.rpt_UsersWithHighSpending;
GO
CREATE PROCEDURE dbo.rpt_UsersWithHighSpending
  @MinAmount DECIMAL(18,2)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT U.FirstName, U.LastName, SUM(O.TotalAmount) AS TotalSpent
  FROM Users U
  JOIN Orders O ON U.UserID = O.UserID
  GROUP BY U.FirstName, U.LastName
  HAVING SUM(O.TotalAmount) >= @MinAmount
     AND SUM(O.TotalAmount) >= (SELECT AVG(TotalAmount) FROM Orders);
END;
GO

IF OBJECT_ID('dbo.rpt_LaptopsNotInAnyCartAbovePrice', 'P') IS NOT NULL DROP PROCEDURE dbo.rpt_LaptopsNotInAnyCartAbovePrice;
GO
CREATE PROCEDURE dbo.rpt_LaptopsNotInAnyCartAbovePrice
  @MinPrice DECIMAL(18,2)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT L.ModelName
  FROM Laptops L
  WHERE L.Price > @MinPrice
    AND NOT EXISTS (SELECT 1 FROM CartLaptops CL WHERE CL.LaptopID = L.LaptopID);
END;
GO

IF OBJECT_ID('dbo.rpt_CategoriesWithHighStock_NotSold', 'P') IS NOT NULL DROP PROCEDURE dbo.rpt_CategoriesWithHighStock_NotSold;
GO
CREATE PROCEDURE dbo.rpt_CategoriesWithHighStock_NotSold
  @MinPrice DECIMAL(18,2)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT C.CategoryName, COUNT(L.LaptopID) AS LaptopCount
  FROM Categories C
  JOIN Laptops L ON C.CategoryID = L.CategoryID
  WHERE L.Price >= @MinPrice
    AND NOT EXISTS (SELECT 1 FROM OrderLaptops OL WHERE OL.LaptopID = L.LaptopID)
  GROUP BY C.CategoryName
  ORDER BY LaptopCount DESC;
END;
GO

IF OBJECT_ID('dbo.rpt_NoPaymentUsersSinceYear', 'P') IS NOT NULL DROP PROCEDURE dbo.rpt_NoPaymentUsersSinceYear;
GO
CREATE PROCEDURE dbo.rpt_NoPaymentUsersSinceYear
  @Year INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT U.FirstName, U.LastName, U.Email
  FROM Users U
  WHERE U.UserID NOT IN (
      SELECT DISTINCT O.UserID
      FROM Orders O
      JOIN Payments P ON O.OrderID = P.OrderID
      WHERE YEAR(P.PaymentDate) >= @Year
  );
END;
GO

--- Complexity 9
IF OBJECT_ID('dbo.rpt_UnsoldInventoryRisk', 'P') IS NOT NULL
    DROP PROCEDURE dbo.rpt_UnsoldInventoryRisk;
GO

CREATE PROCEDURE dbo.rpt_UnsoldInventoryRisk
    @MinUnits INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        C.CategoryName,
        B.BrandName,
        SUM(L.StockQuantity)                   AS StockUnits,
        SUM(L.StockQuantity * L.Price)         AS StockValue,
        AVG(L.Price)                           AS AvgPrice
    FROM Laptops L
    JOIN Brands        B  ON L.BrandID    = B.BrandID
    JOIN Categories    C  ON L.CategoryID = C.CategoryID
    LEFT JOIN OrderLaptops OL ON OL.LaptopID = L.LaptopID
    LEFT JOIN Orders       O  ON O.OrderID   = OL.OrderID
    LEFT JOIN CartLaptops  CL ON CL.LaptopID = L.LaptopID
    WHERE (O.OrderID IS NULL OR O.OrderDate < DATEADD(MONTH, -1, GETDATE()))
      AND CL.LaptopID IS NULL
    GROUP BY C.CategoryName, B.BrandName
    HAVING AVG(L.Price) > (SELECT AVG(Price) FROM Laptops)
       AND SUM(L.StockQuantity) >= @MinUnits
    ORDER BY StockValue DESC;
END;
GO