CREATE DATABASE QLNH
USE QLNH
--MON AN
CREATE TABLE MONAN(
    MaMonAn Char(10) not null,
	TenMonAn Varchar(50),
	MaLoaiMonAn Char(10),
	constraint pk_ma primary key(MaMonAn)
)
--LOAI MON AN
CREATE TABLE LOAIMONAN(
    MaLoaiMonAn Char(10) not null,
	TenLoaiMonAn Varchar(20),
	constraint pk_la primary key(MaLoaiMonAn)
)
--NV PHUC VU
CREATE TABLE NVPHUCVU(
    MaNVPhucVu Char(10) not null,
	HoTenNVPhucVu Varchar(50),
	NgayVaoLam Date,
	constraint pk_nv primary key(MaNVPhucVu)
)
--BAN AN
CREATE TABLE BANAN(
    MaBanAn Char(10) not null,
	KhuVuc Char(10),
	SucChua Int,
	constraint pk_ba primary key(MaBanAn)
)
--HOA DON
CREATE TABLE HOADON(
    MaHoaDon Char(10) not null,
	MaBanAn Char(10),
	MaNVPhucVu Char(10),
	NgayHoaDon Date,
	ThanhTien Int,
	constraint pk_hd primary key(MaHoaDon)
)
--CTHD
CREATE TABLE CTHD(
    MaHoaDon Char(10) not null,
	MaMonAn Char(10) not null,
	SoLuong Int,
	constraint pk_cthd primary key(MaHoaDon,MaMonAn)
)
set dateformat dmy
--KHOA NGOAI CUA MON AN
ALTER TABLE MONAN ADD CONSTRAINT pk_ma FOREIGN KEY(MaLoaiMonAn) REFERENCES LOAIMONAN(MaLoaiMonAn)
--KHOA NGOAI CUA HOA DON
ALTER TABLE HOADON ADD CONSTRAINT pk01_hd FOREIGN KEY(MaBanAn) REFERENCES BANAN(MaBanAn)
ALTER TABLE HOADON ADD CONSTRAINT pk02_hd FOREIGN KEY(MaNVPhucVu) REFERENCES NVPHUCVU(MaNVPhucVu)
--Cau 2.1:
ALTER TABLE BANAN
ADD CONSTRAINT CHK_SC
CHECK (SucChua<=10)
--Cau 2.1:
ALTER TABLE LOAIMONAN
ADD CONSTRAINT CHK_TLMA
CHECK (TenLoaiMonAn IN ('Khai vi, Mon chinh, Trang mieng'))
--Cau 2.3:
CREATE TRIGGER KT_NGAYHOADON_NGAYVAOLAM
ON HOADON
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @NGAYHOADON DATE
	DECLARE @NGAYVAOLAM DATE
	SELECT @NGAYHOADON=NgayHoaDon
	FROM INSERTED
	SELECT @NGAYVAOLAM=NgayVaoLam
	FROM INSERTED, HOADON, NVPHUCVU
	WHERE INSERTED.MaHoaDon=HOADON.MaHoaDon AND HOADON.MaNVPhucVu=NVPHUCVU.MaNVPhucVu
	IF(@NGAYHOADON>@NGAYVAOLAM)
	   COMMIT
    ELSE
	   ROLLBACK
END
--Cau 3.1:
SELECT MaMonAn, TenMonAn
FROM LOAIMONAN AS l, MONAN AS m
WHERE m.MaLoaiMonAn=l.MaLoaiMonAn
AND l.TenLoaiMonAn = 'khai vi'
--Cau 3.2:
SELECT MaHoaDon, b.MaBanAn, MaNVPhucVu
FROM HOADON AS h,BANAN AS b
WHERE h.MaBanAn=b.MaBanAn
AND B.KhuVuc='VIP'
AND h.NgayHoaDon like '25/12/2014'
--Cau 3.3:
SELECT MaLoaiMonAn, TenLoaiMonAn, COUNT(MaLoaiMonAn) AS SoLuong
FROM LOAIMONAN
WHERE MaLoaiMonAn>10
GROUP BY TenLoaiMonAn,MaLoaiMonAn
ORDER BY COUNT(MaLoaiMonAn) DESC
--Cau Bonus:
SELECT MaMonAn, TenMonAn
FROM MONAN
WHERE NOT EXISTS (SELECT *
                  FROM HOADON
				  WHERE NOT EXISTS (SELECT *
				                    FROM CTHD
									WHERE CTHD.MaHoaDon=HOADON.NgayHoaDon
									AND CTHD.MaMonAn=MONAN.MaMonAn))
