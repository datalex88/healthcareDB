--**********************************************************************************************--
-- Title: INFO330 Final - Database Code
-- Author: Alexander Davis
-- Desc: This file creates the final project Database for a health clinic that
--       stores patient, doctor, locaiton and appointment information
-- Change Log: When,Who,What
-- 2019-07-11,Davisa88,Created File
--***********************************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'InfoFinalDB_Davisa88')
	 Begin 
	  Alter Database [InfoFinalDB_Davisa88] set Single_user With Rollback Immediate;
	  Drop Database InfoFinalDB_Davisa88;
	 End
	Create Database InfoFinalDB_Davisa88;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use InfoFinalDB_Davisa88;

--***********************************************************************************************--
-- Creating Tables
-- Create a new table called '[tblPatient]' in schema '[dbo]'
CREATE TABLE [dbo].[tblPatient]
(
    [PatientId]          INT IDENTITY(1,1) PRIMARY KEY NOT NULL, -- Primary Key column, auto increment
    [PatientFirstName]   NVARCHAR(50)      NOT NULL,
    [PatientLastName]    NVARCHAR(50)      NOT NULL,
    [PatientPhoneNumber] NVARCHAR(50)      NOT NULL,
    [PatientAddress1]    NVARCHAR(50)      NOT NULL,
    [PatientAddress2]    NVARCHAR(50)      NULL,
    [PatientCity]        NVARCHAR(50)      NOT NULL,
    [PatientState]       NVARCHAR(2)       NOT NULL,
    [PatientZip]         NVARCHAR(5)       NOT NULL,
        CHECK ([PatientZip] LIKE '[0-9][0-9][0-9][0-9][0-9]'),
        UNIQUE ([PatientPhoneNumber])
);
GO

-- Create a new table called '[tblDoctor]' in schema '[dbo]'
CREATE TABLE [dbo].[tblDoctor]
(
    [DoctorId]        INT IDENTITY(1,1) PRIMARY KEY NOT NULL, -- Primary Key column, auto increment
    [DoctorFirstName] NVARCHAR(50)      NOT NULL,
    [DoctorLastName]  NVARCHAR(50)      NOT NULL
);
GO

-- Create a new table called '[tblClinic]' in schema '[dbo]'
CREATE TABLE [dbo].[tblClinic]
(
    [ClinicID]      INT IDENTITY(1,1) PRIMARY KEY NOT NULL, -- Primary Key column, auto increment
    [ClinicName]    NVARCHAR(50)      NOT NULL,
    [ClinicAddress] NVARCHAR(50)      NOT NULL,
    [ClinicCity]    NVARCHAR(50)      NOT NULL,
    [ClinicState]   NVARCHAR(2)       NOT NULL,
    [ClinicZip]     NVARCHAR(5)       NOT NULL,
        CHECK  ([ClinicZip] LIKE '[0-9][0-9][0-9][0-9][0-9]'),
        UNIQUE ([ClinicName])
);
GO

-- Create a new table called '[tblAppointment]' in schema '[dbo]'
CREATE TABLE [dbo].[tblAppointment]
(
    [AppointmentId]   INT IDENTITY(1,1) PRIMARY KEY NOT NULL, -- Primary Key column, auto increment
    [PatientId]       INTEGER FOREIGN KEY REFERENCES tblPatient (PatientId) NOT NULL,
    [DoctorId]        INTEGER FOREIGN KEY REFERENCES tblDoctor  (DoctorId)  NOT NULL,
    [ClinicID]        INTEGER FOREIGN KEY REFERENCES tblClinic  (ClinicID)  NOT NULL,
    [AppointmentDate] DATETIME NOT NULL,
        --CHECK ((GETDATE()) < [AppointmentDate]) This would be a check to not allow appointments to be created in the past
        -- But for practicality and this project I am not going to run it
);
GO

--***********************************************************************************************--
-- Views
CREATE VIEW vAllClinics AS -- View for all available clinic locations
SELECT * FROM [tblClinic]
GO

CREATE VIEW vAllPatients AS -- View for all available patients
SELECT * FROM [tblPatient]
GO

CREATE VIEW vAllDoctors AS -- View for all available doctors
SELECT * FROM [tblDoctor]
GO

--***********************************************************************************************--
-- Stored procedures -- INSERT
/* Author: Davisa88
Desc: Processes This will insert a new Clinic value in the Clinic table
Change Log: When,Who,What** 
<2019-07-11>,<Alex Davis>,Created Sproc.*/
CREATE PROCEDURE uspNewClinic (
    @ClinicName    NVARCHAR(100),
    @ClinicAddress NVARCHAR(100),
    @ClinicCity    NVARCHAR(100),
    @ClinicState   NVARCHAR(2),
    @ClinicZip     NVARCHAR(5)
)
  AS 
    BEGIN -- Body
    DECLARE @RC int = 0;
      BEGIN TRY   
        BEGIN TRAN    
        -- Transaction Code --
        INSERT INTO tblClinic(
            [ClinicName],    
            [ClinicAddress], 
            [ClinicCity],    
            [ClinicState],   
            [ClinicZip]     
        )
        VALUES(
            @ClinicName,
            @ClinicAddress,
            @ClinicCity,
            @ClinicState,
            @ClinicZip
        )
        COMMIT TRAN 
        SET @RC = +1;
      END TRY  
    BEGIN CATCH   
      IF(@@Trancount > 0) 
        ROLLBACK TRAN;   
        PRINT Error_Message();
        SET @RC = -1; 
    END CATCH  
    RETURN @RC;
    END -- Body
GO

/* Author: Davisa88
Desc: Processes This will insert a new Patient value in the Patient table
Change Log: When,Who,What** 
<2019-07-11>,<Alex Davis>,Created Sproc.*/
CREATE PROCEDURE uspNewPatient (
    @PatientFirstName   NVARCHAR(50),
    @PatientLastName    NVARCHAR(50),
    @PatientPhoneNumber NVARCHAR(50),
    @PatientAddress1    NVARCHAR(50),
    @PatientAddress2    NVARCHAR(50),
    @PatientCity        NVARCHAR(50),
    @PatientState       NVARCHAR(2),
    @PatientZip         NVARCHAR(5)
)
  AS 
    BEGIN -- Body
    DECLARE @RC int = 0;
      BEGIN TRY   
        BEGIN TRAN    
        -- Transaction Code --
        INSERT INTO tblPatient(
            [PatientFirstName],
            [PatientLastName],
            [PatientPhoneNumber],
            [PatientAddress1],
            [PatientAddress2],
            [PatientCity],
            [PatientState],
            [PatientZip]        
            )
        VALUES(
            @PatientFirstName,
            @PatientLastName,
            @PatientPhoneNumber,
            @PatientAddress1,
            @PatientAddress2,
            @PatientCity,
            @PatientState,
            @PatientZip         
        )
        COMMIT TRAN 
        SET @RC = +1;
      END TRY  
    BEGIN CATCH   
      IF(@@Trancount > 0) 
        ROLLBACK TRAN;   
        PRINT Error_Message();
        SET @RC = -1; 
    END CATCH  
    RETURN @RC;
    END -- Body
GO

/* Author: Davisa88
Desc: Processes This will insert a new Appointment value in the Appointment table
Change Log: When,Who,What** 
<2019-07-11>,<Alex Davis>,Created Sproc.*/
CREATE PROCEDURE uspNewAppointment (
    @PatientFirstName NVARCHAR(50),
    @PatientLastName  NVARCHAR(50),
    @DoctorFirstName  NVARCHAR(50),
    @DoctorLastName   NVARCHAR(50),
    @ClinicID           INTEGER,
    @AppointmentDate  DATETIME
)
  AS 
    BEGIN -- Body
    DECLARE @RC int = 0,
    @Patient_ID INTEGER,
    @Doctor_ID  INTEGER;
      BEGIN TRY   
        BEGIN TRAN    
        SET @Patient_ID = (SELECT PatientID
                            FROM tblPatient
                            WHERE PatientFirstName LIKE @PatientFirstName
                            AND PatientLastName    LIKE @PatientLastName
                            )
        SET @Doctor_ID = (SELECT DoctorID
                            FROM tblDoctor
                            WHERE DoctorFirstName LIKE @DoctorFirstName
                            AND DoctorLastName    LIKE @DoctorLastName
                    )
        -- Transaction Code --
        INSERT INTO tblAppointment(
            [PatientID],
            [DoctorID],
            [ClinicID],
            [AppointmentDate]
            )
        VALUES(
            @Patient_ID,
            @Doctor_ID,
            @ClinicID,
            @AppointmentDate
        )
        COMMIT TRAN 
        SET @RC = +1;
      END TRY  
    BEGIN CATCH   
      IF(@@Trancount > 0) 
        ROLLBACK TRAN;   
        PRINT Error_Message();
        SET @RC = -1; 
    END CATCH  
    RETURN @RC;
    END -- Body
GO

/* Author: Davisa88
Desc: Processes This will insert a new Doctor value in the doctor table
Change Log: When,Who,What** 
<2019-07-11>,<Alex Davis>,Created Sproc.*/
CREATE PROCEDURE uspNewDoctor (
    @DoctorFirstName   NVARCHAR(50),
    @DoctorLastName    NVARCHAR(50)
)
  AS 
    BEGIN -- Body
    DECLARE @RC int = 0;
      BEGIN TRY   
        BEGIN TRAN    
        -- Transaction Code --
        INSERT INTO tblDoctor(
            [DoctorFirstName],
            [DoctorLastName]
            )
        VALUES(
            @DoctorFirstName,
            @DoctorLastName
        )
        COMMIT TRAN 
        SET @RC = +1;
      END TRY  
    BEGIN CATCH   
      IF(@@Trancount > 0) 
        ROLLBACK TRAN;   
        PRINT Error_Message();
        SET @RC = -1; 
    END CATCH  
    RETURN @RC;
    END -- Body
GO

-- Stored procedures -- UPDATE

/* Author: Davisa88
Desc: Processes This will update a Clinic value in the clinic table
Change Log: When,Who,What** 
<2019-07-11>,<Alex Davis>,Created Sproc.*/
CREATE PROCEDURE uspUpdateClinic (
    @ClinicID      INTEGER,
    @ClinicName    NVARCHAR(100),
    @ClinicAddress NVARCHAR(100),
    @ClinicCity    NVARCHAR(100),
    @ClinicState   NVARCHAR(2),
    @ClinicZip     NVARCHAR(5)
)
  AS 
    BEGIN -- Body
    DECLARE @RC int = 0;
      BEGIN TRY   
        BEGIN TRAN    
        -- Transaction Code --
        UPDATE tblClinic
        SET
            [ClinicName]    = @ClinicName,    
            [ClinicAddress] = @ClinicAddress, 
            [ClinicCity]    = @ClinicCity,    
            [ClinicState]   = @ClinicState,   
            [ClinicZip]     = @ClinicZip   
        WHERE [ClinicID] = @ClinicID
        COMMIT TRAN 
        SET @RC = +1;
      END TRY  
    BEGIN CATCH   
      IF(@@Trancount > 0) 
        ROLLBACK TRAN;   
        PRINT Error_Message();
        SET @RC = -1; 
    END CATCH  
    RETURN @RC;
    END -- Body
GO

/* Author: Davisa88
Desc: Processes This will update a Patient value in the Patient table
Change Log: When,Who,What** 
<2019-07-11>,<Alex Davis>,Created Sproc.*/
CREATE PROCEDURE uspUpdatePatient (
    @PatientID          INTEGER,
    @PatientFirstName   NVARCHAR(50),
    @PatientLastName    NVARCHAR(50),
    @PatientPhoneNumber NVARCHAR(50),
    @PatientAddress1    NVARCHAR(50),
    @PatientAddress2    NVARCHAR(50),
    @PatientCity        NVARCHAR(50),
    @PatientState       NVARCHAR(2),
    @PatientZip         NVARCHAR(5)
)
  AS 
    BEGIN -- Body
    DECLARE @RC int = 0;
      BEGIN TRY   
        BEGIN TRAN    
        -- Transaction Code --
        UPDATE tblPatient
        SET
            [PatientFirstName]   = @PatientFirstName,
            [PatientLastName]    = @PatientLastName,
            [PatientPhoneNumber] = @PatientPhoneNumber,
            [PatientAddress1]    = @PatientAddress1,
            [PatientAddress2]    = @PatientAddress2,
            [PatientCity]        = @PatientCity,
            [PatientState]       = @PatientState,
            [PatientZip]         = @PatientZip        
        WHERE PatientId = @PatientID
        COMMIT TRAN 
        SET @RC = +1;
      END TRY  
    BEGIN CATCH   
      IF(@@Trancount > 0) 
        ROLLBACK TRAN;   
        PRINT Error_Message();
        SET @RC = -1; 
    END CATCH  
    RETURN @RC;
    END -- Body
GO

/* Author: Davisa88
Desc: Processes This will update an Appointment value in the Appointment table
Change Log: When,Who,What** 
<2019-07-11>,<Alex Davis>,Created Sproc.*/
CREATE PROCEDURE uspUpdateAppointment (
    @AppointmentID   INTEGER,
    @DoctorID        INTEGER,
    @PatientID       INTEGER,
    @ClinicID        INTEGER,
    @AppointmentDate DATETIME
)
  AS 
    BEGIN -- Body
    DECLARE @RC int = 0;
      BEGIN TRY   
        BEGIN TRAN    
        -- Transaction Code --
        UPDATE tblAppointment
        SET
            [PatientID]       = @PatientID,
            [DoctorID]        = @DoctorID,
            [ClinicID]        = @ClinicID,
            [AppointmentDate] = @AppointmentDate
        WHERE AppointmentId = @AppointmentID
        COMMIT TRAN 
        SET @RC = +1;
      END TRY  
    BEGIN CATCH   
      IF(@@Trancount > 0) 
        ROLLBACK TRAN;   
        PRINT Error_Message();
        SET @RC = -1; 
    END CATCH  
    RETURN @RC;
    END -- Body
GO

/* Author: Davisa88
Desc: Processes This will update a Doctor value in the Doctor table
Change Log: When,Who,What** 
<2019-07-11>,<Alex Davis>,Created Sproc.*/
CREATE PROCEDURE uspUpdateDoctor (
    @DoctorID        INTEGER,
    @DoctorFirstName NVARCHAR(50),
    @DoctorLastName  NVARCHAR(50)
)
  AS 
    BEGIN -- Body
    DECLARE @RC int = 0;
      BEGIN TRY   
        BEGIN TRAN    
        -- Transaction Code --
        UPDATE tblDoctor
        SET
            [DoctorFirstName] = @DoctorFirstName,
            [DoctorLastName]  = @DoctorLastName
        WHERE [DoctorID] = @DoctorID
        COMMIT TRAN 
        SET @RC = +1;
      END TRY  
    BEGIN CATCH   
      IF(@@Trancount > 0) 
        ROLLBACK TRAN;   
        PRINT Error_Message();
        SET @RC = -1; 
    END CATCH  
    RETURN @RC;
    END -- Body
GO

-- Stored procedures -- DELETE

/* Author: Davisa88
Desc: Processes This will DELETE a Clinic value in the clinic table
Change Log: When,Who,What** 
<2019-07-11>,<Alex Davis>,Created Sproc.*/
CREATE PROCEDURE uspDeleteClinic (@ClinicID INTEGER)
  AS 
    BEGIN -- Body
    DECLARE @RC int = 0;
      BEGIN TRY   
        BEGIN TRAN    
        -- Transaction Code --
        DELETE FROM tblClinic
        WHERE ClinicID = @ClinicID
        COMMIT TRAN 
        SET @RC = +1;
      END TRY  
    BEGIN CATCH   
      IF(@@Trancount > 0) 
        ROLLBACK TRAN;   
        PRINT Error_Message();
        SET @RC = -1; 
    END CATCH  
    RETURN @RC;
    END -- Body
GO

/* Author: Davisa88
Desc: Processes This will DELETE a new patient value in the patient table
Change Log: When,Who,What** 
<2019-07-11>,<Alex Davis>,Created Sproc.*/
CREATE PROCEDURE uspDeletePatient (@PatientID INTEGER)
  AS 
    BEGIN -- Body
    DECLARE @RC int = 0;
      BEGIN TRY   
        BEGIN TRAN    
        -- Transaction Code --
        DELETE FROM tblPatient
        WHERE PatientID = @PatientID
        COMMIT TRAN 
        SET @RC = +1;
      END TRY  
    BEGIN CATCH   
      IF(@@Trancount > 0) 
        ROLLBACK TRAN;   
        PRINT Error_Message();
        SET @RC = -1; 
    END CATCH  
    RETURN @RC;
    END -- Body
GO

/* Author: Davisa88
Desc: Processes This will DELETE a new Doctor value in the Doctor table
Change Log: When,Who,What** 
<2019-07-11>,<Alex Davis>,Created Sproc.*/
CREATE PROCEDURE uspDeleteDoctor (@DoctorID INTEGER)
  AS 
    BEGIN -- Body
    DECLARE @RC int = 0;
      BEGIN TRY   
        BEGIN TRAN    
        -- Transaction Code --
        DELETE FROM tblDoctor
        WHERE DoctorID = @DoctorID
        COMMIT TRAN 
        SET @RC = +1;
      END TRY  
    BEGIN CATCH   
      IF(@@Trancount > 0) 
        ROLLBACK TRAN;   
        PRINT Error_Message();
        SET @RC = -1; 
    END CATCH  
    RETURN @RC;
    END -- Body
GO

/* Author: Davisa88
Desc: Processes This will DELETE an Appointment value in the Appointment table
Change Log: When,Who,What** 
<2019-07-11>,<Alex Davis>,Created Sproc.*/
CREATE PROCEDURE uspDeleteAppointment (@AppID INTEGER)
  AS 
    BEGIN -- Body
    DECLARE @RC int = 0;
      BEGIN TRY   
        BEGIN TRAN    
        -- Transaction Code --
        DELETE FROM tblAppointment
        WHERE AppointmentId = @AppID
        COMMIT TRAN 
        SET @RC = +1;
      END TRY  
    BEGIN CATCH   
      IF(@@Trancount > 0) 
        ROLLBACK TRAN;   
        PRINT Error_Message();
        SET @RC = -1; 
    END CATCH  
    RETURN @RC;
    END -- Body
GO