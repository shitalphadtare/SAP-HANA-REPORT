/****************************HANA GENERAL LEDGER REPORT ON 16-10-2019********************************/

create PROCEDURE PTS_GENERAL_LEDGER_20191016

(IN Fromdate timestamp
,IN ToDate timestamp
,IN FromGLAcc nvarchar(100)
,IN ToGLAcc nvarchar(100)
--,@Narration bit
--,@Print bit
--,@ZeroBalance bit
--,@NoPosting bit
--,@Daily bit
--,@Monthly bit
--,@Yearly bit
,IN Currency nvarchar(5))
LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER
AS
 Begin 

with Query1 as(
SELECT act."AcctCode", 
	   CASE WHEN act."Segment_0" <> '' THEN act."Segment_0" || '-' || act."Segment_1" ELSE act."AcctCode" END AS "AcctCode1", 
	   act."AcctName", 
	   (CASE WHEN act."ActCurr" = 'INR' OR act."ActCurr" = '##' THEN '(Local)' ELSE '(FC)' END) AS "Currency", 
	   jdt."RefDate" AS "Date1", 
	   (CASE WHEN JT1."TransType" = 46 THEN (CASE WHEN :Currency = 'LC' THEN IFNULL(JT1."Debit", 0) ELSE IFNULL(JT1."FCDebit", 0) END) 
		     WHEN JT1."TransType" = 24 THEN (CASE WHEN :Currency = 'LC' THEN IFNULL(JT1."Debit", 0) ELSE IFNULL(JT1."FCDebit", 0) END) 
			 WHEN JT1."TransType" = 13 THEN (CASE WHEN :Currency = 'LC' THEN IFNULL(JT1."Debit", 0) ELSE IFNULL(JT1."FCDebit", 0) END) 
			 WHEN JT1."TransType" = 18 THEN (CASE WHEN :Currency = 'LC' THEN IFNULL(JT1."Debit", 0) ELSE IFNULL(JT1."FCDebit", 0) END) 
			 WHEN JT1."TransType" = 14 THEN (CASE WHEN :Currency = 'LC' THEN IFNULL(JT1."Debit", 0) ELSE IFNULL(JT1."FCDebit", 0) END) 
			 WHEN JT1."TransType" = 19 THEN (CASE WHEN :Currency = 'LC' THEN IFNULL(JT1."Debit", 0) ELSE IFNULL(JT1."FCDebit", 0) END) 
		ELSE (CASE WHEN :Currency = 'LC' THEN jt1."Debit" ELSE jt1."FCDebit" END) END) AS "Debit", 
		(CASE WHEN JT1."TransType" = 46 THEN (CASE WHEN :Currency = 'LC' THEN IFNULL(JT1."Credit", 0) ELSE IFNULL(JT1."FCCredit", 0) END) 
			  WHEN JT1."TransType" = 24 THEN (CASE WHEN :Currency = 'LC' THEN IFNULL(JT1."Credit", 0) ELSE IFNULL(JT1."FCCredit", 0) END) 
			  WHEN JT1."TransType" = 13 THEN (CASE WHEN :Currency = 'LC' THEN IFNULL(JT1."Credit", 0) ELSE IFNULL(JT1."FCCredit", 0) END) 
			  WHEN JT1."TransType" = 18 THEN (CASE WHEN :Currency = 'LC' THEN IFNULL(JT1."Credit", 0) ELSE IFNULL(JT1."FCCredit", 0) END) 
			  WHEN JT1."TransType" = 14 THEN (CASE WHEN :Currency = 'LC' THEN IFNULL(JT1."Credit", 0) ELSE IFNULL(JT1."FCCredit", 0) END) 
			  WHEN JT1."TransType" = 19 THEN (CASE WHEN :Currency = 'LC' THEN IFNULL(JT1."Credit", 0) ELSE IFNULL(JT1."FCCredit", 0) END) 
		ELSE (CASE WHEN :Currency = 'LC' THEN jt1."Credit" ELSE jt1."FCCredit" END) END) AS "Credit", 
		JT1."TransId", JT1."TransType", 
		(CASE WHEN JT1."TransType" = 46 THEN IFNULL(NM6."SeriesName", '') || '/' || CAST(VPM."DocNum" AS char) 
		      WHEN JT1."TransType" = 24 THEN IFNULL(NM5."SeriesName", '') || '/' || CAST(RCT."DocNum" AS char) 
			  WHEN JT1."TransType" = 13 THEN IFNULL(NM1."SeriesName", '') || '/' || CAST(INV."DocNum" AS char) 
			  WHEN JT1."TransType" = 18 THEN IFNULL(NM2."SeriesName", '') || '/' || CAST(PCH."DocNum" AS char) 
			  WHEN JT1."TransType" = 14 THEN IFNULL(NM3."SeriesName", '') || '/' || CAST(RIN."DocNum" AS char) 
			  WHEN JT1."TransType" = 19 THEN IFNULL(NM4."SeriesName", '') || '/' || CAST(RPC."DocNum" AS char) 
			  WHEN JT1."TransType" = 30 THEN IFNULL(NM7."SeriesName", '') || '/' || CAST(JDT."BaseRef" AS char) 
		ELSE JDT."BaseRef" END) AS "Document No", 
		(CASE WHEN JT1."TransType" = 46 THEN 'Outgoing Payment' 
		      WHEN JT1."TransType" = 24 THEN 'Incoming Payment' 
			  WHEN JT1."TransType" = 13 THEN 'A/R Invoice' 
			  WHEN JT1."TransType" = 18 THEN 'A/P Invoice' 
			  WHEN JT1."TransType" = 14 THEN 'A/R Credit Memo' 
			  WHEN JT1."TransType" = 19 THEN 'A/P Credit Memo' 
			  WHEN JT1."TransType" = 30 THEN 'Manual JE' 
		ELSE 'Other' END) AS "Transction Name", 
		CASE WHEN jdt."TransType" <> 30 THEN 
			(CASE WHEN act1."Segment_0" <> '' THEN act1."Segment_0" || '  - ' || act1."Segment_1" || ' ' || act1."AcctName" 
			WHEN act1."AcctCode" IS NULL OR act1."AcctCode" = '' AND act1."Segment_0" IS NULL 
			THEN 
			(CASE WHEN JT1."TransType" = 46 THEN VPM."CardCode" || '-' || VPM."CardName" 
			      WHEN JT1."TransType" = 24 THEN RCT."CardCode" || '-' || RCT."CardName" 
				  WHEN JT1."TransType" = 13 THEN INV."CardCode" || '-' || INV."CardName" 
				  WHEN JT1."TransType" = 18 THEN PCH."CardCode" || '-' || PCH."CardName" 
				  WHEN JT1."TransType" = 14 THEN RIN."CardCode" || '-' || RIN."CardName" 
				  WHEN JT1."TransType" = 19 THEN RPC."CardCode" || '-' || RPC."CardName" END) 
			ELSE act1."AcctCode" || ' - ' || act1."AcctName" END) ELSE jdt."Memo" END AS "BP/GL Code", 
		(CASE WHEN JT1."TransType" = 46 THEN VPM."Comments" 
												WHEN JT1."TransType" = 24 THEN RCT."Comments" 
												WHEN JT1."TransType" = 13 THEN INV."Comments" 
												WHEN JT1."TransType" = 18 THEN PCH."Comments" 
												WHEN JT1."TransType" = 14 THEN RIN."Comments" 
												WHEN JT1."TransType" = 19 THEN RPC."Comments" 
										  ELSE jdt."Memo" END) AS "Description 1", 
		CASE WHEN JT1."TransType" IN (46,24) THEN ('Ch No.' || CAST((CASE WHEN JT1."TransType" = 46 THEN VM1."CheckNum" 
																		  WHEN JT1."TransType" = 24 THEN RT1."CheckNum" END) AS char)) 
			 WHEN JT1."TransType" = 13 THEN INV."NumAtCard" 
			 WHEN JT1."TransType" = 18 THEN PCH."NumAtCard" 
			 WHEN JT1."TransType" = 14 THEN RIN."NumAtCard" 
			 WHEN JT1."TransType" = 19 THEN RPC."NumAtCard" END AS "Cheque No/BP Ref", 
	    jdt."RefDate" AS "Date2", 
		(CASE WHEN RIGHT(LEFT(right(jdt."RefDate", 23), 5), 1) = '' THEN '0' ELSE RIGHT(LEFT(right(jdt."RefDate", 23), 5), 1) END) || 
		(CASE WHEN RIGHT(LEFT(right(jdt."RefDate", 23), 6), 1) = '' THEN '0' ELSE RIGHT(LEFT(right(jdt."RefDate", 23), 6), 1) END) AS "Dt", 
		left(CAST(jdt."RefDate" AS varchar(10)), 2) AS "Mnth", 
		RIGHT(LEFT(right(jdt."RefDate", 23), 12), 5) AS "yr1", 
		OA."Name" AS "Segment" 
FROM OACT ACT 
INNER JOIN JDT1 JT1 ON JT1."Account" = ACT."AcctCode" 
LEFT OUTER JOIN OASC OA ON act."Segment_1" = OA."Code" 
LEFT OUTER JOIN OACT act1 ON JT1."ContraAct" = act1."AcctCode" 
LEFT OUTER JOIN OJDT jdt ON jt1."TransId" = jdt."TransId" 
LEFT OUTER JOIN NNM1 NM7 ON JDT."Series" = NM7."Series" 
LEFT OUTER JOIN OINV INV ON inv."TransId" = jt1."TransId" 
LEFT OUTER JOIN NNM1 NM1 ON INV."Series" = NM1."Series" 
LEFT OUTER JOIN OPCH PCH ON PCH."TransId" = JT1."TransId" 
LEFT OUTER JOIN NNM1 NM2 ON PCH."Series" = NM2."Series" 
LEFT OUTER JOIN ORIN RIN ON RIN."TransId" = JT1."TransId" 
LEFT OUTER JOIN NNM1 NM3 ON NM3."Series" = RIN."Series" 
LEFT OUTER JOIN ORPC RPC ON RPC."TransId" = JT1."TransId" 
LEFT OUTER JOIN NNM1 NM4 ON NM4."Series" = RPC."Series" 
LEFT OUTER JOIN ORCT RCT ON RCT."TransId" = JT1."TransId" 
LEFT OUTER JOIN NNM1 NM5 ON NM5."Series" = RCT."Series" 
LEFT OUTER JOIN (SELECT "CheckNum", "DocNum" FROM RCT1) AS RT1 ON RT1."DocNum" = RCT."DocEntry" 
LEFT OUTER JOIN OVPM VPM ON VPM."TransId" = JT1."TransId" 
LEFT OUTER JOIN NNM1 NM6 ON NM6."Series" = VPM."Series" 
LEFT OUTER JOIN (SELECT "CheckNum", "DocNum" FROM VPM1) AS VM1 ON VM1."DocNum" = VPM."DocEntry" 
WHERE jdt."RefDate" >= :Fromdate AND jdt."RefDate" <= :ToDate AND act."AcctName" >= :FromGLAcc AND act."AcctName" <= :ToGLAcc
),
--------------------------------------------------------**************************-----------------------------------------------------
Query2 as(
SELECT CASE WHEN T0."Segment_0" <> '' THEN T0."Segment_0" || '-' || T0."Segment_1" ELSE T0."AcctCode" END AS "AcctCode1", 
	   SUM(CASE WHEN T2."RefDate" < :Fromdate THEN IFNULL(T1."Debit", 0) ELSE 0 END) - SUM(CASE WHEN T2."RefDate" < :Fromdate 
	   THEN IFNULL(T1."Credit", 0) ELSE 0 END) AS "Opening Balance" 
	   FROM OACT T0 
	   INNER JOIN JDT1 T1 ON T1."Account" = T0."AcctCode" 
	   INNER JOIN OJDT T2 ON T1."TransId" = T2."TransId" 
	   WHERE T0."AcctName" >= :FromGLAcc AND T0."AcctName" <= :ToGLAcc 
	   GROUP BY CASE WHEN T0."Segment_0" <> '' THEN T0."Segment_0" || '-' || T0."Segment_1" ELSE T0."AcctCode" END
)


-------------------------------------------------*******************************---------------------------------------------------
select * from 
Query1 C1
inner join Query2 C2 on C1."AcctCode1" = C2."AcctCode1"
-------------------------------------------------*******************************---------------------------------------------------
union all

SELECT DISTINCT T0."AcctCode", 
				CASE WHEN T0."Segment_0" <> '' THEN T0."Segment_0" ELSE T0."AcctCode" END AS "AcctCode1", 
				T0."AcctName", 
				(CASE WHEN T0."ActCurr" = 'INR' OR T0."ActCurr" = '##' THEN '(Local)' ELSE '(FC)' END) AS "Currency", '', 0, 0, '', '', NULL, NULL, '', 
				'', '', '', '', '', '', '', '', T0."CurrTotal" 
FROM OACT T0 
WHERE T0."Postable" = 'Y' AND T0."AcctCode" NOT IN (SELECT DISTINCT "Account" FROM JDT1 
													INNER JOIN OACT ON JDT1."Account" = OACT."AcctCode" 
													WHERE JDT1."RefDate" >= :Fromdate AND JDT1."RefDate" <= :ToDate AND OACT."AcctName" >= :FromGLAcc AND OACT."AcctName" <= :ToGLAcc) 
													
AND T0."AcctName" >= :FromGLAcc AND T0."AcctName" <= :ToGLAcc;
end 


