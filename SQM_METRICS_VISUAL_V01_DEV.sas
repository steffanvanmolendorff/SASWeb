*--- Uncomment to run on local machine ---;
/*
%Global _APIName;
%Let _APIName = SQ1;
*/
Options MPrint MLogic Source Source2 Symbolgen;

%Macro Main();
Libname OBData "C:\inetpub\wwwroot\sasweb\Data\Perm";

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

Data Work.&Dsn;
*	Length Infile $20. 
	QuestionNumber
	Title
	SubTitle
	Brand
	Rank
	DisplayRank
	PublishedScore
	PublishedScore2dp
	Lowbase 
	Value $200.;

	Set LibAPIs.Alldata;

	InFile = "&Dsn";
/*
	If P3 EQ 'QuestionNumber' Then QuestionNumber = Value;
	If P3 EQ 'Title' Then Title = Value;
	If P3 EQ 'SubTitle' Then SubTitle = Value;

	If P4 EQ 'Brand' Then Brand = Value;
	If P4 EQ 'Rank' Then Rank = Value;
	If P4 EQ 'DisplayRank' Then DisplayRank = Value;
	If P4 EQ 'PublishedScore' Then PublishedScore = Value;
	If P4 EQ 'PublishedScore2dp' Then PublishedScore2dp = Value;
	If P4 EQ 'LowBase' Then LowBase = Value;

	Retain QuestionNumber
	Title
	SubTitle
	Brand
	Rank
	DisplayRank
	PublishedScore
	PublishedScore2dp
	Lowbase;

	If Brand NE '';
	If V NE 0;
	*/
Run;

%Mend API;
%API(&SQMFile,SQM,SQM,Filename API Temp);

Data Work.&Dsn;
*	Length Brand
	Rank
	DisplayRank
	PublishedScore
	PublishedScore2dp
	Lowbase $200.;

	Set Work.&Dsn;
	/*
	Work.BCA_NI_AGG_1
	Work.PCA_GB_AGG_1
	Work.PCA_NI_AGG_1;
	*/
	If P1 NE 'Meta';
	If V NE 0;
	RowCnt + 1;
	If P4 EQ '' Then P4=P3;
Run;

Proc Sort Data = Work.&Dsn;
	By RowCnt;
Run;

Data Work.&Dsn;
	Set Work.&Dsn;
	By RowCnt;

	If Trim(Left(P4)) EQ 'QuestionNumber' Then
	Do;
		QuestionNo_Cnt + 1;
		Brand_Cnt = 0;
	End;

	If P4 EQ 'Brand' Then
	Do;
		Brand_Cnt + 1;
	End;

Run;

Proc Summary Data = Work.&Dsn(Where=(P4 EQ 'Brand')) Nway Missing;
	Class Infile P4 Value;
	Var V;
	Output Out = Work.&Dsn._Summ(Drop=_Freq_ _Type_ V) Sum=;
Run;

proc export 
  data=Work.&Dsn._Summ 
  dbms=csv 
  outfile="C:\inetpub\wwwroot\sasweb\Data\Results\OB\SQM\&Dsn..csv" 
  replace;
run;

%Mend Run_SQM;
	%Run_SQM(PCA_GB_AGG,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/GB/export-type/aggregated/wave/latest,SQM_Swagger);
	%Run_SQM(PCA_NI_AGG,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/NI/export-type/aggregated/wave/latest,SQM_Swagger);
	%Run_SQM(BCA_GB_AGG,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/bca/area/GB/export-type/aggregated/wave/latest,SQM_Swagger);
	%Run_SQM(BCA_NI_AGG,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/bca/area/NI/export-type/aggregated/wave/latest,SQM_Swagger);
*	%Run_SQM(BCA_NI_FULL,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/bca/area/NI/export-type/full/wave/latest,SQM_Swagger);
*	%Run_SQM(PCA_GB_FULL,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/GB/export-type/full/wave/latest,SQM_Swagger);
*	%Run_SQM(PCA_NI_FULL,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/NI/export-type/full/wave/latest,SQM_Swagger);
*	%Run_SQM(BCA_GB_FULL,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/bca/area/GB/export-type/full/wave/latest,SQM_Swagger);

%Mend Main;
%Main;


/*

Data Work.Aggregate1;
	Set Work.Aggregate End=Last;
	By RowCnt;
Run;

/*
Proc Transpose Data = Work.Aggregate
	Out = Work.Transpose_AGG LET;
	By P1 - P3;
	ID P4;
	Var Value;
Run;
/*
Data OBData.Transpose_Agg1;
	Set Work.Transpose_Agg;

	Rank_N = Input(Rank,2.);
	If Substr(DisplayRank,1,1) = '=' Then
	Do;
		DisplayRank_N = Input(Substr(DisplayRank,2),2.);
	End;
	Else Do;
		DisplayRank_N = Input(DisplayRank,2.);
	End;
Run;

Data OBData.Full;
	Set Work.BCA_GB_Full_1
	Work.BCA_NI_Full_1
	Work.PCA_GB_Full_1
	Work.PCA_NI_Full_1;
Run;
*/

/*

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

	Set LibAPIs.Alldata;

Run;

%Mend API;
%API(&SQMFile,SQM,SQM,Filename API Temp);


%Mend Run_SQM;
*	%Run_SQM(PCA_GB_AGG,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/GB/export-type/aggregated/wave/latest,SQM_Swagger);
	%Run_SQM(PCA_GB_FULL,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/GB/export-type/full/wave/latest,SQM_Swagger);
*	%Run_SQM(PCA_NI_AGG,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/NI/export-type/aggregated/wave/latest,SQM_Swagger);
	%Run_SQM(PCA_NI_FULL,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/NI/export-type/full/wave/latest,SQM_Swagger);
*	%Run_SQM(BCA_GB_AGG,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/bca/area/GB/export-type/aggregated/wave/latest,SQM_Swagger);
	%Run_SQM(BCA_GB_FULL,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/bca/area/GB/export-type/full/wave/latest,SQM_Swagger);
*	%Run_SQM(BCA_NI_AGG,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/bca/area/NI/export-type/aggregated/wave/latest,SQM_Swagger);
	%Run_SQM(BCA_NI_FULL,https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/bca/area/NI/export-type/full/wave/latest,SQM_Swagger);
