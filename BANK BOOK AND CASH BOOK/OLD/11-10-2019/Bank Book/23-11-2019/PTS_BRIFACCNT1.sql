CREATE VIEW "WINTAC_LIVE"."PTS_BRIFACCNT1" ( "outDocType",
	 "InDocType",
	 "AcctName",
	 "TransId",
	 "Account",
	 "TransType",
	 "Outgoing",
	 "Incoming",
	 "AcctCode",
	 "IncomeSum",
	 "IncomeSumFC",
	 "OutSum",
	 "OutSumFC",
	 "AcctTotal" ) AS select
	 T1."DocType" "outDocType",
	 T4."DocType" "InDocType",
	 T7."AcctName",
	 T0."TransId",
	 T0."Account",
	 T0."TransType",
	 T3."AppliedSys" "Outgoing",
	 T6."AppliedSys" "Incoming",
	 case when T1."DocType" = 'A' 
then T7."Segment_0" ||' - '|| T7."Segment_1" when T1."DocType" = 'S' 
AND T1."PayNoDoc" = 'N' 
Then cast((T8."DocNum") as nvarchar(50)) --T1.CardCode 
 When T1."DocType" = 'S' 
AND T1."PayNoDoc" = 'Y' 
Then T7."Segment_0" ||' - '|| T7."Segment_1" when T1."DocType" = 'c' 
AND T1."PayNoDoc" = 'N' 
Then cast((T8."DocNum") as nvarchar(50)) --T1.CardCode 
 When T1."DocType" = 'C' 
AND T1."PayNoDoc" = 'Y' 
Then T7."Segment_0" ||' - '|| T7."Segment_1" when T4."DocType" = 'A' 
Then T7."Segment_0" ||' - '|| T7."Segment_1" when T4."DocType" = 'C' 
AND T4."PayNoDoc" = 'N' 
Then Cast((T9."DocNum") as nvarchar(50)) when T4."DocType" = 'C' 
AND T4."PayNoDoc" = 'Y' 
Then T7."Segment_0" ||' - '|| T7."Segment_1" when T4."DocType" = 'S' 
AND T4."PayNoDoc" = 'N' 
Then Cast((T9."DocNum") as nvarchar(50)) when T4."DocType" = 'S' 
AND T4."PayNoDoc" = 'Y' 
Then T7."Segment_0" ||' - '|| T7."Segment_1" 
Else '' 
End "AcctCode",
	 Case When T0."TransType" = '24' 
AND T5."AppliedSys" Is Null 
AND T6."AppliedSys" IS Null 
Then (case when T0."Account" = T4."CashAcct" 
	then -T4."CashSum" when T0."Account" = T10."CreditAcct" 
	Then -T4."CreditSum" When T0."Account" = T4."TrsfrAcct" 
	Then -T4."TrsfrSum" When T0."Account" = T4."CheckAcct" 
	Then -T4."CheckSum" When T0."Account" = '54110005' 
	Then -T4."BcgSum" 
	else ifNull(T4."NoDocSum",
	0) 
	end) 
else ifNull(T5."AppliedSys",
	T6."AppliedSys") 
end "IncomeSum",
	 Case When T0."TransType" = '24' 
AND T5."AppliedFC" Is Null 
AND T6."AppliedFC" IS Null 
Then (case when T0."Account" = T4."CashAcct" 
	then -T4."CashSumFC" when T0."Account" = T10."CreditAcct" 
	Then -T4."CredSumFC" When T0."Account" = T4."TrsfrAcct" 
	Then -T4."TrsfrSumFC" When T0."Account" = T4."CheckAcct" 
	Then -T4."CheckSumFC" When T0."Account" = T4."BpAct" 
	Then -T4."BcgSumFC" 
	else T4."NoDocSumFC" 
	end) 
else ifNull(T5."AppliedFC",
	T6."AppliedFC") 
end "IncomeSumFC",
	 Case When T0."TransType" = '46' 
AND T2."AppliedSys" Is Null 
AND T3."AppliedSys" IS Null 
Then (case when T0."Account" = T1."CashAcct" 
	then -T1."CashSum" when T0."Account" = T11."CreditAcct" 
	Then -T1."CreditSum" When T0."Account" = T1."TrsfrAcct" 
	Then -T1."TrsfrSum" When T0."Account" = T1."CheckAcct" 
	Then -T1."CheckSum" When T0."Account" = T1."BpAct" 
	Then T1."BcgSum" 
	else T1."NoDocSum" 
	end) 
else ifNull(T2."AppliedSys",
	T3."AppliedSys") 
end "OutSum",
	 Case When T0."TransType" = '46' 
AND T2."AppliedFC" Is Null 
AND T3."AppliedFC" IS Null 
Then (case when T0."Account" = T1."CashAcct" 
	then -T1."CashSumFC" when T0."Account" = T11."CreditAcct" 
	Then -T1."CredSumFC" When T0."Account" = T1."TrsfrAcct" 
	Then -T1."TrsfrSumFC" When T0."Account" = T1."CheckAcct" 
	Then -T1."CheckSumFC" When T0."Account" = T1."BpAct" 
	Then T1."BcgSumFC" 
	else T1."NoDocSumFC" 
	end) 
else ifNull(T2."AppliedFC",
	T3."AppliedFC") 
end "OutSumFC",
	 Case when T0."TransType" != '24' 
OR T0."TransType" != '46' 
Then (case when T1."DocType" = 'A' 
	then T3."AppliedSys" when T1."DocType" = 'S' 
	AND T1."PayNoDoc" = 'N' 
	Then T2."AppliedSys" when T1."DocType" = 'S' 
	AND T1."PayNoDoc" = 'Y' 
	Then T1."NoDocSum" When T1."DocType" = 'c' 
	AND T1."PayNoDoc" = 'N' 
	Then T2."AppliedSys" when T1."DocType" = 'C' 
	AND T1."PayNoDoc" = 'Y' 
	Then T1."NoDocSum" when T4."DocType" = 'A' 
	Then T6."AppliedSys" when T4."DocType" = 'C' 
	AND T4."PayNoDoc" = 'N' 
	Then T5."AppliedSys" when T4."DocType" = 'C' 
	AND T4."PayNoDoc" = 'Y' 
	Then T4."NoDocSum" when T4."DocType" = 'S' 
	AND T4."PayNoDoc" = 'N' 
	Then T5."AppliedSys" when T4."DocType" = 'S' 
	AND T4."PayNoDoc" = 'Y' 
	Then T4."NoDocSum" 
	Else 0 
	End) 
END "AcctTotal" 
from JDT1 T0 
LEFT JOIN OVPM T1 ON T0."CreatedBy" = T1."DocEntry" 
AND T0."BaseRef" = T1."DocNum" 
AND T0."TransId" = T1."TransId" --AND T0.ShortName = T1.CardCode
--LEFT JOIN VPM1 T10 ON T1.DocEntry = T10.DocNum
 
LEFT JOIN VPM2 T2 ON T1."DocEntry" = T2."DocNum" 
AND T0."Line_ID" = T2."InstId" 
LEFT JOIN VPM4 T3 ON T1."DocEntry" = T3."DocNum" 
AND T0."Account" = T3."AcctCode" 
LEFT JOIN VPM3 T11 ON T1."DocEntry" = T11."DocNum" 
AND T0."Account" = T11."CreditAcct" 
LEFT JOIN OPCH T8 ON T2."DocEntry" = T8."DocEntry" 
LEFT JOIN ORCT T4 ON T0."CreatedBy" = T4."DocEntry" 
AND T0."BaseRef" = T4."DocNum" 
AND T0."TransId" = T4."TransId" --AND T0.ShortName = T4.CardCode
--LEFT JOIN RCT1 T11 ON T4.DocEntry = T11.DocNum
 
LEFT JOIN RCT2 T5 ON T4."DocEntry" = T5."DocNum" 
AND T0."Line_ID" = T5."InstId" 
LEFT JOIN RCT4 T6 ON T4."DocEntry" = T6."DocNum" 
AND T0."Account" = T6."AcctCode" 
LEFT JOIN RCT3 T10 ON T4."DocEntry" = T10."DocNum" 
AND T0."Account" = T10."CreditAcct" 
LEFT JOIN OINV T9 ON T4."DocEntry" = T9."DocEntry" 
LEFT JOIN OACT T7 ON T0."Account" = T7."AcctCode"