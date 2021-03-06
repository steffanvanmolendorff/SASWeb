*--- The Main macro will execute the code to extract data from the API end points ---;
%Macro API(Url,Bank,API);

Filename API Temp;
 
*--- Proc HTTP assigns the GET method in the URL to access the data ---;
Proc HTTP
	Url = "&Url."
 	Method = "GET"
 	Out = API;
Run;


*--- The JSON engine will extract the data from the JSON script ---; 
Libname LibAPIs JSON Fileref=API;

*--- Proc datasets will create the datasets to examine resulting tables and structures ---;
Proc Datasets Lib = LibAPIs; 
Quit;

Data Work.&Bank._API;
	Set LibAPIs.Alldata;
Run;

%Mend API;
%API(http://localhost/Data/Temp/OB/SQM/h1_2019/pca.gb.agg.json,pca_gb_agg);
%API(http://localhost/Data/Temp/OB/SQM/h1_2019/pca.gb.full.json,pca_gb_full);
/*
%API(https://atlas.api.barclays/open-banking/v1.3/personal-current-accounts,Barclays,PCA);
%API(https://obp-api.danskebank.com/open-banking/v1.2/atms,Danske,ATM);
%API(https://obp-api.danskebank.com/open-banking/v1.2/personal-current-accounts,Danske,PCA);

%Macro Loop(URL);
%Do i = 1 %To 1;
%API(https://atlas.api.barclays/open-banking/v2.2/atms,Barclays,ATM);
%End;
%Mend Loop;
%Loop();
*/
