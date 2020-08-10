CREATE PROCEDURE  PTS_BANK_BOOK5
(
in Fromdate Timestamp
,in ToDate Timestamp
,in Bank nvarchar(100)
--,in Narration 
--,in Cheque BIT
--,in Daily BIT
--,in Monthly BIT
--,in Yearly BIT
)

LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER
AS
 BEGIN

   
with  Query1 AS(
 select
 T0."AcctCode"
,T0."AcctName"
,(CASE when T0."ActCurr" = 'INR' or T0."ActCurr" = '##'  then '(Local)'
 else '(FC)' end  ) "Currency"
,T2."RefDate" "Date1"
--,(CASE when T2."TransType" = 46 then (case  when  T4."DocCurr" = 'INR' then ifnull(T1."Debit",0) else ifnull(T1."FCDebit",0) end)--Outgoing
  --  when T2."TransType" = 24 then (case  when T6."DocCurr" = 'INR' then  ifnull(T1."Debit",0) else ifnull(T1."FCDebit",0) end)--Incoming
 --      when T2."TransType" = 30 then ifnull(T1."Debit",0) else ifnull(T1."FCDebit",0)--Journal Entry
  --    end ) "Debit"
,Sum(CASE when T2."TransType" = 46 then ifnull(T1."Debit",0)--Outgoing
    when T2."TransType" = 24 then ifnull(T1."Debit",0)--Incoming
       when T2."TransType" = 30 then ifnull(T1."Debit",0)--Journal Entry
      end ) "Debit"
,Sum(CASE when T2."TransType" = 46 then ifnull(T1."FCDebit",0)   --Outgoing
    when T2."TransType" = 24 then ifnull(T1."FCDebit",0) --Incoming
       when T2."TransType" = 30 then ifnull(T1."FCDebit",0) --Journal Entry
      end ) "FCDebit"
  ,Sum(CASE when T2."TransType" = 46 then ifNull(T1."Credit",0)--Outgoing
      when T2."TransType" = 24 then  ifNull(T1."Credit",0) --Incoming
      when T2."TransType" = 30 then ifNull(T1."Credit",0)--Journal Entry
      end ) "Credit"
  ,Sum(CASE when T2."TransType" = 46 then ifNull(T1."FCCredit",0)--Outgoing
      when T2."TransType" = 24 then  ifNull(T1."FCCredit",0) --Incoming
      when T2."TransType" = 30 then ifNull(T1."FCCredit",0)--Journal Entry
      end ) "FCCredit"
   
--,(CASE when T2."TransType" = 46 then (CASE when T4."DocCurr" = 'INR' then ifNull(T1."Credit",0) else ifNull(T1."FCCredit",0)end)--Outgoing
 --     when T2."TransType" = 24 then (CASE when T6."DocCurr" = 'INR' then ifNull(T1."Credit",0) else ifNull(T1."FCCredit",0)end)--Incoming
 --     when T2."TransType" = 30 then ifNull(T1."Credit",0) else ifNull(T1."FCCredit",0)--Journal Entry
 --     end ) "Credit"
,T1."TransId" 
,T2."TransType"   --CONCAT("column1", CONCAT(' / ', "cloumn2"))
,(CASE when T2."TransType" = 46 then T5."SeriesName" || '-'|| CAST (T4."DocNum" as CHAR) --Outgoing
       when T2."TransType" = 24 then T7."SeriesName" || '-'|| CAST (T6."DocNum" as CHAR) --Incoming
      when T2."TransType" = 30 then T10."SeriesName" || '-'|| CAST(T2."Number" as CHAR) --Journal Entry
        End) "Document No" 
,(CASE when T2."TransType" = 30 then 'Journal Entry' when T2."TransType" = 140000009 then 'Outgoing Ex Invoice'
      when T2."TransType" = 24 then 'Incoming Payment' else 'Outgoing Payment' end ) "Transction Name" 
,(CASE when T0."Segment_0" <> '' then T0."Segment_0" || '-' || T0."Segment_1" || ' ' || T0."AcctName"
       when T0."AcctCode" IS null OR T0."AcctCode" = '' and T0."Segment_0" IS NULL   then T4."CardCode" || '-' || T4."CardName"
       else T0."AcctCode" || ' ' ||T0."AcctName"
        End)"BP/GL Code"
,(CASE when T2."TransType" = 46 then T11."Descrip"  --outcoming
      when T2."TransType" = 24 then T12."Descrip"  --incoming
      when T2."TransType" = 30 then T2."Memo"      --Journal Entry
      end ) "Description 1" 
, (CASE when T2."TransType" = 46 then T4."Comments" --outcoming
       when T2."TransType" = 24 then T6."Comments" end ) "Description 3"  --incoming
, 'CH No.' || (CASE when T2."TransType" = 46 then CAST(T8."CheckNum" as CHAR)  --outcoming 
       when T2."TransType" = 24 then CAST(T9."CheckNum" as CHAR) End)   "Description 2" --incoming
,(CASE when RIGHT (LEFT (right(T2."RefDate",23),5),1) = '' then '0' else RIGHT (LEFT (right(T2."RefDate",23),5),1) end) + 
(CASE when RIGHT (LEFT (right(T2."RefDate",23),6),1) = '' then '0' else RIGHT (LEFT (right(T2."RefDate",23),6),1) end)  "Dt"
--,left  EXTRACT (Month FROM  TO_DATE (Cast(T2."RefDate" as CHAR), 'YYYY-MM-DD')) as "Mnth"  --  CONVERT(VARCHAR(10),T2."RefDate",101),2) as "Mnth"  
,RIGHT (LEFT (right(T2."RefDate",23),12),5) "yr1"        
 ,RIGHT (LEFT (right(T2."RefDate",23),12),2) "Mnth" 
 --,left CONVERT(VARCHAR(10),T2."RefDate",101),2) as "Mnth"  
 from OACT T0       
inner join JDT1 T1 on T1."Account" = T0."AcctCode" 
--left outer join OACT T3 on T1."ContraAct" = T3."AcctCode"

--Journal Entry
inner join OJDT T2 on T1."TransId" = T2."TransId" and T2."TransType" in (30,140000009,24,46)
left outer join (Select W1."Series",W1."SeriesName",W2."TransId" from NNM1 W1 
inner join OJDT W2 on W1."Series" = W2."Series" ) T10 on T10."Series" = T2."Series"  and T2."TransId" = T10."TransId"

--Outgoing Payment
left outer join OVPM T4 on T4."DocNum" =(CASE when  T1."TransType" = 46 then T1."BaseRef"  else 0 end) and T1."RefDate" = T4."DocDate"
left outer join (Select W1."Series",W1."SeriesName",W2."DocNum" from NNM1 W1 inner join OVPM W2 on W1."Series" = W2."Series") T5 
on T4."Series" = T5."Series" and T4."DocNum" = T5."DocNum"
left outer join (select "CheckNum","DocNum" from VPM1 ) T8 on T8."DocNum" = T4."DocEntry"
left outer join (select "Descrip","DocNum","LineId" from VPM4 ) T11 on T11."DocNum" = T4."DocEntry" and T11."LineId" = 0

--Incoming Payment
left outer join ORCT T6 on T6."DocNum" = T1."BaseRef" and T1."RefDate" = T6."DocDate"  AND T1."TransType" = 24  --(CASE when  T1."TransType" = 24 then T1."BaseRef"  else 0 end) 
left outer join (Select N1."Series",N1."SeriesName",N2."DocNum" from NNM1 N1 inner join ORCT N2 on N1."Series" = N2."Series") T7 
on T6."Series" = T7."Series" and T6."DocNum"= T7."DocNum"
left outer join (select "CheckNum","DocNum" from RCT1 ) T9 on T9."DocNum" = T6."DocEntry"
left outer join (select "Descrip","DocNum","LineId" from RCT4)T12 on T12."DocNum" = T6."DocEntry" and T12."LineId" = 0
where
 T0."Finanse" = 'Y'
 and T0."AcctName" = :Bank
 and T2."RefDate" >= :Fromdate 
 and T2."RefDate" <= :ToDate
Group By   T0."AcctCode",T0."AcctName",T0."ActCurr",T2."RefDate",T1."TransId" ,T2."Number",T0."Segment_0",T0."Segment_1"
,T2."TransType",T5."SeriesName",T7."SeriesName",T10."SeriesName",T4."DocNum",T6."DocNum",T4."CardCode",T4."CardName",T11."Descrip",
T12."Descrip",T2."Memo",T4."Comments",T6."Comments",T8."CheckNum",T9."CheckNum" 

),
--------------------------------------------------------**************************-----------------------------------------------------
Query2 as(select 
T0."AcctCode",
sum(CASE when T2."RefDate" < :Fromdate then ifnull(T1."Debit",0) else 0 end)
- sum(CASE when T2."RefDate" < :Fromdate  then ifnull(T1."Credit",0) else 0 end)"Opening Balance"
  from OACT T0 
inner join JDT1 T1 on T1."Account" = T0."AcctCode"
inner join OJDT T2 on T1."TransId" = T2."TransId"
where
T0."Finanse" = 'Y'
and T0."AcctName" = :Bank
 group by T0."AcctCode")


-------------------------------------------------*******************************---------------------------------------------------

select *
 
from 

Query1 C1
inner join Query2 C2 on C1."AcctCode" = C2."AcctCode"

order by C1."Date1" ,C1."TransId" asc;

END