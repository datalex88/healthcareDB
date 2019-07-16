Use Master;
go

If Exists(Select Name from SysDatabases Where Name = 'Davis_temp_FinalDB')
 Begin 
  Alter Database [Davis_temp_FinalDB] set Single_user With Rollback Immediate;
  Drop Database Davis_temp_FinalDB;
 End
go

Create Database Davis_temp_FinalDB;
go
Use Davis_temp_FinalDB;
go

SELECT * FROM patient_list