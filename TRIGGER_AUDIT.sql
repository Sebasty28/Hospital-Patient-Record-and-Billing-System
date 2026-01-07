--6. Trigger: Audit billing updates/deletes.

DELIMITER $$
CREATE TRIGGER trg_BillingAudit_Update
AFTER UPDATE ON Billing
FOR EACH ROW
BEGIN
    IF OLD.TotalAmount <> NEW.TotalAmount
       OR OLD.PaymentStatus <> NEW.PaymentStatus THEN

        INSERT INTO BillingAudit
        (BillingID, ActionType, OldTotalAmount, NewTotalAmount,
         OldPaymentStatus, NewPaymentStatus, ModifiedBy)
        VALUES
        (OLD.BillingID, 'UPDATE',
         OLD.TotalAmount, NEW.TotalAmount,
         OLD.PaymentStatus, NEW.PaymentStatus,
         USER());
    END IF;
END $$
DELIMITER ;

--Test Script:
-- Test the trigger
UPDATE Billing 
SET PaymentStatus = 'Paid', 
	PaymentMethod = 'Cash',
    PaymentDate = NOW() 
WHERE BillingID = 4009;

-- Add InsuranceClaimNumber to try (Optional) If the the patient have insurance

DELIMITER $$
CREATE TRIGGER trg_BillingAudit_Delete
BEFORE DELETE ON Billing
FOR EACH ROW
BEGIN
    INSERT INTO BillingAudit (BillingID, ActionType, OldTotalAmount, NewTotalAmount,
                             OldPaymentStatus, NewPaymentStatus, ModifiedBy)
    VALUES (OLD.BillingID, 'DELETE', OLD.TotalAmount, NULL,
            OLD.PaymentStatus, NULL, USER());
END $$
DELIMITER ;

--Test Script: 
DELETE FROM Billing WHERE BillingID = 4009;