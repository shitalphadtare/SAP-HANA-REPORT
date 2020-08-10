CREATE procedure "CreditorsLedger"
(
In Fromdate timestamp
,IN ToDate timestamp
,IN FromCreditors nvarchar(100)
,IN ToCreditors nvarchar(100)
,IN LocalForeign  nvarchar(100)

)
LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER
--READ SQL DATA 
AS
 Begin
 with Cte1  
 AS  
(  SELECT "ShortName", SUM("Debit") - SUM("Credit") AS "OB"
, SUM("FCDebit") - SUM("FCCredit") AS "obfc" 
FROM JDT1 WHERE "RefDate" < :Fromdate
 GROUP BY "ShortName"       
),  

OpeningBalance  as
  ( 
	SELECT IFNULL(H."FormatCode", B."ShortName") AS "Shortnme", c."CardCode",
	
	  CASE WHEN :LocalForeign = 'LC' THEN
	  (SUM(CASE WHEN (A."RefDate" < :Fromdate) THEN (("Debit") - ("Credit")) ELSE 0 END))
	   ELSE (SUM(CASE WHEN (A."RefDate" < :Fromdate) THEN (("FCDebit") - ("FCCredit")) ELSE 0 END)) 
	   END AS "OPENING BALANCE"
	   FROM OJDT a 
	   INNER JOIN JDT1 b ON a."TransId" = b."TransId" 
	   INNER JOIN OCRD c ON b."ShortName" = c."CardCode" 
	   LEFT OUTER JOIN OACT h ON h."AcctCode" = b."ShortName" 
	   CROSS JOIN OADM 
	   WHERE a."RefDate" <= :Fromdate AND C."CardType" = 'S' AND 
	  c."CardName" || '-' || c."CardCode" >= :FromCreditors AND c."CardName" || '-' || c."CardCode" <= :ToCreditors 
	GROUP BY b."ShortName", c."CardName", H."FormatCode", c."CardCode"),
 ---------------------------------------------
 APInvoice  
AS  
(  SELECT 'APInvoice' AS "CTEType", c."ShortName" AS "CardCode", 
(c."ShortName" || '-' || cd."CardName") AS "CardName", A."DocNum", 
B."TransType", a."TransId", A."DocDate",
 E."SeriesName" || '/ ' || CAST(A."DocNum" AS nvarchar(50)) AS "DOCREFNO",
  A."NumAtCard", A."Comments", (CASE WHEN :LocalForeign = 'LC' THEN A."DocTotal" else A."DocTotalFC" end) "DocTotal", NULL AS "ACCOUNT", NULL AS "AcctName", 
  C."Debit" AS "Debit", C."Credit" AS "Credit", NULL AS "Amount", NULL AS "CheckNo", NULL AS "CheckDt", 
  NULL AS "OnAccountAmt", SUM("FCDebit") AS "FCDebit", SUM("FCCredit") AS "FCCredit", NULL AS "ProfitCode", 
  NULL AS "InvoiceRef", NULL AS "InvoiceRefSeriesName", 0 AS "AmountPaid", 0 AS "AmountPaidFC", NULL AS "Project", 
  'OPCH' AS "TableName", a."DocEntry" AS "Data", A."DocCur" AS "DocCurrency", 
  (CASE WHEN RIGHT(LEFT(right(B."RefDate", 23), 6), 2) = '' THEN '0' ELSE RIGHT(LEFT(right(B."RefDate", 23), 6), 2) END) AS "Dt"
  , left(CAST(B."RefDate" AS varchar(10)), 2) AS "Mnth", RIGHT(LEFT(right(B."RefDate", 23), 12), 5) AS "yr1" 
  FROM OPCH A 
  INNER JOIN OJDT B ON A."TransId" = B."TransId" 
  INNER JOIN JDT1 C ON B."TransId" = C."TransId" 
  INNER JOIN NNM1 E ON E."Series" = A."Series" 
  INNER JOIN OCRD cd ON cd."CardCode" = c."ShortName" 
  WHERE ("Debit" <> 0 OR "Credit" <> 0) 
  AND A."DocDate" BETWEEN :Fromdate AND :ToDate AND B."TransType" = 18 
  GROUP BY c."ShortName", CD."CardName", A."DocNum", B."TransType", a."TransId", A."DocDate", E."SeriesName",
   A."NumAtCard", A."Comments", A."DocTotal", a."DocEntry",A."DocTotalFC", A."DocCur", C."Debit", C."Credit", B."RefDate"
   ),  
-------------------------------------------
 APInvoiceDetails  
AS  
(  
SELECT 'APInvoiceDetails' AS "CTEType", "A"."CardCode" AS "CardCode", 
("A"."CardCode" || '-' || "A"."CardName") AS "CardName", "A"."DocNum", B."TransType", "A"."TransId"
, "A"."DocDate", "A"."DOCREFNO","A"."NumAtCard", "A"."Comments", "A"."DocTotal" "DocTotal",
 d."Segment_0" || '-' || d."Segment_1" AS "ACCOUNT", d."AcctName", 0 AS "Debit", 0 AS "Credit",
  NULL AS "Amount", NULL AS "CheckNo", NULL AS "CheckDt", NULL AS "OnAccountAmt", 0 AS "FCDebit",
   0 AS "FCCredit", '' AS "ProfitCode", NULL AS "InvoiceRef", NULL AS "InvoiceRefSeriesName",
    c."Credit" - c."Debit" AS "AmountPaid", c."FCCredit" - c."FCDebit" AS "AmountPaidFC", 
	NULL AS "Project", 'OPCH' AS "TableName", "A"."Data" AS "Data", "A"."DocCurrency", 
	(CASE WHEN RIGHT(LEFT(right(B."RefDate", 23), 6), 2) = '' THEN '0' ELSE RIGHT(LEFT(right(B."RefDate", 23), 6), 2) END) AS "Dt",
	 left(CAST(B."RefDate" AS varchar(10)), 2) AS "Mnth", RIGHT(LEFT(right(B."RefDate", 23), 12), 5) AS "yr1"
	 
	  FROM APInvoice "A" 
	  INNER JOIN OJDT B ON "A"."TransId" = B."TransId" 
	  INNER JOIN JDT1 C ON B."TransId" = C."TransId" 
	  INNER JOIN OACT D ON D."AcctCode" = C."Account" 
	  WHERE (c."Debit" <> 0 OR c."Credit" <> 0) AND c."ShortName" <> "A"."CardCode"
 AND "A"."DocDate" BETWEEN :Fromdate AND :ToDate AND B."TransType" = 18         
),   
----------------------------------------------------------
APDOWNPAYMENT AS
(
     
 SELECT 'APDOWNPAYMENT' AS "CTEType", c."ShortName" AS "CardCode", 
 (c."ShortName" || '-' || cd."CardName") AS "CardName", A."DocNum", B."TransType",
  a."TransId", A."DocDate", E."SeriesName" || '/ ' || CAST(A."DocNum" AS nvarchar(50)) AS "DOCREFNO", 
  A."NumAtCard", A."Comments", (CASE WHEN :LocalForeign = 'LC' THEN A."DocTotal" else A."DocTotalFC" end) "DocTotal", NULL AS "ACCOUNT", NULL AS "AcctName", C."Debit" AS "Debit",
   C."Credit" AS "Credit", NULL AS "Amount", NULL AS "CheckNo", NULL AS "CheckDt", NULL AS "OnAccountAmt", 
   SUM("FCDebit") AS "FCDebit", SUM("FCCredit") AS "FCCredit", NULL AS "ProfitCode", NULL AS "InvoiceRef", 
   NULL AS "InvoiceRefSeriesName", 0 AS "AmountPaid", 0 AS "AmountPaidFC", NULL AS "Project", 'ODPO' AS "TableName",
    a."DocEntry" AS "Data", A."DocCur" AS "DocCurrency", (CASE WHEN RIGHT(LEFT(right(B."RefDate", 23), 6), 2) = '' 
	THEN '0' ELSE RIGHT(LEFT(right(B."RefDate", 23), 6), 2) END) AS "Dt", left(CAST(B."RefDate" AS varchar(10)), 2) AS "Mnth",
	 RIGHT(LEFT(right(B."RefDate", 23), 12), 5) AS "yr1" 
	 
	 FROM ODPO A 
	 INNER JOIN OJDT B ON A."TransId" = B."TransId" 
	 INNER JOIN JDT1 C ON B."TransId" = C."TransId" 
	 INNER JOIN NNM1 E ON E."Series" = A."Series" 
	 INNER JOIN OCRD cd ON cd."CardCode" = c."ShortName" 
	 WHERE ("Debit" <> 0 OR "Credit" <> 0) 
	 AND A."DocDate" BETWEEN :Fromdate AND :ToDate AND B."TransType" = 204 
	 GROUP BY c."ShortName", CD."CardName", A."DocNum", B."TransType", a."TransId", 
	 A."DocDate", E."SeriesName", A."NumAtCard", A."Comments", A."DocTotal",A."DocTotalFC", a."DocEntry", A."DocCur",
	  C."Debit", C."Credit", B."RefDate"   
),
--------------------------------------------------
APDOWNPAYMENTDETAILS AS
(
SELECT 'APdDownPaymentDetails' AS "CTEType", "A"."CardCode" AS "CardCode",
 ("A"."CardCode" || '-' || "A"."CardName") AS "CardName", "A"."DocNum", B."TransType",
  "A"."TransId", "A"."DocDate", "A"."DOCREFNO", "A"."NumAtCard", "A"."Comments", A."DocTotal" "DocTotal", 
  d."Segment_0" || '-' || d."Segment_1" AS "ACCOUNT", d."AcctName", 0 AS "Debit", 0 AS "Credit",
   NULL AS "Amount", NULL AS "CheckNo", NULL AS "CheckDt", NULL AS "OnAccountAmt", 0 AS "FCDebit", 0 AS "FCCredit",
    '' AS "ProfitCode", NULL AS "InvoiceRef", NULL AS "InvoiceRefSeriesName", c."Credit" - c."Debit" AS "AmountPaid",
	 c."FCCredit" - c."FCDebit" AS "AmountPaidFC", NULL AS "Project", 'ODPO' AS "TableName", "A"."Data" AS "Data", 
	 "A"."DocCurrency", (CASE WHEN RIGHT(LEFT(right(B."RefDate", 23), 6), 2) = '' THEN '0' ELSE
	  RIGHT(LEFT(right(B."RefDate", 23), 6), 2) END) AS "Dt", left(CAST(B."RefDate" AS varchar(10)), 2) AS "Mnth",
	   RIGHT(LEFT(right(B."RefDate", 23), 12), 5) AS "yr1" 
	   
	   FROM APDOWNPAYMENT "A"
	   INNER JOIN OJDT B ON "A"."TransId" = B."TransId" 
	   INNER JOIN JDT1 C ON B."TransId" = C."TransId" 
	   INNER JOIN OACT D ON D."AcctCode" = C."Account" WHERE (c."Debit" <> 0 OR c."Credit" <> 0) AND c."ShortName" <> "A"."CardCode" 
AND "A"."DocDate" BETWEEN :Fromdate AND :ToDate AND B."TransType" = 104
),

--------------------------------------
  APCreditMemo  
AS  
(  
 SELECT 'APCreditMemo' AS "CTEType", c."ShortName" AS "CardCode", (c."ShortName" || '-' || cd."CardName") AS "CardName", 
 A."DocNum", B."TransType", a."TransId", A."DocDate", E."SeriesName" || '/ ' || CAST(A."DocNum" AS nvarchar(50)) AS "DOCREFNO", 
 A."NumAtCard", A."Comments", (CASE WHEN :LocalForeign = 'LC' THEN A."DocTotal" else A."DocTotalFC" end) "DocTotal", NULL AS "ACCOUNT", NULL AS "AcctName", C."Debit" AS "Debit", C."Credit" AS "Credit",
  NULL AS "Amount", NULL AS "CheckNo", NULL AS "CheckDt", NULL AS "OnAccountAmt", SUM("FCDebit") AS "FCDebit", 
  SUM("FCCredit") AS "FCCredit", NULL AS "ProfitCode", NULL AS "InvoiceRef", NULL AS "InvoiceRefSeriesName", 
  0 AS "AmountPaid", 0 AS "AmountPaidFC", NULL AS "Project", 'orpc' AS "TableName", a."DocEntry" AS "Data",
   A."DocCur" AS "DocCurrency", (CASE WHEN RIGHT(LEFT(right(B."RefDate", 23), 6), 2) = '' THEN '0' ELSE 
   RIGHT(LEFT(right(B."RefDate", 23), 6), 2) END) AS "Dt", left(CAST(B."RefDate" AS varchar(10)), 2) AS "Mnth",
    RIGHT(LEFT(right(B."RefDate", 23), 12), 5) AS "yr1" 
	
	FROM ORPC A
	INNER JOIN OJDT B ON A."TransId" = B."TransId" 
	INNER JOIN JDT1 C ON B."TransId" = C."TransId" 
	INNER JOIN OACT D ON D."AcctCode" = C."Account" 
	INNER JOIN NNM1 E ON E."Series" = A."Series" 
	INNER JOIN OCRD cd ON cd."CardCode" = c."ShortName" 
	WHERE ("Debit" <> 0 OR "Credit" <> 0) 
	AND A."DocDate" BETWEEN :Fromdate AND :ToDate AND B."TransType" = 19 
	GROUP BY c."ShortName", CD."CardName", A."DocNum", B."TransType", a."TransId", A."DocDate", E."SeriesName", 
	A."NumAtCard", A."Comments",
  A."DocTotal",A."DocTotalFC", a."DocEntry", A."DocCur", C."Debit", C."Credit", B."RefDate"             
),  
----------------------------------------------------------
APCreditMemoDetails  
AS  
(  
SELECT 'APCreditMemoDetails' AS "CTEType", "A"."CardCode" AS "CardCode", ("A"."CardCode" || '-' || "A"."CardName") AS "CardName", 
"A"."DocNum", B."TransType", "A"."TransId", "A"."DocDate", "A"."DOCREFNO", "A"."NumAtCard", 
"A"."Comments",  A."DocTotal"  "DocTotal", d."Segment_0" || '-' || d."Segment_1" AS "ACCOUNT", d."AcctName", 0 AS "Debit", 0 AS "Credit", 
NULL AS "Amount", NULL AS "CheckNo", NULL AS "CheckDt", NULL AS "OnAccountAmt", 0 AS "FCDebit", 0 AS "FCCredit", '' AS "ProfitCode",
 NULL AS "InvoiceRef", NULL AS "InvoiceRefSeriesName", c."Credit" - c."Debit" AS "AmountPaid", 
 c."FCCredit" - c."FCDebit" AS "AmountPaidFC", NULL AS "Project", 'orpc' AS "TableName", "A"."Data" AS "Data", "A"."DocCurrency", 
 (CASE WHEN RIGHT(LEFT(right(B."RefDate", 23), 6), 2) = '' THEN '0' ELSE RIGHT(LEFT(right(B."RefDate", 23), 6), 2) END) AS "Dt", 
 left(CAST(B."RefDate" AS varchar(10)), 2) AS "Mnth", RIGHT(LEFT(right(B."RefDate", 23), 12), 5) AS "yr1" 
 
 FROM APCreditMemo "A"
 INNER JOIN OJDT B ON "A"."TransId" = B."TransId" 
 INNER JOIN JDT1 C ON B."TransId" = C."TransId" 
 INNER JOIN OACT D ON D."AcctCode" = C."Account" 
 WHERE (c."Debit" <> 0 OR c."Credit" <> 0) AND c."ShortName" <> "A"."CardCode" 
AND "A"."DocDate" BETWEEN :Fromdate AND :ToDate AND B."TransType" = 19           
),   
--------------------------------------------------
ManualJE  
AS  
(  
SELECT 'ManualJE' AS "CTEType", F."CardCode", (F."CardCode" || '-' || F."CardName") AS "CardName",
 A."DocSeries", A."ObjType", a."TransId", A."RefDate", B."SeriesName" || '/ ' || CAST(A."DocSeries" AS nvarchar(50)) AS "DOCREFNO",
  A."Memo" AS "NUMATCARD", C."LineMemo", A."LocTotal", d."Segment_0" || '-' || d."Segment_1" AS "ACCOUNT", NULL AS "AcctName",
   C."Debit", C."Credit", NULL AS "Amount", NULL AS "CheckNo", NULL AS "CheckDt", NULL AS "OnAccountAmt", "FCDebit", "FCCredit",
    '' AS "ProfitCode", NULL AS "InvoiceRef", NULL AS "InvoiceRefSeriesName", 0 AS "AmountPaid", 0 AS "AmountPaidFC", C."Project",
	 'OJDT' AS "TableName", a."TransId" AS "Data", NULL AS "DocCurrency", 
	 (CASE WHEN RIGHT(LEFT(right(A."RefDate", 23), 6), 2) = '' THEN '0' ELSE RIGHT(LEFT(right(A."RefDate", 23), 6), 2) END) AS "Dt", 
	 left(CAST(A."RefDate" AS varchar(10)), 2) AS "Mnth", RIGHT(LEFT(right(A."RefDate", 23), 12), 5) AS "yr1" 
	 
	 FROM OJDT A 
	 INNER JOIN NNM1 B ON A."Series" = b."Series" 
	 INNER JOIN JDT1 C ON A."TransId" = C."TransId" 
	 INNER JOIN OACT d ON d."AcctCode" = c."Account" 
	 INNER JOIN OCRD F ON F."CardCode" = C."ShortName" 
	 WHERE ("Debit" <> 0 OR "Credit" <> 0) AND A."RefDate" >= :Fromdate AND A."RefDate" <= :ToDate 
AND A."TransType" NOT IN (13,14,18,19,24,46,204) 
),  
-------------------------------------------------               
Incoming as (  
SELECT 'Incoming' AS "CTEType", a."CardCode", a."CardName", IFNULL(rc."DocNum", jh."BaseRef") AS "DocNum", jh."TransType", 
jh."TransId", IFNULL(rc."DocDate", jh."RefDate") AS "DocDate", 
IFNULL(CAST(n1."SeriesName" AS varchar(5000)), 'Cancelled') || '/' || CAST(IFNULL(rc."DocNum", jh."BaseRef") AS nvarchar(50)) AS "DOCREFNO",
 NULL AS "NUMATCARD", IFNULL(rc."Comments", jh."Memo") AS "Comments", (CASE WHEN :LocalForeign = 'LC' THEN rc."DocTotal" else rc."DocTotalFC" end) "DocTotal", 
 ac."Segment_0" || '-' || ac."Segment_1" AS "ACCOUNT", ac."AcctName", jd1."Credit", jd1."Debit", 
 SUM(IFNULL(jd."Debit", 0) - IFNULL(jd."Credit", 0)) AS "Amount", r1."CheckNum" AS "CheckNo", r1."U_ChequeDate" AS "chequedt", 
 NULL AS "OnAccountAmt", jd1."FCCredit" AS "FCDebit", jd1."FCDebit" AS "FCCredit", '' AS "ProfitCode", NULL AS "InvoiceRef", 
 NULL AS "invoicerefseries", NULL AS "AmountPaid", 0 AS "AmountPaidFC", rc."PrjCode" AS "Project", 'ORCT' AS "TableName", 
 rc."DocEntry" AS "Data", rc."DocCurr" AS "DocCurrency", 
 (CASE WHEN RIGHT(LEFT(right(jh."RefDate", 23), 6), 2) = '' THEN '0' ELSE RIGHT(LEFT(right(jh."RefDate", 23), 6), 2) END) AS "Dt", 
 left(CAST(jh."RefDate" AS varchar(10)), 2) AS "Mnth", RIGHT(LEFT(right(jh."RefDate", 23), 12), 5) AS "yr1" 
 
 FROM OCRD a 
 INNER JOIN JDT1 jd ON jd."ShortName" = a."CardCode" 
 INNER JOIN OJDT jh ON jh."TransId" = jd."TransId" 
 INNER JOIN JDT1 jd1 ON jd."TransId" = jd1."TransId" 
 INNER JOIN OACT ac ON ac."AcctCode" = jd1."Account" 
 LEFT OUTER JOIN ORCT rc ON rc."TransId" = jh."TransId" 
 LEFT OUTER JOIN RCT1 r1 ON rc."DocEntry" = r1."DocNum" AND r1."LineID" = 0 
 LEFT OUTER JOIN NNM1 n1 ON rc."Series" = n1."Series" 
 WHERE jh."TransType" = 24 AND IFNULL(jd1."ShortName", '  ') <> a."CardCode" 
 AND jh."RefDate" BETWEEN :Fromdate AND :ToDate 
 GROUP BY rc."DocNum", a."CardCode", a."CardName", ac."Segment_0", ac."Segment_1", jh."Memo", jh."TransId", ac."AcctName", 
 rc."DocTotal",rc."DocTotalFC", jh."TransType", rc."DocDate", jd1."ShortName", jd1."Debit", jd1."Credit", jd1."FCCredit", jd1."FCDebit", 
 rc."PrjCode", rc."Comments", jh."BaseRef", jh."RefDate", n1."SeriesName", r1."CheckNum", r1."U_ChequeDate", jd1."Account", 
 rc."DocEntry", rc."DocCurr"
 
 ),  
   ----------------------------------------------------------
IncomingPaymentDetails as (  
SELECT 'IncomingPaymentDetails' AS "CTEType", a."CardCode", a."CardName", rc."DocNum", 24 AS "transtype", rc."TransId", 
rc."DocDate", NULL AS "DOCREFNO", NULL AS "NUMATCARD", NULL AS "Comments", NULL AS "DocTotal", NULL AS "ACCOUNT", NULL AS "AcctName",
 NULL AS "Debit", NULL AS "credit", NULL AS "Amount", NULL AS "CheckNo", NULL AS "chequedt", NULL AS "OnAccountAmt", NULL AS "FCDebit",
  NULL AS "FCCredit", NULL AS "ProfitCode", COALESCE(e."DocNum", g."DocNum", r2."DocTransId") AS "InvoiceRef", 
  COALESCE(f."SeriesName", h."SeriesName", 'JE') AS "invoicerefseries", r2."SumApplied" AS "AmountPaid", 
  r2."AppliedFC" AS "AmountPaidFC", NULL AS "Project", 'ORCT' AS "TableName", rc."DocEntry" AS "Data", rc."DocCurr" AS "DocCurrency", 
  (CASE WHEN RIGHT(LEFT(right(rc."DocDate", 23), 6), 2) = '' THEN '0' ELSE RIGHT(LEFT(right(rc."DocDate", 23), 6), 2) END) AS "Dt",
   left(CAST(rc."DocDate" AS varchar(10)), 2) AS "Mnth", RIGHT(LEFT(right(rc."DocDate", 23), 12), 5) AS "yr1"
   
    FROM OCRD a 
	INNER JOIN ORCT rc ON rc."CardCode" = a."CardCode" 
	INNER JOIN RCT2 r2 ON rc."DocEntry" = r2."DocNum" 
	LEFT OUTER JOIN ORPC e ON e."DocEntry" = r2."DocEntry" AND r2."InvType" = 19 
	LEFT OUTER JOIN NNM1 f ON e."Series" = f."Series" 
	LEFT OUTER JOIN OPCH g ON e."DocEntry" = r2."DocEntry" AND r2."InvType" = 18 
	LEFT OUTER JOIN NNM1 h ON g."Series" = h."Series" 
WHERE rc."DocDate" BETWEEN :Fromdate AND :ToDate), 
 ----------------------------------------------------------  
IncomingOnAccount as (  
SELECT 'IncomingOnAccount' AS "CTEType", a."CardCode", a."CardName", rc."DocNum", 24 AS "transtype", rc."TransId", rc."DocDate",
 NULL AS "DOCREFNO", NULL AS "NUMATCARD", NULL AS "Comments", NULL AS "DocTotal", NULL AS "ACCOUNT", NULL AS "AcctName", 
 NULL AS "Debit", NULL AS "credit", NULL AS "Amount", NULL AS "CheckNo", NULL AS "chequedt", NULL AS "OnAccountAmt", NULL AS "FCDebit",
  NULL AS "FCCredit", NULL AS "ProfitCode", NULL AS "InvoiceRef", 'On Account' AS "invoicerefseries", rc."NoDocSum" AS "AmountPaid", 
  rc."NoDocSumFC" AS "AmountPaidFC", NULL AS "Project", 'ORCT' AS "TableName", rc."DocEntry" AS "Data", rc."DocCurr" AS "DocCurrency",
   (CASE WHEN RIGHT(LEFT(right(rc."DocDate", 23), 6), 2) = '' THEN '0' ELSE RIGHT(LEFT(right(rc."DocDate", 23), 6), 2) END) AS "Dt",
    left(CAST(rc."DocDate" AS varchar(10)), 2) AS "Mnth", RIGHT(LEFT(right(rc."DocDate", 23), 12), 5) AS "yr1" 
	
	FROM OCRD a 
	INNER JOIN ORCT rc ON rc."CardCode" = a."CardCode" 
	WHERE rc."DocDate" BETWEEN :Fromdate AND :ToDate AND rc."NoDocSum" > 0
 ),  
 ------------------------------------------------------
Outgoing as (  
SELECT 'Outgoing' AS "CTEType", a."CardCode", a."CardName", IFNULL(pm."DocNum", jh."BaseRef") AS "DocNum", 
jh."TransType", jh."TransId", IFNULL(pm."DocDate", jh."RefDate") AS "DocDate", IFNULL(CAST(n1."SeriesName" AS varchar(5000)), 
'Cancelled') || '/' || CAST(IFNULL(pm."DocNum", jh."BaseRef") AS nvarchar(50)) AS "DOCREFNO", NULL AS "NUMATCARD", 
IFNULL(pm."Comments", jh."Memo") AS "Comments", (CASE WHEN :LocalForeign = 'LC' THEN pm."DocTotal" else pm."DocTotalFC" end) AS "DocTotal", 
ac."Segment_0" || '-' || ac."Segment_1" AS "ACCOUNT", ac."AcctName", jd1."Credit" AS "Debit", jd1."Debit" AS "credit", 
SUM(IFNULL(jd."Debit", 0) - IFNULL(jd."Credit", 0)) AS "Amount", p1."CheckNum" AS "CheckNo", p1."U_ChequeDate" AS "chequedt", 
NULL AS "OnAccountAmt", jd1."FCCredit" AS "FCDebit", jd1."FCDebit" AS "FCCredit", '' AS "ProfitCode", NULL AS "InvoiceRef", 
NULL AS "invoicerefseries", NULL AS "AmountPaid", 0 AS "AmountPaidFC", pm."PrjCode" AS "Project", 'OVPM' AS "TableName", 
pm."DocEntry" AS "Data", pm."DocCurr" AS "DocCurrency", (CASE WHEN RIGHT(LEFT(right(jh."RefDate", 23), 6), 2) = '' THEN '0' ELSE RIGHT(LEFT(right(jh."RefDate", 23), 6), 2) END) AS "Dt"
, left(CAST(jh."RefDate" AS varchar(10)), 2) AS "Mnth", RIGHT(LEFT(right(jh."RefDate", 23), 12), 5) AS "yr1" 

FROM OCRD a 
INNER JOIN JDT1 jd ON jd."ShortName" = a."CardCode" 
INNER JOIN OJDT jh ON jh."TransId" = jd."TransId" 
INNER JOIN JDT1 jd1 ON jd."TransId" = jd1."TransId" 
INNER JOIN OACT ac ON ac."AcctCode" = jd1."Account" 
LEFT OUTER JOIN OVPM pm ON pm."TransId" = jh."TransId" 
LEFT OUTER JOIN VPM1 p1 ON pm."DocEntry" = p1."DocNum" AND p1."LineID" = 0 
LEFT OUTER JOIN NNM1 n1 ON pm."Series" = n1."Series" 
WHERE jh."TransType" = 46 AND IFNULL(jd1."ShortName", '  ') <> a."CardCode" 
AND jh."RefDate" BETWEEN :Fromdate AND :ToDate 
GROUP BY pm."DocNum", a."CardCode", a."CardName", ac."Segment_0", ac."Segment_1", jh."Memo", jh."TransId", ac."AcctName",
 pm."DocTotal", pm."DocTotalFC",jh."TransType", pm."DocDate", jd1."ShortName", jd1."Debit", jd1."Credit", jd1."FCCredit", jd1."FCDebit", 
 pm."PrjCode", pm."Comments", jh."BaseRef", jh."RefDate", n1."SeriesName"
, p1."CheckNum", p1."U_ChequeDate", jd1."Account", pm."DocEntry", pm."DocCurr"
 
 ),  
   --------------------------------------------------------------------
OutgoingPaymentDetails as (  
SELECT 'OutgoingPaymentDetails' AS "CTEType", a."CardCode", a."CardName", pm."DocNum", 24 AS "transtype", pm."TransId", 
pm."DocDate", NULL AS "DOCREFNO", NULL AS "NUMATCARD", NULL AS "Comments", NULL AS "DocTotal", NULL AS "ACCOUNT", NULL AS "AcctName", 
NULL AS "Debit", NULL AS "credit", NULL AS "Amount", NULL AS "CheckNo", NULL AS "chequedt", NULL AS "OnAccountAmt", NULL AS "FCDebit",
 NULL AS "FCCredit", NULL AS "ProfitCode", COALESCE(e."DocNum", g."DocNum", p2."DocTransId") AS "InvoiceRef", 
 COALESCE(f."SeriesName", h."SeriesName", 'JE') AS "invoicerefseries", p2."SumApplied" AS "AmountPaid", 
 p2."AppliedFC" AS "AmountPaidFC", NULL AS "Project", 'OVPM' AS "TableName", pm."DocEntry" AS "Data", pm."DocCurr" AS "DocCurrency", 
 (CASE WHEN RIGHT(LEFT(right(pm."DocDate", 23), 6), 2) = '' THEN '0' ELSE RIGHT(LEFT(right(pm."DocDate", 23), 6), 2) END) AS "Dt", 
 left(CAST(pm."DocDate" AS varchar(10)), 2) AS "Mnth", RIGHT(LEFT(right(pm."DocDate", 23), 12), 5) AS "yr1" 
 
 FROM OCRD a 
 INNER JOIN OVPM pm ON pm."CardCode" = a."CardCode" 
 INNER JOIN VPM2 p2 ON pm."DocEntry" = p2."DocNum" 
 LEFT OUTER JOIN OPCH e ON e."DocEntry" = p2."DocEntry" AND p2."InvType" = 18 
 LEFT OUTER JOIN NNM1 f ON e."Series" = f."Series" 
 LEFT OUTER JOIN ORPC g ON e."DocEntry" = p2."DocEntry" AND p2."InvType" = 19 
 LEFT OUTER JOIN NNM1 h ON g."Series" = h."Series" 
WHERE pm."DocDate" BETWEEN :Fromdate AND :ToDate
 ),   
 -------------------------------------------------------------------------
OutgoingOnAccount as (  
SELECT 'OutgoingOnAccount' AS "CTEType", a."CardCode", a."CardName", pm."DocNum", 24 AS "transtype", pm."TransId", pm."DocDate",
 NULL AS "DOCREFNO", NULL AS "NUMATCARD", NULL AS "Comments", NULL AS "DocTotal", NULL AS "ACCOUNT", NULL AS "AcctName", 
 NULL AS "Debit", NULL AS "credit", NULL AS "Amount", NULL AS "CheckNo", NULL AS "chequedt", NULL AS "OnAccountAmt", 
 NULL AS "FCDebit", NULL AS "FCCredit", NULL AS "ProfitCode", NULL AS "InvoiceRef", 'On Account' AS "invoicerefseries", 
 pm."NoDocSum" AS "AmountPaid", pm."NoDocSumFC" AS "AmountPaidFC", NULL AS "Project", 'OVPM' AS "TableName", pm."DocEntry" AS "Data", 
 pm."DocCurr" AS "DocCurrency", (CASE WHEN RIGHT(LEFT(right(pm."DocDate", 23), 6), 2) = '' THEN '0' ELSE 
 RIGHT(LEFT(right(pm."DocDate", 23), 6), 2) END) AS "Dt", left(CAST(pm."DocDate" AS varchar(10)), 2) AS "Mnth", 
 RIGHT(LEFT(right(pm."DocDate", 23), 12), 5) AS "yr1" 
 
 FROM OCRD a 
 INNER JOIN OVPM pm ON pm."CardCode" = a."CardCode"
 WHERE pm."DocDate" BETWEEN :Fromdate AND :ToDate AND pm."NoDocSum" > 0
 )  
  -----------------------------------------------------------------------


    ------------------------------------------------
  SELECT b."CardCode" AS "drcode", b."CardName" AS "drname", "FINAL".*, IFNULL(Cte1."OB", 0) AS "ob", 
  IFNULL(Cte1."obfc", 0) AS "obfc", OPRJ."PrjName", "ActCurr" AS "Currency", "op"."OPENING BALANCE" 
  
  FROM 
  (SELECT 'CR' AS "drcr", * FROM APInvoice 
			UNION ALL 
	SELECT 'CR' AS "drcr", * FROM APInvoiceDetails
	UNION ALL 
	SELECT 'CR' AS "drcr", * FROM APDOWNPAYMENT 
	UNION ALL 
	SELECT 'CR' AS "drcr", * FROM APDOWNPAYMENTDETAILS 
	UNION ALL 
	SELECT 'DR' AS "drcr", * FROM APCreditMemo 
	UNION ALL 
	SELECT 'DR' AS "drcr", * FROM APCreditMemoDetails 
	UNION ALL 
	SELECT 'DRCR' AS "drcr", * FROM ManualJE 
	UNION ALL 
	SELECT CASE WHEN "Amount" > 0 THEN 'DR' ELSE 'CR' END AS "drcr", * FROM INComing 
	UNION ALL 
	SELECT CASE WHEN "Amount" > 0 THEN 'DR' ELSE 'CR' END AS "drcr", * FROM IncomingOnAccount 
	UNION ALL 
	SELECT CASE WHEN "Amount" > 0 THEN 'DR' ELSE 'CR' END AS "drcr", * FROM IncomingPaymentDetails 
	UNION ALL 
	SELECT CASE WHEN "Amount" > 0 THEN 'DR' ELSE 'CR' END AS "drcr", * FROM Outgoing 
	UNION ALL 
	SELECT CASE WHEN "Amount" > 0 THEN 'DR' ELSE 'CR' END AS "drcr", * FROM OutgoingOnAccount 
	UNION ALL 
	SELECT CASE WHEN "Amount" > 0 THEN 'DR' ELSE 'CR' END AS "drcr", * FROM OutgoingPaymentDetails
	) AS "FINAL" 
	RIGHT OUTER JOIN OCRD b ON b."CardCode" = "FINAL"."CardCode" 
	LEFT OUTER JOIN Cte1 ON b."CardCode" = Cte1."ShortName" 
	LEFT OUTER JOIN OpeningBalance "op" ON b."CardCode" = "op"."CardCode" 
	LEFT OUTER JOIN OPRJ ON "FINAL"."Project" = OPRJ."PrjCode" 
	LEFT OUTER JOIN OACT ON OACT."AcctCode" = "FINAL"."ACCOUNT" 
	CROSS JOIN OADM 
	WHERE "CardType" = 'S' AND b."CardName" || '-' || b."CardCode" 
	BETWEEN IFNULL(:FromCreditors, b."CardName" || '-' || b."CardCode") 
	AND IFNULL(:ToCreditors, b."CardName" || '-' || b."CardCode") 
	AND (:LocalForeign = 'LC' OR b."Currency" NOT IN ('##',OADM."MainCurncy")) 
  ORDER BY "CardCode", "DocNum", "DocDate", "CTEType";
END