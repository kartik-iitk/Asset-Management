/*  For an Activity funds will be allocated 
    Accordingly, the available lab funds will be updated and data will be logged.
    Step: 
        1)  Activity will be created
        2)  To carry out activity using some items are required.
            Here if the item required is not available (quantity) or is not listed (unknown) in Item table, 
            then new item is first created in Item table.
        3)  Request will be created for the user (Student/individual). 
        4)  The list will be reviewed and will be approved/ rejected
        5)  After the approval, the available items will be issued for that activity.
            Asset inventory will be updated and data will be logged.
        6)  For the items which are not available or not listed (unknown), 
            then purchase order (PO) will be created against the activity FundsAvailable.
        7)  After approval for the PO, when the items are received, 
            the PO will be closed, Activity FundsAvailable will be updated also the data will be logged.
            Multiple PO can be made as per requirement against activity FundsAvailable.  
        8)  The received items will be added in Asset table with quantity and serial number will be assigned to it.
        9)  These item then will be issued for the Activity to user who requested and the request will be closed.
        9)  Once the activity is complete, 
            Item will be returned by Student and accordingly asset inventory will be updated for quantity. 
            The balance FundsAvailable of activity will be refunded (moved/added to lab FundsAvailable)
            The activity will be closed (IsClosed will be set to 1)

    Assumption:
        1)  User table will have records of application users (username, password) as well as student to whom items are issued
            Currently, Students data will be maintained but they will not log in system. 
            (If access is given then they can only create request)
        2)  Currently, Prices of the item is not considered in Item table. 
            If it has to included then for the cost changes, we will need to add log to maintain history of prices for that item, 
            so that correspondingly every project/activity will have the correct price by correct linking with the purchase order.
        3)  Setting IsActive = false is for delete action for front end user. 
            It is soft delete. Record will not deleted actually
        4)  We will not maintain supplier information in the database for purchases. 
        5)  Purchase order has been distilled as per requirement. (Only Create, Approve, Close status will be there)
        6)  Bills will not be maintained for the purchase.
        7)  Every transaction is created first time and then updated as per progress in main table. 
            But all these transaction will be logged in their child table as history of all transaction. 
            History will show the progress for that particular record of main table.
        
            We are maintaining history for following tables:
                (main table)       -  (Child table to maintain transaction history)
                    Lab            -     LabLog
                    LabActivity    -     LabActivityLog
                    Request        -     RequestLog
                    PurchaseOrder  -     POLog
                    Asset          -     AssetTransactionLog

        e.g. 
            a.  Consider Lab (main table) record with initial funds first time. 
                This will be inserted in Lab and will be inserted in the LabLog (Child table) with action (Added)
            b.  Now let lab received more funds, then this record will be updated for funds in Lab table 
                and a new record will be inserted in LabLog table with description and action (Added)
            c.  If the lab funds need to be allocated to some activity, then same record will be updated in Lab table
                and a new record will be inserted in LabLog table with description and action (Spent)
    
    Precaution: 

        1)  Please be careful for delete action, 
            Delete action in parent table will affect the related data in child table.
            e.g. if an user is deleted, then its role will be deleted too. 
                 Also it will affect the record in ActivityItemTransaction table for the item if that user (return) have 
                 as well as Asset table (quantity of item).
            Here, Trigger can be implemented for multiple queries based on single add/delete/update
            or send queries one by one. 
        2)  We need to commit transaction separately on button click (for insert/update/delete). 
            Otherwise data won't be saved in database. 
            Check for rollback if cancel button is clicked.

*/

USE AssetManagement;

DROP TABLE IF EXISTS ActivityItemTransaction;
DROP TABLE IF EXISTS AssetTransactionLog;
DROP TABLE IF EXISTS Asset;
DROP TABLE IF EXISTS POLog;
DROP TABLE IF EXISTS POItem;
DROP TABLE IF EXISTS PurchaseOrder;
DROP TABLE IF EXISTS RequestLog;
DROP TABLE IF EXISTS RequestItem;
DROP TABLE IF EXISTS Request;
DROP TABLE IF EXISTS LabActivityLog;
DROP TABLE IF EXISTS LabActivity;
DROP TABLE IF EXISTS Item;
DROP TABLE IF EXISTS LabLog;
DROP TABLE IF EXISTS UserRole;
DROP TABLE IF EXISTS Lab;
DROP TABLE IF EXISTS Department;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Roles;

CREATE TABLE Roles (
    RoleId INT NOT NULL AUTO_INCREMENT,
    RoleName VARCHAR(50), /* Admin, HOD, Lab incharge (Professor), Lab assistant, Student */ 
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
    IsAppUser BOOLEAN, /* for Student it is false. Student can not log in in the application*/
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN,
    CONSTRAINT pk_u PRIMARY KEY (UserId)
);

CREATE TABLE Department (
    DeptId INT NOT NULL AUTO_INCREMENT,
    DeptName VARCHAR(50),
    DeptDesc VARCHAR(100),
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP, 
    IsActive BOOLEAN,
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
    DateModified DATETIME ON UPDATE CURRENT_TIMESTAMP,
    IsActive BOOLEAN,
    CONSTRAINT pk_l PRIMARY KEY (LabId),
    CONSTRAINT fk_l_DeptId FOREIGN KEY (DeptId) REFERENCES  Department (DeptId)
);

CREATE TABLE UserRole (
    /* mapping of user, role and lab */
    UserRoleId INT NOT NULL AUTO_INCREMENT,
    UserId INT,
    LabId INT,
    RoleId INT,
    DateJoined DATETIME,
    DateLeft DATETIME,
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN, /*Required or not?*/
    CONSTRAINT pk_ur PRIMARY KEY (UserRoleId),
    CONSTRAINT fk_ur_UserId FOREIGN KEY (UserId) REFERENCES  Users (UserId),
    CONSTRAINT fk_ur_LabId FOREIGN KEY (LabId) REFERENCES  Lab (LabId), 
    CONSTRAINT fk_ur_RoleId FOREIGN KEY (RoleId) REFERENCES  Roles (RoleId)
);

CREATE TABLE LabLog (
     /* There will only be inserts with action in this table (for any create/update/delete against fund transaction done in Lab table).*/
    LabLogId INT NOT NULL AUTO_INCREMENT,
    LabId INT,
    ActionTakenBy INT, /* UserId who modified lab record for funds (e.g. 'HOD','Lab Incharge') */
    ActionTaken VARCHAR(20), /* AAdded, Spent, Refund/ */
    ActionDescription VARCHAR(100),	
    Amount FLOAT, /*Funds*/
    DateCreated DATETIME ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_ll PRIMARY KEY (LabLogId),
    CONSTRAINT fk_ll_LabId FOREIGN KEY (LabId) REFERENCES  Lab (LabId),
    CONSTRAINT fk_ll_UserId FOREIGN KEY (ActionTakenBy) REFERENCES  Users (UserId)
);

CREATE TABLE Item (
     /* Stores only unique items. And you should check to not allow for duplicate entries */
    ItemId INT NOT NULL AUTO_INCREMENT,
    Category VARCHAR(20), /* Monitor, Keyboard, CPU, Cards, Camera, Motors, etc*/
	Make VARCHAR(100),
    Model VARCHAR(100),
    WarrantyPeriodMonths INT,
    ItemDescription VARCHAR(100), /* Useful for items for which a box is purchased */
	CreatedBy INT, /* UserId who created this record*/
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN,
    CONSTRAINT pk_i PRIMARY KEY (ItemId),
    CONSTRAINT fk_i_UserId FOREIGN KEY (CreatedBy) REFERENCES  Users (UserId)
);

CREATE TABLE LabActivity (
    /* 
    Initially when record is created, FundsAvailable = FundsAllocated. 
    Lab FundsAvailable when allocated to Activity then it is subtracted from Lab FundsAvailable.
    
    If the funds are not sufficient, then Request/Purchase order should either get rejected or more funds will be made available.
    Once more funds are allocated, the FundsAvailable and FundsAllocated should be updated equally.
      
    Once the purchase done amount in FundsAvailable should be updated. 
    If purchase is made against the activity, then it is subtracted from activity FundsAvailable.
    FundsAvailable will be updated after the completion of Purchase (item received).

    If the activity is closed, then balance fund should be moved to Lab table (add in FundsAvailable),
    and IsClosed will be set to 1. FundsAvailable in this table can be made 0. 
    
    All insertion/updation should be logged in LabActivityLog table
    */  
    ActivityId INT NOT NULL AUTO_INCREMENT,
    LabId INT,
    InitiatorId INT, /*UserId who is responsible for the activity, e.g.'Lab Incharge'*/
    ActivityType VARCHAR(20), /* Research, Project, Lab, other, etc */ 
    ActivityDescription VARCHAR(100), /* project code, name, also for other status*/
    FundsAllocated  FLOAT, /* Total Purchase order amount for this activity should not exceed this amount */
    FundsAvailable FLOAT, 
    StartDate DATETIME,
    EndDate DATETIME,
    IsClosed BOOLEAN, /* If activity closed then value should be 1 else 0 */
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
	DateModified DATETIME ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_la PRIMARY KEY (ActivityId),
    CONSTRAINT fk_la_LabId FOREIGN KEY (LabId) REFERENCES  Lab (LabId),
    CONSTRAINT fk_la_UserId FOREIGN KEY (InitiatorId) REFERENCES  Users (UserId)
);

CREATE TABLE LabActivityLog (
    /* There will only be inserts with action in this table 
    (for any create/update/delete against Activity fund transaction done in LabActivity table).*/
    ActivityLogId INT NOT NULL AUTO_INCREMENT,
    ActivityId INT,
    ActionTakenBy INT, /* (UserId) Processed by  e.g.'Lab Incharge'*/
    ActionTaken VARCHAR(20), /* Added, Spent, Refund */
    ActionDescription VARCHAR(100),	
    Funds FLOAT,
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT pk_lal PRIMARY KEY (ActivityLogId),
    CONSTRAINT fk_lal_ActivityId FOREIGN KEY (ActivityId) REFERENCES  LabActivity (ActivityId),
    CONSTRAINT fk_lal_UserId FOREIGN KEY (ActionTakenBy) REFERENCES  Users (UserId)
);

CREATE TABLE Request (
    RequestId INT NOT NULL AUTO_INCREMENT,
    ActivityID Int,
    RequestDate DATETIME,   
    Requestor INT,  /*User id of the person (student, professor) who created request for items for the activity */
    RequestStatus VARCHAR(50), /* Generated, Approved, Rejected, Complete, other */
    IsActive BOOLEAN,
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    DateModified DATETIME ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_rq PRIMARY KEY (RequestId),
    CONSTRAINT fk_rq_ActivityId FOREIGN KEY (ActivityID) REFERENCES  LabActivity (ActivityID),
    CONSTRAINT fk_rq_UserId FOREIGN KEY (Requestor) REFERENCES  Users (UserId)
);

CREATE TABLE RequestItem (
    /* Child table of Request. Mapping of the item which are Requested*/
    /* if item is not listed in item list,
     then create the item in item table and then allocate in requestItem table*/
    RItemID INT NOT NULL AUTO_INCREMENT,
    RequestId INT,
    ItemId INT,
    IsUnknown BOOLEAN, /* If the item is not listed in item list, then it will be unknown i.e IsUnknown = 1 else 0*/
    QuantityRequested INT,
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_ri PRIMARY KEY (RItemID),
    CONSTRAINT fk_ri_ItemId FOREIGN KEY (ItemId) REFERENCES  Item (ItemId),
    CONSTRAINT fk_ri_RequestId FOREIGN KEY (RequestId) REFERENCES  Request (RequestId)
);
  
CREATE TABLE RequestLog (
    /* Child table of Request. Maintains History of Request transaction*/
    RequestLogId INT NOT NULL AUTO_INCREMENT,    
    RequestId INT,
    ActionTakenBy INT,  /* UserId Processed by e.g. 'Lab Assistance, 'Lab Incharge''*/
    RequestStatus VARCHAR(50), /* Generated, Approved, Rejected, Complete, other */
    RequestDescription VARCHAR(100), 
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_ril PRIMARY KEY (RequestLogId),
    CONSTRAINT fk_ril_RequestId FOREIGN KEY (RequestId) REFERENCES  Request (RequestId),
    CONSTRAINT fk_ril_UserId FOREIGN KEY (ActionTakenBy) REFERENCES  Users (UserId)
);

CREATE TABLE PurchaseOrder (
    /* Stores record for not listed (unknown) items as well as unavailable item  for the activity*/
    POId INT NOT NULL AUTO_INCREMENT,
    ActivityId  INT,
    OrderDate DATETIME,
	Amount FLOAT, /* total cost of all items (cost of one item= quantity*costperunit)*/
    POStatus VARCHAR(50),
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    DateModified DATETIME ON UPDATE CURRENT_TIMESTAMP,
    IsActive BOOLEAN,
    CONSTRAINT pk_po PRIMARY KEY (POId),
    CONSTRAINT fk_po_ActivityId FOREIGN KEY (ActivityId) REFERENCES  LabActivity (ActivityId)
);

CREATE TABLE POItem (
    /* Child table of PurchaseOrder. Mapping of the item which need to be purchased*/
    POItemId INT NOT NULL AUTO_INCREMENT,
    POId INT,
    ItemId INT,
    QuantityOrdered INT,
	CostPerUnit FLOAT,
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_poi PRIMARY KEY (POItemId),
    CONSTRAINT fk_poi_ItemId FOREIGN KEY (ItemId) REFERENCES  Item (ItemId),
    CONSTRAINT fk_poi_POId FOREIGN KEY (POId) REFERENCES  PurchaseOrder (POId)
);

CREATE TABLE POLog (
    /* Child table of PurchaseOrder. Maintains History of PurchaseOrder transaction*/
    POLogId INT NOT NULL AUTO_INCREMENT,
    POId INT,
    POCreatedBy INT, /*UserId who created/updated PO Lab Assistance/incharge  */ 
    POStatus VARCHAR(50), /* Generated, Approved, Rejected, Received/Complete, Other */
    POStatusDescription VARCHAR(100), /* Fill when status is other*/
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_pol PRIMARY KEY (POLogId),
    CONSTRAINT fk_pol_POId FOREIGN KEY (POId) REFERENCES  PurchaseOrder (POId),
    CONSTRAINT fk_pol_UserId FOREIGN KEY (POCreatedBy) REFERENCES  Users (UserId)
);

/*Payment receipt not implemented*/

CREATE TABLE Asset (
    /* Once the item is issued or returned, it must be reflected in Asset (that record needs to be updated) 
    for total quantity available for that item as well as added in AssetTransactionLog table  */
    AssetId INT NOT NULL AUTO_INCREMENT,
    LabId INT, 
    ItemId INT,
    SerialNo VARCHAR(20), /* unique number given to item will help to track item*/
    QuantityAvailable INT, 
    StorageLocation VARCHAR(100),
    ShortDescription VARCHAR(100),
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    DateModified DATETIME ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_a PRIMARY KEY (AssetId),
    CONSTRAINT fk_a_LabId FOREIGN KEY (LabId) REFERENCES  Lab (LabId),
    CONSTRAINT fk_a_ItemId FOREIGN KEY (ItemId) REFERENCES  Item (ItemId)
);

CREATE TABLE AssetTransactionLog (
     /* Child table of Asset. Maintains History of Asset transaction*/
    TransactionId INT NOT NULL AUTO_INCREMENT,
    AssetId INT,
    ActionTakenBy INT, /*UserID who is responsible for the activity, e.g. 'Lab Incharge'*/  
    TransactionAction VARCHAR(50), /*Added, Issued, Returned, Scraped*/
    Quantity INT,
    ShortDescription VARCHAR(100),
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_atl PRIMARY KEY (TransactionId),
    CONSTRAINT fk_atl_AssetId FOREIGN KEY (AssetId) REFERENCES  Asset (AssetId),
    CONSTRAINT fk_atl_UserId FOREIGN KEY (ActionTakenBy) REFERENCES  Users (UserId)
);

CREATE TABLE ActivityItemTransaction (
     /* Once the item is issued or returned, it must be reflected in Asset table for total quantity available for that item */
    ActivityTrasId INT NOT NULL AUTO_INCREMENT,
    ActivityId INT,
    /*RItemID INT,
    ItemId INT,*/
    AssetId INT,
    Requestor INT, /* UserId who raised the request, Student, Individual*/ 
    ProcessedBy INT, /*UserId  who executed the request, e.g. Lab assistant*/
    ActionTaken VARCHAR(50), /*Issued, Returned, etc*/
    ActionDate DATETIME,
    Quantity INT,
    ShortDescription VARCHAR(50),
    CONSTRAINT pk_ait PRIMARY KEY (ActivityTrasId),
    CONSTRAINT fk_ait_ActivityId FOREIGN KEY (ActivityId) REFERENCES  LabActivity (ActivityId),
    CONSTRAINT fk_ait_AssetId FOREIGN KEY (AssetId) REFERENCES  Asset (AssetId),
    CONSTRAINT fk_ait_UserId FOREIGN KEY (Requestor) REFERENCES  Users (UserId),
    CONSTRAINT fk_ait_UserId1 FOREIGN KEY (ProcessedBy) REFERENCES  Users (UserId)
);