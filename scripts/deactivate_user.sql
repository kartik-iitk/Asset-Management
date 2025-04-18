USE AssetManagement;

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_deactivate_user$$
CREATE PROCEDURE sp_deactivate_user(
  IN p_UserId INT
)
BEGIN
  START TRANSACTION;
    UPDATE Users
      SET IsActive     = FALSE,
          DateModified = NOW()
    WHERE UserId = p_UserId;
  COMMIT;
END$$
DELIMITER ;



