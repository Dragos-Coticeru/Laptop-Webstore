IF NOT EXISTS (SELECT 1 FROM dbo.Laptops WHERE ModelName='MacBook Air M2')
INSERT INTO dbo.Laptops
(BrandID, CategoryID, ModelName, Price, StockQuantity, Processor, RAM, Storage, GraphicsCard, ScreenSize, [Description])
SELECT b.BrandID, c.CategoryID, 'MacBook Air M2', 1299.00, 25, 'Apple M2', 8, 256, NULL, 13.60, 'Thin and light'
FROM dbo.Brands b CROSS JOIN dbo.Categories c
WHERE b.BrandName='Apple' AND c.CategoryName='Ultrabook';

IF NOT EXISTS (SELECT 1 FROM dbo.Laptops WHERE ModelName='MacBook Pro 14')
INSERT INTO dbo.Laptops
SELECT b.BrandID, c.CategoryID, 'MacBook Pro 14', 2199.00, 12, 'Apple M3 Pro', 16, 512, NULL, 14.20, 'Pro series'
FROM dbo.Brands b CROSS JOIN dbo.Categories c
WHERE b.BrandName='Apple' AND c.CategoryName='Workstation';

IF NOT EXISTS (SELECT 1 FROM dbo.Laptops WHERE ModelName='Dell XPS 13')
INSERT INTO dbo.Laptops
SELECT b.BrandID, c.CategoryID, 'Dell XPS 13', 1399.00, 30, 'Intel i7-1360P', 16, 512, 'Iris Xe', 13.40, 'Premium ultrabook'
FROM dbo.Brands b CROSS JOIN dbo.Categories c
WHERE b.BrandName='Dell' AND c.CategoryName='Ultrabook';

IF NOT EXISTS (SELECT 1 FROM dbo.Laptops WHERE ModelName='Dell G15')
INSERT INTO dbo.Laptops
SELECT b.BrandID, c.CategoryID, 'Dell G15', 1199.00, 20, 'Intel i7-12700H', 16, 512, 'RTX 3060', 15.60, 'Gaming series'
FROM dbo.Brands b CROSS JOIN dbo.Categories c
WHERE b.BrandName='Dell' AND c.CategoryName='Gaming';

IF NOT EXISTS (SELECT 1 FROM dbo.Laptops WHERE ModelName='HP Spectre x360')
INSERT INTO dbo.Laptops
SELECT b.BrandID, c.CategoryID, 'HP Spectre x360', 1499.00, 18, 'Intel i7-1355U', 16, 512, 'Iris Xe', 13.50, 'Convertible'
FROM dbo.Brands b CROSS JOIN dbo.Categories c
WHERE b.BrandName='HP' AND c.CategoryName='Ultrabook';

IF NOT EXISTS (SELECT 1 FROM dbo.Laptops WHERE ModelName='HP Omen 16')
INSERT INTO dbo.Laptops
SELECT b.BrandID, c.CategoryID, 'HP Omen 16', 1599.00, 15, 'Ryzen 7 6800H', 16, 1024, 'RTX 3070', 16.10, 'Gaming'
FROM dbo.Brands b CROSS JOIN dbo.Categories c
WHERE b.BrandName='HP' AND c.CategoryName='Gaming';

IF NOT EXISTS (SELECT 1 FROM dbo.Laptops WHERE ModelName='Lenovo ThinkPad X1')
INSERT INTO dbo.Laptops
SELECT b.BrandID, c.CategoryID, 'Lenovo ThinkPad X1', 1799.00, 22, 'Intel i7-1365U', 16, 512, 'Iris Xe', 14.00, 'Business flagship'
FROM dbo.Brands b CROSS JOIN dbo.Categories c
WHERE b.BrandName='Lenovo' AND c.CategoryName='Business';

IF NOT EXISTS (SELECT 1 FROM dbo.Laptops WHERE ModelName='Lenovo Legion 5')
INSERT INTO dbo.Laptops
SELECT b.BrandID, c.CategoryID, 'Lenovo Legion 5', 1499.00, 14, 'Ryzen 7 6800H', 16, 1024, 'RTX 3060', 15.60, 'Gaming'
FROM dbo.Brands b CROSS JOIN dbo.Categories c
WHERE b.BrandName='Lenovo' AND c.CategoryName='Gaming';

IF NOT EXISTS (SELECT 1 FROM dbo.Laptops WHERE ModelName='ASUS ROG Zephyrus G14')
INSERT INTO dbo.Laptops
SELECT b.BrandID, c.CategoryID, 'ASUS ROG Zephyrus G14', 1699.00, 10, 'Ryzen 9 6900HS', 16, 1024, 'RTX 3060', 14.00, 'Gaming portable'
FROM dbo.Brands b CROSS JOIN dbo.Categories c
WHERE b.BrandName='ASUS' AND c.CategoryName='Gaming';

IF NOT EXISTS (SELECT 1 FROM dbo.Laptops WHERE ModelName='ASUS ExpertBook')
INSERT INTO dbo.Laptops
SELECT b.BrandID, c.CategoryID, 'ASUS ExpertBook', 1099.00, 26, 'Intel i5-1340P', 16, 512, 'Iris Xe', 14.00, 'Business light'
FROM dbo.Brands b CROSS JOIN dbo.Categories c
WHERE b.BrandName='ASUS' AND c.CategoryName='Business';

IF NOT EXISTS (SELECT 1 FROM dbo.Laptops WHERE ModelName='HP 255 G9')
INSERT INTO dbo.Laptops
SELECT b.BrandID, c.CategoryID, 'HP 255 G9', 599.00, 40, 'Ryzen 5 5625U', 8, 256, 'Radeon', 15.60, 'Student budget'
FROM dbo.Brands b CROSS JOIN dbo.Categories c
WHERE b.BrandName='HP' AND c.CategoryName='Student';

IF NOT EXISTS (SELECT 1 FROM dbo.Laptops WHERE ModelName='Lenovo P1 Max')
INSERT INTO dbo.Laptops
SELECT b.BrandID, c.CategoryID, 'Lenovo P1 Max', 2899.00, 8, 'Intel i9-13900H', 32, 2048, 'RTX 4080', 16.00, 'High-end workstation'
FROM dbo.Brands b CROSS JOIN dbo.Categories c
WHERE b.BrandName='Lenovo' AND c.CategoryName='Workstation';

---------

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE CategoryName='Ultrabook')
    INSERT INTO dbo.Categories (CategoryName, [Description]) VALUES ('Ultrabook',  'Thin & light');
IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE CategoryName='Gaming')
    INSERT INTO dbo.Categories (CategoryName, [Description]) VALUES ('Gaming',     'High performance gaming');
IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE CategoryName='Business')
    INSERT INTO dbo.Categories (CategoryName, [Description]) VALUES ('Business',   'Enterprise-focused laptops');
IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE CategoryName='Student')
    INSERT INTO dbo.Categories (CategoryName, [Description]) VALUES ('Student',    'Affordable, reliable');
IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE CategoryName='Workstation')
    INSERT INTO dbo.Categories (CategoryName, [Description]) VALUES ('Workstation','Pro graphics & CPU');

----------

IF NOT EXISTS (SELECT 1 FROM dbo.Brands WHERE BrandName='Apple')
    INSERT INTO dbo.Brands (BrandName, CollaborationDate) VALUES ('Apple',        '2015-01-01');
IF NOT EXISTS (SELECT 1 FROM dbo.Brands WHERE BrandName='Dell')
    INSERT INTO dbo.Brands (BrandName, CollaborationDate) VALUES ('Dell',         '2010-06-01');
IF NOT EXISTS (SELECT 1 FROM dbo.Brands WHERE BrandName='HP')
    INSERT INTO dbo.Brands (BrandName, CollaborationDate) VALUES ('HP',           '2011-03-15');
IF NOT EXISTS (SELECT 1 FROM dbo.Brands WHERE BrandName='Lenovo')
    INSERT INTO dbo.Brands (BrandName, CollaborationDate) VALUES ('Lenovo',       '2012-09-20');
IF NOT EXISTS (SELECT 1 FROM dbo.Brands WHERE BrandName='ASUS')
    INSERT INTO dbo.Brands (BrandName, CollaborationDate) VALUES ('ASUS',         '2013-11-05');
