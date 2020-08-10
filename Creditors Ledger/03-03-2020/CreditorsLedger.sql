CREATE procedure CreditorsLedger

(IN FromDate Timestamp
,IN ToDate Timestamp,    
IN FromCreditor nvarchar(500)
, IN ToCreditor nvarchar(500),     
IN LocalForeign  nvarchar(2) )   
LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER
--READ SQL DATA 
AS
 Begin
 with Cte1     
 AS    
(    
SELECT "ShortName", SUM("Debit") - SUM("Credit") AS "OB", SUM("FCDebit") - SUM("FCCredit") AS "obfc" FROM JDT1 
WHERE "RefDate"  <:fromdate 
 GROUP BY "ShortName"
          
),    

OpeningBalance  as
  ( 
	SELECT IFNULL(h."FormatCode", B."ShortName") AS "Shortnme", C."CardName", c."CardCode", 
	CASE WHEN :LocalForeign = 'LC' THEN (SUM(CASE WHEN (A."RefDate" < :FromDate) THEN (IFNULL("Debit", 0) - IFNULL("Credit", 0)) ELSE 0 END)) 
	ELSE (SUM(CASE WHEN (A."RefDate" < :FromDate) THEN (IFNULL("FCDebit", 0) - IFNULL("FCCredit", 0)) ELSE 0 END)) END AS "OPENING BALANCE" 
	
	FROM OJDT a 
	INNER JOIN JDT1 b ON a."TransId" = b."TransId" 
	INNER JOIN OCRD c ON b."ShortName" = c."CardCode" 
	LEFT OUTER JOIN OACT h ON h."AcctCode" = b."ShortName" 
	CROSS JOIN OADM 
	WHERE a."RefDate" <= :Todate AND C."CardType" = 'S' AND c."CardName" || '-' || c."CardCode" >= :FromCREDITOR 
	AND c."CardName" || '-' || c."CardCode" <= :ToCREDITOR 
	GROUP BY b."ShortName", c."CardName", H."FormatCode", c."CardCode" ),
INVOICE as(
SELECT crd."CardCode"
, jt1."TransId"
, IFNULL((CASE WHEN jdt."TransType" in (30,321) THEN nm1."SeriesName" --changes on 30-11-2019 for Manual reconcilation 321 transaction added 
               WHEN jdt."TransType" = 18 THEN nm2."SeriesName" 
               WHEN jdt."TransType" = 19 THEN nm3."SeriesName" 
               WHEN jdt."TransType" = 204 THEN nm4."SeriesName" END) || '/', '')
                || 
          (CASE WHEN jdt."TransType" in (30,321) THEN jdt."BaseRef" --changes on 30-11-2019 for Manual reconcilation 321 transaction added 
                WHEN jdt."TransType" = 18 THEN CAST(PCH."DocNum" AS varchar) 
                WHEN jdt."TransType" = 19 THEN CAST(RPC."DocNum" AS varchar) 
                WHEN jdt."TransType" = 204 THEN CAST(Dpo."DocNum" AS varchar) END) AS "DOCREFNO"
, jdt."RefDate" AS "DocDate"
, (CASE WHEN jdt."TransType" in (30,321) THEN jdt."BaseRef" --changes on 30-11-2019 for Manual reconcilation 321 transaction added 
        WHEN jdt."TransType" = 18 THEN CAST(PCH."DocNum" AS varchar) 
        WHEN jdt."TransType" = 19 THEN CAST(RPC."DocNum" AS varchar) 
        WHEN jdt."TransType" = 204 THEN CAST(Dpo."DocNum" AS varchar) END) AS "DocNum"
, (CASE WHEN jdt."TransType" in (30,321) THEN '' --changes on 30-11-2019 for Manual reconcilation 321 transaction added 
WHEN jdt."TransType" = 18 THEN PCH."NumAtCard" 
WHEN jdt."TransType" = 19 THEN rpc."NumAtCard" 
WHEN jdt."TransType" = 204 THEN dpo."NumAtCard" END) AS "numatcard"
, CASE WHEN :LocalForeign = 'LC' THEN jt1."Debit" ELSE jt1."FCDebit" END AS "Debit"
, CASE WHEN :LocalForeign = 'LC' THEN jt1."Credit" ELSE jt1."FCCredit" END AS "Credit"
, jt1."TransType"
, case when JDT."TransType"= 321 then act1."AcctName" --changes on 30-11-2019 for Manual reconcilation 321 transaction added 
else crd."CardName" end AS "AcctName"
, crd."CardName" AS "Creditor"
, DAYOFMONTH(jt1."RefDate") AS "Dt"
, month(jt1."RefDate") AS "Mnth", year(jt1."RefDate") AS "yr1"
, IFNULL((CASE WHEN jdt."TransType" in (30,321) THEN jdt."Memo" --changes on 30-11-2019 for Manual reconcilation 321 transaction added 
WHEN jdt."TransType" = 18 THEN PCH."Comments" 
WHEN jdt."TransType" = 19 THEN rpc."Comments" 
WHEN jdt."TransType" = 204 THEN dpo."Comments" END), '') AS "Comments"
    ----changes on 25-11-2019
    ,Jt1."Line_ID" 
    --changes for Manual reconcilation 321 transaction added
,case when jdt."TransType" = 321 then (select "Recon_Doc" from Reconcilation_Details where "ReconNum"=jdt."CreatedBy") 
else '' end "Reconcile_Detail"
FROM OCRD crd 
LEFT OUTER JOIN JDT1 jt1 ON crd."CardCode" = jt1."ShortName"
 LEFT OUTER JOIN OJDT jdt ON jt1."TransId" = jdt."TransId" 
 left outer join OACT ACT1 on ACT1."AcctCode"=Jt1."ContraAct" --changes on 30-11-2019 for Manual reconcilation 321 transaction added 
 LEFT OUTER JOIN NNM1 nm1 ON jdt."Series" = nm1."Series"
  LEFT OUTER JOIN OACT act ON jt1."Account" = act."AcctCode" 
  LEFT OUTER JOIN OPCH PCH ON jt1."TransId" = PCH."TransId" AND jt1."TransType" = 18 AND pch.CANCELED = 'N' 
  LEFT OUTER JOIN NNM1 nm2 ON pch."Series" = nm2."Series"
   LEFT OUTER JOIN ORPC RPC ON jt1."TransId" = RPC."TransId" AND jt1."TransType" = 19 AND RPC.CANCELED = 'N' 
   LEFT OUTER JOIN NNM1 nm3 ON RPC."Series" = nm3."Series"
    LEFT OUTER JOIN ODPO dpo ON jt1."TransId" = dpo."TransId" AND jt1."TransType" = 204 AND dpo.CANCELED = 'N' 
	LEFT OUTER JOIN NNM1 nm4 ON dpo."Series" = nm4."Series" 
	WHERE crd."CardType" = 'S' AND jt1."TransType" IN (18,19,204,30,321)  --changes on 30-11-2019 for manual reconcilation
	AND 
	(CASE WHEN jdt."TransType" in( 30,321) --changes on 30-11-2019 for manual reconcilation
	 THEN 'N' WHEN jdt."TransType" = 18 THEN PCH.CANCELED WHEN jdt."TransType" = 19 THEN rpc.CANCELED WHEN jdt."TransType" = 204 
	THEN dpo.CANCELED END) = 'N' 
	AND jt1."RefDate" >= :fromdate AND jt1."RefDate" <= :todate AND crd."CardName" || '-' || crd."CardCode" >= :FromCREDITOR AND crd."CardName" || '-' || crd."CardCode" <= :ToCREDITOR
	 order by jt1."TransId",jt1."Line_ID"
	
	),
	------------------------------------------------------------------------------------
 banking As (
 SELECT distinct --outgoing payment debtor hits twice because of downpayment
 a."CardCode", jd."TransId", 
 IFNULL((CASE WHEN jd."TransType" = 24 THEN nm1."SeriesName" WHEN jd."TransType" = 46 THEN nm2."SeriesName" END) || '/', '') 
 || (CASE WHEN jd."TransType" = 24 THEN CAST(rct."DocNum" AS varchar) 
 WHEN jd."TransType" = 46 THEN CAST(vpm."DocNum" AS varchar) END) AS "DOCREFNO"
 , jdt."RefDate" AS "DocDate"
 , jdt."BaseRef" AS "DocNum"
 , IFNULL('Check No.-' || CAST(r1."CheckNum" AS varchar), 'Check No.-' || CAST(r2."CheckNum" AS varchar)) AS "numatcard"
 ,CASE WHEN :LocalForeign = 'LC' THEN jd1."Credit" ELSE jd1."FCCredit" END as "Debit" --changes on 06-12-2019 debit credit opposit TransId 85880
 ,  CASE WHEN :LocalForeign = 'LC' THEN jd1."Debit" ELSE jd1."FCDebit" END   AS "Credit" --changes on 06-12-2019 debit credit opposit TransId 85880
 , jd."TransType"
 , IFNULL(ac."Segment_0" || '-' || ac."Segment_1", ac."FormatCode") || ' - ' || ac."AcctName" AS "AcctName"
 , a."CardName" AS "Creditor"
 ,DAYOFMONTH(jh."RefDate") AS "Dt"
 , month(jh."RefDate") AS "Mnth"
 , year(jh."RefDate") AS "yr1"
 , (CASE WHEN jdt."TransType" = 24 THEN RCT."Comments" WHEN jdt."TransType" = 46 THEN vpm."Comments" WHEN jdt."TransType" = 30 THEN jdt."Memo" END) AS "Comments" 
 ,jd1."Line_ID"
  ,'' "Reconcile_Detail"
  
 FROM OCRD a 
 INNER JOIN JDT1 jd ON jd."ShortName" = a."CardCode"
  LEFT OUTER JOIN OJDT jdt ON jd."TransId" = jdt."TransId" 
  INNER JOIN OJDT jh ON jh."TransId" = jd."TransId" 
  INNER JOIN JDT1 jd1 ON jd."TransId" = jd1."TransId"
   INNER JOIN OACT ac ON ac."AcctCode" = jd1."Account"
   LEFT OUTER JOIN ORCT RCT ON jdt."TransId" = rct."TransId" AND jdt."TransType" = 24 AND rct."Canceled" = 'N'
    LEFT OUTER JOIN RCT1 r1 ON RCT."DocEntry" = r1."DocNum" AND r1."LineID" = 0
	 LEFT OUTER JOIN NNM1 nm1 ON rct."Series" = nm1."Series" 
	 LEFT OUTER JOIN OVPM VPM ON jdt."TransId" = VPM."TransId" AND jdt."TransType" = 46 AND vpm."Canceled" = 'N'
	  LEFT OUTER JOIN VPM1 r2 ON VPM."DocEntry" = r2."DocNum" AND r2."LineID" = 0 
	  LEFT OUTER JOIN NNM1 nm2 ON nm2."Series" = vpm."Series" 
	  WHERE a."CardType" = 'S' AND jd."TransType" IN (24,46) and
	  -----------------Start Changes on 23-11-2019----------------------
	  --AND 
	  IFNULL(jd1."ShortName", '  ') <> a."CardCode" ---changes on 06-12-2019 outgoing Payment j.e.  issue, D032, transid=72745
	  -- IFNULL(jd1."ContraAct", '  ') = a."CardCode"
	   ----------------END Changes on 23-11-2019--------------------------------------------------
	  AND 
	  (CASE WHEN jd."TransType" = 24 THEN CAST(rct."Canceled" AS varchar) WHEN jd."TransType" = 46 
	  THEN CAST(vpm."Canceled" AS varchar) END) = 'N' 
	  AND jd."RefDate" >= :fromdate AND jd."RefDate" <= :todate AND a."CardName" || '-' || a."CardCode" >= :FromCREDITOR 
	  AND a."CardName" || '-' || a."CardCode" <= :ToCREDITOR AND 
	  (CASE WHEN jd."TransType" = 24 THEN CAST(rct."DocNum" AS varchar) WHEN jd."TransType" = 46 THEN 
	  CAST(vpm."DocNum" AS varchar) ELSE '' END) <> ''
	   order by jd."TransId",jd1."Line_ID"
) 

SELECT final.*, IFNULL(cte1.OB, 0) AS "OB", IFNULL(cte1."obfc", 0) AS "OBFC", op."OPENING BALANCE" 
FROM (SELECT * FROM Invoice UNION ALL SELECT * FROM banking) AS Final 
LEFT OUTER JOIN OCRD b ON b."CardCode" = final."CardCode" 
LEFT OUTER JOIN Cte1 ON b."CardCode" = cte1."ShortName" 
LEFT OUTER JOIN OpeningBalance op ON b."CardCode" = op."CardCode" 
CROSS JOIN OADM WHERE "CardType" = 'S' AND b."CardName" || '-' || b."CardCode" >= IFNULL(:fromCREDITOR, b."CardName" || '-' || b."CardCode") 
AND b."CardName" || '-' || b."CardCode" <= IFNULL(:ToCREDITOR, b."CardName" || '-' || b."CardCode") 
ORDER BY final."CardCode", year("DocDate"),month("DocDate"),DAYOFMONTH("DocDate"), "DocNum",final."Line_ID"  ;
end