--*************************************************************************--
-- Title: INFO 330 Final - Database Code
-- Author: Alexander Davis
-- Desc: This file is used to create a database for the Final
-- Change Log: When,Who,What
-- 2019-07-11,Davisa88,Created File
--**************************************************************************--
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
-- 1) Create the tables & Constraints --------------------------------------------------------
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
-- The appointment table will be described by Doctor, Clinic, Patient and Appointment. 
-- The patient will be able to pick their preferred doctor and clinic
CREATE TABLE [dbo].[tblAppointment]
(
  [AppointmentId]   INT IDENTITY(1,1) PRIMARY KEY NOT NULL, -- Primary Key column, auto increment
  [PatientId]       INTEGER FOREIGN KEY REFERENCES tblPatient (PatientId) NOT NULL,
  [DoctorId]        INTEGER FOREIGN KEY REFERENCES tblDoctor  (DoctorId)  NOT NULL,
  [ClinicID]        INTEGER FOREIGN KEY REFERENCES tblClinic  (ClinicID)  NOT NULL,
  [AppointmentDate] DATETIME NOT NULL
      --CHECK ((GETDATE()) < [AppointmentDate]) This would be a check to not allow appointments to be created in the past
      --But for practicality and this project I am not going to run it
);
GO

--***********************************************************************************************--
-- 3) Create the views ---------------------------------------------------------
CREATE VIEW vAllClinics AS -- View for all available clinic locations
SELECT * FROM [tblClinic]
GO

CREATE VIEW vAllPatients AS -- View for all available patients
SELECT * FROM [tblPatient]
GO

CREATE VIEW vAllDoctors AS -- View for all available patients
SELECT * FROM [tblDoctor]
GO

-- This is a view that ideally patients would use to find their information only...
-- The patient's view should be restricted to their own personal information
CREATE FUNCTION fPatientsOwnInformation(@PatientID INT)
  RETURNS TABLE
  AS
    RETURN(
      SELECT P.PatientId AS 'Patient ID', 
      P.PatientFirstName + ' ' + P.PatientLastName AS 'Patient Name',
      D.DoctorFirstName  + ' ' + D.DoctorLastName  AS 'Doctor',
      A.AppointmentId                              AS 'AppointmentID',
      FORMAT(A.AppointmentDate, 'd', 'en-us')      AS 'Appointment Date',
      CONVERT(TIME, AppointmentDate)               AS 'Time'
      FROM tblAppointment AS A
      JOIN tblPatient     AS P ON A.PatientId = P.PatientId
      JOIN tblClinic      AS C ON A.ClinicId  = C.ClinicId
      JOIN tblDoctor      AS D ON A.DoctorId  = D.DoctorId
      WHERE P.PatientId = @PatientID
    )
GO

CREATE VIEW vAppointmentsByPatientsDoctorsAndClinics AS
SELECT 
  A.AppointmentID                              AS 'Appointment ID',
  FORMAT(A.AppointmentDate, 'd', 'en-us')      AS 'Appointment Date',
  CONVERT(TIME, AppointmentDate)               AS 'Time',
  D.DoctorFirstName  + ' ' + D.DoctorLastName  AS 'Doctor',
  P.PatientFirstName + ' ' + P.PatientLastName AS 'Patient',
  P.PatientAddress1  + ' ' + P.PatientCity + ', ' + P.PatientState + ' ' + P.PatientZip AS 'Patient Address',
  C.ClinicName AS 'Clinic Name',
  C.ClinicAddress    + ' ' + C.ClinicCity  + ', ' + C.ClinicState  + ' ' + C.ClinicZip  AS 'Clinic Address'
  FROM tblAppointment AS A
    JOIN tblPatient     AS P ON A.PatientId = P.PatientId
    JOIN tblClinic      AS C ON A.ClinicId  = C.ClinicId
    JOIN tblDoctor      AS D ON A.DoctorId  = D.DoctorId
GO

--***********************************************************************************************--
-- 4) Create the stored procedures ---------------------------------------------
-- INSERT
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
  @PatientID INTEGER,
  @DoctorID  INTEGER,
  @ClinicID  INTEGER,
  @AppointmentDate  DATETIME
)
AS 
  BEGIN -- Body
  DECLARE @RC int = 0;
    BEGIN TRY   
      BEGIN TRAN    
      -- Transaction Code --
      INSERT INTO tblAppointment(
        [PatientID],
        [DoctorID],
        [ClinicID],
        [AppointmentDate]
      )
      VALUES(
        @PatientID,
        @DoctorID,
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
      WHERE [ClinicID]  = @ClinicID
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
      WHERE PatientId        = @PatientID
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
      UPDATE tblDoctor -- Update Doctor information
      SET
        [DoctorFirstName] = @DoctorFirstName,
        [DoctorLastName]  = @DoctorLastName
      WHERE [DoctorID]    = @DoctorID
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

-- 5) Set the permissions ------------------------------------------------------
DENY SELECT, INSERT, UPDATE, DELETE ON [tblClinic]      TO [Public]
DENY SELECT, INSERT, UPDATE, DELETE ON [tblAppointment] TO [Public]
DENY SELECT, INSERT, UPDATE, DELETE ON [tblDoctor]      TO [Public]
DENY SELECT, INSERT, UPDATE, DELETE ON [tblPatient]     TO [Public]
GRANT SELECT  ON [vAllClinics]           TO [Public]
GRANT SELECT  ON [vAllDoctors]           TO [Public]
GRANT EXECUTE ON uspUpdateAppointment    TO [Public]
GRANT EXECUTE ON uspNewPatient           TO [Public]
GRANT EXECUTE ON uspUpdatePatient        TO [Public]
GRANT EXECUTE ON uspNewAppointment       TO [Public]
GRANT SELECT ON fPatientsOwnInformation  TO [Public]
GRANT SELECT ON vAppointmentsByPatientsDoctorsAndClinics TO [Public]
GO