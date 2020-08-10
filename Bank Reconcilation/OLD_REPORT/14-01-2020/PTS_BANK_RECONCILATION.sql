CREATE procedure PTS_BANK_RECONCILATION
(IN Date1 Timestamp,
IN Bank nvarchar(500)
)
LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER
AS
 Begin 
 with OP    
 AS  
 ( select jdt1."Account",sum("Debit"-"Credit") "Opening Balance", 
  ACT."AcctName" "Acctname" 
from jdt1
left outer join OACT ACT on ACT."AcctCode"=JDt1."Account"
 WHERE "RefDate"  <= :Date1 and  "AcctName"=:Bank
 group by jdt1."Account", ACT."AcctName"
 ),
 
Main as (select distinct
	-- obnk."StatemNo" "No",
	 obnk."AcctCode" "MthAcctCod",
	 --obnk."DueDate" "matchdate",
	-- omth."Totals",
	 obnk."AcctName",
	 dsc1."Branch",
	 dsc1."Account",
	 odsc."BankName" 
from obnk 
left join omth on omth."MthAcctCod"=obnk."AcctCode" 
left join dsc1 on obnk."AcctCode"=dsc1."GLAccount" 
left join odsc on odsc."BankCode"=dsc1."BankCode"
WHERE oBNK."DueDate"  <= :Date1  and  obnk."AcctName"=:Bank--:fromdate  
) ,
Balance_AS_BANK as(

select
	 obnk."AcctCode" as "Mthacctcod",
	 sum(obnk."CredAmnt"-obnk."DebAmount")as "totals" ,
	obnk."AcctName" 
from obnk 
Left Join omth on obnk."BankMatch"=omth."MatchNum" 
and obnk."AcctCode" = omth."MthAcctCod"
 WHERE obnk."DueDate"  <= :Date1  and  obnk."AcctName" =:Bank
 group by obnk."AcctCode" ,obnk."AcctName" 
)


select B."MthAcctCod",B."AcctName",B."Branch",B."Account",B."BankName" 
,OP."Opening Balance",A."totals" "Balance as Bank"

from Main B
left outer join OP on B."MthAcctCod"=op."Account"
left outer join Balance_AS_BANK A on A."Mthacctcod"=B."MthAcctCod";
end