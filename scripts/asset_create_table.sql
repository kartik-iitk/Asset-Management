/*  
  For an Activity funds will be allocated 
  Accordingly, the available lab funds will be updated and data will be logged.
  Step: 
    1) Activity will be created
    2) To carry out activity using some items are required.
       Here if the item required is not listed (unknown) in Item table, 
       then new item is first created in Item. 
    3) Request will be created for the user (Student/individual). 
    4) The list will be reviewed and will be approved/ rejected
    5) After the approval, the available items will be issued for that activity.
       Asset inventory will be updated and data will be logged.
    6) For the items which are not available or not listed (unknown), 
       then purchase order (PO) will be created against the activity FundsAvailable.
    7) After approval for the PO, when the items are received, 
       the PO will be closed, Activity FundsAvailable will be updated also the data will be logged.
       Multiple PO can be made as per requirement against activity FundsAvailable.  
    8) The received items will be added in Asset table with quantity and serial number will be assigned to it.
    9) These item then will be issued for the Activity to user who requested and the request will be closed.
   10) Once the activity is complete, 
       Item will be returned by Student and accordingly asset inventory will be updated for quantity. 
       The balance FundsAvailable of activity will be refunded (moved/added to lab FundsAvailable)
       The activity will be closed (IsClosed will be set to 1)
  
  Assumption:
    1) User table will have records of application users (username, password) as well as student to whom items are issued
       Currently, Students data will be maintained but they will not log in system. 
       (If access is given then they can only create request)
    2) Currently, Prices of the item is not considered in Item table. 
       If it has to included then for the cost changes, we will need to add log to maintain history of prices for that item, 
       so that correspondingly every project/activity will have the correct price by correct linking with the purchase order.
    3) Setting IsActive = false is for delete action for front end user. 
       It is soft delete. Record will not deleted actually
    4) We will not maintain supplier information in the database for purchases. 
    5) Purchase order has been distilled as per requirement. (Only Create, Approve, Close status will be there)
    6) Bills will not be maintained for the purchase.
    7) Every transaction is created first time and then updated as per progress in main table. 
       But all these transaction will be logged in their child table as history of all transaction. 
       History will show the progress for that particular record of main table.
  
       We are maintaining history for following tables:
         (main table)       -  (Child table to maintain transaction history)
             Lab            -     LabLog
             LabActivity    -     LabActivityLog
             Request        -     RequestLog
             PurchaseOrder  -     POLog
             Asset          -     AssetTransactionLog

    Precaution: 
      1) Please be careful for delete action, 
         Delete action in parent table will affect the related data in child table.
         e.g. if a user is deleted, then its role will be deleted too. 
              Also it will affect the record in ActivityItemTransaction table for the item if that user performed 
              a return as well as affect Asset (quantity).
      2) We need to commit transaction separately on button click (for insert/update/delete). 
         Otherwise data won't be saved in database. 
         Check for rollback if cancel button is clicked.
*/

USE AssetManagement;

DROP TABLE IF EXISTS 
  ActivityItemTransaction,
  AssetTransactionLog,
  Asset,
  POLog,
  POItem,
  PurchaseOrder,
  RequestLog,
  RequestItem,
  Request,
  LabActivityLog,
  LabActivity,
  Item,
  LabLog,
  UserRole,
  Lab,
  Department,
  Users,
  Roles;

CREATE TABLE Roles (
  RoleId      INT AUTO_INCREMENT PRIMARY KEY,
  RoleName    VARCHAR(50), /* Admin, HOD, Lab incharge, Lab assistant, Student */ 
  RoleDesc    VARCHAR(100),
  DateCreated DATETIME     DEFAULT CURRENT_TIMESTAMP,
  IsActive    BOOLEAN
);

CREATE TABLE Users (
  UserId       INT AUTO_INCREMENT PRIMARY KEY,
  UserName     VARCHAR(20),   /* Institute id can be used as username */
  UserPassword VARCHAR(100),
  InstituteId  VARCHAR(50),
  FirstName    VARCHAR(50),
  MiddleName   VARCHAR(50),
  LastName     VARCHAR(50),
  Gender       VARCHAR(10),
  DOB          DATE,
  Email        VARCHAR(50),
  Contact      VARCHAR(50),
  UserAddress  VARCHAR(100),
  IsAppUser    BOOLEAN,       /* for Student it is false */
  DateCreated  DATETIME       DEFAULT CURRENT_TIMESTAMP,
  IsActive     BOOLEAN
);

CREATE TABLE Department (
  DeptId      INT AUTO_INCREMENT PRIMARY KEY,
  DeptName    VARCHAR(50),
  DeptDesc    VARCHAR(100),
  DateCreated DATETIME        DEFAULT CURRENT_TIMESTAMP,
  IsActive    BOOLEAN
);

CREATE TABLE Lab (
  LabId          INT AUTO_INCREMENT PRIMARY KEY,
  DeptId         INT,
  LabName        VARCHAR(50),
  FundsAvailable FLOAT,
  DateCreated    DATETIME     DEFAULT CURRENT_TIMESTAMP,
  DateModified   DATETIME     ON UPDATE CURRENT_TIMESTAMP,
  IsActive       BOOLEAN,
  CONSTRAINT fk_l_DeptId FOREIGN KEY (DeptId) REFERENCES Department(DeptId)
);

CREATE TABLE UserRole (
  UserRoleId INT AUTO_INCREMENT PRIMARY KEY,
  UserId     INT,
  DeptID     INT, /* for HOD with no lab */
  LabId      INT,
  RoleId     INT,
  DateJoined DATETIME,
  DateLeft   DATETIME,
  DateCreated DATetime       DEFAULT CURRENT_TIMESTAMP,
  IsActive   BOOLEAN,
  CONSTRAINT fk_ur_UserId  FOREIGN KEY (UserId)  REFERENCES Users(UserId),
  CONSTRAINT fk_ur_DeptID  FOREIGN KEY (DeptID)  REFERENCES Department(DeptId),
  CONSTRAINT fk_ur_LabId   FOREIGN KEY (LabId)   REFERENCES Lab(LabId),
  CONSTRAINT fk_ur_RoleId  FOREIGN KEY (RoleId)  REFERENCES Roles(RoleId)
);

CREATE TABLE LabLog (
  LabLogId         INT AUTO_INCREMENT PRIMARY KEY,
  LabId            INT,
  ActionTakenBy    VARCHAR(100),     -- was INT
  ActionTaken      VARCHAR(20),
  ActionDescription VARCHAR(100),
  Amount           FLOAT,
  DateCreated      DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ll_LabId FOREIGN KEY (LabId) REFERENCES Lab(LabId)
  -- removed: FOREIGN KEY (ActionTakenBy) REFERENCES Users(UserId)
);

CREATE TABLE Item (
  ItemId             INT AUTO_INCREMENT PRIMARY KEY,
  Category           VARCHAR(20),
  Make               VARCHAR(100),
  Model              VARCHAR(100),
  WarrantyPeriodMonths INT,
  ItemDescription    VARCHAR(100),
  CreatedBy          INT,     /* UserId who created this record */
  DateCreated        DATETIME DEFAULT CURRENT_TIMESTAMP,
  IsActive           BOOLEAN,
  CONSTRAINT fk_i_UserId FOREIGN KEY (CreatedBy) REFERENCES Users(UserId)
);

CREATE TABLE LabActivity (
  ActivityId          INT AUTO_INCREMENT PRIMARY KEY,
  LabId               INT,
  InitiatorId         INT,
  ActivityType        VARCHAR(20),
  ActivityDescription VARCHAR(100),
  FundsAllocated      FLOAT,
  FundsAvailable      FLOAT,
  StartDate           DATETIME,
  EndDate             DATETIME,
  IsClosed            BOOLEAN,
  DateCreated         DATETIME DEFAULT CURRENT_TIMESTAMP,
  DateModified        DATETIME ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_la_LabId  FOREIGN KEY (LabId)       REFERENCES Lab(LabId),
  CONSTRAINT fk_la_UserId FOREIGN KEY (InitiatorId) REFERENCES Users(UserId)
);

CREATE TABLE LabActivityLog (
  ActivityLogId    INT AUTO_INCREMENT PRIMARY KEY,
  ActivityId       INT,
  ActionTakenBy    VARCHAR(100),     -- was INT
  ActionTaken      VARCHAR(20),
  ActionDescription VARCHAR(100),
  Funds            FLOAT,
  DateCreated      DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_lal_ActivityId FOREIGN KEY (ActivityId) REFERENCES LabActivity(ActivityId)
  -- removed: FOREIGN KEY (ActionTakenBy) REFERENCES Users(UserId)
);

CREATE TABLE Request (
  RequestId     INT AUTO_INCREMENT PRIMARY KEY,
  ActivityID    INT,
  RequestDate   DATETIME,
  Requestor     INT,
  RequestStatus VARCHAR(50),
  /* IsActive removed per teammate feedback */
  DateCreated   DATETIME DEFAULT CURRENT_TIMESTAMP,
  DateModified  DATETIME ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_rq_ActivityId FOREIGN KEY (ActivityID) REFERENCES LabActivity(ActivityId),
  CONSTRAINT fk_rq_UserId     FOREIGN KEY (Requestor)   REFERENCES Users(UserId)
);

CREATE TABLE RequestItem (
  RItemID            INT AUTO_INCREMENT PRIMARY KEY,
  RequestId          INT,
  ItemId             INT,
  IsUnknown          BOOLEAN,
  QuantityRequested  INT,
  DateCreated        DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ri_RequestId FOREIGN KEY (RequestId) REFERENCES Request(RequestId),
  CONSTRAINT fk_ri_ItemId    FOREIGN KEY (ItemId)    REFERENCES Item(ItemId)
);

CREATE TABLE RequestLog (
  RequestLogId     INT AUTO_INCREMENT PRIMARY KEY,
  RequestId        INT,
  ActionTakenBy    VARCHAR(100),     -- was INT
  RequestStatus    VARCHAR(50),
  RequestDescription VARCHAR(100),
  DateCreated      DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ril_RequestId FOREIGN KEY (RequestId) REFERENCES Request(RequestId)
  -- removed: FOREIGN KEY (ActionTakenBy) REFERENCES Users(UserId)
);

CREATE TABLE PurchaseOrder (
  POId         INT AUTO_INCREMENT PRIMARY KEY,
  ActivityId   INT,
  OrderDate    DATETIME,
  Amount       FLOAT,
  POStatus     VARCHAR(50),
  DateCreated  DATETIME DEFAULT CURRENT_TIMESTAMP,
  DateModified DATETIME ON UPDATE CURRENT_TIMESTAMP,
  /* IsActive removed per teammate feedback */
  CONSTRAINT fk_po_ActivityId FOREIGN KEY (ActivityId) REFERENCES LabActivity(ActivityId)
);

CREATE TABLE POItem (
  POItemId       INT AUTO_INCREMENT PRIMARY KEY,
  POId           INT,
  ItemId         INT,
  QuantityOrdered INT,
  CostPerUnit    FLOAT,
  DateCreated    DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_poi_POId    FOREIGN KEY (POId)    REFERENCES PurchaseOrder(POId),
  CONSTRAINT fk_poi_ItemId  FOREIGN KEY (ItemId)  REFERENCES Item(ItemId)
);

CREATE TABLE POLog (
  POLogId           INT AUTO_INCREMENT PRIMARY KEY,
  POId              INT,
  POCreatedBy       VARCHAR(100),    -- was INT
  POStatus          VARCHAR(50),
  POStatusDescription VARCHAR(100),
  DateCreated       DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pol_POId FOREIGN KEY (POId) REFERENCES PurchaseOrder(POId)
  -- removed: FOREIGN KEY (POCreatedBy) REFERENCES Users(UserId)
);

CREATE TABLE Asset (
  AssetId          INT AUTO_INCREMENT PRIMARY KEY,
  LabId            INT,
  ItemId           INT,
  SerialNo         VARCHAR(20),
  QuantityAvailable INT,
  StorageLocation  VARCHAR(100),
  ShortDescription VARCHAR(100),
  DateCreated      DATETIME DEFAULT CURRENT_TIMESTAMP,
  DateModified     DATETIME ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_a_LabId   FOREIGN KEY (LabId)   REFERENCES Lab(LabId),
  CONSTRAINT fk_a_ItemId  FOREIGN KEY (ItemId)  REFERENCES Item(ItemId)
);

CREATE TABLE AssetTransactionLog (
  TransactionId     INT AUTO_INCREMENT PRIMARY KEY,
  AssetId           INT,
  ActionTakenBy     VARCHAR(100),    -- was INT
  TransactionAction VARCHAR(50),
  Quantity          INT,
  ShortDescription  VARCHAR(100),
  DateCreated       DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_atl_AssetId FOREIGN KEY (AssetId) REFERENCES Asset(AssetId)
  -- removed: FOREIGN KEY (ActionTakenBy) REFERENCES Users(UserId)
);

CREATE TABLE ActivityItemTransaction (
  ActivityTrasId INT AUTO_INCREMENT PRIMARY KEY,
  ActivityId     INT,
  AssetId        INT,
  Requestor      INT,
  ProcessedBy    INT,
  ActionTaken    VARCHAR(50),
  ActionDate     DATETIME,
  Quantity       INT,
  ShortDescription VARCHAR(50),
  CONSTRAINT fk_ait_ActivityId FOREIGN KEY (ActivityId)  REFERENCES LabActivity(ActivityId),
  CONSTRAINT fk_ait_AssetId    FOREIGN KEY (AssetId)     REFERENCES Asset(AssetId),
  CONSTRAINT fk_ait_UserId     FOREIGN KEY (Requestor)    REFERENCES Users(UserId),
  CONSTRAINT fk_ait_UserId1    FOREIGN KEY (ProcessedBy)  REFERENCES Users(UserId)
);