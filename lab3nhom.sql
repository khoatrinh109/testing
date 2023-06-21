/*---------------------------------------------------------- 
MASV: 46.01.104.024 - 43.01.104.080 - 46.01.104.001 - 46.01.104.154 - 46.01.104.214
HO TEN CAC THANH VIEN NHOM: Phạm Trọng Đạt, Trịnh Anh Khoa, Nguyễn Quốc An, Trương Quang Sinh, Bùi Thị Ánh Tuyết
LAB: 03 - NHOM 
NGAY: 27/03/2023
----------------------------------------------------------*/ 
--CAU LENH TAO DB

USE master
GO
CREATE DATABASE QLSVNhom
GO
USE QLSVNhom
GO

--CAC CAU LENH TAO TABLE 

USE QLSVNhom
GO

--drop table sinhvien
create table SINHVIEN
(
	MASV		VARCHAR(20),
	HOTEN		NVARCHAR(100)		NOT NULL,
	NGAYSINH	DATETIME,
	DIACHI		NVARCHAR(200),
	MALOP		VARCHAR(20),
	TENDN		NVARCHAR(100)		NOT NULL,
	MATKHAU		VARBINARY(MAX)		NOT NULL,
	
	PRIMARY KEY(MASV)
)
--drop table nhanvien
create table NHANVIEN
(
	MANV	VARCHAR(20),
	HOTEN	NVARCHAR(100)	NOT NULL,
	EMAIL	VARCHAR(20),
	LUONG	VARBINARY(MAX),
	TENDN	NVARCHAR(100)	NOT NULL,
	MATKHAU	VARBINARY(MAX)		NOT NULL,
	PUBKEY	VARCHAR(20),

	PRIMARY KEY(MANV)
)
--drop table lop
create table LOP
(
	MALOP	VARCHAR(20),
	TENLOP	NVARCHAR(100)	NOT NULL,
	MANV	VARCHAR(20),

	PRIMARY KEY(MALOP)
)

--drop table hocphan
create table HOCPHAN
(
	MAHP	VARCHAR(20),
	TENHP	NVARCHAR(100)	NOT NULL,
	SOTC	INT,

	PRIMARY KEY(MAHP)
)

--drop table bangdiem
create table BANGDIEM
(
	MASV	VARCHAR(20),
	MAHP	VARCHAR(20),
	DIEMTHI	VARBINARY(MAX),

	PRIMARY KEY(MASV, MAHP)
)

ALTER TABLE BANGDIEM ADD FOREIGN KEY(MASV) REFERENCES SINHVIEN(MASV);
ALTER TABLE BANGDIEM ADD FOREIGN KEY(MAHP) REFERENCES HOCPHAN(MAHP);
ALTER TABLE SINHVIEN ADD FOREIGN KEY(MALOP) REFERENCES LOP(MALOP);
ALTER TABLE LOP ADD FOREIGN KEY(MANV) REFERENCES NHANVIEN(MANV);
-- CAU LENH TAO STORED PROCEDURE


use QLSVNhom
go

/*---------------------------------------------------------- 
MASV: 46.01.104.024 - 43.01.104.080 - 46.01.104.001 - 46.01.104.154 - 46.01.104.214
HO TEN CAC THANH VIEN NHOM: Phạm Trọng Đạt, Trịnh Anh Khoa, Nguyễn Quốc An, Trương Quang Sinh, Bùi Thị Ánh Tuyết
LAB: 03 - NHOM 
NGAY: 27/03/2023
----------------------------------------------------------*/ 

ALTER DATABASE QLSVNhom
SET COMPATIBILITY_LEVEL = 120

--DROP procedure SP_INS_PUBLIC_NHANVIEN



create proc SP_INS_PUBLIC_NHANVIEN
(
	@MANV varchar(20),
	@HOTEN nvarchar(100),
	@EMAIL varchar(20),
	@LUONG int,
	@TENDN nvarchar(100),
	@MK varchar(32)
)
As
	Begin
		DECLARE @AKEY nvarchar(max)
		DECLARE @PUBKEY varchar(20)
		SET @PUBKEY = @MANV
		SET @AKEY=
			'CREATE ASYMMETRIC KEY '+@MANV+' WITH ALGORITHM = RSA_2048 ENCRYPTION BY PASSWORD = ''' +@MK + ''''
		exec(@AKEY)
		DECLARE @EnPass varbinary(max);
		DECLARE @EnWage varbinary(max);
		SET @EnPass=CONVERT(varbinary, HashBytes('SHA1',@MK));
		SET @EnWage = ENCRYPTBYASYMKEY(ASYMKEY_ID(@PUBKEY), CONVERT(varbinary(MAX), @LUONG))

		insert into NHANVIEN(MANV,HOTEN,EMAIL,LUONG,TENDN,MATKHAU,PUBKEY)
		values (@MANV, @HOTEN, @EMAIL, @EnWage, @TENDN,@EnPass,@PUBKEY);
	END
GO

EXEC SP_INS_PUBLIC_NHANVIEN 'NV03', 'NGUYEN VAN C', 'NVC@', 5000000, 'NVC', 'abcd12'
EXEC SP_INS_PUBLIC_NHANVIEN 'NV04', 'NGUYEN VAN D', 'NVD@', 3000000, 'NVD', 'abcd12'
SELECT *  FROM NHANVIEN where MANV='NV03' or MANV='NV04'
go
create procedure SP_SEL_PUBLIC_NHANVIEN
(
	@TENDN nvarchar(100),
	@MK varchar(32)
)
As
	Begin
		DECLARE @OUTPUT nvarchar(max)
		SET @OUTPUT=
		'SELECT MANV,HOTEN,EMAIL, CONVERT(int, DECRYPTBYASYMKEY(ASYMKEY_ID(PUBKEY),LUONG,N'''+@MK+'''))
		as LUONGCB FROM NHANVIEN WHERE TENDN = N'''+@TENDN+''''		
		exec (@OUTPUT)
	END
GO	 	 
exec SP_SEL_PUBLIC_NHANVIEN  'NVC', 'abcd12'
exec SP_SEL_PUBLIC_NHANVIEN  'NVD', 'abcd12'
--DROP asymmetric key NV04


use QLSVNhom
go

-------

insert into nhanvien(MANV, HOTEN, EMAIL, LUONG, TENDN, MATKHAU, PUBKEY)
values	('NV01','NGUYEN VAN A','nva@yahoo.com',convert(varbinary,3000000),'NVA',convert(varbinary,'123456'),'NV01'),
		('NV02','NGUYEN VAN B','nvb@yahoo.com',convert(varbinary,2000000),'NVB',convert(varbinary,'1234567'),'NV02')
go

select * from nhanvien

insert into LOP(MALOP, TENLOP, MANV)
values	('CNTTA',N'Công nghệ thông tin','NV01'),
('CNTTB',N'Công nghệ thông tin','NV02')
go

select * from lop

insert into SINHVIEN(MASV,HOTEN,NGAYSINH,DIACHI, MALOP, TENDN, MATKHAU)
VALUES	('4601104024',N'Phạm Trọng Đạt','1/1/1999',N'HCM','CNTTA','4601104024',convert(varbinary,'mk')),
		('4301104080',N'Trịnh Anh Khoa','1/1/1999',N'HCM','CNTTB','4301104080',convert(varbinary,'mk'))

select * from sinhvien

insert into HOCPHAN(MAHP, TENHP, SOTC)
VALUES	('TRR', N'Toán rời rạc',2),
		('CTDL',N'Cấu trúc dữ liệu và giải thuật',4),
		('CSDL',N'Cơ sở dữ liệu',3),
		('LTCB',N'Lập trình cơ bản',3),
		('LTNC',N'Lập trình nâng cao',3)
go

select * from hocphan

insert into BANGDIEM(MASV,MAHP,DIEMTHI)
VALUES	('4301104080','CTDL',convert(varbinary,10)),
		('4601104024','TRR',convert(varbinary,5))

select * from BANGDIEM