USE [Website_Database]
GO

-- Dezactivăm temporar constrângerile pentru a putea șterge/popula ușor (opțional, dar util la teste repetate)
-- EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"
-- DELETE FROM OrderLaptops
-- DELETE FROM Orders
-- DELETE FROM CartLaptops
-- DELETE FROM Laptops
-- DELETE FROM Users
-- DELETE FROM Categories
-- DELETE FROM Brands

-- 1. POPULARE BRANDS
INSERT INTO Brands (BrandName) VALUES 
('Dell'), 
('Asus'), 
('Lenovo'), 
('HP'), 
('Apple'), 
('MSI');

-- 2. POPULARE CATEGORIES
INSERT INTO Categories (CategoryName) VALUES 
('Gaming'), 
('Ultrabook'), 
('Business'), 
('Workstation');

-- 3. POPULARE USERS
-- Presupunem coloane standard. Ajusteaza parola/email daca ai alte nume.
INSERT INTO Users (FirstName, LastName, Email, Password, Role) VALUES 
('Ion', 'Popescu', 'user@test.com', 'User123!', 'Customer'),
('Maria', 'Ionescu', 'maria@test.com', 'User123!', 'Customer'),
('Andrei', 'Admin', 'admin@test.com', 'Admin123!', 'Admin'),
('George', 'VIP', 'vip@test.com', 'User123!', 'Customer'); -- Client care va cumpara mult

-- 4. POPULARE LAPTOPS
-- Folosim subquery-uri pentru ID-uri ca sa nu depindem de numere fixe, sau le scriem manual daca stim ordinea.
-- Mai jos presupunem ID-uri incrementale: Brand 1=Dell, 2=Asus... Cat 1=Gaming, 2=Ultrabook...

INSERT INTO Laptops (BrandID, CategoryID, ModelName, Price, StockQuantity, Description, ImageUrl) VALUES 
(1, 3, 'Dell Latitude 5520', 4500.00, 50, 'Laptop Business Robust', 'dell_lat.jpg'),
(1, 1, 'Dell Alienware X17', 12000.00, 5, 'Gaming Extrem, stoc mic (Warning)', 'alienware.jpg'),
(2, 1, 'Asus ROG Strix', 7500.00, 20, 'Gaming Popular', 'rog.jpg'),
(2, 2, 'Asus ZenBook Duo', 8000.00, 2, 'Ultrabook Dual Screen (Risk Stock)', 'zenbook.jpg'),
(3, 3, 'Lenovo ThinkPad X1', 9500.00, 10, 'Business Premium', 'thinkpad.jpg'),
(5, 2, 'MacBook Pro 16', 14000.00, 3, 'Pentru creativi', 'macbook.jpg'),
(5, 2, 'MacBook Air M2', 6500.00, 0, 'Stoc epuizat (Critical)', 'macbook_air.jpg'), -- Test pentru rpt_RestockAdvice (Critical)
(4, 3, 'HP EliteBook', 5000.00, 100, 'Stoc mare, nevandut (Risk)', 'hp.jpg'); -- Test pentru rpt_UnsoldInventoryRisk

-- 5. POPULARE ORDERS & ORDER DETAILS (Istoric comenzi)

-- Comanda 1: Veche (acum 2 luni) - Utilizator Ion
INSERT INTO Orders (UserID, OrderDate, TotalAmount, Status) VALUES 
(1, DATEADD(MONTH, -2, GETDATE()), 4500.00, 'Completed');

DECLARE @LastOrderID INT = SCOPE_IDENTITY();
INSERT INTO OrderLaptops (OrderID, LaptopID, Quantity, Price) VALUES 
(@LastOrderID, 1, 1, 4500.00); -- 1x Dell Latitude

-- Comanda 2: Recentă (acum 2 zile) - Utilizator Maria
INSERT INTO Orders (UserID, OrderDate, TotalAmount, Status) VALUES 
(2, DATEADD(DAY, -2, GETDATE()), 7500.00, 'Processing');

SET @LastOrderID = SCOPE_IDENTITY();
INSERT INTO OrderLaptops (OrderID, LaptopID, Quantity, Price) VALUES 
(@LastOrderID, 3, 1, 7500.00); -- 1x Asus ROG

-- Comanda 3: VIP User (Cumpără mult Apple pentru a testa rpt_VipBrandAffinity)
INSERT INTO Orders (UserID, OrderDate, TotalAmount, Status) VALUES 
(4, DATEADD(DAY, -10, GETDATE()), 28000.00, 'Completed');

SET @LastOrderID = SCOPE_IDENTITY();
INSERT INTO OrderLaptops (OrderID, LaptopID, Quantity, Price) VALUES 
(@LastOrderID, 6, 2, 14000.00); -- 2x MacBook Pro

-- 6. POPULARE CART (Coșuri active)
-- Punem un produs în coșul lui Ion Popescu
INSERT INTO CartLaptops (UserID, LaptopID, Quantity, DateAdded) VALUES 
(1, 5, 1, GETDATE()); -- ThinkPad in cos

-- Reactivăm constrângerile
-- EXEC sp_MSforeachtable "ALTER TABLE ? CHECK CONSTRAINT all"
GO