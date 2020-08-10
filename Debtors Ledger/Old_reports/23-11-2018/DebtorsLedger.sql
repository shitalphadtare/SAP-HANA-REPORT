CREATE procedure DebtorsLedger

(
In Fromdate timestamp
,IN ToDate timestamp
,IN FromDebtor nvarchar(100)
,IN ToDebtor nvarchar(100)
,IN LocalForeign  nvarchar(100)

)
LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER
--READ SQL DATA 
AS
 Begin
 with Cte1  
 AS  
(    
SELECT "ShortName", SUM("Debit") - SUM("Credit") AS "OB",
 SUM("FCDebit") - SUM("FCCredit") AS "obfc" 
 FROM JDT1 WHERE "RefDate" < :Fromdate
 GROUP BY "ShortName"
          
),    

OpeningBalance  as
  ( 
	SELECT IFNULL(h."FormatCode", B."ShortName") AS "Shortnme",
	 C."CardName", c."CardCode",
	  CASE WHEN :LocalForeign = 'LC' THEN (SUM(CASE WHEN (A."RefDate" < :FromDate) 
		THEN (IFNULL("Debit", 0) - IFNULL("Credit", 0)) ELSE 0 END)) 
		ELSE (SUM(CASE WHEN (A."RefDate" < :FromDate) 
		THEN (IFNULL("FCDebit", 0) - IFNULL("FCCredit", 0)) ELSE 0 END)) END AS "OPENING BALANCE" 
	FROM OJDT a 
	INNER JOIN JDT1 b ON a."TransId" = b."TransId" 
	INNER JOIN OCRD c ON b."ShortName" = c."CardCode" 
	LEFT OUTER JOIN OACT h ON h."AcctCode" = b."ShortName" 
	CROSS JOIN OADM 
	WHERE a."RefDate" <= :Todate AND C."CardType" = 'C' AND c."CardName" || '-' || c."CardCode" >= :FromDebtor AND c."CardName" || '-' || c."CardCode" <= :ToDebtor
	 GROUP BY b."ShortName", c."CardName", H."FormatCode", c."CardCode"

),

 Invoice    
AS    
(    
		SELECT 'Invoice' AS "CTEType", 
		CASE WHEN cd."FatherCard" IS NULL OR LTRIM(cd."FatherCard") = '' THEN cd."CardCode" ELSE cd."FatherCard" END AS "CardCode",
		 (A."CardCode" || '-' || cd."CardName") AS "CardName",
		  A."DocNum",
		B."TransType",
		a."TransId",
		A."DocDate",
		E."SeriesName" || '/ ' || CAST(A."DocNum" AS nvarchar(50)) AS "DOCREFNO",
		 A."NumAtCard", 
		 A."Comments", 
		  CASE WHEN :LocalForeign = 'LC' THEN A."DocTotal" else A."DocTotalFC" end "DocTotal", 
		 d."FormatCode" AS "ACCOUNT", 
		 D."AcctName", 
		 CASE WHEN :LocalForeign = 'LC' THEN C."Debit" else C."FCDebit" end AS "Debit", 
		  CASE WHEN :LocalForeign = 'LC' THEN C."Credit" else c."FCCredit" end AS "Credit", 
		 NULL AS "Amount", 
		 NULL AS "CHECKNO", 
		 NULL AS "checkdt", 
		 NULL AS "ONACCOUNTAMT", 
		 "FCCredit" AS "FCDebit", 
		 "FCDebit" AS "FCCredit", 
		 NULL AS "ProfitCode", 
		 NULL AS "invoiceref", 
		 NULL AS "invoicerefseriesname", 
		 0 AS "AmountPaid", 
		 0 AS "AmountPaidFC", 
		 C."Project", 
		 'OINV' AS "tablename",
		  CAST(a."DocEntry" AS varchar(5000)) AS "data", 
		  A."DocCur" AS "DocCurrency", 
		  (CASE WHEN RIGHT(LEFT(right(B."RefDate", 23), 6), 2) = '' THEN '0' 
		  ELSE RIGHT(LEFT(right(B."RefDate", 23), 6), 2) END) AS "Dt", 
		  left(CAST(B."RefDate" AS varchar(10)), 2) AS "Mnth", 
		  RIGHT(LEFT(right(B."RefDate", 23), 12), 5) AS "yr1" 
		  
		  FROM OINV A 
		  INNER JOIN OJDT B ON A."TransId" = B."TransId" 
		  INNER JOIN JDT1 C ON B."TransId" = C."TransId" 
		  INNER JOIN OACT D ON D."AcctCode" = C."Account" 
		  INNER JOIN NNM1 E ON E."Series" = A."Series" 
		  INNER JOIN OCRD cd ON cd."CardCode" = a."CardCode" 
		  WHERE cd."CardCode" <> C."ShortName" AND A."DocDate" >= :Fromdate AND A."DocDate" <= :Todate 
		  AND B."TransType" = 13    
),    

CreditMemo    
AS    
(    
	SELECT 'CreditMemo' AS "CTEType", 
	A."CardCode", (A."CardCode" || '-' || "CardName") AS "CardName",
	A."DocNum", 
	B."TransType",
	a."TransId",
	a."DocDate",
	E."SeriesName" || '/ ' || CAST(A."DocNum" AS nvarchar(50)) AS "DOCREFNO", 
	A."NumAtCard", 
	A."Comments", 
	CASE WHEN :LocalForeign = 'LC' THEN A."DocTotal" else A."DocTotalFC" end "DocTotal", 
	d."FormatCode" AS "ACCOUNT", 
	D."AcctName", 
	 CASE WHEN :LocalForeign = 'LC' THEN C."Debit" else C."FCDebit" end "debit", 
	 CASE WHEN :LocalForeign = 'LC' THEN C."Credit" else C."FCCredit" end "credit", 
	NULL AS "Amount", 
	NULL AS "CHECKNO", 
	NULL AS "checkdt", 
	NULL AS "ONACCOUNTAMT", 
	"FCDebit" AS "FCCredit", 
	"FCCredit" AS "fcdebit", 
	NULL AS "ProfitCode", 
	NULL AS "invoiceref", 
	NULL AS "invoicerefseriesname", 
	0 AS "AmountPaid", 
	0 AS "AmountPaidFC", 
	C."Project",
	'ORIN' AS "tablename", 
	CAST(a."DocEntry" AS varchar(5000)) AS "data", 
	A."DocCur" AS "DocCurrency", 
	(CASE WHEN RIGHT(LEFT(right(B."RefDate", 23), 6), 2) = '' 
	THEN '0' ELSE RIGHT(LEFT(right(B."RefDate", 23), 6), 2) END) AS "Dt", 
	left(CAST(B."RefDate" AS varchar(10)), 2) AS "Mnth", 
	RIGHT(LEFT(right(B."RefDate", 23), 12), 5) AS "yr1" 
	
	FROM ORIN A 
	INNER JOIN OJDT B ON A."TransId" = B."TransId" 
	INNER JOIN JDT1 C ON B."TransId" = C."TransId" 
	INNER JOIN OACT D ON D."AcctCode" = C."Account" 
	INNER JOIN NNM1 E ON E."Series" = A."Series" 
	WHERE A."CardCode" <> C."ShortName" AND A."DocDate" >= :Fromdate AND A."DocDate" <= :Todate
	 AND B."TransType" = 14
),    
    
ManualJE    
AS    
(    
			SELECT 'ManualJE' AS "CTEType", 
			F."CardCode", (F."CardCode" || '-' || F."CardName") AS "CardName", 
			A."Number", 
			A."ObjType", 
			a."TransId", 
			A."RefDate", 
			B."SeriesName" || '/ ' || CAST(A."Number" AS nvarchar(50)) AS "DOCREFNO", 
			'' AS "NUMATCARD", 
			C."LineMemo", 
			CASE WHEN :LocalForeign = 'LC' then A."LocTotal" else A."FcTotal" end "DocTotal", 
			d."Segment_0" || '-' || d."Segment_1" AS "ACCOUNT", 
			NULL AS "ACCTNAME", 
			 CASE WHEN :LocalForeign = 'LC' THEN C."Debit" else c."FCDebit" end "Debit", 
			 CASE WHEN :LocalForeign = 'LC' THEN C."Credit" else C."FCCredit" end "Credit", 
			NULL AS "Amount", 
			NULL AS "CHECKNO", 
			NULL AS "checkdt", 
			NULL AS "ONACCOUNTAMT", 
			"FCDebit", "FCCredit", 
			NULL AS "ProfitCode", 
			NULL AS "invoiceref", 
			NULL AS "invoicerefseriesname", 
			0 AS "AmountPaid", 
			0 AS "AmountPaidFC", 
			C."Project", 
			'OJDT' AS "tablename", 
			CAST(a."TransId" AS varchar(5000)) AS "data", 
			NULL AS "DocCurrency", 
			(CASE WHEN RIGHT(LEFT(right(A."RefDate", 23), 6), 2) = '' 
			THEN '0' ELSE RIGHT(LEFT(right(A."RefDate", 23), 6), 2) END) AS "Dt", 
			left(CAST(A."RefDate" AS varchar(10)), 2) AS "Mnth", 
			RIGHT(LEFT(right(A."RefDate", 23), 12), 5) AS "yr1" 
			
			FROM OJDT A 
			INNER JOIN NNM1 B ON A."Series" = b."Series" 
			INNER JOIN JDT1 C ON A."TransId" = C."TransId" 
			INNER JOIN OACT d ON d."AcctCode" = c."Account" 
			INNER JOIN OCRD F ON F."CardCode" = C."ShortName" 
			WHERE A."RefDate" >= :Fromdate AND A."RefDate" <= :Todate AND A."TransType" NOT IN (13,14,18,19,24,46)   
),    
               
ManualJE_Account  
AS    
(    
			SELECT 'ManualJE' AS "CTEType",
			 F."CardCode", (F."CardCode" || '-' || F."CardName") AS "CardName", 
			 A."Number", 
			 A."ObjType", 
			 a."TransId", 
			 A."RefDate", 
			 B."SeriesName" || '/ ' || CAST(A."Number" AS nvarchar(50)) AS "DOCREFNO", 
			 '' AS "NUMATCARD", 
			 C."LineMemo", 
			CASE WHEN :LocalForeign = 'LC' THEN  A."LocTotal" else a."FcTotal" end "DocTotal", 
			 d."AcctName" AS "ACCOUNT", 
			 d."AcctName" AS "ACCTNAME", 
			  CASE WHEN :LocalForeign = 'LC' THEN C."Debit" else C."FCDebit" end "Debit", 
			  CASE WHEN :LocalForeign = 'LC' THEN C."Credit" else C."FCCredit" end "Credit", 
			 NULL AS "Amount", 
			 NULL AS "CHECKNO", 
			 NULL AS "checkdt", 
			 NULL AS "ONACCOUNTAMT", 
			 "FCDebit", 
			 "FCCredit", 
			 NULL AS "ProfitCode", 
			 NULL AS "invoiceref", 
			 NULL AS "invoicerefseriesname", 
			 0 AS "AmountPaid", 
			 0 AS "AmountPaidFC", 
			 C."Project", 
			 'OJDT' AS "tablename", 
			 CAST(a."TransId" AS varchar(5000)) AS "data", 
			 NULL AS "DocCurrency", 
			 (CASE WHEN RIGHT(LEFT(right(A."RefDate", 23), 6), 2) = '' THEN '0' 
			 ELSE RIGHT(LEFT(right(A."RefDate", 23), 6), 2) END) AS "Dt", 
			 left(CAST(A."RefDate" AS varchar(10)), 2) AS "Mnth", 
			 RIGHT(LEFT(right(A."RefDate", 23), 12), 5) AS "yr1" 
			 
			 FROM OJDT A 
			 INNER JOIN NNM1 B ON A."Series" = b."Series" 
			 INNER JOIN JDT1 C ON A."TransId" = C."TransId" 
			 INNER JOIN OACT d ON d."AcctCode" = c."Account" 
			 INNER JOIN OCRD F ON F."CardCode" = C."ContraAct" 
			 WHERE A."RefDate" >= :Fromdate AND A."RefDate" <= :Todate AND A."TransType" NOT IN (13,14,18,19,24,46)
),                   
               
                 
Incoming as (    
				SELECT 'Incoming' AS "CTEType", 
				a."CardCode", 
				a."CardName", 
				IFNULL(rc."DocNum", jh."BaseRef") AS "docnum", 
				jh."TransType", 
				jh."TransId", 
				IFNULL(rc."DocDate", jh."RefDate") AS "docdate", 
				IFNULL(n1."SeriesName" || '/', '') || CAST(IFNULL(rc."DocNum", jh."BaseRef") AS varchar) AS "DOCREFNO", 
				NULL AS "NUMATCARD", 
				IFNULL(rc."Comments", jh."Memo") AS "comments", 
				CASE WHEN :LocalForeign = 'LC' THEN rc."DocTotal" else rc."DocTotalFC" end "DocTotal",
				 ac."FormatCode" AS "ACCOUNT", 
				ac."AcctName", SUM( CASE WHEN :LocalForeign = 'LC' THEN jd1."Debit" else jd1."FCDebit" end) AS "Debit", 
				SUM( CASE WHEN :LocalForeign = 'LC' THEN jd1."Credit" else jd1."FCCredit" end) AS "credit", 
				SUM(IFNULL(jd."Debit", 0) - IFNULL(jd."Credit", 0)) AS "Amount", 
				r1."CheckNum" AS "checkno", 
				r1."U_ChequeDate" AS "chequedt", 
				NULL AS "onaccountamt", 
				jd1."FCCredit" AS "fcdebit", 
				jd1."FCDebit" AS "fccredit", 
				NULL AS "ProfitCode", 
				NULL AS "invoiceref", 
				NULL AS "invoicerefseries",
				NULL AS "AmountPaid", 
				0 AS "AmountPaidFC", 
				rc."PrjCode" AS "Project", 
				'ORCT' AS "tablename", 
				CAST(rc."DocEntry" AS varchar(5000)) AS "data", 
				rc."DocCurr" AS "DocCurrency", 
				(CASE WHEN RIGHT(LEFT(right(jh."RefDate", 23), 6), 2) = '' THEN
				 '0' ELSE RIGHT(LEFT(right(jh."RefDate", 23), 6), 2) END) AS "Dt", 
				 left(CAST(jh."RefDate" AS varchar(10)), 2) AS "Mnth", 
				 RIGHT(LEFT(right(jh."RefDate", 23), 12), 5) AS "yr1" 
				 
				 FROM OCRD a 
				 INNER JOIN JDT1 jd ON jd."ShortName" = a."CardCode" 
				 INNER JOIN OJDT jh ON jh."TransId" = jd."TransId" 
				 INNER JOIN JDT1 jd1 ON jd."TransId" = jd1."TransId" 
				 INNER JOIN OACT ac ON ac."AcctCode" = jd1."Account" 
				 LEFT OUTER JOIN ORCT rc ON rc."TransId" = jh."TransId" 
				 LEFT OUTER JOIN RCT1 r1 ON rc."DocEntry" = r1."DocNum" AND r1."LineID" = 0 
				 LEFT OUTER JOIN NNM1 n1 ON rc."Series" = N1."Series" 
				 WHERE jh."TransType" = 24 AND jh."RefDate" BETWEEN :Fromdate AND :Todate 
				 GROUP BY rc."DocNum", a."CardCode", a."CardName", ac."FormatCode", jh."Memo", jh."TransId", ac."AcctName",
				  rc."DocTotal", rc."DocTotalFC", jh."TransType", rc."DocDate", jd1."ShortName", jd1."Debit", jd1."Credit", jd1."FCCredit", 
				  jd1."FCDebit", rc."PrjCode", jd1."ProfitCode", rc."Comments", jh."BaseRef", jh."RefDate", n1."SeriesName", 
				  r1."CheckNum", r1."U_ChequeDate", jd1."Account", rc."DocEntry", rc."DocCurr"
				),    
     
IncomingPaymentDetails as (    
							SELECT 'IncomingPaymentDetails' AS "CTEType", 
							a."CardCode", 
							a."CardName", 
							rc."DocNum", 
							24 AS "Transtype", 
							rc."TransId", 
							rc."DocDate", 
							h."SeriesName" || '-' || CAST(rc."DocNum" AS varchar) AS "DOCREFNO", 
							NULL AS "NUMATCARD", 
							NULL AS "Comments", 
							NULL AS "DocTotal", 
							NULL AS "ACCOUNT", 
							NULL AS "AcctName", 
							NULL AS "Debit", 
							NULL AS "credit", 
							NULL AS "Amount", 
							NULL AS "checkno", 
							NULL AS "chequedt", 
							NULL AS "onaccountamt", 
							NULL AS "fcdebit", 
							NULL AS "fccredit", 
							NULL AS "ProfitCode", 
							COALESCE(e."DocNum", g."DocNum", r2."DocTransId") AS "invoiceref", 
							COALESCE(f."SeriesName", h."SeriesName", 'JE') AS "invoicerefseries", 
							r2."SumApplied" AS "AmountPaid", 
							r2."AppliedFC" AS "AmountPaidFC", 
							NULL AS "Project", 
							'ORCT' AS "tablename", 
							CAST(rc."DocEntry" AS varchar(5000)) AS "data", 
							rc."DocCurr" AS "DocCurrency", 
							(CASE WHEN RIGHT(LEFT(right(rc."DocDate", 23), 6), 2) = '' THEN '0' ELSE 
							RIGHT(LEFT(right(rc."DocDate", 23), 6), 2) END) AS "Dt", 
							left(CAST(rc."DocDate" AS varchar(10)), 2) AS "Mnth", 
							RIGHT(LEFT(right(rc."DocDate", 23), 12), 5) AS "yr1" 
							
							FROM OCRD a 
							INNER JOIN ORCT rc ON rc."CardCode" = a."CardCode" 
							INNER JOIN RCT2 r2 ON rc."DocEntry" = r2."DocNum" 
							LEFT OUTER JOIN OINV e ON e."DocEntry" = r2."DocEntry" AND r2."InvType" = 13 
							LEFT OUTER JOIN NNM1 f ON e."Series" = f."Series" 
							LEFT OUTER JOIN ORIN g ON e."DocEntry" = r2."DocEntry" AND r2."InvType" = 14 
							LEFT OUTER JOIN NNM1 h ON g."Series" = h."Series" 
							WHERE rc."DocDate" >= :Fromdate AND rc."DocDate" <= :Todate
							),     
IncomingOnAccount as (    
						SELECT 'IncomingOnAccount' AS "CTEType", 
						a."CardCode", 
						a."CardName", 
						rc."DocNum", 
						24 AS "transtype", 
						rc."TransId", 
						rc."DocDate", 
						n1."SeriesName" || '-' || CAST(rc."DocNum" AS varchar) AS "DOCREFNO", 
						NULL AS "NUMATCARD", 
						NULL AS "Comments", 
						NULL AS "DocTotal", 
						NULL AS "ACCOUNT", 
						NULL AS "AcctName", 
						NULL AS "Debit", 
						NULL AS "credit", 
						NULL AS "Amount", 
						NULL AS "checkno", 
						NULL AS "chequedt", 
						NULL AS "onaccountamt", 
						NULL AS "fcdebit", 
						NULL AS "fccredit", 
						NULL AS "ProfitCode", 
						NULL AS "invoiceref", 
						'On Account' AS "invoicerefseries", 
						rc."NoDocSum" AS "AmountPaid", 
						rc."NoDocSumFC" AS "AmountPaidFC", 
						NULL AS "Project", 
						'ORCT' AS "tablename", 
						CAST(rc."DocEntry" AS varchar(5000)) AS "data", 
						rc."DocCurr" AS "DocCurrency", 
						(CASE WHEN RIGHT(LEFT(right(rc."DocDate", 23), 6), 2) = '' THEN '0' 
						ELSE RIGHT(LEFT(right(rc."DocDate", 23), 6), 2) END) AS "Dt", 
						left(CAST(rc."DocDate" AS varchar(10)), 2) AS "Mnth", 
						RIGHT(LEFT(right(rc."DocDate", 23), 12), 5) AS "yr1" 
						
						FROM OCRD a 
						INNER JOIN ORCT rc ON rc."CardCode" = a."CardCode" 
						LEFT OUTER JOIN NNM1 n1 ON n1."Series" = rc."Series" 
						WHERE rc."DocDate" >= :Fromdate AND rc."DocDate" <= :Todate AND rc."NoDocSum" <> 0 
 ),    
Outgoing as (    
				SELECT 'Outgoing' AS "CTEType", 
				a."CardCode", 
				a."CardName", 
				IFNULL(pm."DocNum", jh."BaseRef") AS "docnum", 
				jh."TransType", 
				jh."TransId", 
				IFNULL(pm."DocDate", jh."RefDate") AS "docdate", 
				n1."SeriesName" || '/' || CAST(IFNULL(pm."DocNum", jh."BaseRef") AS nvarchar(50)) AS "DOCREFNO", 
				NULL AS "NUMATCARD", 
				IFNULL(pm."Comments", jh."Memo") AS "comments", 
				CASE WHEN :LocalForeign = 'LC' THEN pm."DocTotal" else pm."DocTotalFC" end "DocTotal", 
				ac."FormatCode" AS "ACCOUNT", 
				ac."AcctName", 
				SUM( CASE WHEN :LocalForeign = 'LC' THEN jd1."Debit" else jd1."FCDebit" end) AS "Debit", 
				SUM( CASE WHEN :LocalForeign = 'LC' THEN jd1."Credit" else jd1."FCCredit" end) AS "credit", 
				SUM(IFNULL(jd."Debit", 0) - IFNULL(jd."Credit", 0)) AS "Amount", 
				p1."CheckNum" AS "checkno", 
				p1."U_ChequeDate" AS "chequedt", 
				NULL AS "onaccountamt", 
				jd1."FCCredit" AS "fcdebit", 
				jd1."FCDebit" AS "fccredit", 
				NULL AS "ProfitCode", 
				NULL AS "invoiceref", 
				NULL AS "invoicerefseries", 
				NULL AS "AmountPaid", 
				0 AS "AmountPaidFC", 
				pm."PrjCode" AS "Project", 
				'OVPM' AS "tablename", 
				CAST(pm."DocEntry" AS varchar(5000)) AS "data", 
				pm."DocCurr" AS "DocCurrency", 
				(CASE WHEN RIGHT(LEFT(right(jh."RefDate", 23), 6), 2) = '' THEN '0' 
				ELSE RIGHT(LEFT(right(jh."RefDate", 23), 6), 2) END) AS "Dt", 
				left(CAST(jh."RefDate" AS varchar(10)), 2) AS "Mnth", 
				RIGHT(LEFT(right(jh."RefDate", 23), 12), 5) AS "yr1" 
				
				FROM OCRD a 
				INNER JOIN JDT1 jd ON jd."ShortName" = a."CardCode" 
				INNER JOIN OJDT jh ON jh."TransId" = jd."TransId" 
				INNER JOIN JDT1 jd1 ON jd."TransId" = jd1."TransId" 
				INNER JOIN OACT ac ON ac."AcctCode" = jd1."Account" 
				LEFT OUTER JOIN OVPM pm ON pm."TransId" = jh."TransId" 
				LEFT OUTER JOIN VPM1 p1 ON pm."DocEntry" = p1."DocNum" AND p1."LineID" = 0 
				LEFT OUTER JOIN NNM1 n1 ON pm."Series" = n1."Series" 
				WHERE jh."TransType" = 46 AND IFNULL(jd1."ShortName", '') <> a."CardCode" AND jh."RefDate" >= :Fromdate 
				AND jh."RefDate" <= :Todate 
				GROUP BY pm."DocNum", a."CardCode", a."CardName", ac."FormatCode", jh."Memo", jh."TransId",
				 ac."AcctName", pm."DocTotal", pm."DocTotalFC", jh."TransType", pm."DocDate", jd1."ShortName", jd1."Debit", 
				 jd1."Credit", jd1."FCCredit", jd1."FCDebit", pm."PrjCode", jd1."ProfitCode", pm."Comments", 
				 jh."BaseRef", jh."RefDate", n1."SeriesName", p1."CheckNum", p1."U_ChequeDate", jd1."Account", 
				 pm."DocEntry", pm."DocCurr"
				),    
     
OutgoingPaymentDetails as (    
							SELECT 'OutgoingPaymentDetails' AS "CTEType", 
							a."CardCode", 
							a."CardName", 
							pm."DocNum", 
							24 AS "transtype", 
							pm."TransId", 
							pm."DocDate", 
							NULL AS "DOCREFNO", 
							NULL AS "NUMATCARD", 
							NULL AS "Comments", 
							NULL AS "DocTotal", 
							NULL AS "ACCOUNT", 
							NULL AS "AcctName", 
							NULL AS "Debit", 
							NULL AS "credit", 
							NULL AS "Amount", 
							NULL AS "checkno", 
							NULL AS "chequedt", 
							NULL AS "onaccountamt", 
							NULL AS "fcdebit", 
							NULL AS "fccredit", 
							NULL AS "ProfitCode", 
							COALESCE(e."DocNum", g."DocNum", p2."DocTransId") AS "invoiceref", 
							COALESCE(f."SeriesName", h."SeriesName", 'JE') AS "invoicerefseries", 
							p2."SumApplied" AS "AmountPaid", 
							p2."AppliedFC" AS "AmountPaidFC", 
							NULL AS "Project", 
							'OVPM' AS "tablename", 
							CAST(pm."DocEntry" AS varchar(5000)) AS "data", 
							pm."DocCurr" AS "DocCurrency", 
							(CASE WHEN RIGHT(LEFT(right(pm."DocDate", 23), 6), 2) = '' THEN '0' 
							ELSE RIGHT(LEFT(right(pm."DocDate", 23), 6), 2) END) AS "Dt", 
							left(CAST(pm."DocDate" AS varchar(10)), 2) AS "Mnth", 
							RIGHT(LEFT(right(pm."DocDate", 23), 12), 5) AS "yr1" 
							
							FROM OCRD a 
							INNER JOIN OVPM pm ON pm."CardCode" = a."CardCode" 
							INNER JOIN VPM2 p2 ON pm."DocEntry" = p2."DocNum" 
							LEFT OUTER JOIN OINV e ON e."DocEntry" = p2."DocEntry" AND p2."InvType" = 13 
							LEFT OUTER JOIN NNM1 f ON e."Series" = f."Series" 
							LEFT OUTER JOIN ORIN g ON e."DocEntry" = p2."DocEntry" AND p2."InvType" = 14 
							LEFT OUTER JOIN NNM1 h ON g."Series" = h."Series" 
							WHERE pm."DocDate" >= :Fromdate AND pm."DocDate" <= :Todate
							),     

OutgoingOnAccount as (    
						SELECT 'OutgoingOnAccount' AS "CTEType", 
						a."CardCode", 
						a."CardName", 
						pm."DocNum", 
						24 AS "transtype", 
						pm."TransId", 
						pm."DocDate", 
						NULL AS "DOCREFNO", 
						NULL AS "NUMATCARD", 
						NULL AS "Comments", 
						NULL AS "DocTotal", 
						NULL AS "ACCOUNT", 
						NULL AS "AcctName", 
						NULL AS "Debit", 
						NULL AS "credit", 
						NULL AS "Amount", 
						NULL AS "checkno", 
						NULL AS "chequedt", 
						NULL AS "onaccountamt", 
						NULL AS "fcdebit", 
						NULL AS "fccredit", 
						NULL AS "ProfitCode", 
						NULL AS "invoiceref", 
						'On Account' AS "invoicerefseries", 
						pm."NoDocSum" AS "AmountPaid", 
						pm."NoDocSumFC" AS "AmountPaidFC", 
						NULL AS "Project", 
						'OVPM' AS "tablename", 
						CAST(pm."DocEntry" AS varchar(5000)) AS "data", 
						pm."DocCurr" AS "DocCurrency", 
						(CASE WHEN RIGHT(LEFT(right(pm."DocDate", 23), 6), 2) = '' THEN '0' 
						ELSE RIGHT(LEFT(right(pm."DocDate", 23), 6), 2) END) AS "Dt", 
						left(CAST(pm."DocDate" AS varchar(10)), 2) AS "Mnth", 
						RIGHT(LEFT(right(pm."DocDate", 23), 12), 5) AS "yr1" 
						
						FROM OCRD a 
						INNER JOIN OVPM pm ON pm."CardCode" = a."CardCode" 
						WHERE pm."DocDate" >= :Fromdate AND pm."DocDate" <= :Todate AND pm."NoDocSum" <> 0
 )    
    
      
 SELECT b."CardCode" AS "drcode", 
		b."CardName" AS "drname", 
		"FINAL".*, 
		IFNULL(cte1."OB", 0) AS "OB", 
		IFNULL(cte1."obfc", 0) AS "OBFC", 
		OPRJ."PrjName", 
		"ActCurr" AS "Currency", 
		"op"."OPENING BALANCE" 
		
		FROM 
		(SELECT 'DR' AS "drcr", * FROM Invoice 
		
		UNION ALL 
		
		SELECT 'CR' AS "drcr", * FROM CreditMemo 
		
		UNION ALL 
		
		SELECT 'DRCR' AS "drcr", * FROM ManualJE 
		
		UNION ALL 
		
		SELECT 'DRCR' AS "drcr", * FROM ManualJE_Account 
		
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
		
		LEFT OUTER JOIN OCRD b ON b."CardCode" = "FINAL"."CardCode" 
		LEFT OUTER JOIN Cte1 ON b."CardCode" = Cte1."ShortName" 
		LEFT OUTER JOIN OpeningBalance "op" ON b."CardCode" = "op"."CardCode" 
		LEFT OUTER JOIN OPRJ ON "FINAL"."Project" = OPRJ."PrjCode" 
		LEFT OUTER JOIN OACT ON OACT."AcctCode" = "FINAL"."ACCOUNT" 
		CROSS JOIN OADM 
		WHERE "CardType" = 'C' AND b."CardName" || '-' || b."CardCode" >= IFNULL(:fromdebtor, b."CardName" || '-' || b."CardCode") 
		AND b."CardName" || '-' || b."CardCode" <= IFNULL(:Todebtor, b."CardName" || '-' || b."CardCode") 
		AND (:LocalForeign = 'LC' OR b."Currency" NOT IN ('##',OADM."MainCurncy")) 
		ORDER BY "CardCode", "DocDate", "CTEType", "DocNum";   
END