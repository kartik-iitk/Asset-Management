USE AssetManagement;
/*  For an Activity funds will be allocated accordingly. 
    The available lab funds will be updated and data will be logged.
    To carry out activity using some items, Request will be created.
    The list will be reviewed and the available items will be issued for that activity. 
    Accordingly Asset inventory will be updated.
    If the items are not available then, purchase order (PO) will be created against the activity funds. 
    After approval, when the items are received, the PO will be closed, Funds will be updated.
    The received items will be added in item list, Asset as well as item lab list. 
    These item then will be issued for the Activity and the request will be closed.

    User table will have records of application users (username, password) as well as student to whom items are issued
    Students data will be maintained but they will not log in system

    Setting IsActive = false is for delete action for front end user. 
    It is soft delete. Record will not deleted actually
    
    Please be careful for delete action, 
    Delete action in parent table will affect the related data in child table.
    for example if an user is deleted,  then its role will be deleted too.  

    Trigger can be implemented for multiple queries based on single add/delete/update
    or send queries one by one. 
    We need to commit transaction separately on button click otherwise data won't be saved
    in database. 

    We will not maintain supplier information in the database for purchases. Purchase order has been distilled as per requirement.
*/

/*
DROP TABLE IF EXISTS ItemSupplier;
DROP TABLE IF EXISTS Supplier;
*/
DROP TABLE IF EXISTS AssetTransactionLog;
DROP TABLE IF EXISTS Asset;
DROP TABLE IF EXISTS POLog;
DROP TABLE IF EXISTS POItem;
DROP TABLE IF EXISTS PurchaseOrder;
DROP TABLE IF EXISTS ActivityItemTransaction;
DROP TABLE IF EXISTS LabActivityLog;
DROP TABLE IF EXISTS RequestLog;
DROP TABLE IF EXISTS RequestItem;
DROP TABLE IF EXISTS Request;
DROP TABLE IF EXISTS LabActivity;
DROP TABLE IF EXISTS LabItemStatus;
DROP TABLE IF EXISTS Item;
DROP TABLE IF EXISTS LabLog;
DROP TABLE IF EXISTS UserRole;
DROP TABLE IF EXISTS Lab;
DROP TABLE IF EXISTS Department;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Roles;

CREATE TABLE Roles (
    RoleId INT NOT NULL AUTO_INCREMENT,
    RoleName VARCHAR(50), /* HOD, Lab incharge, Lab assistant, Student */ 
    RoleDesc VARCHAR(100),
	DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN,
    CONSTRAINT pk_r PRIMARY KEY (RoleId)
);

CREATE TABLE Users (
    UserId INT NOT NULL AUTO_INCREMENT,
    UserName VARCHAR(20), /* Institute id can be used as a username for login*/
    UserPassword VARCHAR(20),
	InstituteId VARCHAR(50),
    FirstName VARCHAR(50),	
    MiddleName VARCHAR(50),	
	LastName VARCHAR(50),	
	Gender VARCHAR(10),	
    DOB DATE,
	Email VARCHAR(50),
    Contact VARCHAR(50),
    UserAddress VARCHAR(100),
	DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsAppUser BOOLEAN, /* for Student it is false. Student can not log in in the application*/
    IsActive BOOLEAN,
    CONSTRAINT pk_u PRIMARY KEY (UserId)
);

CREATE TABLE Department (
    DeptId INT NOT NULL AUTO_INCREMENT,
    DeptName VARCHAR(50),
    DeptDesc VARCHAR(100),
    CONSTRAINT pk_d PRIMARY KEY (DeptId)
);

CREATE TABLE Lab (
    /* FundsAvailable will be updated if funds are received as well as 
      if the funds allocated to lab activity are spent, this amount need to be updated.
      All transaction will be logged in Lablog as history
    */
    LabId INT NOT NULL AUTO_INCREMENT,
    DeptId INT,
    LabName VARCHAR(50),
    FundsAvailable FLOAT, 
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN,
    CONSTRAINT pk_l PRIMARY KEY (LabId),
    CONSTRAINT fk_l_DeptId FOREIGN KEY (DeptId) REFERENCES  Department (DeptId)
);

CREATE TABLE UserRole (
    UserRoleId INT NOT NULL AUTO_INCREMENT,
    UserId INT,
    LabId INT,
    RoleId INT,
    DateJoined DATETIME,
    DateLeft DATETIME,
    IsActive BOOLEAN,
    CONSTRAINT pk_ur PRIMARY KEY (UserRoleId),
    CONSTRAINT fk_ur_UserId FOREIGN KEY (UserId) REFERENCES  Users (UserId),
    CONSTRAINT fk_ur_LabId FOREIGN KEY (LabId) REFERENCES  Lab (LabId), 
    CONSTRAINT fk_ur_RoleId FOREIGN KEY (RoleId) REFERENCES  Roles (RoleId)
);

CREATE TABLE LabLog (
    /* There will only be inserts in this table, no updation or deletion against fund transaction done in lab table.*/
    LabLogId INT NOT NULL AUTO_INCREMENT,
    LabId INT,
    UserId INT, /* UserId who modified lab record for funds */
    ActionTaken VARCHAR(20), /* Added, Spent */
    ActionDescription VARCHAR(100),	
    Amount FLOAT, /*Funds*/
    DateCreated DATETIME ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_ll PRIMARY KEY (LabLogId),
    CONSTRAINT fk_ll_LabId FOREIGN KEY (LabId) REFERENCES  Lab (LabId),
    CONSTRAINT fk_ll_UserId FOREIGN KEY (UserId) REFERENCES  Users (UserId)
);

CREATE TABLE Item (
    /* Stores only unique items. And you should check to not allow for duplicate entries. TODO: Add unique constraints. Assume cost of the item is fixed for all time. If the cost changes, then we will need to add log to maintain history of prices for that item, so that correspondingly every project will have the correct price by correct linking with the purchase order. */
    ItemId INT NOT NULL AUTO_INCREMENT,
    SerialNo VARCHAR(20),
    Category VARCHAR(20), /* Monitor, Keyboard, CPU, Cards, Camera, Motors, etc*/
	Make VARCHAR(100),
    Model VARCHAR(100),
    PurchaseDate DATETIME,
	WarrantyEndDate DATETIME,
    Cost FLOAT,
    ItemDescription VARCHAR(100), /* Useful for items for which a box is purchased */
	CreatedBy INT, /* UserId*/
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN,
    CONSTRAINT pk_i PRIMARY KEY (ItemId)
);

/* Separated for efficiency for updation and */
CREATE TABLE LabItemStatus (
    LabItemId INT NOT NULL AUTO_INCREMENT,
    LabId INT,
    ItemId INT,
    ItemCondition VARCHAR(20), /* Good, Under Repair, scraped, lost*/ 
    StatusDescription VARCHAR(100), 
    CreatedBy INT, /* UserId*/
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_lis PRIMARY KEY (LabItemId),
    CONSTRAINT fk_lis_ItemId FOREIGN KEY (ItemId) REFERENCES  Item (ItemId),
    CONSTRAINT fk_lis_LabId FOREIGN KEY (LabId) REFERENCES  Lab (LabId)
);

CREATE TABLE LabActivity (
    /* Once the purchase done amount in FundsAvailable should be updated. 
    Initially when record is created, FundsAvailable = FundsAllocated. 
    If the funds are not sufficient, then Request/Purchase order must get rejected.
    If the activity is closed, the funds available should get added to lab funds.
    Once more funds are allocated, the funds available and allocated should be updated equally.
    Note that only the spent amount from the activity should be deducted from the lab funds.
    FundsAllocated is only used for planning and can be changed as required.  
    */  
    ActivityId INT NOT NULL AUTO_INCREMENT,
    LabId INT,
    UserId INT, /*who created */
    ActivityType VARCHAR(20), /* Research, Project, Lab, other, etc */ 
    ActivityDescription VARCHAR(100), /* project code, name, also for other status*/
    FundsAllocated  FLOAT, /* Total Purchase order amount for this activity should not exceed this amount */
    FundsAvailable FLOAT, 
    StartDate DATETIME,
    EndDate DATETIME,
    IsActive BOOLEAN,
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
	DateModified DATETIME ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_la PRIMARY KEY (ActivityId),
    CONSTRAINT fk_la_LabId FOREIGN KEY (LabId) REFERENCES  Lab (LabId),
    CONSTRAINT fk_la_UserId FOREIGN KEY (UserId) REFERENCES  Users (UserId)
);

CREATE TABLE Request (
    RequestId INT NOT NULL AUTO_INCREMENT,
    ActivityID Int,
    RequestDate DATETIME,   
    UserId INT,  /*User id of the person (student, professor) who created request for items for the activity */
    RequestStatus VARCHAR(50), /* Generated, Approved, Rejected, Complete, other */
    IsActive BOOLEAN,
    CONSTRAINT pk_rq PRIMARY KEY (RequestId),
    CONSTRAINT fk_rq_ActivityId FOREIGN KEY (ActivityID) REFERENCES  LabActivity (ActivityID),
    CONSTRAINT fk_rq_UserId FOREIGN KEY (UserId) REFERENCES  Users (UserId)
);

CREATE TABLE RequestItem (
    RItemID INT NOT NULL AUTO_INCREMENT,
    RequestId INT,
    Category VARCHAR(20), /*Monitor, Keyboard, CPU, Camera etc*/
	Make VARCHAR(100),
    Model VARCHAR(100),
    QuantityRequested INT,
    CONSTRAINT pk_ri PRIMARY KEY (RItemID),
    CONSTRAINT fk_ri_RequestId FOREIGN KEY (RequestId) REFERENCES  Request (RequestId)
);
  
CREATE TABLE RequestLog (
    RequestLogId INT NOT NULL AUTO_INCREMENT,    
    RequestId INT,
    UserId INT,  /* Processed by */
    RequestStatus VARCHAR(50), /* Generated, Approved, Rejected, Complete, other */
    RequestDescription VARCHAR(100), 
    StatusUpdateDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_ril PRIMARY KEY (RequestLogId),
    CONSTRAINT fk_ril_RequestId FOREIGN KEY (RequestId) REFERENCES  Request (RequestId),
    CONSTRAINT fk_ril_UserId FOREIGN KEY (UserId) REFERENCES  Users (UserId)
);

CREATE TABLE LabActivityLog (
    /* Once the item is issued or returned, it must be reflected in Asset table for total quantity available for that item */
    ActivityLogId INT NOT NULL AUTO_INCREMENT,
    ActivityId INT,
    UserId INT, /* Processed by */
    ActionTaken VARCHAR(20), /* Added, Spent */
    ActionDescription VARCHAR(100),	
    Funds FLOAT,
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT pk_lal PRIMARY KEY (ActivityLogId),
    CONSTRAINT fk_lal_ActivityId FOREIGN KEY (ActivityId) REFERENCES  LabActivity (ActivityId),
    CONSTRAINT fk_lal_UserId FOREIGN KEY (IssuedUserId) REFERENCES  Users (UserId)
);

CREATE TABLE ActivityItemTransaction (
     /* Once the item is issued or returned, it must be reflected in Asset table for total quantity available for that item */
    ActivityTrasId INT NOT NULL AUTO_INCREMENT,
    ActivityId INT,
    RItemID INT,
    ItemId INT,
    IssuedUserId INT, /* Project Leader/Individual*/ 
    IssuedDate DATETIME,
    IssuedQuantity INT,  
    ReceiveDate DATETIME,
    ReceivedQuantity INT,
 /*   QuantityDamaged INT,
    QuantityLost INT,*/
    ShortDescription VARCHAR(50),	
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
	DateModified DATETIME ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_ait PRIMARY KEY (ActivityTrasId),
    CONSTRAINT fk_ait_ActivityId FOREIGN KEY (ActivityId) REFERENCES  LabActivity (ActivityId),
    CONSTRAINT fk_ait_RItemId FOREIGN KEY (RItemID) REFERENCES  RequestItem (RItemID),
    CONSTRAINT fk_ait_ItemId FOREIGN KEY (ItemId) REFERENCES  Item (ItemId),
    CONSTRAINT fk_ait_UserId FOREIGN KEY (IssuedUserId) REFERENCES  Users (UserId)
);

CREATE TABLE PurchaseOrder (
    POId INT NOT NULL AUTO_INCREMENT,
    ActivityId  INT,
    OrderDate DATETIME,
	Amount FLOAT,
    POStatus VARCHAR(50),
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    DateModified DATETIME ON UPDATE CURRENT_TIMESTAMP,
    IsActive BOOLEAN,
    CONSTRAINT pk_po PRIMARY KEY (POId),
    CONSTRAINT fk_po_ActivityId FOREIGN KEY (ActivityId) REFERENCES  LabActivity (ActivityId)
);

CREATE TABLE POItem (
    POItemId INT NOT NULL AUTO_INCREMENT,
    POId INT,
    Category VARCHAR(20), /*Monitor, Keyboard, CPU, Resistors etc*/
	Make VARCHAR(100),
    Model VARCHAR(100),
    QuantityOrdered INT,
	CostPerUnit FLOAT,
    CONSTRAINT pk_poi PRIMARY KEY (POItemId),
    CONSTRAINT fk_poi_POId FOREIGN KEY (POId) REFERENCES  PurchaseOrder (POId)
);

CREATE TABLE POLog (
    POLogId INT NOT NULL AUTO_INCREMENT,
    POId INT,
    UserId INT, /*User who updated status */ 
    POStatus VARCHAR(50), /* Generated, Approved, Rejected, Received/Complete, Other */
    POStatusDescription VARCHAR(100), /* Fill when status is other*/
    StatusUpdateDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_pol PRIMARY KEY (POLogId),
    CONSTRAINT fk_pol_POId FOREIGN KEY (POId) REFERENCES  PurchaseOrder (POId),
    CONSTRAINT fk_pol_UserId FOREIGN KEY (UserId) REFERENCES  Users (UserId)
);

/*Payment receipt not implemented*/

CREATE TABLE Asset (
    /* Once the item is issued or returned, it must be reflected in Asset(updated) 
    for total quantity available for that item as well as added in AssetTransactionLog table  */
    AssetId INT NOT NULL AUTO_INCREMENT,
    LabId INT, 
    ItemId INT,
    QuantityAvailable INT, 
    StorageLocation VARCHAR(100),
    ShortDescription VARCHAR(100),
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    DateModified DATETIME ON UPDATE CURRENT_TIMESTAMP,
    IsActive BOOLEAN,
    CONSTRAINT pk_a PRIMARY KEY (AssetId),
    CONSTRAINT fk_a_LabId FOREIGN KEY (LabId) REFERENCES  Lab (LabId),
    CONSTRAINT fk_a_ItemId FOREIGN KEY (ItemId) REFERENCES  Item (ItemId)
);

CREATE TABLE AssetTransactionLog (
    TransactionId INT NOT NULL AUTO_INCREMENT,
    AssetId INT,
    TransactionAction VARCHAR(50), /*Added, Issued, Returned, Scraped*/
    POItemId INT, /* only for purchase otherwise NULL*/
    ActivityLogId INT, /* Only for issued, Returned otherwise NULL*/
    Quantity INT,
    ShortDescription VARCHAR(100),
    CreatedBy INT, /*userid*/  
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_atl PRIMARY KEY (TransactionId),
    CONSTRAINT fk_atl_AssetId FOREIGN KEY (AssetId) REFERENCES  Asset (AssetId),
    CONSTRAINT fk_atl_POItemId FOREIGN KEY (POItemId) REFERENCES  POItem (POItemId),
    CONSTRAINT fk_atl_ActivityLogId FOREIGN KEY (ActivityLogId) REFERENCES  LabActivityLog (ActivityLogId)
);