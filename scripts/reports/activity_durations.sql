SELECT  
  LA.ActivityDescription,  
  LA.StartDate,  
  LA.EndDate,  
  TIMESTAMPDIFF(DAY,LA.StartDate,LA.EndDate) AS DurationDays  
FROM LabActivity LA  
WHERE LA.IsClosed=TRUE  
ORDER BY DurationDays DESC  
LIMIT 10;