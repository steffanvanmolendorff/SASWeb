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

Data Work.&Bank;
	Set LibAPIs.Alldata;
Run;

%Mend API;
*%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/Test-File.json,Test_File,Test,Filename API Temp);
*%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/PCA.GB.AGG.json,PCA_GB_AGG,SQM,Filename API Temp);
*%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/PCA.GB.Full.json,PCA_GB_FULL,SQM,Filename API Temp);
*%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/PCA.NI.AGG.json,PCA_NI_AGG,SQM,Filename API Temp);
*%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/PCA.NI.Full.json,PCA_NI_FULL,SQM,Filename API Temp);
%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/BCA.GB.Full.json,BCA_GB_FULL,SQM,Filename API Temp);


/*
*--- Test rows vs Meta TotalRecords ---;
Data Work.PCA_GB_AGG1;
	Set Work.PCA_GB_AGG(Where=(P2='Question' and P3='Results' and P4='Brand' and V=1));
Run;
*--- Test rows vs Meta TotalRecords ---;
Data Work.PCA_GB_FULL1;
	Set Work.PCA_GB_FULL(Where=(P3='Data' and V=0));
Run;
*--- Test rows vs Meta TotalRecords ---;
Data Work.PCA_NI_AGG1;
	Set Work.PCA_NI_AGG(Where=(P2='Question' and P3='Results' and V=1));
Run;
*--- Test rows vs Meta TotalRecords ---;
Data Work.PCA_NI_FULL1;
	Set Work.PCA_NI_FULL(Where=(P3='Data' and V=0));
Run;
