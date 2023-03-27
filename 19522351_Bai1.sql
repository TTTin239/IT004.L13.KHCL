CREATE DATABASE QLXE
USE QLXE
--XE TAI
CREATE TABLE XETAI(
    BienSo Char(10) not null,
	MaLoaiXe Char(04),
	NgayMua Date,
	SoKm Int,
	constraint pk_xt primary key(BienSo)
)
--LOAI XE
CREATE TABLE LOAIXE(
    MaLoaiXe Char(04) not null,
	TenLoaiXe Varchar(20),
	NhaSx Varchar(20),
	TaiTrongXe Int,
	NienHanSuDung Int,
	constraint pk_lx primary key(MaLoaiXe)
)
--TAI XE
CREATE TABLE TAIXE(
    MaTaiXe Char(4) not null,
	HoTenTaiXe Varchar(50),
	constraint pl_tx primary key(MaTaiXe)
)
--BANG LAI
CREATE TABLE BANGLAI(
    MaBangLai Char(4) not null,
	MaTaiXe Char(4) not null,
	NgayCap Date,
	LoaiGPLX Varchar(50),
	constraint pk_bl primary key(MaBangLai,MaTaiXe)
)
--VAN CHUYEN
CREATE TABLE VANCHUYEN(
    MaChuyen Char(4) not null,
	MaTaiXe Char(4) not null,
	BienSo Char(10) not null,
	TaiTrongHang Int,
	QuangDuong Int,
	NgayVanChuyen Date,
	constraint pk_vc primary key(MaChuyen,MaTaiXe,BienSo)
)
set dateformat dmy
--Khoa ngoai cho XE TAI
ALTER TABLE XETAI ADD CONSTRAINT fk_xt FOREIGN KEY(MaLoaiXe) REFERENCES LOAIXE(MaLoaiXe)
--Khoa Ngoai cho BANG LAI
ALTER TABLE BANGLAI ADD CONSTRAINT fk_bl FOREIGN KEY(MaTaiXe) REFERENCES TAIXE(MaTaiXe)
--Khoa ngoai cho VAN CHUYEN
ALTER TABLE VANCHUYEN ADD CONSTRAINT fk01_vc FOREIGN KEY(MaTaiXe) REFERENCES TAIXE(MaTaiXe)
ALTER TABLE VANCHUYEN ADD CONSTRAINT fk02_vc FOREIGN KEY(BienSo) REFERENCES TAIXE(BienSo)
--Cau 2.1:
ALTER TABLE LOAIXE
ADD CONSTRAINT CHK_TTX
CHECK (TaiTrongXe<=30)
--Cau 2.2:
ALTER TABLE BANGLAI
ADD CONSTRAINT CHK_GPLX
CHECK (LoaiGPLX IN ('B1','B2','C','D','E','F'))
--Cau 2.3:
CREATE TRIGGER KT_TRONGTAIHANG_TRONGTAIXE
ON VANCHUYEN
FOR INSERT, UPDATE
AS
BEGIN
   DECLARE @TRONGTAIHANG INT
   DECLARE @TRONGTAIXE INT
   SELECT @TRONGTAIHANG= TaiTrongHang
   FROM INSERTED
   SELECT @TRONGTAIXE= TaiTrongXe
   FROM INSERTED, XETAI, LOAIXE
   WHERE INSERTED.BienSo=XETAI.BienSo AND XETAI.MaLoaiXe=LOAIXE.MaLoaiXe
   IF(@TRONGTAIHANG<=@TRONGTAIXE)
       COMMIT
   ELSE
       ROLLBACK
END
--Cau 3.1:
SELECT BienSo, TenLoaiXe
FROM XETAI,LOAIXE
WHERE (XETAI.MaLoaiXe=LOAIXE.MaLoaiXe)
AND (LOAIXE.TaiTrongXe>10)
--Cau 3.2:
SELECT NgayMua, NhaSX
FROM XETAI,LOAIXE
WHERE (XETAI.MaLoaiXe=LOAIXE.MaLoaiXe)
AND (NhaSX='HuynDai' AND Year(NgayMua)='2012')
--Cau 3.3:
SELECT TAIXE.HoTenTaiXe, TAIXE.MaTaiXe, COUNT(MaBangLai) AS SL_BangLai
FROM BANGLAI, TAIXE
WHERE BANGLAI.MaTaiXe=TAIXE.MaTaiXe
HAVING COUNT(MaBangLai)>3
ORDER BY COUNT(MaBangLai) DESC
--Cau Bonus:
SELECT MaTaiXe, HoTenTaiXe
FROM TAIXE
WHERE NOT EXISTS( SELECT *
                  FROM XETAI
				  WHERE NOT EXISTS( SELECT *
				                    FROM VANCHUYEN
									WHERE TAIXE.MaTaiXe=VANCHUYEN.MaTaiXe
									AND XETAI.BienSo=VANCHUYEN.BienSo))