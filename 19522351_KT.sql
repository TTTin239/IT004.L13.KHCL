CREATE DATABASE QUANLIMB
USE QUANLIMB
--MAY BAY
CREATE TABLE MAYBAY(
    MaMayBay Char(4) not  null,
	MaLoaiMB Char(4) not  null,
	MaHangHK Char(4),
	NgaySX Date,
	SoLanBay Int,
	constraint pk_mb primary key(MaMayBay)
)
--LOAI MAY BAY
CREATE TABLE LOAIMAYBAY(
    MaLoaiMB Char(4) not null,
	TenLoaiMB Varchar(20),
	NhaSX Varchar(20),
	SucChua Int,
	constraint pk_lmb primary key(MaLoaiMB)
)
--HANG HK
CREATE TABLE HANGHK(
    MaHangHK Char(4) not null,
	TenHangHk Varchar(20),
    constraint pk_hhk primary key(MaHangHK)
)
--PHI CONG
CREATE TABLE PHICONG(
    MaPhiCong Char(4),
	HoTen Varchar(50),
	NgaySinh Date not null,
	QuocTich Varchar(20),
	MaLoaiMB Char(4) not null,
	constraint pk_pc primary key(MaPhiCong)
)
--CHUYEN BAY
CREATE TABLE CHUYENBAY(
    MaChuyenBay Char(4),
	MaMayBay Char(4) not null,
	MaPhiCong Char(4) not null,
	NoiDi Varchar(20),
	NoiDen Varchar(20),
	constraint pk_cb primary key(MaChuyenBay)
)
set dateformat dmy
--KHOA NGOAI MAYBAY
ALTER TABLE MAYBAY ADD CONSTRAINT pk01_mb FOREIGN KEY(MaLoaiMB) REFERENCES LOAIMAYBAY(MaLoaiMB)
ALTER TABLE MAYBAY ADD CONSTRAINT pk02_mb FOREIGN KEY(MaHangHK) REFERENCES HANGHK(MaHangHK)
--KHOA NGOAI PHICONG
ALTER TABLE PHICONG ADD CONSTRAINT pk_pc FOREIGN KEY(MaLoaiMB) REFERENCES LOAIMAYBAY(MaLoaiMB)
--KHOA NGOAI CHUYENBAY
ALTER TABLE CHUYENBAY ADD CONSTRAINT pk01_cb FOREIGN KEY(MaMayBay) REFERENCES MAYBAY(MaMayBay)
ALTER TABLE CHUYENBAY ADD CONSTRAINT pk02_cb FOREIGN KEY(MaPhiCong) REFERENCES PHICONG(MaPhiCong)
--Cau 2.1:
ALTER TABLE LOAIMAYBAY
ADD CONSTRAINT CHK_SC
CHECK (SucChua<=300)
--Cau 2.2:
ALTER TABLE LOAIMAYBAY
ADD CONSTRAINT CHK_NSX
CHECK (NhaSX IN ('Boeing','Airbus','ATR','Embraer'))
--Cau 2.3:
CREATE TRIGGER UPDATE_SOLANBAY
ON CHUYENBAY
AFTER INSERT
AS
BEGIN
    DECLARE @MAMB CHAR(4)
	DECLARE @SOLANBAY INT
	SELECT @MAMB = MaMayBay FROM INSERTED
	SELECT @SOLANBAY = SoLanBay
	    FROM INSERTED, dbo.MAYBAY
		WHERE INSERTED.MaMayBay=dbo.MAYBAY.MaMayBay
    SELECT @SOLANBAY = @SOLANBAY+1
	UPDATE MAYBAY SET SoLanBay = @SOLANBAY
	WHERE MaMayBay=@MAMB
END
GO
--Cau 3.1:
SELECT MaMayBay, TenHangHK
FROM MAYBAY, HANGHK, LOAIMAYBAY
WHERE (MAYBAY.MaHangHK=HANGHK.MaHangHK)
AND (MAYBAY.MaLoaiMB=LOAIMAYBAY.MaLoaiMB)
AND (SoLanBay>500)
AND (NhaSX='ATR')
--Cau 3.2:
SELECT COUNT(MAYBAY.MaMayBay) AS SL
FROM MAYBAY, HANGHK
WHERE (MAYBAY.MaHangHK=HANGHK.MaHangHK)
AND (HANGHK.TenHangHk='VietJet Air')
--Cau 3.3:
SELECT MaPhiCong, HoTen
FROM PHICONG
WHERE (MaPhiCong NOT IN( SELECT PHICONG.MaPhiCong
                               FROM CHUYENBAY,PHICONG
							   WHERE (NoiDen = 'CanTho')
							   OR (NoiDi = 'CanTho')))
--Cau 3.4:
SELECT MaPhiCong, HoTen
FROM PHICONG AS PC
WHERE NOT EXISTS(SELECT *
                 FROM MAYBAY AS MB
				 WHERE NOT EXISTS ( SELECT *
				                    FROM CHUYENBAY AS CB
									WHERE MB.MaLoaiMB=PC.MaLoaiMB
									AND PC.MaPhiCong=CB.MaPhiCong
									AND MB.MaLoaiMB = 'AT72'))
--Cau Bonus:
SELECT PHICONG.MaPhiCong,HoTen
FROM PHICONG,CHUYENBAY
WHERE (PHICONG.MaPhiCong=CHUYENBAY.MaPhiCong)
AND (PHICONG.MaPhiCong IN (SELECT TOP 10 MaPhiCong
                           FROM CHUYENBAY
						   ORDER BY COUNT(MaChuyenBay) ASC))
HAVING PHICONG.NgaySinh LIKE (SELECT TOP 1 NgaySinh
                              FROM PHICONG
							  GROUP BY MaPhiCong
							  ORDER BY NgaySinh ASC)