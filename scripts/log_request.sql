-- filepath: d:\IITK\…\scripts\log_request.sql
USE AssetManagement;

DELIMITER $$
CREATE TRIGGER trg_request_after_update
AFTER UPDATE ON Request
FOR EACH ROW
BEGIN
  INSERT INTO RequestLog
    (RequestId, ActionTakenBy, RequestStatus, RequestDescription)
  VALUES
    (OLD.RequestId, USER(), NEW.RequestStatus, 'Status updated');
END$$
DELIMITER ;