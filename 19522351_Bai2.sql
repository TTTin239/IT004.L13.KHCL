CREATE DATABASE QLXE
USE QLXE
--XETAI
CREATE TABLE XETAI(
   BienSo char(10) not null,
   MaLoaiXe char(4),
   NgayMua Date,
   SoKm Int,
   constraint pk_xt primary key(BienSo)
)
--LoaiXe
CREATE TABLE LOAIXE(
   MaLoaiXe CHAR(4) not null,
   TenLoaiXe Varchar(20),
   NhaSX Varchar(20),
   TaiTrongXe int,
   NienHanSuDung int,
   constraint pk_lx primary key(MaLoaiXe)
)
--TAIXE
CREATE TABLE TAIXE(
   MaTaiXe Char(4) not null,
   HoTenTaiXe Varchar(50)
   constraint pk_tx primary key(MaTaiXe)
)
--BANGLAI
CREATE TABLE BANGLAI(
   MaBangLai char(4) not null,
   MaTaiXe char(4) not null,
   NgayCap Date,
   LoaiGPLX Varchar(50),
   constraint pk_bl primary key(MaBangLai,MaTaiXe)
)
--VANCHUYEN
CREATE TABLE VANCHUYEN(
   MaChuyen char(4) not null,
   MaTaiXe Char(4) not null,
   BienSo Char(10) not null,
   TaiTrongHang int,
   QuangDuong Int,
   NgayVanChuyen Date,
   constraint pk_vc primary key(MaChuyen)
)
--Khoa ngoai cho bang XETAI
ALTER TABLE XETAI ADD CONSTRAINT fk_xt FOREIGN KEY(MaLoaiXe) REFERENCES LOAIXE(MaLoaiXe)
--Khoa ngoai cho bang BANGLAI
ALTER TABLE BANGLAI ADD CONSTRAINT fk01_bl FOREIGN KEY(MaTaiXe) REFERENCES TAIXE(MaTaiXe)
--Khoa ngoai cho bang VANCHUYEN
ALTER TABLE VANCHUYEN ADD CONSTRAINT fk01_vc FOREIGN KEY(MaTaiXe) REFERENCES TAIXE(MaTaiXe)
ALTER TABLE VANCHUYEN ADD CONSTRAINT fk02_vc FOREIGN KEY(BienSo) REFERENCES TAIXE(BienSo)
--
set dateformat dmy
--Cau2.1:
ALTER TABLE LOAIXE 
ADD CONSTRAINT CHK_NHSD
CHECK (NienHanSuDung<10)
--Cau2.2:
ALTER TABLE XETAI
ADD CONSTRAINT CHK_NM
CHECK (Year(NgayMua)>=2012)
--Cau3.1:
SELECT BienSo, TenLoaiXe, NhaSX, TaiTrongXe, NienHanSuDung
FROM  XETAI, LOAIXE
WHERE (XETAI.MaLoaiXe=LOAIXE.MaLoaiXe)
AND (XETAI.NgayMua like('15/10/2011'))
--Cau3.2:
SELECT TAIXE.MaTaiXe,HoTenTaiXe
FROM TAIXE,BANGLAI
WHERE (TAIXE.MaTaiXe=BANGLAI.MaTaiXe)
AND (LoaiGPLX='D' AND Year(NgayCap)='2013')
--Cau3.3:
SELECT COUNT(MaChuyen)
FROM VANCHUYEN
GROUP BY BienSo
ORDER BY COUNT(MaChuyen) DESC
--Cau3.4:
SELECT BIENSO, MALOAIXE
FROM XETAI
WHERE NOT EXISTS(SELECT *
                 FROM TAIXE
		 WHERE NOT EXISTS(SELECT*
				  FROM VANCHUYEN
                                  WHERE XETAI.BienSo=VANCHUYEN.BienSo
				  AND TAIXE.MaTaiXe =VANCHUYEN.MaTaiXe))