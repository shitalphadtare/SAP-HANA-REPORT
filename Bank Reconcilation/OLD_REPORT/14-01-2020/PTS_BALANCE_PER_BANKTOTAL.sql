CREATE VIEW "PTS_BALANCE_PER_BANKTOTAL"  AS select
	 obnk."AcctCode" as "Mthacctcod",
	 obnk."DueDate" as "Matchdate",
	 (obnk."CredAmnt"-obnk."DebAmount")as "totals" ,
	obnk."AcctName" 
from obnk 
Left Join omth on obnk."BankMatch"=omth."MatchNum" 
and obnk."AcctCode" = omth."MthAcctCod" WITH READ ONLY