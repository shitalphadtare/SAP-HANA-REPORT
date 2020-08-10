


CREATE PROCEDURE PTS_GENERAL_LEDGER
(
In Fromdate timestamp
,IN ToDate timestamp
,IN FromGLAcc nvarchar(100)
,IN ToGLAcc nvarchar(100)
--,IN Narration boolean
--,IN Print bit
--,IN ZeroBalance bit
--,IN NoPosting bit
--,IN Daily bit
--,IN Monthly bit
--,IN Yearly bit
)
LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER
AS
 Begin
 
with Query1 as(
select 
T0."AcctCode"
,CASE when T0."Segment_0" <>'' then T0."Segment_0" || '-' || T0."Segment_1" else T0."AcctCode"  end "AcctCode1"
,T0."AcctName"
,(CASE when T0."ActCurr" = 'INR' or T0."ActCurr" = '##'  then '(Local)' 
 else '(FC)' end ) "Currency"
,T2."RefDate" "Date1"
,(CASE when T2."TransType" = 46 then (case  when T4."DocCurr" = 'INR' then IFNULL(T1."Debit",0) else IFNULL(T1."FCDebit",0) end)--Outgoing
       when T2."TransType" = 24 then (case  when T6."DocCurr" = 'INR' then  IFNULL(T1."Debit",0) else IFNULL(T1."FCDebit",0) end)--Incoming
       when T2."TransType" = 13 then (case  when A1."DocCur"  = 'INR' then  IFNULL(T1."Debit",0) else IFNULL(T1."FCDebit",0) end)--A/R Invoice
       when T2."TransType" = 18 then (case  when A3."DocCur"  = 'INR' then  IFNULL(T1."Debit",0) else IFNULL(T1."FCDebit",0) end)--A/P Invoice
       when T2."TransType" = 14 then (case  when C1."DocCur"  = 'INR' then  IFNULL(T1."Debit",0) else IFNULL(T1."FCDebit",0) end)--A/R Credit Memo
       when T2."TransType" = 19 then (case  when C3."DocCur"  = 'INR' then  IFNULL(T1."Debit",0) else IFNULL(T1."FCDebit",0) end)--A/P Credit Memo
       when T2."TransType" = 30 then IFNULL(T1."Debit",0) else IFNULL(T1."FCDebit",0)--Journal Entry
       end ) "Debit"
,(CASE when T2."TransType" = 46 then (CASE when T4."DocCurr" = 'INR' then IFNULL(T1."Credit",0) else IFNULL(T1."FCCredit",0)end)--Outgoing
       when T2."TransType" = 24 then (CASE when T6."DocCurr" = 'INR' then IFNULL(T1."Credit",0) else IFNULL(T1."FCCredit",0)end)--Incoming
       when T2."TransType" = 13 then (CASE when A1."DocCur"  = 'INR' then  IFNULL(T1."Credit",0) else IFNULL(T1."FCCredit",0) end)--A/R Invoice
       when T2."TransType" = 18 then (CASE when A3."DocCur"  = 'INR' then  IFNULL(T1."Credit",0) else IFNULL(T1."FCCredit",0) end)--A/P Invoice
       when T2."TransType" = 14 then (CASE when C1."DocCur"  = 'INR' then  IFNULL(T1."Credit",0) else IFNULL(T1."FCCredit",0) end)--A/R Credit Memo
       when T2."TransType" = 19 then (CASE when C3."DocCur"  = 'INR' then  IFNULL(T1."Credit",0) else IFNULL(T1."FCCredit",0) end)--A/P Credit Memo
       when T2."TransType" = 30 then IFNULL(T1."Credit",0) else IFNULL(T1."FCCredit",0)--Journal Entry
       end ) "Credit"
,T1."TransId" 
,T2."TransType"
,(CASE when T2."TransType" = 46 then "T5"."SeriesName"  || '/' || CAST (T4."DocNum" as CHAR) --Outgoing
       when T2."TransType" = 24 then "T7"."SeriesName"  || '/' || CAST (T6."DocNum" as CHAR) --Incoming
       when T2."TransType" = 13 then "A2"."SeriesName"  || '/' || CAST(A1."DocNum" as CHAR)--A/R Invoice
       when T2."TransType" = 18 then "A4"."SeriesName"  || '/' || CAST(A3."DocNum" as CHAR)--A/P Invoice
       when T2."TransType" = 14 then "C2"."SeriesName"  || '/' || CAST(C1."DocNum" as CHAR)--A/R Credit Memo
       when T2."TransType" = 19 then "C4"."SeriesName"  || '/' || CAST(C3."DocNum" as CHAR)--A/P Credit Memo
       when T2."TransType" = 30 then "T10"."SeriesName" || '/' || CAST(T2."Number" as CHAR) --Journal Entry
       End) "Document No" 
,(CASE when T2."TransType" = 30 then 'Journal Entry'
       when T2."TransType" = 140000009 then 'Outgoing Ex Invoice'
       when T2."TransType" = 24 then 'Incoming Payment' 
       when T2."TransType" = 13 then 'A/R Invoice' 
       when T2."TransType" = 18 then 'A/P Invoice'
       when T2."TransType" = 14 then 'A/R Credit Memo' 
       when T2."TransType" = 19 then 'A/P Credit Memo'  
       else 'Outgoing Payment' end ) "Transction Name"  
,case when t2."TransType" <> 30 then (CASE when T3."Segment_0" <> '' then T3."Segment_0" || '  - ' || T3."Segment_1" || ' ' || T3."AcctName" 
       when T3."AcctCode" IS null OR T3."AcctCode" = '' and T3."Segment_0" IS NULL   then 
       (case when T2."TransType" = 46 then T4."CardCode" || '-' || T4."CardName" --Outgoing
             when T2."TransType" = 24 then T6."CardCode" || '-' || T6."CardName" --Incoming
             when T2."TransType" = 13 then A1."CardCode" || '-' || A1."CardName" --A/R Invoice
             when T2."TransType" = 18 then A3."CardCode" || '-' || A3."CardName" --A/P Invoice
             when T2."TransType" = 14 then C1."CardCode" || '-' || C1."CardName" --A/R Credit Memo
             when T2."TransType" = 19 then C3."CardCode" || '-' || C3."CardName" --A/P Credit Memo
             End)else T3."AcctCode" || ''   End)
             else T2."Memo" --Journal Entry
             end "BP/GL Code"         
,(CASE when T2."TransType" = 46 then T4."Comments" --outcoming
       when T2."TransType" = 24 then T6."Comments" --incoming
       when T2."TransType" = 13 then A1."Comments" --A/R Invoice
       when T2."TransType" = 18 then A3."Comments" --A/P Invoice
       when T2."TransType" = 14 then C1."Comments" --A/R Credit Memo
       when T2."TransType" = 19 then C3."Comments" --A/P Credit Memo
        end ) "Description 1"  
,Case when T2."TransType" in (46,24) then  ('Ch No.' || cast ( (CASE when T2."TransType" = 46 then "T8"."CheckNum"  --outcoming Ch no
      when T2."TransType" = 24 then "T9"."CheckNum" End)as CHAR))  --incoming Ch No
      when T2."TransType" = 13 then A1."NumAtCard"               --A/R Invoice Ref No
      when T2."TransType" = 18 then A3."NumAtCard"               --A/P Invoice Ref No
      when T2."TransType" = 14 then C1."NumAtCard"               --A/R Credit Memo Ref No
      when T2."TransType" = 19 then C3."NumAtCard"            --A/P Credit Memo Ref No
      End  "Cheque No/BP Ref"
,T2."RefDate" "Date2"
,DAYOFMONTH(T2."RefDate")  "Dt"
,Month(T2."RefDate") as "Mnth"
,year(T2."RefDate") "yr1" 
,OA."Name" "Segment"
       
from OACT T0 
inner join JDT1 T1 on T1."Account" = T0."AcctCode" 
left outer join OACT T3 on T1."ContraAct" = T3."AcctCode"
left outer join OASC OA on T0."Segment_1" = OA."Code"
--Journal Entry
inner join OJDT T2 on T1."TransId" = T2."TransId" and T2."TransType" in
  (30,140000009,24,46,13,18,14,19)--(13,30)
left outer join (Select W1."Series",W1."SeriesName",W2."TransId" from NNM1 W1 
inner join OJDT W2 on W1."Series" = W2."Series" 
) "T10" on "T10"."Series" = T2."Series"  and T2."TransId" = "T10"."TransId"

--Outgoing Payment
left outer join OVPM T4 on T4."DocNum" =(CASE when  T1."TransType" = 46 then T1."BaseRef"  else '' end) and T1."RefDate" = T4."DocDate"
left outer join (Select W1."Series","SeriesName",W2."DocNum" from NNM1 W1 inner join OVPM W2 on W1."Series" = W2."Series") "T5" on T4."Series" = "T5"."Series" and T4."DocNum" = "T5"."DocNum"
left outer join (select "CheckNum","DocNum" from VPM1 ) "T8" on "T8"."DocNum" = T4."DocEntry"
left outer join (select "Descrip","DocNum","LineId" from VPM4)"T11" on "T11"."DocNum" = T4."DocEntry" and "T11"."LineId" = 0

--Incoming Payment
left outer join ORCT T6 on T6."DocNum" =(CASE when  T1."TransType" = 24 then T1."BaseRef"  else '' end) and T1."RefDate" = T6."DocDate"
left outer join (Select W1."Series","SeriesName",W2."DocNum" from NNM1 W1 inner join ORCT W2 on W1."Series" = W2."Series") "T7" on T6."Series" = "T7"."Series" and T6."DocNum" = "T7"."DocNum"
left outer join (select "CheckNum","DocNum" from RCT1 ) "T9" on "T9"."DocNum" = T6."DocEntry"
left outer join (select "Descrip","DocNum","LineId" from RCT4)"T12" on "T12"."DocNum" = T6."DocEntry" and "T12"."LineId" = 0

--A/R Invoice
left outer join OINV A1 on A1."DocNum" =(CASE when  T1."TransType" = 13 then T1."BaseRef"  else '' end) and T1."RefDate" = A1."DocDate"
left outer join (Select W1."Series","SeriesName",W2."DocNum" from NNM1 W1 inner join OINV W2 on W1."Series" = W2."Series") "A2" on A1."Series" = "A2"."Series" and A1."DocNum" = "A2"."DocNum"

--A/P Invoice
left outer join OPCH A3 on A3."DocNum" =(CASE when  T1."TransType" = 18 then T1."BaseRef"  else '' end) and T1."RefDate" = A3."DocDate"
left outer join (Select W1."Series","SeriesName",W2."DocNum" from NNM1 W1 inner join OPCH W2 on W1."Series" = W2."Series") "A4" on A3."Series" = "A4"."Series" and A3."DocNum" = "A4"."DocNum"

--A/R Credit Memo
left outer join ORIN C1 on C1."DocNum" =(CASE when  T1."TransType" = 14 then T1."BaseRef"  else '' end) and T1."RefDate" = C1."DocDate"
left outer join (Select W1."Series","SeriesName",W2."DocNum" from NNM1 W1 inner join ORIN W2 on W1."Series" = W2."Series") "C2" on C1."Series" = "C2"."Series" and C1."DocNum" = "C2"."DocNum"

--A/P Credit Memo
left outer join ORPC C3 on C3."DocNum" =(CASE when  T1."TransType" = 19 then T1."BaseRef"  else '' end) and T1."RefDate" = C3."DocDate"
left outer join (Select W1."Series","SeriesName",W2."DocNum" from NNM1 W1 inner join ORPC W2 on W1."Series" = W2."Series") "C4" on C3."Series" = "C4"."Series" and C3."DocNum" = "C4"."DocNum"

where
 T2."RefDate" >= :Fromdate
 and T2."RefDate" <= :ToDate
 --and OA."Name" = :Segment
 and T0."AcctName" >= :FromGLAcc
 and T0."AcctName" <= :ToGLAcc
),
--------------------------------------------------------**************************-----------------------------------------------------
Query2 as(select 
CASE when T0."Segment_0" <>'' then T0."Segment_0" || '-' || T0."Segment_1" else T0."AcctCode"  end "AcctCode1",
sum(CASE when T2."RefDate" < :Fromdate then IFNULL(T1."Debit",0) else 0 end)
- sum(CASE when T2."RefDate" < :Fromdate
  then IFNULL(T1."Credit",0) else 0 end)"Opening Balance" 

  from OACT T0 
inner join JDT1 T1 on T1."Account" = T0."AcctCode"
inner join OJDT T2 on T1."TransId" = T2."TransId" 
 where T0."AcctName" >= :FromGLAcc
 and T0."AcctName" <= :ToGLAcc
 group by CASE when T0."Segment_0" <>'' then T0."Segment_0" || '-' || T0."Segment_1" else T0."AcctCode"  end)


-------------------------------------------------*******************************---------------------------------------------------

select 
*
from 

Query1 C1
inner join Query2 C2 on C1."AcctCode1" = C2."AcctCode1"
--order by C1."AcctName", C1.Date1,C1."TransId" asc

-------------------------------------------------*******************************---------------------------------------------------

union all

select distinct 
T0."AcctCode",
CASE when T0."Segment_0" <>'' then T0."Segment_0" else T0."AcctCode"  end "AcctCode1",
T0."AcctName",(CASE when T0."ActCurr" = 'INR' or T0."ActCurr" = '##'  then '(Local)' 
 else '(FC)' end  ) "Currency"
,'',0,0,'','',null,null,'','','','','','','','','',T0."CurrTotal"
from OACT T0 

where T0."Postable" = 'Y' and  T0."AcctCode" not in (select distinct "Account" from JDT1 
inner join OACT on JDT1."Account" = OACT."AcctCode"
--inner join OASC on OACT."Segment_1" = OASC.Code
where JDT1."RefDate" >= :Fromdate
 and JDT1."RefDate" <= :ToDate
 and "TransType" in (30,140000009,24,46,13,18,14,19)
 --and OASC.Name = :Segment
 and OACT."AcctName" >= :FromGLAcc
 and OACT."AcctName" <= :ToGLAcc )
  and T0."AcctName" >=  :FromGLAcc
 and T0."AcctName" <= :ToGLAcc;

end 
