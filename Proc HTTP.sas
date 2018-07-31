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
%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/PCA_GB_Full.json,PCA,SQM,);
Proc Summary Data = Work.Acc1_api Nway Missing;
	Where V = 1;
	Class P1;
	Var V;
	Output Out = Acc1_Sum(Drop=_Type_ _Freq_)Sum=;
Run;
Proc Summary Data = Work.Acc2_api Nway Missing;
	Where V = 1;
	Class P1;
	Var V;
	Output Out = Acc2_Sum(Drop=_Type_ _Freq_)Sum=;
Run;
