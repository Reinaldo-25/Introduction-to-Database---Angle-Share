CREATE DATABASE AngleShare
GO
USE AngleShare
GO

CREATE TABLE [MsStaffPosition] (
	PositionID CHAR(5) PRIMARY KEY CHECK (PositionID LIKE 'SP[0-9][0-9][0-9]'),
	PositionName VARCHAR(50) NOT NULL CHECK (LEN(PositionName)>= 5)
)

CREATE TABLE [MsStaff] (
	StaffID CHAR(5) PRIMARY KEY CHECK (StaffID LIKE 'ST[0-9][0-9][0-9]'),
	StaffName VARCHAR(50) NOT NULL CHECK (LEN(StaffName) >= 3),
	StaffDOB DATE NOT NULL,
	StaffGender VARCHAR(10) NOT NULL CHECK (StaffGender IN ('Male', 'Female')),
	PositionID CHAR(5) FOREIGN KEY REFERENCES MsStaffPosition(PositionID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL
)

CREATE TABLE [MsDrinkType] (
	DrinkTypeID CHAR(5) PRIMARY KEY CHECK (DrinkTypeID LIKE 'DT[0-9][0-9][0-9]'),
	DrinkTypeName VARCHAR(50) NOT NULL CHECK (CHARINDEX(' ', DrinkTypeName) = 0)
)

CREATE TABLE [MsDrink] (
	DrinkID CHAR(5) PRIMARY KEY CHECK (DrinkID LIKE 'DR[0-9][0-9][0-9]'),
	DrinkName VARCHAR(50) NOT NULL CHECK (CHARINDEX(' ', DrinkName) > 0),
	DrinkPrice FLOAT NOT NULL CHECK (DrinkPrice BETWEEN 15000 AND 60000),
	Quantity INT NOT NULL CHECK (Quantity > 0),
	DrinkTypeID CHAR(5) FOREIGN KEY REFERENCES MsDrinkType(DrinkTypeID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL
)

CREATE TABLE [MsCityDetail] (
	CityID CHAR(5) PRIMARY KEY CHECK (CityID LIKE 'CI[0-9][0-9][0-9]'),
	CityName VARCHAR(50) NOT NULL
)

CREATE TABLE [MsMembership] (
	MembershipID CHAR(5) PRIMARY KEY CHECK (MembershipID LIKE 'ME[0-9][0-9][0-9]'),
	MembershipStartDate DATE NOT NULL,
	MembershipEndDate DATE NOT NULL
)

CREATE TABLE [MsCustomer] (
	CustomerID CHAR(5) PRIMARY KEY CHECK (CustomerID LIKE 'CU[0-9][0-9][0-9]'),
	CustomerName VARCHAR(50) NOT NULL CHECK (LEN(CustomerName) >= 3),
	CustomerDOB DATE NOT NULL,
	CustomerGender VARCHAR(10) NOT NULL CHECK (CustomerGender IN ('Male', 'Female')),
	CustomerAddress VARCHAR(100) NOT NULL,
	CityID CHAR(5) FOREIGN KEY REFERENCES MsCityDetail(CityID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	MembershipID CHAR(5) FOREIGN KEY REFERENCES MsMembership(MembershipID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL
)

ALTER TABLE MsCustomer
ADD CONSTRAINT ck_CustomerAddress CHECK(
	CustomerAddress LIKE '%Street' OR
	CustomerAddress LIKE '%Avenue' OR
	CustomerAddress LIKE '%Lane' OR
	CustomerAddress LIKE '%Terrace' OR
	CustomerAddress LIKE '%Hill' OR
	CustomerAddress LIKE '%Road' OR
	CustomerAddress LIKE '%Path' OR
	CustomerAddress LIKE '%Center' OR
	CustomerAddress LIKE '%Village'
)

CREATE TABLE [TransactionHeader] (
	TransactionID CHAR(5) PRIMARY KEY CHECK (TransactionID LIKE 'TR[0-9][0-9][0-9]'),
	TransactionDate DATE NOT NULL,
	StaffID CHAR(5) FOREIGN KEY REFERENCES MsStaff(StaffID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	CustomerID CHAR(5) FOREIGN KEY REFERENCES MsCustomer(CustomerID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL
)

CREATE TABLE [TransactionDetail] (
	TransactionID CHAR(5) FOREIGN KEY REFERENCES TransactionHeader(TransactionID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	DrinkID CHAR(5) FOREIGN KEY REFERENCES MsDrink(DrinkID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	QuantityBought INT NOT NULL CHECK (QuantityBought > 0)
)
