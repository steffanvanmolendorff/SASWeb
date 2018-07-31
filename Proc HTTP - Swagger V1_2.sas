Proc Options option=encoding;
Run;
*--- The Main macro will execute the code to extract data from the API end points ---;
%Macro API(Url,Bank,API,Encoding);

/*Filename API Temp encoding="wlatin2";*/
&Encoding;

*--- Proc HTTP assigns the GET method in the URL to access the data ---;
Proc HTTP
	Url = "&Url."
 	Method = "GET"
 	Out = API;
Run;

*--- The JSON engine will extract the data from the JSON script ---; 
Libname LibAPIs JSON Fileref=API Ordinalcount = All;

*--- Proc datasets will create the datasets to examine resulting tables and structures ---;
Proc Datasets Lib = LibAPIs; 
Quit;

Data Work.&Bank._API;
	Set LibAPIs.Alldata;
Run;

%Mend API;
%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/account_v1_1_swagger.json,ACC1,AC1,Filename API Temp;);
%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/account_v2_0_swagger.json,ACC2,AC2,Filename API Temp encoding="wlatin2";);
Proc Summary Data = Work.Acc1_api Nway Missing;
	Where V = 1;
	Class P1 P2;
	Var V;
	Output Out = Acc1_Sum(Drop=_Type_ _Freq_)Sum=;
Run;
Proc Summary Data = Work.Acc2_api Nway Missing;
	Where V = 1;
	Class P1 P2;
	Var V;
	Output Out = Acc2_Sum(Drop=_Type_ _Freq_)Sum=;
Run;

Data Work.Only_In_Version1
	Work.Only_In_Version2
	Work.In_Both_Versions;
	Length P1 $50. P2 $100.;
	Merge Work.Acc1_Sum(In=a Rename=(V=V1))
	Work.Acc2_Sum(In=b Rename=(V=V2));
	By P1 P2;
	
	If a and not b then 
	Do;
		Infile = 'Acc1';
		Output Work.Only_In_Version1;
	End;
	If b and not a then 
	Do;
		Infile = 'Acc2';
		Output  Work.Only_In_Version2;
	End;
	If a and b then 
	Do;
		Infile = 'Both';
		Output Work.In_Both_Versions;
	End;
Run;

%Macro ExportXL(Path,Dsn);
Proc Export Data = Work.&Dsn
 	Outfile = "&Path"
	DBMS = CSV REPLACE;
	PUTNAMES=YES;
Run;
%Mend ExportXL;
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\OB\&Dsn._%sysfunc(date(),date9.).csv,In_Both_Versions);
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\OB\&Dsn._%sysfunc(date(),date9.).csv,Only_In_Version1);
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\OB\&Dsn._%sysfunc(date(),date9.).csv,Only_In_Version2);

