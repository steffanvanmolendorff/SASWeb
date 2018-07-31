Proc Options option=encoding;
Run;
*--- The Main macro will execute the code to extract data from the API end points ---;
%Macro API(Url,Bank,API,Encoding);

/*Filename API Temp encoding="wlatin21";*/
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
/*%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/PCA_GB_Full.json,PCA,SQM,Filename API Temp encoding="wlatin1";);*/
%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/atms1.json,PCA,SQM,Filename API Temp/* encoding="wlatin1";*/);
