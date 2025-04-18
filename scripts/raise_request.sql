USE AssetManagement;
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_raise_request$$
CREATE PROCEDURE sp_raise_request(
  IN p_ActivityId  INT,
  IN p_Requestor   INT
)
BEGIN
  START TRANSACTION;
    INSERT INTO Request  
      (ActivityID, RequestDate, Requestor, RequestStatus)  
    VALUES  
      (p_ActivityId, NOW(), p_Requestor, 'Generated');
  COMMIT;
END$$
DELIMITER ;