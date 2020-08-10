create PROCEDURE PTS_BANK_RECONCILIATION_CREDIT
	-- Add the parameters for the stored procedure here
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

    -- Insert statements for procedure here
	select 							
jdt1."Account",obnk."DueDate" as "mthdate",							
jdt1."RefDate",jdt1."TransId",jdt1."Credit",							
jdt1."Ref3Line" as "chqNo",jdt1."DueDate" as "chqDate",jdt1."ExtrMatch",							
case when ovpm."Address" is null or ovpm."Address"='' then oact."AcctName" else ovpm."Address" end "acctname", 							
ocrd."CardName",(select "AcctName" from OACT	where "AcctCode"=jdt1."Account") "Acountname",
jdt1."Ref1" "Docnum"										
							
from jdt1							
left join oact  on jdt1."ContraAct" = oact."AcctCode"							
left join ocrd  on jdt1."ContraAct" = ocrd."CardCode"							
left join obnk on obnk."AcctCode"=jdt1."Account" and obnk."BankMatch"=jdt1."ExtrMatch"							
left join  ojdt on jdt1."TransId"=ojdt."TransId"							
left join OVPM on ovpm."TransId"=ojdt."TransId" and ovpm."DocType"='A'							
where jdt1."Credit"<>0  order by jdt1."DueDate" asc;

END;

