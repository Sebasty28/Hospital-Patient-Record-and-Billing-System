--8. Import/Export: CSV billing reports.

SHOW VARIABLES LIKE 'secure_file_priv'; -- To verify the file path

--IMPORT

LOAD DATA INFILE 'C:/wamp64/tmp/billing.csv'
IGNORE INTO TABLE Billing
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(BillingID, AppointmentID, TreatmentID, Quantity, UnitPrice, Discount, 
 TaxRate, TotalAmount, PaymentStatus, PaymentMethod)
SET InsuranceClaimNumber = NULL, PaymentDate = NULL;

--EXPORT

CREATE VIEW vw_BillingExport AS
SELECT 
    b.BillingID,
    b.AppointmentID,
    a.AppointmentDate,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    p.ContactNumber AS PatientPhone,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    dep.DepartmentName,
    t.TreatmentName,
    t.TreatmentCode,
    b.Quantity,
    b.UnitPrice,
    b.Discount,
    b.TaxRate,
    b.TotalAmount,
    b.PaymentStatus,
    b.PaymentDate,
    b.PaymentMethod,
    b.InsuranceClaimNumber
FROM Billing b
JOIN Appointments a ON b.AppointmentID = a.AppointmentID
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Doctors d ON a.DoctorID = d.DoctorID
JOIN Departments dep ON d.DepartmentID = dep.DepartmentID
JOIN Treatments t ON b.TreatmentID = t.TreatmentID
ORDER BY b.BillingID;

--Test Script:
SELECT *
INTO OUTFILE 'C:/wamp64/tmp/billing_report.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
FROM Billing; 