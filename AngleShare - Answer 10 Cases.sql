-- SOAL 1
SELECT ms.StaffName,
    [DrinksSold] = SUM(td.QuantityBought)
FROM MsStaff ms
	JOIN TransactionHeader th ON th.StaffID = ms.StaffID
	JOIN TransactionDetail td ON th.TransactionID = td.TransactionID
WHERE th.TransactionDate > '2021-12-31' AND DATEDIFF(YEAR, ms.StaffDOB, '2023-12-12') > 26
GROUP BY ms.StaffName

-- SOAL 2
SELECT [StaffName] = 'Ms./Mrs. ' + UPPER(ms.StaffName), 
    [TotalCustomers] = COUNT(th.CustomerID)
FROM MsStaff ms 
    JOIN TransactionHeader th ON th.StaffID = ms.StaffID
    JOIN MsCustomer mc ON th.CustomerID = mc.CustomerID
    JOIN MsCityDetail mcd ON mc.CityID = mcd.CityID
WHERE ms.StaffGender = 'Female' AND mcd.CityName LIKE '%Village'
GROUP BY ms.StaffName
ORDER BY [TotalCustomers] DESC

-- SOAL 3
SELECT [CustomerID] = REPLACE(mc.CustomerID, 'CU', 'Customer '),
    [CustomerName] = 'Mr. ' + mc.CustomerName,
    [TotalTransaction] = SUM(td.QuantityBought * md.DrinkPrice),
    [TotalMaxTransaction] = MAX(td.QuantityBought * md.DrinkPrice)
FROM MsCustomer mc 
    JOIN TransactionHeader th ON th.CustomerID = mc.CustomerID
    JOIN TransactionDetail td ON th.TransactionID = td.TransactionID
    JOIN MsDrink md ON td.DrinkID = md.DrinkID
WHERE mc.CustomerGender = 'Male' AND th.TransactionDate < '2022-01-01'
GROUP BY mc.CustomerID, mc.CustomerName

-- SOAL 4
SELECT [DrinkTypeName] = UPPER(mdt.DrinkTypeName),
    [TotalDrinksBought] = SUM(td.QuantityBought),
    [AvgPrice] = CONVERT(VARCHAR, CAST(AVG(md.DrinkPrice) AS MONEY), 1) + ' IDR'
FROM MsDrinkType mdt
	JOIN MsDrink md ON md.DrinkTypeID = mdt.DrinkTypeID
	JOIN TransactionDetail td ON td.DrinkID = md.DrinkID
	JOIN TransactionHeader th ON th.TransactionID = td.TransactionID
WHERE mdt.DrinkTypeName IN (
	SELECT DrinkTypeName
	FROM MsDrinkType
	WHERE DrinkTypeName LIKE '%Alcohol%' OR
		DrinkTypeName LIKE '%Cocktail%'
) AND DATEPART(WEEKDAY, th.TransactionDate) IN (2, 4, 6)
GROUP BY mdt.DrinkTypeName

-- SOAL 5 
SELECT mc.CustomerName, 
	[CustomerAge] = DATEDIFF(YEAR, mc.CustomerDOB, '2023-12-12'),
	[CustomerDOB] = FORMAT(mc.CustomerDOB, 'dd MMMM yyyy'),
	mcd.CityName
FROM MsCustomer mc
	JOIN MsCityDetail mcd ON mc.CityID = mcd.CityID
	JOIN MsMembership mm ON mc.MembershipID = mm.MembershipID
	JOIN (
		SELECT [AvgCustAge] = AVG(DATEDIFF(YEAR, CustomerDOB, '2023-12-12'))
		FROM MsCustomer
	) AS CustomerAge ON DATEDIFF(YEAR, mc.CustomerDOB, '2023-12-12') > CustomerAge.AvgCustAge
WHERE YEAR(mm.MembershipEndDate) = 2023

-- SOAL 6 
SELECT [Staff] = CONCAT(msp.PositionName, ' ', ms.StaffName),
    [Quantity] = td.QuantityBought,
    [TransactionID] = REPLACE(td.TransactionID, 'TR', 'Transaction '),
    [StaffBonus] = (td.QuantityBought * 50000)
FROM MsStaffPosition msp 
	JOIN MsStaff ms ON ms.PositionID = msp.PositionID
	JOIN TransactionHeader th ON ms.StaffID = th.StaffID
	JOIN TransactionDetail td on th.TransactionID = td.TransactionID
	JOIN (
		SELECT [AverageQuantity] = AVG(QuantityBought)
		FROM TransactionDetail
	) AS AvgQuantity ON td.QuantityBought > AvgQuantity.AverageQuantity
WHERE msp.PositionName NOT LIKE '%Manager%'

-- SOAL 7
SELECT [DrinkCode] = CONCAT(LEFT(md.DrinkName, 1), LEFT(SUBSTRING(md.DrinkName, CHARINDEX(' ', md.DrinkName) + 1, LEN(md.DrinkName)), 1), LEFT(mdt.DrinkTypeName, 1)), 
	md.DrinkName,
    [DrinkDiscountedPrice] = md.DrinkPrice * 0.9,
    TransactionJune.TotalProfit, mdt.DrinkTypeName
FROM MsDrink md
	JOIN MsDrinkType mdt ON md.DrinkTypeID = mdt.DrinkTypeID
	JOIN (
		SELECT td.DrinkID, 
		[TotalProfit] = SUM(td.QuantityBought * (md.DrinkPrice - md.DrinkPrice * 0.9))
		FROM TransactionDetail td
			JOIN MsDrink md ON td.DrinkID = md.DrinkID
			JOIN TransactionHeader th ON td.TransactionID = th.TransactionID
		WHERE th.TransactionDate > '2021-06-30'
		GROUP BY td.DrinkID
	) AS TransactionJune ON md.DrinkID = TransactionJune.DrinkID
WHERE md.DrinkName LIKE '%a%'

-- SOAL 8
SELECT [DrinkName] = LEFT(md.DrinkName, CHARINDEX(' ', md.DrinkName) - 1) + ' ' + RIGHT(md.DrinkName, CHARINDEX(' ', REVERSE(md.DrinkName)) - 1),
	mc.CustomerName,
	[DaysAgo] = DATEDIFF(DAY, th.TransactionDate, '2023-12-12'),
	td.QuantityBought
FROM MsDrink md
	JOIN TransactionDetail td ON md.DrinkID = td.DrinkID
	JOIN TransactionHeader th ON td.TransactionID = th.TransactionID
	JOIN MsCustomer mc ON th.CustomerID = mc.CustomerID
	JOIN (
		SELECT [MinQuantityBought] = MIN(QuantityBought)
		FROM TransactionDetail
	) AS MinQty ON td.QuantityBought > MinQty.MinQuantityBought
	JOIN (
		SELECT [MaxQuantityBought] = MAX(QuantityBought)
		FROM TransactionDetail
	) AS MaxQty ON td.QuantityBought < MaxQty.MaxQuantityBought

-- SOAL 9
CREATE VIEW TotalSalesDrinkType 
AS

SELECT mdt.DrinkTypeName,
	[DrinksSold] = SUM(td.QuantityBought),
	[AverageDrinkPrice] = AVG(md.DrinkPrice)
FROM MsDrinkType mdt
	JOIN MsDrink md ON mdt.DrinkTypeID = md.DrinkTypeID
	JOIN TransactionDetail td ON md.DrinkID = td.DrinkID
	JOIN TransactionHeader th ON td.TransactionID = th.TransactionID
WHERE mdt.DrinkTypeName IN (
	SELECT DrinkTypeName
	FROM MsDrinkType
	WHERE DrinkTypeName IN ('Boba', 'Juice', 'Milkshake', 'Smoothie', 'Tea')
) AND MONTH(th.TransactionDate) > 6
GROUP BY mdt.DrinkTypeName

SELECT *
FROM TotalSalesDrinkType

-- SOAL 10
CREATE VIEW TotalCustomersBasedOnCity 
AS

SELECT mcd.CityName,
	[TotalCustomers] = COUNT(mc.CustomerID),
	[MinAmountOfDrinksBought] = CONCAT(MIN(td.QuantityBought), ' Drink(s)')
FROM MsCityDetail mcd
	JOIN MsCustomer mc ON mcd.CityID = mc.CityID
	JOIN TransactionHeader th ON mc.CustomerID = th.CustomerID
	JOIN TransactionDetail td ON th.TransactionID = td.TransactionID
WHERE LEN(mcd.CityName) - LEN(REPLACE(mcd.CityName, ' ', ' ')) >= 0 AND 
	mc.CustomerAddress LIKE '%Road'
GROUP BY mcd.CityName

SELECT *
FROM TotalCustomersBasedOnCity