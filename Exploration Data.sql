CREATE DATABASE Zomato
USE Zomato
GO

--ALTER TABLE dbo.Zomato_Dataset
--ALTER COLUMN Has_Table_booking BIT

--EXPLORATION DATA
SELECT * FROM INFORMATION_SCHEMA.COLUMNS

-- Kiểm tra datatype của từng bảng
SELECT 
	DISTINCT (TABLE_CATALOG),
	TABLE_NAME
FROM 
	INFORMATION_SCHEMA.COLUMNS

SELECT 
	COLUMN_NAME,
	DATA_TYPE
FROM 
	INFORMATION_SCHEMA.COLUMNS
WHERE 
	TABLE_NAME = 'Zomato_Dataset'

-- Xem dữ liệu của từng bảng

SELECT TOP 10 * FROM dbo.Zomato_Dataset

SELECT * FROM dbo.Country_Name

-- Kiểm tra dữ liệu trùng trong database
SELECT 
	RestaurantID,
	COUNT(RestaurantID) AS [Số lượng]
FROM 
	dbo.Zomato_Dataset
GROUP BY 
	RestaurantID
ORDER BY 
	[Số lượng] DESC
GO
-- NHẬN XÉT: Không có hiện tượng trùng lặp dữ liệu trong database


-- KHÁM PHÁ DỮ LIỆU CỦA TỪNG CỘT TRONG CÁC BẢNG

/* 
	Tên nhà hàng (restauranname) và tên thành phố (city) có dấu hiệu lỗi font chữ
	Tuy nhiên, tên nhà hàng không quá quan trọng và khó sửa nên giữ nguyên
	Vì vậy, trong phạm vi file này, tác giả chỉ sửa lỗi font chữ của cột City
*/
-- Xác định tên thành phố bị lỗi
SELECT DISTINCT RestaurantName FROM dbo.Zomato_Dataset 
WHERE RestaurantName LIKE '%?%'


SELECT 
	REPLACE(City, '?', 'i')
FROM 
	dbo.Zomato_Dataset 
WHERE 
	CITY LIKE '%?%'

-- Sửa lại tên thành phố bị lỗi
UPDATE 
	dbo.Zomato_Dataset 
SET City = REPLACE(City, '?', 'i')
			FROM 
				dbo.Zomato_Dataset 
			WHERE 
				CITY LIKE '%?%'
GO

-- Xác định số nhà hàng tại mỗi thành phố ở mỗi quốc gia
SELECT 
	c.[Country Code],
	c.Country AS[Country Name],
	d.City,
	COUNT(d.RestaurantID) AS [Số lượng nhà hàng]
FROM 
	dbo.Zomato_Dataset d
INNER JOIN
	dbo.Country_Name c
ON d.CountryCode = c.[Country Code]
GROUP BY 
	c.[Country Code],
	c.Country,
	d.City
ORDER BY 
	[Số lượng nhà hàng] DESC
GO


--Cột Cuisines (ẩm thực)
--Thông tin các nhà hàng có cột Cuisines null hoặc để trống
SELECT
	*
FROM 
	dbo.Zomato_Dataset
WHERE 
	Cuisines IS NULL OR Cuisines = ''

-- Số lượng các nhà hàng có cột cuisines null hoặc để trống
SELECT 
	COUNT(RestaurantID) AS [Số lượng]
FROM 
	dbo.Zomato_Dataset
WHERE 
	Cuisines IS NULL OR Cuisines = ''
GROUP BY 
	Cuisines
GO
-- Nhận xét: Trong database hiện tại có 9 nhà hàng có cột cuisines null hoặc để trống


-- Số lượng phong cách ẩm thực mà các nhà hàng áp dụng
SELECT 
	Cuisines, 
	COUNT(Cuisines) AS [Số lượng]
FROM 
	dbo.Zomato_Dataset
GROUP BY 
	Cuisines
ORDER BY 
	[Số lượng] DESC
GO
--Nhận xét: Ẩm thực chủ đạo Bắc Ấn Độ (North Indian) xuất hiện phổ biến nhất tại các nhà hàng


-- Cột Currency (tiền tệ)
SELECT 
	Currency,
	COUNT(Currency) AS [Số lượng]
FROM 
	dbo.Zomato_Dataset
GROUP BY 
	Currency
ORDER BY 
	[Số lượng] DESC
GO
--Nhận xét: Tiền tệ được sử dụng phổ biến nhất là đồng Rupe của Ấn Độ và đồng Dollar


-- Các cột có dữ liệu dạng Yes/No

--Cột Has_Table_booking (có bàn đặt trước)
SELECT 
	Has_Table_booking,
	COUNT(Has_Table_booking) AS [Số lượng]
FROM 
	dbo.Zomato_Dataset
GROUP BY 
	Has_Table_booking
GO
-- Nhận xét: Đa số các nhà hàng chưa có hệ thống đặt bàn trước

-- Cột Has_Online_delivery (có dịch vụ giao đồ ăn online)
SELECT 
	Has_Online_delivery,
	COUNT(Has_Online_delivery) AS [Số lượng]
FROM
	dbo.Zomato_Dataset
GROUP BY 
	Has_Online_delivery
GO
-- Nhận xét: Đa số nhà hàng chưa có dịch vụ giao đồ ăn online

-- Cột Is_delivering_now
SELECT 
	Is_delivering_now,
	COUNT(Is_delivering_now) AS [Số lượng]
FROM
	dbo.Zomato_Dataset
GROUP BY 
	Is_delivering_now
GO

-- Cột Switch_to_order_menu
SELECT 
	Switch_to_order_menu,
	COUNT(Switch_to_order_menu) AS [Số lượng]
FROM
	dbo.Zomato_Dataset
GROUP BY 
	Switch_to_order_menu
GO
--Nhận xét: Chưa có nhà hàng nào có thực đơn online


-- Cột Price_range
SELECT 
	Price_range,
	COUNT(Price_range) AS [Số lượng]
FROM 
	dbo.Zomato_Dataset
GROUP BY 
	Price_range
ORDER BY [Số lượng] DESC
GO
/*
1 = Inexpensive, usually $10 and under
2 = Moderately expensive, usually between $10-$25
3 = Expensive, usually between $25-$45
4 = Very Expensive, usually $50 and up
*/
-- Nhận xét: khoảng giá chênh lệch (price range) chủ yếu của các nhà hàng là 1 (không đắt)


-- Cột Votes
-- Kiểm tra các giá trị nhỏ nhất, giá trị trung bình, giá trị lớn nhất của cột
SELECT
	MIN(Votes) AS [Điểm vote thấp nhất],
	AVG(Votes) AS [Điểm vote trung bình],
	MAX(votes) AS [Điểm vote cao nhất]
FROM 
	dbo.Zomato_Dataset
GO

-- Kiểm tra lượng phân bổ điểm vote của các nhà hàng
SELECT 
	Votes, 
	COUNT(Votes) AS [Số lượng]
FROM 
	dbo.Zomato_Dataset
GROUP BY 
	Votes
ORDER BY 
	[Số lượng] DESC
-- Nhận xét: vote 0 chiếm tỉ lệ lớn 
GO

-- Cột Cost
SELECT 
	Currency,
	MIN(Average_Cost_for_two) AS [Giá nhỏ nhất],
	AVG(Average_Cost_for_two) AS [Giá trung bình],
	MAX(Average_Cost_for_two) AS [Giá lớn nhất]
FROM 
	dbo.Zomato_Dataset 
GROUP BY 
	Currency
GO


-- Cột Raiting
-- Kiểm tra các giá trị nhỏ nhất, giá trị trung bình, giá trị lớn nhất của cột
SELECT 
	MIN(Rating),
	ROUND(MAX(Rating),1),
	ROUND(AVG(Rating),1)
FROM
	dbo.Zomato_Dataset
GO

-- Kiểm tra lượng phân bổ raiting (đã làm tròn 2 chữ số thập phân) của các nhà hàng
SELECT
	ROUND(Rating,2) [Raiting làm tròn 2 chữ số thập phân],
	COUNT(ROUND(Rating,2)) AS [số lượng]
FROM 
	dbo.Zomato_Dataset
GROUP BY 
	ROUND(Rating,2)
ORDER BY 
	[số lượng] DESC

/*
Thêm một cột "Rate_Category" thể hiện:
	- Raiting trong nửa khoảng 1 - 2,5: Poor
	- Raiting trong nửa khoảng 2,5 - 3,5: Good
	- Raiting trong nửa khoảng 3,5 - 4,5: Great
	- Raiting từ 4,5 trở lên: Excellent

*/ 
ALTER TABLE dbo.Zomato_Dataset ADD Rate_Category VARCHAR(20)
UPDATE 
	dbo.Zomato_Dataset
SET [Rate_Category] =
	(CASE 
		WHEN Rating >= 1 AND Rating < 2.5 THEN 'Poor'
		WHEN Rating >= 2.5 AND Rating < 3.5 THEN 'Good'
		WHEN Rating >= 3.5 AND Rating < 4.5 THEN 'Great'
		ELSE 'Excellent'
	END)
GO

SELECT TOP 10 * FROM dbo.Zomato_Dataset
