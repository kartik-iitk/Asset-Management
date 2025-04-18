SELECT  
  AVG(TIMESTAMPDIFF(HOUR, R.DateCreated, RL.DateCreated)) AS AvgApprovalTimeHrs  
FROM RequestLog RL  
JOIN Request R ON RL.RequestId=R.RequestId  
WHERE RL.RequestStatus='Approved';