--7. View: Monthly revenue summary.

CREATE VIEW vw_MonthlyRevenueSummary AS
SELECT 
    YEAR(a.AppointmentDate) AS Year,
    MONTH(a.AppointmentDate) AS Month,
    DATE_FORMAT(a.AppointmentDate, '%Y-%m') AS YearMonth,
    MONTHNAME(a.AppointmentDate) AS MonthName,
    COUNT(DISTINCT b.BillingID) AS TotalBills,
    COUNT(DISTINCT a.AppointmentID) AS TotalAppointments,
    COUNT(DISTINCT a.PatientID) AS UniquePatients,
    SUM(b.TotalAmount) AS TotalRevenue,
    SUM(CASE WHEN b.PaymentStatus = 'Paid' THEN b.TotalAmount ELSE 0 END) AS PaidRevenue,
    SUM(CASE WHEN b.PaymentStatus = 'Unpaid' THEN b.TotalAmount ELSE 0 END) AS UnpaidRevenue,
    SUM(CASE WHEN b.PaymentStatus = 'Partial' THEN b.TotalAmount ELSE 0 END) AS PartialRevenue,
    AVG(b.TotalAmount) AS AverageBillAmount
FROM Appointments a
JOIN Billing b ON a.AppointmentID = b.AppointmentID
GROUP BY YEAR(a.AppointmentDate), MONTH(a.AppointmentDate), DATE_FORMAT(a.AppointmentDate, '%Y-%m'), 
         MONTHNAME(a.AppointmentDate)
ORDER BY Year DESC, Month DESC;

Test Script: 
SELECT * FROM vw_MonthlyRevenueSummary;

-- Query: Get Unpaid Balances by Patient (Subquery)
DELIMITER $$
CREATE PROCEDURE sp_GetUnpaidBalances()
BEGIN
    SELECT 
        p.PatientID,
        CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
        p.ContactNumber,
        p.Email,
        (SELECT SUM(b.TotalAmount) 
         FROM Billing b
         JOIN Appointments a ON b.AppointmentID = a.AppointmentID
         WHERE a.PatientID = p.PatientID 
         AND b.PaymentStatus = 'Unpaid') AS UnpaidBalance,
        (SELECT COUNT(*) 
         FROM Billing b
         JOIN Appointments a ON b.AppointmentID = a.AppointmentID
         WHERE a.PatientID = p.PatientID 
         AND b.PaymentStatus = 'Unpaid') AS UnpaidBills
    FROM Patients p
    WHERE EXISTS (
        SELECT 1 
        FROM Billing b
        JOIN Appointments a ON b.AppointmentID = a.AppointmentID
        WHERE a.PatientID = p.PatientID 
        AND b.PaymentStatus = 'Unpaid'
    )
    ORDER BY UnpaidBalance DESC;
END $$
DELIMITER ;

--Test Script:
CALL subquery_GetUnpaidBalances();

--ADDITIONAL VIEW

--View: Doctor Performance Report
CREATE VIEW vw_DoctorPerformance AS
SELECT 
    d.DoctorID,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    d.Specialization,
    dep.DepartmentName,
    COUNT(DISTINCT a.AppointmentID) AS TotalAppointments,
    COUNT(DISTINCT a.PatientID) AS UniquePatients,
    SUM(b.TotalAmount) AS TotalRevenueGenerated,
    AVG(b.TotalAmount) AS AverageRevenuePerAppointment,
    SUM(CASE WHEN a.Status = 'Completed' THEN 1 ELSE 0 END) AS CompletedAppointments,
    SUM(CASE WHEN a.Status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledAppointments
FROM Doctors d
JOIN Departments dep ON d.DepartmentID = dep.DepartmentID
LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
LEFT JOIN Billing b ON a.AppointmentID = b.AppointmentID
WHERE d.IsActive = 1
GROUP BY d.DoctorID, d.FirstName, d.LastName, d.Specialization, dep.DepartmentName
ORDER BY TotalRevenueGenerated DESC;

--Test Script:
SELECT * FROM vw_doctorperformance;


