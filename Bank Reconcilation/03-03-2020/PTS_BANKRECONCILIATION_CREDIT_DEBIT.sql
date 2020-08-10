CREATE VIEW  PTS_BANKRECONCILIATION_CREDIT_DEBIT  AS select
	 'Less: Amount debited in books but not credited by bank'as "colum",
	 jdt1."Account",
	obnk."DueDate" "mthdate",
	jdt1."RefDate",
	"Debit" as "Add1" ,
	obnk."AcctName" "Acountname" 
from jdt1 
left join obnk on obnk."AcctCode"=jdt1."Account" 
and obnk."BankMatch"=jdt1."ExtrMatch" 
where "Debit"<>0 WITH READ ONLY