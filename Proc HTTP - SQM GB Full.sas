Proc Options option=encoding;
Run;
Libname OBData "C:\inetpub\wwwroot\sasweb\Data\Perm";
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
%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/BCA_GB_Full_1.json,BCA_GB,SQM,Filename API Temp;);
%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/BCA_NI_Full_1.json,BCA_NI,SQM,Filename API Temp;);
%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/PCA_GB_Full.json,PCA_GB,SQM,Filename API Temp;);
%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/PCA_NI_Full.json,BCA_NI,SQM,Filename API Temp;);
/*%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/atms1.json,PCA,SQM,Filename API Temp/* encoding="wlatin1";);*/



*--- Test rows vs Meta TotalRecords ---;
Data Work.BCA_GB;
	Set Work.BCA_GB_API(Where=(P3='Data' and V=0));
Run;
*--- Test rows vs Meta TotalRecords ---;
Data Work.BCA_NI;
	Set Work.BCA_NI_API(Where=(P3='Data' and V=0));
Run;
