USE AssetManagement;
DROP TRIGGER IF EXISTS trg_request_after_insert;
DELIMITER $$

CREATE TRIGGER trg_request_after_insert
  AFTER INSERT ON Request
  FOR EACH ROW
BEGIN
  INSERT INTO RequestLog
    (RequestId, ActionTakenBy, RequestStatus, RequestDescription)
  VALUES
    (NEW.RequestId, USER(), NEW.RequestStatus, 'Request created');
END$$

CREATE TRIGGER trg_request_after_update
AFTER UPDATE ON Request
FOR EACH ROW
BEGIN
  IF OLD.RequestStatus <> NEW.RequestStatus THEN
    INSERT INTO RequestLog
      (RequestId, ActionTakenBy, RequestStatus, RequestDescription)
    VALUES
      (NEW.RequestId, USER(), NEW.RequestStatus, CONCAT('Status changed from ',OLD.RequestStatus,' to ',NEW.RequestStatus));
  END IF;
END$$

DELIMITER ;