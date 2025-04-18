USE AssetManagement;
BEGIN;
INSERT INTO Users
  (UserName, UserPassword, InstituteId, FirstName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, IsActive)
VALUES
  (@u, @p, @i, @f, @l, @g, @d, @e, @c, @a, @app, @act);
COMMIT;