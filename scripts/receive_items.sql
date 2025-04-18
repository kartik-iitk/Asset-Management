USE AssetManagement;
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_receive_items$$
CREATE PROCEDURE sp_receive_items(
  IN p_POId           INT,
  IN p_StorageLoc     VARCHAR(100),
  IN p_ShortDesc      VARCHAR(100)
)
BEGIN
  START TRANSACTION;
    -- 1) mark PO received
    UPDATE PurchaseOrder  
      SET POStatus='Received', DateModified=NOW()  
    WHERE POId = p_POId;

    -- 2) for each POItem, insert into Asset
    INSERT INTO Asset (LabId, ItemId, SerialNo, QuantityAvailable, StorageLocation, ShortDescription)  
    SELECT L.LabId, PI.ItemId, CONCAT('PO',p_POId,'-',PI.POItemId),
           PI.QuantityOrdered, p_StorageLoc, p_ShortDesc
    FROM POItem PI  
    JOIN PurchaseOrder PO USING (POId)  
    JOIN LabActivity LA ON LA.ActivityId=PO.ActivityId  
    JOIN Lab L ON L.LabId=LA.LabId  
    WHERE PI.POId = p_POId;

    -- 3) close the PO
    UPDATE PurchaseOrder  
      SET POStatus='Closed', DateModified=NOW()  
    WHERE POId = p_POId;
  COMMIT;
END$$
DELIMITER ;