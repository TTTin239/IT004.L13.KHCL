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
	constraint pk_lma primary key(MaLoaiMonAn)
)
--NV PHUC VU
CREATE TABLE NVPHUCVU(
    MaNVPhucVu Char(10) not null,
	HoTenNVPhucVu Varchar(50),
	NgayVaoLam Date,
	constraint pk_nvpv primary key(MaNVPhucVu)
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
--KHOA NGOAI CHO MON AN
ALTER TABLE MONAN ADD CONSTRAINT pk_ma FOREIGN KEY(MaLoaiMonAn) REFERENCES LOAIMONAN(MaLoaiMonAn)
--KHOA NGOAI CHO HOA DON
ALTER TABLE HOADON ADD CONSTRAINT pk01_hd FOREIGN KEY(MaBanAn) REFERENCES BANAN(MaBanAn)
ALTER TABLE HOADON ADD CONSTRAINT pk02_hd FOREIGN KEY(MaNVPhucVu) REFERENCES NVPHUCVU(MaNVPhucVu)

set dateformat dmy
--Cau 2.1:
ALTER TABLE HOADON
ADD CONSTRAINT CHK_TT
CHECK (ThanhTien>30000)
--Cau 2.2:
ALTER TABLE BANAN
ADD CONSTRAINT CHK_KV
CHECK (KhuVuc IN ('T1,T2,A1,VIP'))
--Cau 2.3:

--Cau 3.1:
SELECT MaMonAn, TenMonAn
FROM MONAN AS m, LOAIMONAN AS l
WHERE m.MaLoaiMonAn=l.MaLoaiMonAn
AND L.MaLoaiMonAn = 'Trang mieng'
--Cau 3.2:
SELECT MaHoaDon, NgayHoaDon, MaBanAn
FROM NVPHUCVU AS n, HOADON AS h
WHERE n.MaNVPhucVu=h.MaNVPhucVu
AND N.HoTenNVPhucVu = 'Nguyen Van A'
AND h.NgayHoaDon LIKE '26/12/2014'
--Cau 3.3:
SELECT l.MaLoaiMonAn, TenLoaiMonAn, COUNT(MaMonAn) AS SoLuong
FROM  MONAN AS m,LOAIMONAN AS l
WHERE m.MaLoaiMonAn=l.MaLoaiMonAn
AND MaMonAn >20
ORDER BY COUNT(MaMonAn)  DESC
--Cau Bonus:
SELECT MaMonAn, TenMonAn
FROM MONAN
WHERE NOT EXISTS (SELECT *
                  FROM HOADON
				  WHERE NOT EXISTS (SELECT *
				                    FROM CTHD
									WHERE CTHD.MaHoaDon=HOADON.MaHoaDon
									AND CTHD.MaMonAn=MONAN.MaMonAn))