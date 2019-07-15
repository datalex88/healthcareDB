--**********************************************************************************************--
-- Title: INFO330 Final - DATA IMPORT
-- Author: Alexander Davis
-- Desc: This file will fill the database with mock data
-- Change Log: When,Who,What
-- 2019-07-14,Davisa88,Created File
--***********************************************************************************************--
USE InfoFinalDB_Davisa88;
GO
/*
-- Importing mock data from files
INSERT INTO tblPatient
SELECT * FROM patient_list
GO

INSERT INTO tblClinic
SELECT * FROM clinic_list
GO

INSERT INTO tblDoctor
SELECT * FROM doctor_list
GO

-- Creating insert, update, and delete statements with 
-- error feedback
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
  WHEN +1 THEN 'Insert was successful!'
  WHEN -1 THEN 'Insert Failed!'
  END AS [Status]
GO

DECLARE @Status INT; 
EXEC @Status = uspNewDoctor
    @DoctorFirstName = 'Alex',
    @DoctorLastName  = 'Davis';
SELECT CASE @Status
  WHEN +1 THEN 'Insert was successful!'
  WHEN -1 THEN 'Insert Failed!'
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
  WHEN +1 THEN 'Insert was successful!'
  WHEN -1 THEN 'Insert Failed!'
  END AS [Status]
GO

DECLARE @Status INT; 
EXEC @Status = uspNewAppointment
    @PatientFirstName = 'Saundra',
    @PatientLastName  = 'Broek',
    @DoctorFirstName  = 'Jesselyn',
    @DoctorLastName   = 'Oxford',
    @ClinicID         = 7,
    @AppointmentDate  = '2019-07-17 14:30';
SELECT CASE @Status
  WHEN +1 THEN 'Insert was successful!'
  WHEN -1 THEN 'Insert Failed!'
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
  WHEN +1 THEN 'Update was successful!'
  WHEN -1 THEN 'Update Failed!'
  END AS [Status]
GO

DECLARE @Status INT; 
EXEC @Status = uspUpdatePatient
    @PatientID          = 1,
    @PatientFirstName   = 'Adam',
    @PatientLastName    = 'Davis',
    @PatientPhoneNumber = '(206) 1231234',
    @PatientAddress1    = '425 W 57th St',
    @PatientAddress2    = NULL,
    @PatientCity        = 'Seattle',
    @PatientState       = 'WA',
    @PatientZip         = '98105'
SELECT CASE @Status
  WHEN +1 THEN 'Update was successful!'
  WHEN -1 THEN 'Update Failed!'
  END AS [Status]
GO

DECLARE @Status INT; 
EXEC @Status = uspDeleteClinic
    @ClinicID = 1;
SELECT CASE @Status
  WHEN +1 THEN 'Delete was successful!'
  WHEN -1 THEN 'Delete Failed!'
  END AS [Status]
GO

DECLARE @Status INT; 
EXEC @Status = uspDeleteAppointment
    @ClinicID = 1;
SELECT CASE @Status
  WHEN +1 THEN 'Delete was successful!'
  WHEN -1 THEN 'Delete Failed!'
  END AS [Status]
GO
*/

-- View for all appointments for patients/doctors/clinics... All tables joined
CREATE VIEW vAppointmentsByPatientsDoctorsAndClinics AS
SELECT 
    A.AppointmentID                              AS 'Appointment ID',
    FORMAT(A.AppointmentDate, 'd', 'en-us')      AS 'Appointment Date',
    CONVERT(TIME, AppointmentDate)               AS 'Time',
    D.DoctorFirstName  + ' ' + D.DoctorLastName  AS 'Doctor',
    P.PatientFirstName + ' ' + P.PatientLastName AS 'Patient',
    P.PatientAddress1  + ' ' + P.PatientCity + ', ' + P.PatientState + ' ' + P.PatientZip AS 'Patient Address',
    C.ClinicName AS 'Clinic Name',
    C.ClinicAddress + ' ' + C.ClinicCity + ', ' + C.ClinicState + ' ' + C.ClinicZip      AS 'Clinic Address'
FROM tblDoctor D 
    JOIN tblAppointment A ON D.DoctorID      = A.DoctorID
    JOIN tblClinic C      ON A.AppointmentID = C.ClinicID
    JOIN tblPatient P     ON A.PatientID     = P.PatientID
GO

-- All of my views
SELECT * FROM vAppointmentsByPatientsDoctorsAndClinics
GO

SELECT * FROM vAllClinics
GO

SELECT * FROM vAllDoctors
GO

SELECT * FROM vAllPatients
GO