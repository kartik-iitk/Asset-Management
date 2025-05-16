
-- ================================================================
--  Get details of Activity wise with purchase 
-- ================================================================

SELECT  la.LabId,
        la.ActivityId,
        SUM(l.Funds) AddedFunds,
        SUM(COALESCE(ll.Funds, 0)) Spent,
        SUM(COALESCE(ll1.Funds, 0)) Refund,
        SUM(COALESCE(po.purchase, 0)) purchase,
        SUM(la.FundsAvailable) Available
FROM  assetmanagement.LabActivity la,
    (SELECT ActivityId,  Sum(Funds) Funds
      FROM assetmanagement.LabActivityLog 
      WHERE  ActionTaken = 'Added'
      GROUP BY ActivityId) l
LEFT OUTER JOIN 
      (SELECT ActivityId,  Sum(Funds) Funds
      FROM assetmanagement.LabActivityLog 
      WHERE  ActionTaken = 'Spent'
      GROUP BY ActivityId) ll
ON ll.ActivityId = l.ActivityId
LEFT OUTER JOIN 
    (SELECT ActivityId, SUM(Funds) AS Funds 
     FROM assetmanagement.LabActivityLog 
     WHERE ActionTaken = 'Refunded' 
     GROUP BY ActivityId) ll1
ON ll1.ActivityId = l.ActivityId
LEFT OUTER JOIN 
      (SELECT ActivityId, sum(Amount) purchase
      FROM assetmanagement.PurchaseOrder
      WHERE POStatus = 'Closed'
      GROUP BY ActivityId) po
ON po.ActivityId = l.ActivityId
WHERE la.ActivityId = l.ActivityId
GROUP BY la.LabId, la.ActivityId;   

-- ================================================================
-- Get details of lab wise purchase 
-- ================================================================

SELECT  la.LabId,
        SUM(l.Funds) AddedFunds,
        SUM(COALESCE(ll.Funds, 0)) Spent,
        SUM(COALESCE(ll1.Funds, 0)) Refund,
        SUM(COALESCE(po.purchase, 0)) purchase,
        SUM(la.FundsAvailable) Available
FROM  assetmanagement.LabActivity la,
    (SELECT ActivityId,  Sum(Funds) Funds
      FROM assetmanagement.LabActivityLog 
      WHERE  ActionTaken = 'Added'
      GROUP BY ActivityId) l
LEFT OUTER JOIN 
      (SELECT ActivityId,  Sum(Funds) Funds
      FROM assetmanagement.LabActivityLog 
      WHERE  ActionTaken = 'Spent'
      GROUP BY ActivityId) ll
ON ll.ActivityId = l.ActivityId
LEFT OUTER JOIN 
    (SELECT ActivityId, SUM(Funds) AS Funds 
     FROM assetmanagement.LabActivityLog 
     WHERE ActionTaken = 'Refunded' 
     GROUP BY ActivityId) ll1
ON ll1.ActivityId = l.ActivityId
LEFT OUTER JOIN 
      (SELECT ActivityId, sum(Amount) purchase
      FROM assetmanagement.PurchaseOrder
      WHERE POStatus = 'Closed'
      GROUP BY ActivityId) po
ON po.ActivityId = l.ActivityId
WHERE la.ActivityId = l.ActivityId
GROUP BY la.LabId;   

-- ================================================================
-- Get details of Lab funds Transaction
-- ================================================================
SELECT ll1.LabId, 
		ll1.LabName,
        ll1.amt AS AddedFunds, 
        COALESCE(ll2.amt, 0)  AS AllocatedToActivities, 
        COALESCE(ll3.amt, 0)  AS Refunded, 
        (ll1.amt - COALESCE(ll2.amt, 0) + COALESCE(ll3.amt, 0)) as AvailableBalance
FROM 
    (SELECT l.LabId, l.LabName, SUM(log.Amount) AS amt 
     FROM Lab l , assetmanagement.LabLog log
     WHERE  l.labId = log.LabId
     AND	log.ActionTaken IN ('Added')
     GROUP BY l.LabId, l.LabName) ll1
LEFT OUTER JOIN 
    (SELECT LabId, SUM(Amount) AS amt 
     FROM assetmanagement.LabLog 
     WHERE ActionTaken = 'Allocated' 
     GROUP BY LabId) ll2
ON ll1.LabId = ll2.LabId
LEFT OUTER JOIN 
    (SELECT LabId, SUM(Amount) AS amt 
     FROM assetmanagement.LabLog 
     WHERE ActionTaken = 'Refunded' 
     GROUP BY LabId) ll3
ON ll1.LabId = ll3.LabId;
