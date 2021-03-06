USE [master]
GO
/****** Object:  Database [QuanLyQuanCafe]    Script Date: 12/29/2019 4:08:19 PM ******/
CREATE DATABASE [QuanLyQuanCafe]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'QuanLyQuanCafe', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\QuanLyQuanCafe.mdf' , SIZE = 3136KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'QuanLyQuanCafe_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\QuanLyQuanCafe_log.ldf' , SIZE = 832KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [QuanLyQuanCafe] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [QuanLyQuanCafe].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [QuanLyQuanCafe] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [QuanLyQuanCafe] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [QuanLyQuanCafe] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [QuanLyQuanCafe] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [QuanLyQuanCafe] SET ARITHABORT OFF 
GO
ALTER DATABASE [QuanLyQuanCafe] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [QuanLyQuanCafe] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [QuanLyQuanCafe] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [QuanLyQuanCafe] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [QuanLyQuanCafe] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [QuanLyQuanCafe] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [QuanLyQuanCafe] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [QuanLyQuanCafe] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [QuanLyQuanCafe] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [QuanLyQuanCafe] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [QuanLyQuanCafe] SET  ENABLE_BROKER 
GO
ALTER DATABASE [QuanLyQuanCafe] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [QuanLyQuanCafe] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [QuanLyQuanCafe] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [QuanLyQuanCafe] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [QuanLyQuanCafe] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [QuanLyQuanCafe] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [QuanLyQuanCafe] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [QuanLyQuanCafe] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [QuanLyQuanCafe] SET  MULTI_USER 
GO
ALTER DATABASE [QuanLyQuanCafe] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [QuanLyQuanCafe] SET DB_CHAINING OFF 
GO
ALTER DATABASE [QuanLyQuanCafe] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [QuanLyQuanCafe] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [QuanLyQuanCafe]
GO
/****** Object:  StoredProcedure [dbo].[USP_GetAccountByUserName]    Script Date: 12/29/2019 4:08:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_GetAccountByUserName]
@userName nvarchar(50)
AS
BEGIN
	SELECT * FROM dbo.Account WHERE UserName = @userName
END

GO
/****** Object:  StoredProcedure [dbo].[USP_GetListBillByDate]    Script Date: 12/29/2019 4:08:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_GetListBillByDate]
@CheckIn date, @CheckOut date
AS
BEGIN
	SELECT t.name, DateCheckIn, DateCheckOut, discount, b.totalPrice
	FROM Bill AS b, TableFood AS t
	WHERE DateCheckIn >= @CheckIn AND DateCheckOut <= @CheckOut AND b.status = 1
	AND t.id = b.idTable 
END

GO
/****** Object:  StoredProcedure [dbo].[USP_GetTableList]    Script Date: 12/29/2019 4:08:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_GetTableList]
AS SELECT * FROM dbo.tableFood

GO
/****** Object:  StoredProcedure [dbo].[USP_InsertBill]    Script Date: 12/29/2019 4:08:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_InsertBill]
@idTable INT
AS
BEGIN
	INSERT dbo.Bill (DateCheckIn, 
					DateCheckOut, 
					idTable, 
					status,
					discount
					)
	VALUES (GETDATE(), --DateCheckIn - date
			NULL,		--DateCheckOut - date
			@idTable,	--idTable - int
			0,		-- status - int
			0
			)
END

GO
/****** Object:  StoredProcedure [dbo].[USP_InsertBillInfo]    Script Date: 12/29/2019 4:08:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_InsertBillInfo]
@idBill INT, @idFood INT, @count INT
AS
BEGIN
	DECLARE @isExitsBillInfo INT
	DECLARE @foodCount INT = 1

	SELECT @isExitsBillInfo = id, @foodCount = b.count 
	FROM dbo.BillInfo AS b
	WHERE idBill = @idBill	AND idFood = @idFood

	IF (@isExitsBillInfo > 0)
	BEGIN
		DECLARE @newCount INT = @foodCount + @count
		IF(@newCount > 0)
			UPDATE dbo.BillInfo SET count = @foodCount + @count WHERE idFood = @idFood
		ELSE
			DELETE dbo.BillInfo WHERE idBill = @idBill AND idFood = @idFood
	END
	ELSE
	BEGIN
		INSERT dbo.BillInfo
		(idBill, idFood, count)	
	VALUES (@idBill, @idFood, @count)
	END
END

GO
/****** Object:  StoredProcedure [dbo].[USP_Login]    Script Date: 12/29/2019 4:08:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_Login]
@userName nvarchar(50), @passWord nvarchar(50)
AS
BEGIN
	SELECT * FROM dbo.Account WHERE UserName = @userName AND PassWord = @passWord
END

GO
/****** Object:  StoredProcedure [dbo].[USP_SwitchTable]    Script Date: 12/29/2019 4:08:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_SwitchTable]
@idTable1 INT, @idTable2 INT
AS
BEGIN
	DECLARE @idFirstBill INT
	DECLARE @idSecondBill INT

	DECLARE @isFisrtTableEmty INT = 0
	DECLARE @isSecondTableEmty INT = 0

	SELECT @idSecondBill = id FROM dbo.Bill WHERE idTable = @idTable2 and status = 0
	SELECT @idFirstBill = id FROM dbo.Bill WHERE idTable = @idTable1 and status = 0

	IF(@idFirstBill IS NULL)
	BEGIN
		INSERT dbo.Bill (	DateCheckIn, 
							DateCheckOut, 
							idTable, 
							status				
						)
		VALUES (	GETDATE(), --DateCheckIn - date
				NULL,		--DateCheckOut - date
				@idTable1,	--idTable - int
				0		-- status - int			
				)
			SELECT @idFirstBill = MAX(id) FROM dbo.Bill WHERE idTable = @idTable1 AND status = 0
	END
	SELECT @isFisrtTableEmty = COUNT(*) FROM dbo.BillInfo WHERE idBill = @idFirstBill

	IF(@idSecondBill IS NULL)
	BEGIN
		INSERT dbo.Bill (	DateCheckIn, 
							DateCheckOut, 
							idTable, 
							status				
						)
		VALUES (	GETDATE(), --DateCheckIn - date
				NULL,		--DateCheckOut - date
				@idTable2,	--idTable - int
				0		-- status - int			
				)
			SELECT @idSecondBill = MAX(id) FROM dbo.Bill WHERE idTable = @idTable2 AND status = 0
	END
	SELECT @isSecondTableEmty = COUNT(*) FROM dbo.BillInfo WHERE idBill = @idSecondBill

	SELECT id INTO IDBillIndoTable FROM dbo.BillInfo WHERE idBill = @idSecondBill
	UPDATE dbo.BillInfo SET idBill = @idSecondBill WHERE idBill = @idFirstBill
	UPDATE dbo.BillInfo SET idBill = @idFirstBill WHERE id IN (SELECT * FROM IDBillIndoTable)
	DROP TABLE IDBillIndoTable

	IF(@isFisrtTableEmty = 0)
		UPDATE dbo.TableFood SET status = N'Bàn Trống' WHERE id = @idTable2

	IF(@isSecondTableEmty = 0)
		UPDATE dbo.TableFood SET status = N'Bàn Trống' WHERE id = @idTable1
END

GO
/****** Object:  StoredProcedure [dbo].[USP_UpdateAccount]    Script Date: 12/29/2019 4:08:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_UpdateAccount]
@userName NVARCHAR(50), @displayName NVARCHAR(50), @password NVARCHAR(50), @newPass NVARCHAR(50)
AS
BEGIN
	DECLARE @isRightPass INT = 0
	SELECT @isRightPass = COUNT(*) FROM dbo.Account WHERE UserName = @userName AND PassWord = @password
	IF(@isRightPass = 1)
	BEGIN
		IF(@newPass = NULL OR @newPass = '')
		BEGIN
			UPDATE dbo.Account SET DisplayName = @displayName WHERE UserName = @userName
		END
		ELSE
			UPDATE dbo.Account SET DisplayName = @displayName, PassWord = @newPass WHERE UserName = @userName
	END
END

GO
/****** Object:  UserDefinedFunction [dbo].[non_unicode_convert]    Script Date: 12/29/2019 4:08:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[non_unicode_convert](@inputVar NVARCHAR(MAX) )
RETURNS NVARCHAR(MAX)
AS
BEGIN    
    IF (@inputVar IS NULL OR @inputVar = '')  RETURN ''
   
    DECLARE @RT NVARCHAR(MAX)
    DECLARE @SIGN_CHARS NCHAR(256)
    DECLARE @UNSIGN_CHARS NCHAR (256)
 
    SET @SIGN_CHARS = N'ăâđêôơưàảãạáằẳẵặắầẩẫậấèẻẽẹéềểễệếìỉĩịíòỏõọóồổỗộốờởỡợớùủũụúừửữựứỳỷỹỵýĂÂĐÊÔƠƯÀẢÃẠÁẰẲẴẶẮẦẨẪẬẤÈẺẼẸÉỀỂỄỆẾÌỈĨỊÍÒỎÕỌÓỒỔỖỘỐỜỞỠỢỚÙỦŨỤÚỪỬỮỰỨỲỶỸỴÝ' + NCHAR(272) + NCHAR(208)
    SET @UNSIGN_CHARS = N'aadeoouaaaaaaaaaaaaaaaeeeeeeeeeeiiiiiooooooooooooooouuuuuuuuuuyyyyyAADEOOUAAAAAAAAAAAAAAAEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOUUUUUUUUUUYYYYYDD'
 
    DECLARE @COUNTER int
    DECLARE @COUNTER1 int
   
    SET @COUNTER = 1
    WHILE (@COUNTER <= LEN(@inputVar))
    BEGIN  
        SET @COUNTER1 = 1
        WHILE (@COUNTER1 <= LEN(@SIGN_CHARS) + 1)
        BEGIN
            IF UNICODE(SUBSTRING(@SIGN_CHARS, @COUNTER1,1)) = UNICODE(SUBSTRING(@inputVar,@COUNTER ,1))
            BEGIN          
                IF @COUNTER = 1
                    SET @inputVar = SUBSTRING(@UNSIGN_CHARS, @COUNTER1,1) + SUBSTRING(@inputVar, @COUNTER+1,LEN(@inputVar)-1)      
                ELSE
                    SET @inputVar = SUBSTRING(@inputVar, 1, @COUNTER-1) +SUBSTRING(@UNSIGN_CHARS, @COUNTER1,1) + SUBSTRING(@inputVar, @COUNTER+1,LEN(@inputVar)- @COUNTER)
                BREAK
            END
            SET @COUNTER1 = @COUNTER1 +1
        END
        SET @COUNTER = @COUNTER +1
    END
    -- SET @inputVar = replace(@inputVar,' ','-')
    RETURN @inputVar
END

GO
/****** Object:  Table [dbo].[Account]    Script Date: 12/29/2019 4:08:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Account](
	[DisplayName] [nvarchar](50) NOT NULL,
	[UserName] [nvarchar](50) NOT NULL,
	[PassWord] [nvarchar](50) NOT NULL,
	[Type] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Bill]    Script Date: 12/29/2019 4:08:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bill](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[DateCheckIn] [date] NOT NULL,
	[DateCheckOut] [date] NULL,
	[idTable] [int] NOT NULL,
	[status] [int] NOT NULL,
	[discount] [int] NULL,
	[totalPrice] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BillInfo]    Script Date: 12/29/2019 4:08:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillInfo](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idBill] [int] NOT NULL,
	[idFood] [int] NOT NULL,
	[count] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Food]    Script Date: 12/29/2019 4:08:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Food](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[idCategory] [int] NOT NULL,
	[Price] [float] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FoodCategory]    Script Date: 12/29/2019 4:08:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FoodCategory](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TableFood]    Script Date: 12/29/2019 4:08:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TableFood](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[status] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
INSERT [dbo].[Account] ([DisplayName], [UserName], [PassWord], [Type]) VALUES (N'Master', N'admin', N'0', 1)
INSERT [dbo].[Account] ([DisplayName], [UserName], [PassWord], [Type]) VALUES (N'staff', N'staff', N'1', 0)
INSERT [dbo].[Account] ([DisplayName], [UserName], [PassWord], [Type]) VALUES (N'người dùng', N'user', N'0', 1)
SET IDENTITY_INSERT [dbo].[Bill] ON 

INSERT [dbo].[Bill] ([id], [DateCheckIn], [DateCheckOut], [idTable], [status], [discount], [totalPrice]) VALUES (1, CAST(0x8C400B00 AS Date), NULL, 1, 0, 0, NULL)
INSERT [dbo].[Bill] ([id], [DateCheckIn], [DateCheckOut], [idTable], [status], [discount], [totalPrice]) VALUES (2, CAST(0x8C400B00 AS Date), NULL, 2, 0, 0, NULL)
INSERT [dbo].[Bill] ([id], [DateCheckIn], [DateCheckOut], [idTable], [status], [discount], [totalPrice]) VALUES (3, CAST(0x8C400B00 AS Date), CAST(0x8C400B00 AS Date), 2, 1, 0, NULL)
INSERT [dbo].[Bill] ([id], [DateCheckIn], [DateCheckOut], [idTable], [status], [discount], [totalPrice]) VALUES (4, CAST(0x8C400B00 AS Date), CAST(0x8C400B00 AS Date), 5, 1, 0, 330)
INSERT [dbo].[Bill] ([id], [DateCheckIn], [DateCheckOut], [idTable], [status], [discount], [totalPrice]) VALUES (5, CAST(0x8C400B00 AS Date), CAST(0x8C400B00 AS Date), 4, 1, 10, 216)
SET IDENTITY_INSERT [dbo].[Bill] OFF
SET IDENTITY_INSERT [dbo].[BillInfo] ON 

INSERT [dbo].[BillInfo] ([id], [idBill], [idFood], [count]) VALUES (1, 4, 1, 6)
INSERT [dbo].[BillInfo] ([id], [idBill], [idFood], [count]) VALUES (2, 4, 3, 4)
INSERT [dbo].[BillInfo] ([id], [idBill], [idFood], [count]) VALUES (3, 4, 5, 1)
INSERT [dbo].[BillInfo] ([id], [idBill], [idFood], [count]) VALUES (4, 2, 1, 6)
INSERT [dbo].[BillInfo] ([id], [idBill], [idFood], [count]) VALUES (5, 2, 6, 2)
INSERT [dbo].[BillInfo] ([id], [idBill], [idFood], [count]) VALUES (6, 3, 5, 2)
INSERT [dbo].[BillInfo] ([id], [idBill], [idFood], [count]) VALUES (7, 5, 1, 6)
SET IDENTITY_INSERT [dbo].[BillInfo] OFF
SET IDENTITY_INSERT [dbo].[Food] ON 

INSERT [dbo].[Food] ([id], [name], [idCategory], [Price]) VALUES (1, N'Hot Chocolate', 1, 40000)
INSERT [dbo].[Food] ([id], [name], [idCategory], [Price]) VALUES (2, N'Chocolate Ice Blender', 1, 50000)
INSERT [dbo].[Food] ([id], [name], [idCategory], [Price]) VALUES (3, N'Chocolate Coconut', 1, 50000)
INSERT [dbo].[Food] ([id], [name], [idCategory], [Price]) VALUES (4, N'Bún bò', 2, 50000)
INSERT [dbo].[Food] ([id], [name], [idCategory], [Price]) VALUES (5, N'Phở bò', 2, 50000)
INSERT [dbo].[Food] ([id], [name], [idCategory], [Price]) VALUES (6, N'Cơm chiên gà rán', 2, 35000)
INSERT [dbo].[Food] ([id], [name], [idCategory], [Price]) VALUES (7, N'Tequila Sunrise', 3, 77000)
INSERT [dbo].[Food] ([id], [name], [idCategory], [Price]) VALUES (8, N'Bloody Mary', 3, 77000)
INSERT [dbo].[Food] ([id], [name], [idCategory], [Price]) VALUES (9, N'Blue Hawaii', 3, 77000)
INSERT [dbo].[Food] ([id], [name], [idCategory], [Price]) VALUES (10, N'Black Coffee', 4, 20000)
INSERT [dbo].[Food] ([id], [name], [idCategory], [Price]) VALUES (11, N'Milk Coffee', 4, 25000)
INSERT [dbo].[Food] ([id], [name], [idCategory], [Price]) VALUES (12, N'Sinh tố bơ', 5, 30000)
INSERT [dbo].[Food] ([id], [name], [idCategory], [Price]) VALUES (13, N'Sinh tố dâu', 5, 30000)
INSERT [dbo].[Food] ([id], [name], [idCategory], [Price]) VALUES (14, N'Sữa tươi', 5, 30000)
INSERT [dbo].[Food] ([id], [name], [idCategory], [Price]) VALUES (15, N'Bánh mì bò kho', 2, 40000)
SET IDENTITY_INSERT [dbo].[Food] OFF
SET IDENTITY_INSERT [dbo].[FoodCategory] ON 

INSERT [dbo].[FoodCategory] ([id], [name]) VALUES (1, N'Chocolate')
INSERT [dbo].[FoodCategory] ([id], [name]) VALUES (2, N'Beakfast')
INSERT [dbo].[FoodCategory] ([id], [name]) VALUES (3, N'Cocktails')
INSERT [dbo].[FoodCategory] ([id], [name]) VALUES (4, N'Coffee')
INSERT [dbo].[FoodCategory] ([id], [name]) VALUES (5, N'Drinks')
SET IDENTITY_INSERT [dbo].[FoodCategory] OFF
SET IDENTITY_INSERT [dbo].[TableFood] ON 

INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (1, N'Bàn 0', N'Bàn Trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (2, N'Bàn 1', N'Bàn trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (3, N'Bàn 2', N'Bàn trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (4, N'Bàn 3', N'Bàn Trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (5, N'Bàn 4', N'Bàn Trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (6, N'Bàn 5', N'Bàn trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (7, N'Bàn 6', N'Bàn trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (8, N'Bàn 7', N'Bàn trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (9, N'Bàn 8', N'Bàn trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (10, N'Bàn 9', N'Bàn trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (11, N'Bàn 10', N'Bàn trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (12, N'Bàn 11', N'Bàn trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (13, N'Bàn 12', N'Bàn trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (14, N'Bàn 13', N'Bàn trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (15, N'Bàn 14', N'Bàn trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (16, N'Bàn 15', N'Bàn trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (17, N'Bàn 16', N'Bàn trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (18, N'Bàn 17', N'Bàn trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (19, N'Bàn 18', N'Bàn trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (20, N'Bàn 19', N'Bàn trống')
INSERT [dbo].[TableFood] ([id], [name], [status]) VALUES (21, N'Bàn 20', N'Bàn trống')
SET IDENTITY_INSERT [dbo].[TableFood] OFF
ALTER TABLE [dbo].[Account] ADD  DEFAULT (N'User') FOR [DisplayName]
GO
ALTER TABLE [dbo].[Account] ADD  DEFAULT ((0)) FOR [PassWord]
GO
ALTER TABLE [dbo].[Account] ADD  DEFAULT ((0)) FOR [Type]
GO
ALTER TABLE [dbo].[Bill] ADD  DEFAULT (getdate()) FOR [DateCheckIn]
GO
ALTER TABLE [dbo].[Bill] ADD  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[BillInfo] ADD  DEFAULT ((0)) FOR [count]
GO
ALTER TABLE [dbo].[Food] ADD  DEFAULT (N'Chưa đặt tên') FOR [name]
GO
ALTER TABLE [dbo].[Food] ADD  DEFAULT ((0)) FOR [Price]
GO
ALTER TABLE [dbo].[FoodCategory] ADD  DEFAULT (N'Chưa đặt tên') FOR [name]
GO
ALTER TABLE [dbo].[TableFood] ADD  DEFAULT (N'Bàn chưa có tên') FOR [name]
GO
ALTER TABLE [dbo].[TableFood] ADD  DEFAULT (N'Bàn trống') FOR [status]
GO
ALTER TABLE [dbo].[Bill]  WITH CHECK ADD FOREIGN KEY([idTable])
REFERENCES [dbo].[TableFood] ([id])
GO
ALTER TABLE [dbo].[BillInfo]  WITH CHECK ADD FOREIGN KEY([idBill])
REFERENCES [dbo].[Bill] ([id])
GO
ALTER TABLE [dbo].[BillInfo]  WITH CHECK ADD FOREIGN KEY([idFood])
REFERENCES [dbo].[Food] ([id])
GO
ALTER TABLE [dbo].[Food]  WITH CHECK ADD FOREIGN KEY([idCategory])
REFERENCES [dbo].[FoodCategory] ([id])
GO
USE [master]
GO
ALTER DATABASE [QuanLyQuanCafe] SET  READ_WRITE 
GO
