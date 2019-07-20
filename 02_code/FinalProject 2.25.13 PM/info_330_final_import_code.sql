--*************************************************************************--
-- Title: INFO 330 Final - Import Code
-- Author: Alexander Davis
-- Desc: This file is used to create a database for the Final
-- Change Log: When,Who,What
-- 2019-07-17,Davisa88,Created File
-- **************** MILESTONE 03 ****************************************************************
Use InfoFinalDB_Davisa88;

-- 6) Test the views and stored procedures -------------------------------------
-- Creating insert, update, and delete statements with 
DECLARE @Status INT; 
EXEC @Status = uspNewPatient
  @PatientFirstName   = 'Adam',
  @PatientLastName    = 'Davis',
  @PatientPhoneNumber = '(206) 1231234',
  @PatientAddress1    = '456 Main St', 
  @PatientAddress2    = NULL,
  @PatientCity        = 'Seattle',
  @PatientState       = 'WA',
  @PatientZip         = '98105';
SELECT CASE @Status
  WHEN +1 THEN 'Insert Patient was successful!'
  WHEN -1 THEN 'Insert Patient Failed!'
  END AS [Status]
GO

DECLARE @Status INT;
EXEC @Status = uspNewDoctor
  @DoctorFirstName = 'Alex',
  @DoctorLastName  = 'Davis';
SELECT CASE @Status
  WHEN +1 THEN 'Insert Doctor was successful!'
  WHEN -1 THEN 'Insert Doctor Failed!'
  END AS [Status]
GO

DECLARE @Status INT; 
EXEC @Status = uspNewClinic
  @ClinicName    = 'Providence on Cherry Hill',
  @ClinicAddress = '456 Main St', 
  @ClinicCity    = 'Seattle',
  @ClinicState   = 'WA',
  @ClinicZip     = '98105';
SELECT CASE @Status
  WHEN +1 THEN 'Insert Clinic was successful!'
  WHEN -1 THEN 'Insert Clinic Failed!'
  END AS [Status]
GO

DECLARE @Status INT;
EXEC @Status = uspNewAppointment
  @PatientID = 1,
  @DoctorID  = 1,
  @ClinicID  = 1,
  @AppointmentDate  = '2019-07-16 09:30';
SELECT CASE @Status
  WHEN +1 THEN 'Insert Appointment was successful!'
  WHEN -1 THEN 'Insert Appointment Failed!'
  END AS [Status]
GO

DECLARE @Status INT; 
EXEC @Status = uspUpdateAppointment
  @AppointmentID   = 1,
  @DoctorID        = 1,
  @PatientID       = 1,
  @ClinicID        = 1,
  @AppointmentDate = '7/12/2019 10:30';
SELECT CASE @Status
  WHEN +1 THEN 'Update Appointment info was successful!'
  WHEN -1 THEN 'Update Appointment info Failed!'
  END AS [Status]
GO

DECLARE @Status INT; 
EXEC @Status = uspUpdateDoctor
  @DoctorID        = 1,
  @DoctorFirstName = 'Alexander',
  @DoctorLastName  = 'Davis';
SELECT CASE @Status
  WHEN +1 THEN 'Update Doctor info was successful!'
  WHEN -1 THEN 'Update Doctor info Failed!'
  END AS [Status]
GO

DECLARE @Status INT; 
EXEC @Status = uspUpdatePatient
  @PatientID          = 1,
  @PatientFirstName   = 'Adam',
  @PatientLastName    = 'Davis',
  @PatientPhoneNumber = '(206) 1231230',
  @PatientAddress1    = '425 W 57th St',
  @PatientAddress2    = NULL,
  @PatientCity        = 'Seattle',
  @PatientState       = 'WA',
  @PatientZip         = '98105'
SELECT CASE @Status
  WHEN +1 THEN 'Update Patient info was successful!'
  WHEN -1 THEN 'Update Patient info Failed!'
  END AS [Status]
GO

DECLARE @Status INT; 
EXEC @Status = uspDeleteAppointment
  @AppID = 1;
SELECT CASE @Status
  WHEN +1 THEN 'Delete appointment was successful!'
  WHEN -1 THEN 'Delete appointment failed!'
  END AS [Status]
GO

DECLARE @Status INT; 
EXEC @Status = uspDeleteDoctor
  @DoctorID = 1;
SELECT CASE @Status
  WHEN +1 THEN 'Doctor was successfully removed!'
  WHEN -1 THEN 'Delete doctor failed!'
  END AS [Status]
GO

DECLARE @Status INT; 
EXEC @Status = uspDeleteClinic
  @ClinicID = 1;
SELECT CASE @Status
  WHEN +1 THEN 'Delete clinic was successful!'
  WHEN -1 THEN 'Delete clinic failed!'
  END AS [Status]
GO

DECLARE @Status INT; 
EXEC @Status = uspDeletePatient
  @PatientID = 1;
SELECT CASE @Status
  WHEN +1 THEN 'Patient was successfully removed!'
  WHEN -1 THEN 'Delete patient failed!'
  END AS [Status]
GO

-- Importing mock data from files
INSERT INTO tblPatient
SELECT * FROM [Davis_temp_FinalDB].[dbo].patient_list
GO

INSERT INTO tblClinic
SELECT * FROM [Davis_temp_FinalDB].[dbo].clinic_list
GO

INSERT INTO tblDoctor
SELECT * FROM [Davis_temp_FinalDB].[dbo].doctor_list
GO

INSERT INTO tblAppointment
SELECT * FROM [Davis_temp_FinalDB].[dbo].appointment_list
GO

-- Testing VIEWS
SELECT * FROM vAppointmentsByPatientsDoctorsAndClinics
GO

SELECT * FROM fPatientsOwnInformation(5)
GO

SELECT * FROM vAllClinicsAndPatients
GO

SELECT * FROM vAllPatients
GO
