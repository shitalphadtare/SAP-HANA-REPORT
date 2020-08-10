CREATE VIEW "WINTAC_LIVE"."BANK_RECONCILIATION" ( "No",
	 "MthAcctCod",
	 "matchdate",
	 "Totals",
	 "AcctName",
	 "Branch",
	 "Account",
	 "BankName" ) AS select
	 obnk."StatemNo" "No",
	 obnk."AcctCode" "MthAcctCod",
	 obnk."DueDate" "matchdate",
	 omth."Totals",
	 obnk."AcctName",
	 dsc1."Branch",
	 dsc1."Account",
	 odsc."BankName" 
from obnk 
left join omth on omth."MthAcctCod"=obnk."AcctCode" 
left join dsc1 on obnk."AcctCode"=dsc1."GLAccount" 
left join odsc on odsc."BankCode"=dsc1."BankCode" WITH READ ONLY