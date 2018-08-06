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
Libname LibAPIs JSON Fileref=API Ordinalcount = All;

*--- Proc datasets will create the datasets to examine resulting tables and structures ---;
Proc Datasets Lib = LibAPIs; 
Quit;

Data Work.&Bank._API;
	Set LibAPIs.Alldata;
Run;

%Mend API;
%API(https://sqm.openbanking.me.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/GB/export-type/full/wave/latest,SQM_PCA_GB_AGG,X1);
%API(https://sqm.openbanking.me.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/GB/export-type/aggregated/wave/latest,SQM_PCA_GB_FULL,X2);
%API(https://sqm.openbanking.me.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/NI/export-type/full/wave/latest,SQM_PCA_NI_AGG,X3);
%API(https://sqm.openbanking.me.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/NI/export-type/aggregated/wave/latest,SQM_PCA_NI_FULL,X4);
