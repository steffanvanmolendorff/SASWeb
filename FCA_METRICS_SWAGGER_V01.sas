*--- Uncomment to run on local machine ---;
/*
%Global _APIName;
%Let _APIName = SQ1;
*/
Options MPrint MLogic Source Source2 Symbolgen;

*--- The Main macro will execute the code to extract data from the API end points ---;
%Macro Main();
%Macro API(Url,Bank,API);

Filename API Temp;

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
	Set LibAPIs.Alldata(Where=(V=1));
Run;

%Mend API;
%API(http://localhost/sasweb/data/temp/ob/fca/v1_0/fca_pca_swagger.json,FCA_PCA_SWAGGER,SWA);
%API(http://localhost/sasweb/data/temp/ob/fca/v1_0/fca_nbs_pca.json,FCA_NBS_PCA,FCA);

%Mend Main;
%Main();
