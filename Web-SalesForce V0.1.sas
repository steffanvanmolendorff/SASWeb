filename WedPage URL "https://qa1-openbankingorg.cs84.force.com/registration";
*filename seercode URL "https://github.com/OpenBankingUK";
*filename seercode URL "https://github.com/OpenBankingUK/opendata-api-spec-compiled";
*filename seercode URL "https://github.com/OpenBankingUK/opendata-api-spec-compiled/blob/master/atm.json";

Data WebPageReg;
    Infile WedPage Truncover;
    Input @1 Value $char500.;

	WEB_File = Trim(Left(Value));

	If Scan(Web_File,1,'') in ('<div ','<label') then Value1 = 1;
	If Scan(Web_File,1,'>') eq ('<label') then Value1 = 1;
Run;

Data WebPageReg1(Keep = Chars Value2);
	set WebPageReg;
	
/*-- Clear out the HTML text --*/
	Chars = prxparse("s/<(.|\n)*?>//");
	Call Prxchange(Chars, -1, Value);

	If Trim(Left(Value)) NE '';

	Value2 = Trim(Left(Value));

	If IndexC(Value2, "{","}","<","/","j","<") then delete;
Run;



Filename SF "https://openbanking--qa1.lightning.force.com/one/one.app#/sObject/0065E000002xuvZQAQ/view?a:t=1493882620165";
data SF1;
    infile SF truncover;
    input @1 Value $char500.;
run;




filename INDEXIN URL "https://openbanking--qa1.lightning.force.com/one/";
Data HTMLData;
    infile INDEXIN truncover;

textline = _INFILE_;

*-- Clear out the HTML text --*;
re1 = prxparse("s/<(.|\n)*?>//");
call prxchange(re1, -1, textline);

run;
