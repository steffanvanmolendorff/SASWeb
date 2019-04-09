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
	Set LibAPIs.Alldata(Where=(V=1));
Run;

%Mend API;
%API(https://openapi.rbs.co.uk/open-banking/fca-service-metrics/pca,RBS,PCA,Filename API Temp);
%API(https://openapi.rbs.co.uk/open-banking/fca-service-metrics/bca,RBS,BCA,Filename API Temp);
%API(https://openapi.aibgb.co.uk/open-banking/fca-service-metrics/pca,AIB,PCA,Filename API Temp);
%API(https://obp-data.danskebank.com/open-banking/fca-service-metrics/pca,DANSKE,PCA,Filename API Temp);
%API(https://obp-data.danskebank.com/open-banking/fca-service-metrics/bca,DANSKE,BCA,Filename API Temp);
%API(https://openapi.firsttrustbank.co.uk/open-banking/fca-service-metrics/pca,FIRSTTRUST,PCA,Filename API Temp);
%API(https://openapi.firsttrustbank.co.uk/open-banking/fca-service-metrics/bca,FIRSTTRUST,BCA,Filename API Temp);
%API(https://openapi.natwest.com/open-banking/fca-service-metrics/pca,NATWEST,PCA,Filename API Temp);
%API(https://openapi.natwest.com/open-banking/fca-service-metrics/bca,NATWEST,BCA,Filename API Temp);
%API(https://openbanking.santander.co.uk/sanuk/external/open-banking/fca-service-metrics/pca,SANTANDER,PCA,Filename API Temp);
%API(https://openbanking.santander.co.uk/sanuk/external/open-banking/fca-service-metrics/bca,SANTANDER,BCA,Filename API Temp);
%API(https://openapi.ulsterbank.co.uk/open-banking/fca-service-metrics/pca,ULSTER,PCA,Filename API Temp);
%API(https://openapi.ulsterbank.co.uk/open-banking/fca-service-metrics/bca,ULSTER,BCA,Filename API Temp);
%API(https://api.lloydsbank.com/open-banking/fca-service-metrics/pca,LLOYDS,PCA,Filename API Temp);
%API(https://api.lloydsbank.com/open-banking/fca-service-metrics/bca,LLOYDS,BCA,Filename API Temp);
%API(https://api.bankofscotland.co.uk/open-banking/fca-service-metrics/pca,BOS,PCA,Filename API Temp);
%API(https://api.bankofscotland.co.uk/open-banking/fca-service-metrics/bca,BOS,BCA,Filename API Temp);
%API(https://api.halifax.co.uk/open-banking/fca-service-metrics/pca,,,Filename API Temp);
%API(https://openapi.nationwide.co.uk/open-banking/fca-service-metrics/pca,NATIONWIDE,PCA,Filename API Temp);
%API(https://openapi.nationwide.co.uk/open-banking/fca-service-metrics/bca,NATIONWIDE,BCA,Filename API Temp);
%API(https://api.hsbc.com/open-banking/fca-service-metrics/pca,HSBC,PCA,Filename API Temp);
%API(https://api.hsbc.com/open-banking/fca-service-metrics/bca,HSBC,BCA,Filename API Temp);
%API(https://atlas.api.barclays/open-banking/fca-service-metrics/pca,BARCLAYS,PCA,Filename API Temp);
%API(https://atlas.api.barclays/open-banking/fca-service-metrics/bca,BARCLAYS,BCA,Filename API Temp);
%API(https://openapi.bankofireland.com/open-banking/fca-service-metrics/pca,BOI,PCA,Filename API Temp);
%API(https://openapi.bankofireland.com/open-banking/fca-service-metrics/bca,BOI,BCA,Filename API Temp);

/*
%API(http://localhost/sasweb/data/temp/ob/sqm/h1_2019/pca.gb.agg.json,SQM,SQM,Filename API Temp);
%API(http://localhost/sasweb/data/temp/ob/sqm/h1_2019/pca.ni.agg.json,SQM,SQM,Filename API Temp);
%API(http://localhost/sasweb/data/temp/ob/sqm/h1_2019/pca.gb.full.json,SQM,SQM,Filename API Temp);
%API(http://localhost/sasweb/data/temp/ob/sqm/h1_2019/pca.ni.full.json,SQM,SQM,Filename API Temp);
