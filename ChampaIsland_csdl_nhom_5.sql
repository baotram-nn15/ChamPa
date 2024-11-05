CREATE DATABASE ChampaIsland
USE ChampaIsland
GO
CREATE TABLE Account
(
	AccountID INT IDENTITY PRIMARY KEY,
	Email NVARCHAR(150) UNIQUE,
	Password NVARCHAR(150),
	TenHienThi NVARCHAR(150),
	RoleID  INT DEFAULT(0), -- Vai tro 
	CreateDate DATETIME -- Ngay tao tk
)
GO
CREATE TABLE KhachHang (
    ma_KH INT IDENTITY PRIMARY KEY,
    ten_KH NVARCHAR(255),
    sdt NVARCHAR(15),
    email NVARCHAR(150) REFERENCES Account(Email),
    diachi NVARCHAR(255),
    ngaysinh DATE,
    gioitinh bit DEFAULT(1),
)
GO
CREATE TABLE MonAn (
    ma_MA INT IDENTITY PRIMARY KEY,
    ten_MA NVARCHAR(255),
    loai_MA NVARCHAR(255),	
    giatien INT,
    anh_MA NVARCHAR(255),
    mota NVARCHAR(255)
)
GO
CREATE TABLE HoaDon (
    ma_DH INT IDENTITY PRIMARY KEY,
    ma_KH INT,
    ngaygiao DATETIME,
    ghichu NVARCHAR(255),
    FOREIGN KEY (ma_KH) REFERENCES KhachHang(ma_KH)
)
GO
CREATE TABLE ChiTietHoaDon (
    ma_DH INT,
    ma_MA INT,
    soluong INT,
    giatien INT,
    PRIMARY KEY (ma_DH, ma_MA),
    FOREIGN KEY (ma_DH) REFERENCES HoaDon(ma_DH),
    FOREIGN KEY (ma_MA) REFERENCES MonAn(ma_MA)
)


-- Thêm dữ liệu
GO
BEGIN
INSERT INTO KhachHang ( ten_KH, sdt, email, diachi, ngaysinh, gioitinh)
VALUES
    (N'Nguyễn Văn Anh', '0987654321', N'anhN@gmail.com', N'Nha Trang, Khánh Hòa', '1990-05-15', 1),
    (N'Trần Thị Bình', '0123456789', N'binhT@gmail.com', N'456 Ninh Hòa, Khánh Hòa', '1985-10-20', 0),
    ( N'Lê Văn Cường', '0987654321', N'cuongL@gmail.com', N'789 Bình Thuận', '1988-03-25', 1),
    ( N'Nguyễn Thị Dung', '0123456789', N'dungN@gmail.com', N'012 Ninh Thuận', '1992-08-10', 0),
    ( N'Phạm Văn Ý', '0123459989', N'yPham@example.com', N'789 Tam Kỳ, Quảng Nam', '1988-03-25', 1),
(N'Đặng Tường Vy', '0341456789', 'VyDang@example.com', N'123 Quang Trung, Nguyễn Huệ', '1998-01-01', 0);
END
GO
BEGIN

INSERT INTO Account(Email,Password,TenHienThi,CreateDate,RoleID) 
VALUES
('thuy.ndt.63cntt@ntu.edu.vn','123','tt','2023-11-09',1),
('admin','123','admin', NULL, 1),
('anhN@gmail.com','anhN','VanAnh', '2022-05-04', 0),
('binhT@gmail.com','binhT','ThiBinh', '2023-08-01', 0),
('cuongL@gmail.com','cuongL','CuongLe', '2023-05-01', 0),
('dungN@gmail.com','dungN','DungNguyen', '2021-05-01', 0),
('yPham@example.com','yPham','YPham123', '2023-03-03', 0),
('VyDang@example.com','VyDang','DangVy123', 'GETDATE()', 0);
END
GO
BEGIN
INSERT INTO MonAn ( ten_MA, loai_MA, giatien, anh_MA, mota)
VALUES
    ( N'Phở Bò', N'Món chính', 50000, N'anh.png', N'Món phở ngon'),
    ( N'Gỏi Cuốn', N'Món khai vị', 30000, N'anh.png', N'Gỏi cuốn tươi ngon'),
    (N'Bánh Mì', N'Món chính', 40000,N'anh.png', N'Bánh mì thơm ngon'),
    ( N'Bún Thịt Nướng', N'Món chính', 45000, N'anh.png', N'Bún thịt nướng ngon'),
    ( N'Cơm tấm', N'Món chính', 35000, N'anh.png', N'Cơm tấm ngon');

END
GO
BEGIN
INSERT INTO  HoaDon(ma_KH,ngaygiao, ghichu)
VALUES
    ( 3,'2023-10-20', N'Giao hàng nhanh'),
    ( 1,'2023-10-21', N'Đặt càng sớm càng tốt'),
    (5,'2023-08-22', N'Đặt hàng cho buổi tối'),
    ( 2,'2023-09-23', N'Ghi chú đặt hàng'),
    ( 4,'2023-10-20', N'Ghi chú đặt hàng');
END
GO
BEGIN
INSERT INTO ChiTietHoaDon(ma_DH, ma_MA, soluong, giatien)
VALUES
    (1, 5, 2, 100000),
    (2, 4, 1, 30000),
    (3, 3, 3, 150000),
    (4, 2, 2, 90000),
    (5, 1, 2, 70000);
END
-- Thống kê
CREATE PROCEDURE GetSalesReport
AS
BEGIN
    SELECT
        MA.ten_MA AS N'Tên món ăn',
        MA.loai_MA AS N'Loại món ăn',
		MA.giatien AS N'Đơn giá',
        SUM(CTHD.soluong) AS N'Số lượng bán',
        SUM(CTHD.soluong * MA.giatien) AS N'Doanh số bán hàng'
    FROM
        MonAn MA
    JOIN
        ChiTietHoaDon CTHD ON MA.ma_MA = CTHD.ma_MA
    JOIN
        HoaDon HD ON CTHD.ma_DH = HD.ma_DH
    GROUP BY
        MA.ten_MA, MA.loai_MA, MA.giatien
	EXEC DBO.GetSalesReport
END
--Lấy thông tin chi tiết đơn hàng
CREATE PROCEDURE GetCustomerOrderDetails
AS
BEGIN
    SELECT 
        KH.ten_KH AS N'Tên Khách Hàng',
        KH.sdt AS N'Số Điện Thoại',
        KH.diachi AS N'Địa Chỉ',
		HD.ngaygiao AS N'Ngày giao',
        MA.ten_MA AS N'Tên Món Ăn',
        CTHD.soluong AS N'Số Lượng',
        MA.giatien AS N'Đơn Giá',
        CTHD.soluong * MA.giatien AS N'Thành Tiền',
		HD.ghichu as N'Ghi chú'
    FROM 
        KhachHang KH
    JOIN 
        HoaDon HD ON KH.ma_KH = HD.ma_KH
    JOIN 
        ChiTietHoaDon CTHD ON HD.ma_DH = CTHD.ma_DH
    JOIN 
        MonAn MA ON CTHD.ma_MA = MA.ma_MA
	EXEC DBO.GetCustomerOrderDetails
END
--Hiển thị chi tiết đơn hàng khi khách hàng  đặt món
CREATE PROCEDURE GetOrderDetails
AS
BEGIN
    SELECT 
        KH.ten_KH AS N'Tên Khách Hàng',
        KH.sdt AS N'Số Điện Thoại',
        KH.diachi AS N'Địa Chỉ',
        MA.ten_MA AS N'Tên Món Ăn',
        CTHD.soluong AS N'Số Lượng',
        MA.giatien AS N'Đơn Giá',
        CTHD.soluong * MA.giatien AS N'Thành Tiền'
    FROM 
        KhachHang KH
    JOIN 
        HoaDon HD ON KH.ma_KH = HD.ma_KH
    JOIN 
        ChiTietHoaDon CTHD ON HD.ma_DH = CTHD.ma_DH
    JOIN 
        MonAn MA ON CTHD.ma_MA = MA.ma_MA
    WHERE
        CONVERT(date, HD.ngaygiao) = CONVERT(date, GETDATE()) -- Chỉ lấy các đơn hàng có ngày giao là hôm nay
END
--Hiển thị danh sách đăng ký
CREATE PROCEDURE DisplayCustomerInfoByCreateDate
AS
BEGIN
	-- Lấy thời điểm hiện tại
	DECLARE @CurrentDate DATETIME = GETDATE()

	-- Hiển thị thông tin của khách hàng
	SELECT KH.*, A.CreateDate, A.Password
	FROM KhachHang KH
	INNER JOIN Account A ON KH.email = A.Email
	WHERE A.RoleID = 0 AND CONVERT(DATE, A.CreateDate) = CONVERT(DATE, @CurrentDate)
END
--Hiển thị thông tin khách hàng đã có tài khoản đăng nhập
CREATE PROCEDURE DisplayCustomerLogin
AS
BEGIN
	-- Hiển thị thông tin của khách hàng
	SELECT KH.*, A.CreateDate, A.Password
	FROM KhachHang KH
	INNER JOIN Account A ON KH.email = A.Email
	WHERE A.RoleID = 0
END
--Lệnh đặt bàn của khách hàng
CREATE PROCEDURE DatMonAn
    @ten_KH NVARCHAR(255),
    @sdt NVARCHAR(15),
    @email NVARCHAR(150),
    @diachi NVARCHAR(255),
    @ngaysinh DATE,
    @gioitinh BIT,
    @ten_MA NVARCHAR(255),
    @soluong INT,
    @ngaygiao DATETIME,
    @ghichu NVARCHAR(255)
AS
BEGIN
    -- Kiểm tra xem email của khách hàng có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE email = @email)
    BEGIN
        PRINT N'Email của khách hàng không tồn tại';
        RETURN;
    END

    -- Kiểm tra xem món ăn có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM MonAn WHERE ten_MA = @ten_MA)
    BEGIN
        PRINT N'Món ăn không tồn tại';
        RETURN;
    END

    -- Lấy mã khách hàng
    DECLARE @ma_KH INT
    SET @ma_KH = (SELECT ma_KH FROM KhachHang WHERE email = @email)

    -- Lấy mã món ăn
    DECLARE @ma_MA INT
    SET @ma_MA = (SELECT ma_MA FROM MonAn WHERE ten_MA = @ten_MA)

    -- Tạo hóa đơn nếu chưa có
    DECLARE @ma_DH INT
    IF NOT EXISTS (SELECT 1 FROM HoaDon WHERE ma_KH = @ma_KH AND ngaygiao IS NULL)
    BEGIN
        INSERT INTO HoaDon (ma_KH, ngaygiao, ghichu)
        VALUES (@ma_KH, @ngaygiao, @ghichu)
        SET @ma_DH = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        SET @ma_DH = (SELECT ma_DH FROM HoaDon WHERE ma_KH = @ma_KH AND ngaygiao IS NULL);
    END

    -- Thêm chi tiết hóa đơn (món ăn và số lượng)
    INSERT INTO ChiTietHoaDon (ma_DH, ma_MA, soluong, giatien)
    VALUES (@ma_DH, @ma_MA, @soluong, (SELECT giatien FROM MonAn WHERE ma_MA = @ma_MA))
END


