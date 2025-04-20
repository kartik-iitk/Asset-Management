USE AssetManagement;
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_return_assets$$
CREATE PROCEDURE sp_return_assets(
  IN p_ActivityId     INT,
  IN p_AssetId        INT,
  IN p_Requestor      INT,
  IN p_ProcessedBy    INT,
  IN p_Quantity       INT,
  IN p_ShortDesc      VARCHAR(100)
)
BEGIN
  START TRANSACTION;
    INSERT INTO ActivityItemTransaction  
      (ActivityId, AssetId, Requestor, ProcessedBy, ActionTaken, ActionDate, Quantity, ShortDescription)  
    VALUES  
      (p_ActivityId, p_AssetId, p_Requestor, p_ProcessedBy, 'Returned', NOW(), p_Quantity, p_ShortDesc);

    UPDATE Asset  
      SET QuantityAvailable = QuantityAvailable + p_Quantity  
    WHERE AssetId = p_AssetId;
  COMMIT;
END$$
DELIMITER ;