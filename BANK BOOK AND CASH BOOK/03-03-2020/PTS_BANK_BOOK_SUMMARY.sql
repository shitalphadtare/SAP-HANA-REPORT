CREATE PROCEDURE PTS_BANK_BOOK_SUMMARY

(
IN Fromdate datetime
,IN ToDate datetime
,IN Bank nvarchar(200)
)
as
 Begin

select T1."AcctName",T1."BP/GL Code",T1."BP/GL Description"
,SUM(T1."Credit") "Credit"
,SUM(T1."Debit") "Debit"
 from 
(select 
T0."AcctName"
,(CASE when T3."Segment_0" <> '' then T3."Segment_0" 
       when T3."AcctCode" IS null OR T3."AcctCode" = '' and T3."Segment_0" IS NULL   then 
       (case when T2."TransType" = 46 then T4."CardCode"
            when T2."TransType" = 24 then T6."CardCode"  End)
       else T3."AcctCode" || '' 
        End)"BP/GL Code"
,(CASE when T3."Segment_0" <> '' then  T3."Segment_1" || ' ' || T3."AcctName" 
       when T3."AcctCode" IS null OR T3."AcctCode" = '' and T3."Segment_0" IS NULL   then 
       (case when T2."TransType" = 46 then  T4."CardName" 
            when T2."TransType" = 24 then  T6."CardName" End)
       else T3."AcctCode" || '' 
        End)"BP/GL Description" 
,T1."Credit"
,T1."Debit"
 
from OACT T0 
inner join JDT1 T1 on T1."Account" = T0."AcctCode" 
left outer join OACT T3 on T1."ContraAct" = T3."AcctCode"
inner join OJDT T2 on T1."TransId" = T2."TransId" 
left outer join OVPM T4 on T4."DocNum" =(CASE when  T1."TransType" = 46 then T1."BaseRef"  else 0 end) and T1."RefDate" = T4."TaxDate"
left outer join ORCT T6 on T6."DocNum" =(CASE when  T1."TransType" = 24 then T1."BaseRef"  else 0 end) and T1."RefDate" = T6."TaxDate"

where 
T0."Finanse" = 'Y'
and T0."AcctName" = :Bank
 and T2."RefDate" >= :Fromdate
 and T2."RefDate" <= :ToDate
 )
 as T1
 
 group by T1."BP/GL Code",T1."BP/GL Description",T1."AcctName";
end

