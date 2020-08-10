create PROCEDURE PTS_BANK_RECONCILIATION_DEBIT

AS
BEGIN

	--SET NOCOUNT ON;

  select
jdt1."Account",obnk."DueDate" as "mthdate",							
jdt1."RefDate",jdt1."TransId",jdt1."Debit",							
jdt1."Ref3Line" as "chqNo",jdt1."DueDate" as "chqDate",jdt1."ExtrMatch",							
CASE when  OVPM."Address" is null OR OVPM."Address"='' then oact."AcctName" else OVPM."Address" end "acctname", 							
ocrd."CardName",(select "AcctName" from OACT where "AcctCode"=jdt1."Account") "Acountname",
jdt1."Ref1" "Docnum"								
from jdt1							
left join oact  on jdt1."ContraAct" = oact."AcctCode"							
left join ocrd  on jdt1."ContraAct" = ocrd."CardCode"							
left join obnk on obnk."AcctCode"=jdt1."Account" and obnk."BankMatch"=jdt1."ExtrMatch"							
left join OJDT on jdt1."TransId"=ojdt."TransId"							
left join OVPM on OVPM."TransId"=ojdt."TransId" and OVPM."DocType"='A'							
where "Debit"<>0 order by jdt1."DueDate" asc;
END;

