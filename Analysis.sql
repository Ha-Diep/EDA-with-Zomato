USE Zomato
GO

SELECT TOP 10 * FROM dbo.Zomato_Dataset


ALTER TABLE dbo.Zomato_Dataset
ALTER COLUMN Locality VARCHAR(250)

-- Số nhà hàng trong từng khu vực theo Locality và City của từng quốc gia 
-- Ví dụ: Ấn độ
-- Có thể làm thêm về việc viết function cho từng quốc gia

SELECT 
	--c.Country,
	d.City,
	d.Locality,
	COUNT(d.Locality) AS [Số nhà hàng trong khu vực]
	,SUM(COUNT(d.Locality)) OVER (
									PARTITION BY 
												d.City 
									ORDER BY 
												d.Locality DESC
									) AS [Tổng số nhà hàng trong thành phố] 
	-- Tính số nhà hàng luỹ kế (không phải là hiện tổng)
FROM 
	dbo.Zomato_Dataset d
INNER JOIN
	dbo.Country_Name c
ON 
	d.CountryCode = c.[Country Code]
WHERE 
	c.Country = 'India'
GROUP BY	
	--c.Country, 
	d.City, 
	d.Locality


-- Tính số nhà hàng hiện tổng
SELECT COUNT(d.RestaurantID) FROM dbo.Zomato_Dataset d
INNER JOIN
dbo.Country_Name c
ON d.CountryCode = c.[Country Code]
WHERE c.Country = 'India'
	AND d.City = 'Agra'

GO


-- Tính tỉ lệ phần trăm số nhà hàng của từng quốc gia 

WITH ct1 as
(
	SELECT
		c.Country, 
		COUNT(d.RestaurantID) [Tổng số nhà hàng]
	FROM 
		dbo.Zomato_Dataset d
	INNER JOIN 
		dbo.Country_Name c
	ON 
		d.CountryCode = c.[Country Code]
	GROUP BY
		c.Country
), 
	ct2 AS
(
	SELECT
		DISTINCT c.Country, 
		COUNT(d.RestaurantID) OVER() [Tổng số nhà hàng toàn danh sách]
	FROM 
		dbo.Zomato_Dataset d
	INNER JOIN 
		dbo.Country_Name c
	ON 
		d.CountryCode = c.[Country Code]	
)
SELECT 
	ct1.Country, 
	ct1.[Tổng số nhà hàng],
	ROUND (CAST(ct1.[Tổng số nhà hàng] AS DECIMAL)
			/CAST(ct2.[Tổng số nhà hàng toàn danh sách] AS DECIMAL)* 100,2) 
				AS [Phần trăm]
FROM 
	ct1 join ct2 
ON  ct2.Country = ct1.Country
ORDER BY 
	[Phần trăm] DESC
GO


-- Đưa thêm function (hoặc tìm xem quốc gia nào có xếp hạng % thứ x chẳng hạn)

-- Tìm thành phố và khu vực (ở một quốc gia nhất định) với số lượng nhà hàng lớn nhất
WITH ct1 as
(
	SELECT
		c.Country,
		d.City,
		d.Locality,
		COUNT(d.RestaurantID) AS [Số nhà hàng],
		DENSE_RANK() OVER(PARTITION BY d.City 
					 ORDER BY COUNT(d.RestaurantID) DESC) AS [Xếp hạng]
	FROM
		dbo.Zomato_Dataset d
	INNER JOIN 
		dbo.Country_Name c
	ON 
		d.CountryCode = c.[Country Code]
	WHERE 
		c.Country = 'India'
	GROUP BY 
		c.Country, d.City, d.Locality
)
SELECT * FROM ct1 WHERE ct1.[Xếp hạng] <5 AND city = 'New Delhi'
GO


-- Xây dựng function (scalar hoặc table đều được)

-- Tìm thành phố và khu vực (ở một quốc gia nhất định) với số lượng nhà hàng nhỏ nhất 
WITH ct1 as
(
	SELECT
		c.Country,
		d.City,
		d.Locality,
		COUNT(d.RestaurantID) AS [Số nhà hàng],
		DENSE_RANK() OVER(PARTITION BY d.City 
					 ORDER BY COUNT(d.RestaurantID)) AS [Xếp hạng]
	FROM
		dbo.Zomato_Dataset d
	INNER JOIN 
		dbo.Country_Name c
	ON 
		d.CountryCode = c.[Country Code]
	WHERE 
		c.Country = 'India'
	GROUP BY 
		c.Country, d.City, d.Locality
)
SELECT * FROM ct1 WHERE ct1.[Xếp hạng] = 1  AND city = 'Agra'
GO


-- Loại ẩm thực (cuisines) được áp dụng tại các nhà hàng trong 
-- khu vực với số lượng nhà hàng xếp thứ x (x là số tự nhiên)

WITH ct1 as
(
	SELECT
		c.Country,
		d.City,
		d.Locality,
		COUNT(d.RestaurantID) AS [Số nhà hàng],
		DENSE_RANK() OVER(PARTITION BY d.City 
					 ORDER BY COUNT(d.RestaurantID) DESC) AS [Xếp hạng]
	FROM
		dbo.Zomato_Dataset d
	INNER JOIN 
		dbo.Country_Name c
	ON 
		d.CountryCode = c.[Country Code]
	WHERE 
		c.Country = 'India'
	GROUP BY 
		c.Country, d.City, d.Locality
),
	ct2 AS
(
	SELECT	
		d.Locality,
		TRIM(N.Cuisines) AS [Cuisines]
	FROM dbo.Zomato_Dataset d
	CROSS APPLY 
	(SELECT value AS [Cuisines] FROM STRING_SPLIT([Cuisines], '|')) N
)
SELECT 
	ct1.Locality, 
	ct2.Cuisines,
	COUNT(ct2.Cuisines) AS [Số lượng nhà hàng áp dụng]
FROM 
	ct1 INNER JOIN ct2 ON ct2.Locality = ct1.Locality

WHERE 
	ct1.[Xếp hạng] = 1 AND ct1.city = 'Agra'
GROUP BY 
	ct1.Locality,
	ct2.Cuisines
GO

-- Số lượng nhà hàng cung cấp lựa chọn đặt bàn (Has Table Booking) trong khu vực đông nhà hàng thứ x

WITH ct1 as
(
	SELECT
		c.Country,
		d.City,
		d.Locality,
		COUNT(d.RestaurantID) AS [Số nhà hàng],
		DENSE_RANK() OVER(PARTITION BY d.City 
					 ORDER BY COUNT(d.RestaurantID)) AS [Xếp hạng theo số nhà hàng]
		FROM 
			dbo.Zomato_Dataset d
	JOIN 
		dbo.Country_Name c
	ON 
		d.CountryCode = c.[Country Code]
	GROUP BY 
		c.Country, d.City, d.Locality
),
	ct2 AS
(
	SELECT 
		d.Locality,
		COUNT(d.Has_Table_booking) [Số nhà hàng cho phép đặt bàn]
	FROM 
		dbo.Zomato_Dataset d
	JOIN 
		dbo.Country_Name c
	ON 
		d.CountryCode = c.[Country Code]
	WHERE d.Has_Table_booking = 'Yes'
	GROUP BY 
		d.Locality
)
SELECT 
	ct1.Country,
	ct1.City, 
	ct2.Locality, 
	ct1.[Số nhà hàng],
	ct1.[Xếp hạng theo số nhà hàng], 
	ct2. [Số nhà hàng cho phép đặt bàn]
FROM 
	ct1 JOIN ct2 ON ct2.Locality = ct1.Locality  
WHERE 
	ct1.[Xếp hạng theo số nhà hàng] < 5  AND ct1.Country = 'India'

-- Nghiên cứu xem với trường hợp null thì thay thế = 0 như thế nào



SELECT * FROM dbo.Zomato_Dataset WHERE Locality = 'Connaught Place'



/*
Ảnh hưởng của điểm rating đến khu vực có số lượng nhà hàng lớn nhất 
trong điều kiện có cung cấp và không cung cấp lựa chọn đặt bàn
*/ 

-- Lưu ý viết stored Procude hay function
SELECT 
	Locality,
	N'Có' [Cung cấp lựa chọn đặt bàn],
	COUNT([Has_Table_booking]) [Số nhà hàng], 
	ROUND(AVG([Rating]),2) [Raiting trung bình]
FROM 
	dbo.Zomato_Dataset
WHERE	
	[Has_Table_booking] = 'Yes'
	AND [City] = 'New Delhi'
GROUP BY Locality
UNION
SELECT 
	Locality,
	N'Không' [Cung cấp lựa chọn đặt bàn],
	COUNT([Has_Table_booking]) [Số nhà hàng], 
	ROUND(AVG([Rating]),2) [Raiting trung bình]
FROM 
	dbo.Zomato_Dataset
WHERE 
	[Has_Table_booking] = 'No'
	AND City = 'New Delhi' 
GROUP BY Locality
ORDER BY Locality 


-- Điểm raiting trung bình của từng khu vực
SELECT CountryCode ,City, Locality,
COUNT([RestaurantID]) TOTAL_REST ,ROUND(AVG(CAST([Rating] AS DECIMAL)),2) AVG_RATING
FROM dbo.Zomato_Dataset
GROUP BY CountryCode, city, Locality
ORDER BY TOTAL_REST DESC


-- Lựa chọn nhà hàng phù hợp cho người Ấn Độ với mức giá cho 2 người thích hợp và có món ăn Ấn Độ (cuisines Indian)