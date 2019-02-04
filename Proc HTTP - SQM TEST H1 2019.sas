%Macro API(Url,Agency,API,Encoding);

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

Data Work.&Agency._API;
	Set LibAPIs.Alldata(Where=(V=1));
Run;

%Mend API;
%API(http://localhost/sasweb/data/temp/ob/sqm/h1_2019/pca.gb.agg.json,SQM,SQM,Filename API Temp);
%API(http://localhost/sasweb/data/temp/ob/sqm/h1_2019/pca.ni.agg.json,SQM,SQM,Filename API Temp);
%API(http://localhost/sasweb/data/temp/ob/sqm/h1_2019/pca.gb.full.json,SQM,SQM,Filename API Temp);
%API(http://localhost/sasweb/data/temp/ob/sqm/h1_2019/pca.ni.full.json,SQM,SQM,Filename API Temp);
