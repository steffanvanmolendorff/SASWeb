*--- Uncomment to run on local machine ---;
/*
%Global _APIName;
%Let _APIName = SQ1;
*/
Options MPrint MLogic Source Source2 Symbolgen;
%Global _URL_Link;

%Macro Main();
Proc Options option=encoding;
Run;
*--- Run_SQM Macro to execute code and get Macro Variables from Webpage - JSON Validation App ---;
%Macro Run_SQM(Dsn,SQMFile,SwaggerFile);
*--- The Main macro will execute the code to extract data from the API end points ---;
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
	Call Symput("_URL_Link",%Str(Trim(Left("&Url"))));
Run;

%Mend API;
*%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/sqm_swagger.json,SWAGGER,SWA,Filename API Temp);
*%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/PCA.GB.Full.json,PCAFULL,SQM,Filename API Temp);
*%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/&SwaggerFile..json,SWAGGER,SWA,Filename API Temp);
*%API(http://localhost/sasweb/data/temp/ob/sqm/v1_0/&SQMFile..json,SQM,SQM,Filename API Temp);
%API(http://localhost/sasweb/data/temp/ob/sqm/h1_2019/&SwaggerFile..json,SWAGGER,SWA,Filename API Temp);
%API(http://localhost/sasweb/data/temp/ob/sqm/h1_2019/&SQMFile..json,SQM,SQM,Filename API Temp);
/*%API(&SQMFile,SQM,SQM,Filename API Temp);*/

%Put _URL_Link = &_URL_Link;

Data Work.Swagger_API1(Keep = P4 P5 Value Where=(P5 in ('description')));
	Set Work.Swagger_API(Where=(P1 EQ 'definitions'));
	If P2 EQ 'Weight' and P3 EQ 'description' then
	Do;
		P4 = P2;
		P5 = P3;
	End;

	If P2 EQ 'Meta' and P3 EQ 'required' and P5 EQ '' then
	Do;
		P4 = Value;
	End;

	If P2 in ('PCABrand','BCABrand') and P4 ='BrandName' Then
	Do;
		P5 = 'description';
	End;

Run;

*--- Add a Required field as Area does not contain have this in the Spec ---;
*--- THIS MUST BE ADDED IN THE NEXT STANDARD UPDATE - VERSION 2 ---;
Data Work.Required;
	Set Work.Swagger_API(Where=(P2 EQ 'Meta' and P3 = 'required'));
Run;
Data Work.Area;
	Set Work.Swagger_API(Where=(P2 = 'Meta' and P3 = 'required' and Value = 'Wave'));
	Value = 'Area';
	P4 = 'required8';
Run;
Data Work.Required1;
	Set Work.Required
	Work.Area;
	If Value EQ 'TypeofExport' Then 
	Do;
		Value = 'ProductType';
	End;

	If P2 EQ 'Meta' and P3 EQ 'required' and P5 EQ '' then
	Do;
		P4 = Value;
	End;
	If P5 EQ '' Then P5 = 'Meta';
	If P2 EQ 'Meta' and P5 EQ 'description' then Delete;
Run;

Data Work.Swagger_API2;
	Set Work.Swagger_API1
	Work.Required1;
	P4 = Trim(Left(P4));
Run;

Proc Sort Data = Work.Swagger_API2;
	By P4 Value;
Run;

Data Work.SQM_API1(Keep = P1 P4 Value Count RowCnt);
	Set Work.SQM_API;
	Count = 1;
	RowCnt + Count;

	If P3 = 'BrandName' and P4 EQ '' Then
	Do;
		P4 = P3;
	End;
	If P1 = 'Meta' and P4 EQ '' Then
	Do;
		P4 = P2;
	End;

	If P4 EQ '' and P3 NE '' Then
	Do;
		P4 = P2;
	End;
	If P4 EQ '' and P3 EQ '' and P2 NE '' Then
	Do;
		P4 = P2;
	End;
*--- Changes Footnotes1,2,3,4 to Footnotes as SAS adds 1234 to an array of values. 
	The spec states Footnotes ---;
	If P4 in ('Footnotes1','Footnotes2','Footnotes3','Footnotes4') Then P4 = 'Footnotes';

	P4 = Trim(Left(P4));
	Value = Trim(Left(Value));
Run;
Proc Sort Data = Work.SQM_API1;
	By P4 Value;
Run;

*--- Merge datasets SQM-SWAGGER and output separately to build reports ---;
Data Work._Meta_&Dsn(Keep = P4 P5 Value Swagger_Desc Infile Count RowCnt DiffDate)
	Work._Match_&Dsn(Keep = P4 P5 Value Swagger_Desc Infile Count RowCnt DiffDate)
	Work._SQM_&Dsn(Keep = P4 P5 Value Swagger_Desc Infile Count RowCnt DiffDate)
	Work._SWA_&Dsn(Keep = P4 P5 Value Swagger_Desc Infile Count RowCnt DiffDate);
	Length P4 $25. Infile $5.;
	Merge Work.SQM_API1(In=a)
	Work.SWAGGER_API2(In=b Rename=(Value = Swagger_Desc));
	By P4;

*--- Set the default DiffDate = 0 ---;
	DiffDate = 0;

*--- DiffDate is used to validate the LastUpdated date in the meta tags and should be less than
	60 days on the date that the Live data is published. This is to prevent files being published
	from the previous half years results ---; 
	If P4 = 'LastUpdated' then
	Do;
		Day = Input(Substr(Value,9,2),2.);
		Month = Input(Substr(Value,6,2),2.);
		Year = Input(Substr(Value,1,4),4.);
		MDY = MDY(Month,day,year);
		DiffDate = Today() - MDY;
	End;

	If a and not b then 
	Do;
		Infile = 'SQM';
		Output Work._SQM_&Dsn;
	End;

	If b and not a then 
	Do;
		Infile = 'SWA';
		Output Work._SWA_&Dsn;
	End;

	If a and b then 
	Do;
		Infile = 'MATCH';
		Output Work._Match_&Dsn;
	End;

	If a and b then 
	Do;
		If P5 = 'Meta';
		Infile = 'META';
		Output Work._META_&Dsn;
	End;
Run;

Proc Sort Data = Work._META_&Dsn;
	By RowCnt;
Run;
Proc Sort Data = Work._SQM_&Dsn;
	By RowCnt;
Run;
Proc Sort Data = Work._SWA_&Dsn;
	By RowCnt;
Run;
Proc Sort Data = Work._MATCH_&Dsn;
	By RowCnt;
Run;

/*
*--- Extract only the Meta records to display in the Report section ---;
*--- Create a LastUpdatedDate test to ensure the dateof the file is within 60 days of go-live date ---;
Data Work.SQM_API_Meta;
	Set Work.SQM_API(Where=(P1 EQ 'Meta'));
Run;
*/

*=====================================================================================================================================================
--- Macro code for the Resubmit-Return button at the bottom of the reports ---
======================================================================================================================================================;
%Macro ReturnButton();
Data _Null_;
		File _Webout;

		Put '<HTML>';
		Put '<HEAD>';
		Put '<html xmlns="http://www.w3.org/1999/xhtml">';
		Put '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
		Put '<meta http-equiv="X-UA-Compatible" content="IE=10"/>';
		Put '<title>OB TESTING</title>';

		Put '<meta charset="utf-8" />';
		Put '<title>Open Data Test Harness</title>';
		Put '<meta name="description" content="">';
		Put '<meta name="author" content="">';

		Put '<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />'; 

		Put '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
		Put '<title>LRM</title>';

		Put '<script type="text/javascript" src="'"&_Path/js/jquery.js"'">';
		Put '</script>';

		Put '<link rel="stylesheet" type="text/css" href="'"&_Path/css/style.css"'">';

		Put '</HEAD>';
		Put '<BODY>';

		Put '<p></p>';
		Put '<HR>';
		Put '<p></p>';

		Put '<Table align="center" style="width: 100%; height: 15%" border="0">';
		Put '<td valign="center" align="center" style="background-color: #D4E6F1; color: White">';
		Put '<FORM NAME=check METHOD=get ACTION="'"http://&_Host/scripts/broker.exe"'">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=submit VALUE="Return" align="center">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.Validate_Login.sas">';
		Put '<INPUT TYPE=hidden NAME=_service VALUE=' /
			"&_service"
			'>';
	    Put '<INPUT TYPE=hidden NAME=_debug VALUE=' /
			"&_debug"
			'>';
		Put '<INPUT TYPE=hidden NAME=_WebUser VALUE=' /
			"&_WebUser"
			'>';
		Put '<INPUT TYPE=hidden NAME=_WebPass VALUE=' /
			"&_WebPass"
			'>';
		Put '</Form>';
		Put '</td>';
		Put '</tr>';
		Put '</Table>';

		Put '<Table align="center" style="width: 100%; height: 15%" border="0">';
		Put '<td valign="top" style="background-color: White; color: black">';
		Put '<H3>All Rights Reserved</H3>';
		Put '<A HREF="http://www.openbanking.org.uk">Open Banking Limited</A>';
		Put '</td>';
		Put '</Table>';

		Put '</BODY>';
		Put '<HTML>';
		
Run;
%Mend ReturnButton;

%Macro Fdate(FMT,FMT2);
   %Global Fdate FdateTime;
   Data _Null_;
      Call Symput("Fdate",Left(Put("&Sysdate"d,&Fmt)));
      Call Symput("FdateTime",Left(Put("&Sysdate"d,&Fmt2)));
  Run;
%Mend Fdate;
%Fdate(worddate12., datetime.);

%Macro SQM_Reports(SQM_Dsn);

*=====================================================================================================================================================
--- Print Report with reocrds only in the Bank API dataset ---
======================================================================================================================================================;

%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";

*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
======================================================================================================================================================;
ODS _All_ Close;
ods listing close; 

ods tagsets.tableeditor file=_Webout
/*ods tagsets.tableeditor file="C:\inetpub\wwwroot\sasweb\Data\Results\OB\SQM\_SQM_&Dsn._%sysfunc(today(),date9.).html"*/
    style=styles.SASWeb 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ); 

		Title1 "OPEN BANKING - QUALITY ASSURANCE TESTING";
		Title2 "%Sysfunc(UPCASE(&SQMFile)) vs. %Sysfunc(UPCASE(&SwaggerFile))";
		Title3 color=red "&SQMFile - %Sysfunc(UPCASE(&Fdate))";
		Footnote1 "API LOCATION: &_URL_Link";
		Footnote2 "SCHEMA LOCATION: &_URL_Link";

		Proc Sort Data = Work.&SQM_Dsn;
			By RowCnt P5 P4;
		Run;

		Proc Report Data = Work.&SQM_Dsn nowd;

			Columns RowCnt
			Infile
			P5
			P4
			Value
			Swagger_Desc
			DiffDate;

			Define P5 / display 'SQM Metric Type' style(column)=[width=15%] left;
			Define P4 / display 'SQM Agency Metric Name' style(column)=[width=15%] left;
			Define Value / display 'SQM Agency Metric Value' style(column)=[width=15%] left;
			Define Swagger_Desc / display 'OB Metric Description' style(column)=[width=20%] left;
			Define RowCnt / display 'Row Number' style(column)=[width=5%] left;
			Define Infile / display 'Source File' style(column)=[width=5%] left;
			Define DiffDate / display 'Date Difference' style(column)=[width=5%] left /*Noprint*/;

			Compute P5;
			If P5 NE '' then 
				Do;
					call define(_col_,'style',"style=[foreground=blue background=#D4E6F1 font_weight=bold]");
				End;
			Endcomp;

			Compute P4;
			If P4 NE '' then 
			Do;
				Call define(_col_,'style',"style=[foreground=blue background=#D4E6F1 font_weight=bold]");
			End;
			Endcomp;

			Compute Value;
			If Value NE '' then 
			Do;
					Call define(_col_,'style',"style=[foreground=blue background=#D4E6F1 font_weight=bold]");
			End;
			Endcomp;

			Compute DiffDate;
			If DiffDate > 60 then
				Do;
					Call define(_col_,'style',"style=[foreground=red background=#D4E6F1 font_weight=bold]");
					Call define('Value','style',"style=[foreground=red background=#D4E6F1 font_weight=bold]");
				End;
				Else Do;
					call define(_col_,'style',"style=[foreground=blue background=#D4E6F1 font_weight=bold]");
				End;
			Endcomp;

			Compute Swagger_Desc;
			If Swagger_Desc NE '' then 
				Do;
					call define(_col_,'style',"style=[foreground=blue background=#D4E6F1 font_weight=bold]");
				End;
			Endcomp;

			Compute Infile;
			If Infile NE '' then 
				Do;
					call define(_col_,'style',"style=[foreground=blue background=#D4E6F1 font_weight=bold]");
				End;
			Endcomp;

			Compute RowCnt;
			If RowCnt NE '' then 
				Do;
					call define(_col_,'style',"style=[foreground=blue background=#D4E6F1 font_weight=bold]");
				End;
			Endcomp;

		Run;

%Mend SQM_Reports;
%SQM_Reports(_META_&Dsn);
%SQM_Reports(_MATCH_&Dsn);
%SQM_Reports(_SQM_&Dsn);
%SQM_Reports(_SWA_&Dsn);

*=====================================================================================================================================================
--- Add bottom of report Menu ReturnButton code here ---
======================================================================================================================================================;
	%ReturnButton();
*=====================================================================================================================================================
--- Open Output Delivery Parameters  ---
======================================================================================================================================================;
ODS HTML Close;	
ODS Listing;	
/*
	%Macro PrintPDF(Path,Dsn);
	ODS PDF style=HTMLBlue file="&Path";
	Proc Print Data = Work.&Dsn;
	Run;
	%Mend PrintPDF;
	%PrintPDF(C:\inetpub\wwwroot\sasweb\Data\Results\OB\SQM\_Meta_&Dsn._%sysfunc(today(),date9.).pdf,_Meta_&Dsn);
	%PrintPDF(C:\inetpub\wwwroot\sasweb\Data\Results\OB\SQM\_SQM_&Dsn._%sysfunc(today(),date9.).pdf,_SQM_&Dsn);
	%PrintPDF(C:\inetpub\wwwroot\sasweb\Data\Results\OB\SQM\_SWA_&Dsn._%sysfunc(today(),date9.).pdf,_SWA_&Dsn);
	%PrintPDF(C:\inetpub\wwwroot\sasweb\Data\Results\OB\SQM\_MATCH_&Dsn._%sysfunc(today(),date9.).pdf,_MATCH_&Dsn);
	ODS PDF Close;
*/
*=====================================================================================================================================================
						EXPORT REPORT RESULTS TO RESULTS FOLDER
=====================================================================================================================================================;
%Macro ExportXL(Path,Dsn);
Proc Export Data = Work.&Dsn
 	Outfile = "&Path"
	DBMS = CSV REPLACE;
	PUTNAMES=YES;
Run;
%Mend ExportXL;
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\OB\SQM\_Meta_&Dsn._%sysfunc(today(),date9.).csv,_META_&Dsn);
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\OB\SQM\_SQM_&Dsn._%sysfunc(today(),date9.).csv,_SQM_&Dsn);
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\OB\SQM\_SWA_&Dsn._%sysfunc(today(),date9.).csv,_SWA_&Dsn);
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\OB\SQM\_MATCH_&Dsn._%sysfunc(today(),date9.).csv,_MATCH_&Dsn);
/*
*================================================================================
					EMAIL REPORTS TO WEBUSER
=================================================================================;
%Macro SendMail();
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\OB\SQM\_META_&Dsn._%sysfunc(today(),date9.).csv"
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\OB\SQM\_SQM_&Dsn._%sysfunc(today(),date9.).csv"
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\OB\SQM\_SWA_&Dsn._%sysfunc(today(),date9.).csv"
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\OB\SQM\_MATCH_&Dsn._%sysfunc(today(),date9.).csv"
%Mend;


options emailhost=
 (
   "smtp.stackmail.com" 
   port=587 STARTTLS 
   auth=login
   id="steffan@vanmolendorff.com"
   pw="@Octa7700" 
 )
;

Filename myemail EMAIL
  To=("steffan.vanmolendorff@openbanking.org.uk" "&_WebUser" "daniel.johnson@openbanking.org.uk") 
  Subject="JSON VALIDATION - SQM &SQMFile -RESULTS"
		%SendMail;

Data _Null_;
  File Myemail;
  Put "All,";
  Put " ";
  Put "This email contains the results of the SQM &SQMFile August 2018 validation test results.";
  Put " ";
  Put "Regards";
  Put " ";
  Put "Open Banking - Test Team";
Run;
*/
*Filename Myemail Clear;
/*
%API(https://sqm.openbanking.me.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/GB/export-type/aggregated/wave/latest,SQM_PCA_GB_FULL,X2);
%API(https://sqm.openbanking.me.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/GB/export-type/full/wave/latest,SQM_PCA_GB_AGG,X1);
%API(https://sqm.openbanking.me.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/NI/export-type/aggregated/wave/latest,SQM_PCA_NI_FULL,X4);
%API(https://sqm.openbanking.me.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/NI/export-type/full/wave/latest,SQM_PCA_NI_AGG,X3);
*/
%Mend Run_SQM;
%If "&_APIName" EQ "SQ1" %Then
%Do;
	%Run_SQM(PCA_GB_AGG,pca.gb.agg,SQM_Swagger);
/*	%Run_SQM(PCA_GB_AGG,https://sqm.openbanking.me.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/GB/export-type/aggregated/wave/latest,SQM_Swagger);*/
%End;

%If "&_APIName" EQ "SQ2" %Then
%Do;
	%Run_SQM(PCA_GB_FULL,pca.gb.full,SQM_Swagger);
/*%Run_SQM(PCA_GB_FULL,https://sqm.openbanking.me.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/GB/export-type/full/wave/latest,SQM_Swagger);*/
	
%End;

%If "&_APIName" EQ "SQ3" %Then
%Do;
	%Run_SQM(PCA_NI_AGG,pca.ni.agg,SQM_Swagger);
/*	%Run_SQM(PCA_NI_AGG,https://sqm.openbanking.me.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/NI/export-type/aggregated/wave/latest,SQM_Swagger);*/
%End;

%If "&_APIName" EQ "SQ4" %Then
%Do;
	%Run_SQM(PCA_NI_FULL,pca.ni.full,SQM_Swagger);
/*	%Run_SQM(PCA_NI_FULL,https://sqm.openbanking.me.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/NI/export-type/full/wave/latest,SQM_Swagger);*/
%End;

%If "&_APIName" EQ "SQ5" %Then
%Do;
	%Run_SQM(BCA_GB_AGG,BCA.GB.Agg,SQM_Swagger);
%End;

%If "&_APIName" EQ "SQ6" %Then
%Do;
	%Run_SQM(BCA_GB_FULL,BCA.GB.Full,SQM_Swagger);
%End;

%If "&_APIName" EQ "SQ7" %Then
%Do;
	%Run_SQM(BCA_NI_AGG,BCA.NI.Agg,SQM_Swagger);
%End;

%If "&_APIName" EQ "SQ8" %Then
%Do;
	%Run_SQM(BCA_NI_FULL,BCA.NI.Full,SQM_Swagger);
%End;

%Mend Main;
%Main;


/*
%Macro MacroVars();
Proc Summary Data = Work.Swagger_API Nway Missing;
	Where P5 EQ 'enum';
	Class P4 P6 Value;
	Var V;
	Output Out = SWA_Summary(Drop=_Type_ _Freq_) Sum=;
Run;

Data Work.SWA_Summary1;
	Set Work.SWA_Summary End=Last;
	By P4 P6;
	If First.P4 Then
	Do;
		P4_Cnt + 1;
		P6_Cnt = 1;
	End;
	If Not First.P4 Then 
	Do;
		P6_Cnt + 1; 
	End;
	If Last.P4 and Last.P6 Then
	Do;
		P4_Total = P4_Cnt;
		P6_Total = P6_Cnt;
	End;
	Row_Cnt + 1;
	Retain P4_Cnt;
Run;

Data Work.SWA_Summary2;
	Set Work.SWA_Summary1; 
	Call Symput(Compress('P4_Var'||Put(P4_Cnt,2.)),P4);
	Call Symput(Compress('P6_VarVal'||Put(P4_Cnt,2.)||'_'||Put(P6_Cnt,2.)),Trim(Left(Value)));
Run;
Data Work.SWA_Summary_Total;
	Set Work.SWA_Summary1(Where=(P4_Total NE .)); 
	Call Symput(Compress('P4_Total'),Put(P4_Total,2.));
	Call Symput(Compress('P6_Total'||Put(P4_Total,2.)),Put(P6_Total,2.));
Run;
%Put _All_;

%Put _All_;

%Macro Test();
%Do i=1 %To &P4_Total;
	%Put i = &i;
	Data Work.X;
		Set Work._Match_BCA_GB_Full;
		%Do j = 1 %To &&P6_Total&i;
			%Put j = &&P6_Total&i;
			%Put P6_VarVal = "&&P6_VarVal&i._&j";
			If Trim(Left(Value)) EQ %Sysfunc(Trim(%Sysfunc(Left("&&P6_VarVal&i._&j")))) Then
			Do;
				Test = 'Yes';
				Output;
			End;
			Else Do;
				Test = 'No';
				Output;
			End;
		%End;
	Run;
%End;
%Mend Test;
%Test();

%Mend MacroVars;
%MacroVars();

Proc Sort Data = Work.SQM_API1;
	By P4 Value;
Run;
Proc Sort Data = Work.Swagger_API2;
	By P4 Value;
Run;

Data Work.Match Work.NoMatch;
	Merge Work.SWA_Summary2(In=a)
	Work.SQM_API1(In=b Rename=(Value=SQM_Value));
	By P4;
	If a and b then
	Do;
		Output Work.Match;
	End;
	Else Do;
		Output Work.NoMatch;
	End;
Run;
