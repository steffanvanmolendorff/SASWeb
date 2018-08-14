*--- Uncomment to run on local machine ---;
/*
%Global _APIName;
%Let _APIName = SQ1;
*/
Options MPrint MLogic Source Source2 Symbolgen;

%Macro Main();
Proc Options option=encoding;
Run;
*--- Run_SQM Macro to execute code and get Macro Variables from Webpage - JSON Validation App ---;
%Macro Run_SQM(Dsn,SQMFile,SwaggerFile);
*--- The Main macro will execute the code to extract data from the API end points ---;
%Macro API(Url,Agency,API,Encoding);

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

Data Work.&Dsn._1;
	Set LibAPIs.Alldata(Where=(V=1));
Run;

%Mend API;
%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/&SQMFile..json,SQM,SQM,Filename API Temp);
*%API(&SQMFile,SQM,SQM,Filename API Temp);

%Mend Run_SQM;
	%Run_SQM(PCA_GB_AGG,pca.gb.agg,SQM_Swagger);
*	%Run_SQM(PCA_GB_AGG,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/GB/export-type/aggregated/wave/latest,SQM_Swagger);
	%Run_SQM(PCA_GB_FULL,pca.gb.full,SQM_Swagger);
*	%Run_SQM(PCA_GB_FULL,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/GB/export-type/full/wave/latest,SQM_Swagger);
	%Run_SQM(PCA_NI_AGG,pca.ni.agg,SQM_Swagger);
*	%Run_SQM(PCA_NI_AGG,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/NI/export-type/aggregated/wave/latest,SQM_Swagger);
	%Run_SQM(PCA_NI_FULL,pca.ni.full,SQM_Swagger);
*	%Run_SQM(PCA_NI_FULL,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/NI/export-type/full/wave/latest,SQM_Swagger);
	%Run_SQM(BCA_GB_AGG,BCA.GB.Agg,SQM_Swagger);
*	%Run_SQM(PCA_NI_FULL,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/bca/area/GB/export-type/aggregated/wave/latest,SQM_Swagger);
	%Run_SQM(BCA_GB_FULL,BCA.GB.Full,SQM_Swagger);
*	%Run_SQM(PCA_NI_FULL,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/bca/area/GB/export-type/full/wave/latest,SQM_Swagger);
	%Run_SQM(BCA_NI_AGG,BCA.NI.Agg,SQM_Swagger);
*	%Run_SQM(PCA_NI_FULL,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/bca/area/NI/export-type/aggregated/wave/latest,SQM_Swagger);
	%Run_SQM(BCA_NI_FULL,BCA.NI.Full,SQM_Swagger);
*	%Run_SQM(PCA_NI_FULL,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/bca/area/NI/export-type/full/wave/latest,SQM_Swagger);
%Mend Main;
%Main;


