CREATE procedure DebtorsLedger

(IN FromDate Timestamp
,IN ToDate Timestamp,    
IN fromdebtor nvarchar(500)
, IN Todebtor nvarchar(500),     
IN LocalForeign  nvarchar(2) )   
LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER
--READ SQL DATA 
AS
 Begin
 with Cte1 as
(    
SELECT "ShortName", SUM("Debit") - SUM("Credit") AS "OB", SUM("FCDebit") - SUM("FCCredit") AS "obfc" 
FROM JDT1 
WHERE "RefDate" < :fromdate GROUP BY "ShortName"   
          
),    

OpeningBalance  as
  ( 
	SELECT IFNULL(h."FormatCode", B."ShortName") AS "Shortnme", C."CardName", c."CardCode", 
	CASE WHEN :LocalForeign = 'LC' THEN (SUM(CASE WHEN (A."RefDate" < :FromDate) THEN 
	(IFNULL("Debit", 0) - IFNULL("Credit", 0)) ELSE 0 END)) 
	ELSE (SUM(CASE WHEN (A."RefDate" < :FromDate) 
	THEN (IFNULL("FCDebit", 0) - IFNULL("FCCredit", 0)) ELSE 0 END)) END AS "OPENING BALANCE" 
	FROM OJDT a 
	INNER JOIN JDT1 b ON a."TransId" = b."TransId" 
	INNER JOIN OCRD c ON b."ShortName" = c."CardCode" 
	LEFT OUTER JOIN OACT h ON h."AcctCode" = b."ShortName" 
	CROSS JOIN OADM 
	WHERE a."RefDate" <= :Todate AND C."CardType" = 'C' AND c."CardName" || '-' || c."CardCode" >= :FromDebtor 
	AND c."CardName" || '-' || c."CardCode" <= :ToDebtor 
	GROUP BY b."ShortName", c."CardName", H."FormatCode", c."CardCode" ),
	
	
INVOICE as(
SELECT crd."CardCode", 
		jt1."TransId", 
		IFNULL((CASE WHEN jdt."TransType" in (30,321) --changes for Manual reconcilation 321 transaction added
				 THEN nm1."SeriesName" 
				WHEN jdt."TransType" = 13 THEN nm2."SeriesName" 
				WHEN jdt."TransType" = 14 THEN nm3."SeriesName" 
				WHEN jdt."TransType" = 203 THEN nm4."SeriesName" END) || '/', '') || jdt."BaseRef" AS "DOCREFNO", 
	  jdt."RefDate" AS "DocDate", 
	  jdt."BaseRef" AS "DocNum", 
	  IFNULL((CASE WHEN jdt."TransType" in (30) --changes for Manual reconcilation 321 transaction added
				  THEN jdt."Memo" 
				  WHEN jdt."TransType" = 13 THEN inv."NumAtCard" 
				  WHEN jdt."TransType" = 14 THEN rin."NumAtCard" 
				  WHEN jdt."TransType" = 203 THEN DPi."NumAtCard" 
 end),'')
  AS "NumAtCard"

, CASE WHEN :LocalForeign = 'LC' THEN jt1."Debit" ELSE 
 jt1."FCDebit" END AS "Debit", CASE WHEN :LocalForeign = 'LC' THEN jt1."Credit" ELSE jt1."FCCredit" END AS "Credit",
  jt1."TransType",
   case when JDT."TransType"= 321 then act1."AcctName" else Crd."CardName" end AS "AcctName" --changes for Manual reconcilation 321 transaction added
   
   , crd."CardName" AS "Creditor",
   Dayofmonth(jt1."RefDate") AS "Dt", month(jt1."RefDate") AS "Mnth", year(jt1."RefDate") AS "yr1", 
   IFNULL((CASE WHEN jdt."TransType" in (30,321) --changes for Manual reconcilation 321 transaction added
   THEN jdt."Memo" WHEN jdt."TransType" = 13 THEN inv."Comments" 
   WHEN jdt."TransType" = 14 THEN rin."Comments" WHEN jdt."TransType" = 203 THEN DPi."Comments" END), '') AS "Comments",
    crg."GroupName" 
    ----changes on 25-11-2019
    ,Jt1."Line_ID"
    --changes for Manual reconcilation 321 transaction added
,case when jdt."TransType" = 321 then (select "Recon_Doc" from Reconcilation_Details where "ReconNum"=jdt."CreatedBy") 
else '' end "Reconcile_Detail"
    FROM OCRD crd 
    LEFT OUTER JOIN OCRG crg ON crd."GroupCode" = crg."GroupCode" 
    LEFT OUTER JOIN JDT1 jt1 ON crd."CardCode" = jt1."ShortName"
    left outer join OACT ACT1 on ACT1."AcctCode"=Jt1."ContraAct" --changes for Manual reconcilation 321 transaction added 
    LEFT OUTER JOIN OJDT jdt ON jt1."TransId" = jdt."TransId" 
    LEFT OUTER JOIN NNM1 nm1 ON jdt."Series" = nm1."Series" 
    LEFT OUTER JOIN OACT act ON jt1."Account" = act."AcctCode" 
    LEFT OUTER JOIN OINV INV ON jt1."TransId" = inv."TransId" AND jt1."TransType" = 13 AND inv.CANCELED = 'N' 
    LEFT OUTER JOIN NNM1 nm2 ON inv."Series" = nm2."Series" 
    LEFT OUTER JOIN ORIN RIN ON jt1."TransId" = rin."TransId" AND jt1."TransType" = 14 AND rin.CANCELED = 'N' 
    LEFT OUTER JOIN NNM1 nm3 ON RIN."Series" = nm3."Series" 
    LEFT OUTER JOIN ODPI DPI ON jt1."TransId" = DPI."TransId" AND jt1."TransType" = 203 AND DPI.CANCELED = 'N' 
    LEFT OUTER JOIN NNM1 nm4 ON DPI."Series" = nm4."Series" WHERE crd."CardType" = 'C' 
    AND jt1."TransType" IN (13,14,30,203,321)--changes for Manual reconcilation 321 transaction added
     AND (CASE WHEN jdt."TransType" in (30,321) --changes for Manual reconcilation 321 transaction added
     THEN 'N' WHEN jdt."TransType" = 13 THEN
     inv.CANCELED WHEN jdt."TransType" = 14 THEN rin.CANCELED WHEN jdt."TransType" = 203 THEN DPi.CANCELED END) = 'N' 
     AND jt1."RefDate" >= :fromdate AND jt1."RefDate" <= :todate AND crd."CardName" || '-' || crd."CardCode" >= :FromDebtor
      AND crd."CardName" || '-' || crd."CardCode" <= :ToDebtor
      order by jt1."TransId",jt1."Line_ID"
      ),
 banking As (
 SELECT a."CardCode", jd."TransId", 
 IFNULL((CASE WHEN jd."TransType" = 24 THEN nm1."SeriesName" WHEN jd."TransType" = 46 THEN nm2."SeriesName" END) || '/', '') || jdt."BaseRef" AS "DOCREFNO", 
 jdt."RefDate" AS "DocDate", jdt."BaseRef" AS "DocNum", 
 IFNULL('Check No.-' || CAST( r1."U_ChequeNo"--changes on 26-11-2019 r1."CheckNum" 
  AS varchar), 'Check No.-' || CAST(r2."CheckNum" AS varchar)) AS "NumAtCard", 
 CASE WHEN :LocalForeign = 'LC' THEN jd1."Credit" ELSE jd1."FCCredit" END AS "Debit", 
 CASE WHEN :LocalForeign = 'LC' THEN jd1."Debit" ELSE jd1."FCDebit" END AS "Credit", 
 jd."TransType", 
 IFNULL(ac."FormatCode" || '  ', '') || ac."AcctName" AS "AcctName", a."CardName" AS "Creditor",
  Dayofmonth(jh."RefDate") AS "Dt", month(jh."RefDate") AS "Mnth", year(jh."RefDate") AS "yr1", 
  IFNULL((CASE WHEN jdt."TransType" = 24 THEN RCT."Comments" WHEN jdt."TransType" = 46 THEN VPM."Comments" END), '') AS "Comments", 
  crg."GroupName"
,jd1."Line_ID"
 ,'' "Reconcile_Detail"
  FROM OCRD a 
  LEFT OUTER JOIN OCRG crg ON a."GroupCode" = crg."GroupCode" 
  INNER JOIN JDT1 jd ON jd."ShortName" = a."CardCode" 
  LEFT OUTER JOIN OJDT jdt ON jd."TransId" = jdt."TransId" 
  INNER JOIN OJDT jh ON jh."TransId" = jd."TransId" 
  INNER JOIN JDT1 jd1 ON jd."TransId" = jd1."TransId" 
  INNER JOIN OACT ac ON ac."AcctCode" = jd1."Account" 
  LEFT OUTER JOIN ORCT RCT ON jdt."TransId" = rct."TransId"  AND rct."Canceled" = 'N'-- AND jdt."TransType" = 24
  LEFT OUTER JOIN RCT1 r1 ON RCT."DocEntry" = r1."DocNum" AND r1."LineID" = 0 
  LEFT OUTER JOIN NNM1 nm1 ON rct."Series" = nm1."Series" 
  LEFT OUTER JOIN OVPM VPM ON jdt."TransId" = VPM."TransId" AND vpm."Canceled" = 'N' -- AND jdt."TransType" = 46
  LEFT OUTER JOIN VPM1 r2 ON VPM."DocEntry" = r2."DocNum" AND r2."LineID" = 0 LEFT OUTER JOIN NNM1 nm2 ON nm2."Series" = vpm."Series" WHERE a."CardType" = 'C' AND jd."TransType" IN (24,46) AND (CASE WHEN jd."TransType" = 24 THEN CAST(rct."Canceled" AS varchar) WHEN jd."TransType" = 46 THEN CAST(vpm."Canceled" AS varchar) END) = 'N' AND IFNULL(jd1."ShortName", '  ') <> a."CardCode" AND jd."RefDate" >= :fromdate AND jd."RefDate" <= :todate AND a."CardName" || '-' || a."CardCode" >= :FromDebtor AND a."CardName" || '-' || a."CardCode" <= :ToDebtor AND (CASE WHEN jd."TransType" = 24 THEN CAST(rct."DocNum" AS varchar) WHEN jd."TransType" = 46 THEN CAST(vpm."DocNum" AS varchar) ELSE '' END) <> ''
 order by jd1."TransId",jd1."Line_ID"
) 

SELECT 
---changes on 25-11-2019
final."CardCode",
-----------------
 final."TransId", Final."DOCREFNO", Final."DocDate", Final."DocNum", Final."NumAtCard", 
Final."Debit", Final."Credit", Final."TransType", Final."AcctName", b."CardName" AS "Creditor", 
Final."Dt", Final."Mnth", Final."yr1", Final."Comments", crg."GroupName", 
IFNULL(cte1.OB, 0) AS "OB", IFNULL(cte1."obfc", 0) AS "OBFC", op."OPENING BALANCE" 
,final."Line_ID",final."Reconcile_Detail"
FROM OCRD b 
LEFT OUTER JOIN OCRG crg ON b."GroupCode" = crg."GroupCode" 
LEFT OUTER JOIN OpeningBalance op ON b."CardCode" = op."CardCode" 
LEFT OUTER JOIN (SELECT * FROM Invoice UNION ALL SELECT * FROM banking) AS Final ON b."CardCode" = final."CardCode" 
LEFT OUTER JOIN Cte1 ON b."CardCode" = cte1."ShortName" 
CROSS JOIN OADM 
WHERE "CardType" = 'C' 
AND b."CardName" || '-' || b."CardCode" >= IFNULL(:fromdebtor, b."CardName" || '-' || b."CardCode") 
AND b."CardName" || '-' || b."CardCode" <= IFNULL(:Todebtor, b."CardName" || '-' || b."CardCode") 
ORDER BY final."CardCode", "DocDate", "DocNum",final."Line_ID";  
end