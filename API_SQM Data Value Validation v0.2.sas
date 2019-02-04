*--- Set Global Macro variables ---;
%Global _Host;
%Global _Path;
%Global _PCA_GB_FULL_Records;
%Global _BCA_GB_FULL_Records;
%Global _PCA_NI_FULL_Records;
%Global _BCA_NI_FULL_Records;
%Global _Record_Cnt;

%Let _Host = &_SRVNAME;
%Let _Host = Localhost;
*%Put _Host = &_Host;

%Let _Path = http://&_Host/sasweb;
%Put _Path = &_Path;

*--- Assign permamnent data library ---;
Libname OBData "C:\inetpub\wwwroot\sasweb\Data\Perm";
*--- Set log file parameters ---;
Options MPrint MLogic Source Source2 Symbolgen;

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

*=====================================================================================================================================================
--- The Header Macro inserts the OB Test Application Banner on top of the web reports ---
======================================================================================================================================================;
%Macro Header();

Data _Null_;
		File _Webout;

Put '<HTML>';
Put '<HEAD>';
Put '<TITLE>OB TESTING</TITLE>';
Put '</HEAD>';

Put '<BODY>';

Put '<table style="width: 100%; height: 5%" border="0">';
   Put '<tr>';
      Put '<td valign="top" style="background-color: #D4E6F1; color: orange">';
	Put '<img src="'"&_Path/images/london.jpg"'" alt="Cant find image" style="width:100%;height:8%px;">';
      Put '</td>';
   Put '</tr>';
Put '</table>';
Put '</BODY>';

		Put '<p><br></p>';

		Put '<div id="container"></div>';

Put '</HTML>';

Run;
%Mend Header;

%Macro Sys_Errors();
*=====================================================================================================================================================
--- Run Header code to include OPEN BANKING Image at the top of the Report ---
======================================================================================================================================================;
%Header();
*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
======================================================================================================================================================;
		ODS _All_ Close;
  		ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;

	Data Work.System_Error;
		Length ERROR_DESC $ 100;

					ERROR_DESC = '';
					Output;
					ERROR_DESC = "     There are crytical system Errors in the execution of the program    ";
					Output;
					ERROR_DESC = '';
					Output;
					ERROR_DESC = '   Validate that the correct Version no was selected in the previous screen   ';
					Output;
					ERROR_DESC = '';
					Output;
					ERROR_DESC = "   *** Error Code: &ErrorCode - Error Description: &ErrorDesc ***   ";
					Output;
					ERROR_DESC = '';
					Output;
					ERROR_DESC = '   Contact the OBIE System Administrator - Email: steffan.vanmolendorff@openbanking.org.uk - Mobile: +44 749 7002 765   ';
					Output;
					ERROR_DESC = '';
					Output;
				Run;


				Title1 "OPEN BANKING - QUALITY ASSURANCE TESTING";

				Proc Report Data =  OBData.System_Error nowd
					style(report)=[rules=all cellspacing=0 bordercolor=gray] 
					style(header)=[background=lightskyblue foreground=black] 
					style(column)=[background=lightcyan foreground=black];

					Columns ERROR_DESC;

					Define ERROR_DESC / display 'System Execution Error' left;

					Compute ERROR_DESC;
					If ERROR_DESC NE '' then 
						Do;
							call define(_col_,'style',"style=[foreground=Red background=pink font_weight=bold]");
						End;
					Endcomp;

				Run;
*=====================================================================================================================================================
--- Add bottom of report Menu ReturnButton code here ---
======================================================================================================================================================;
		%ReturnButton();

	ODS Listing;

%Mend Sys_Errors;

*=====================================================================================================================================================
--- Set Title Date in Proc Print ---
======================================================================================================================================================;
%Macro Fdate(Fmt,Fmt2);
   %Global Fdate FdateTime;
   Data _Null_;
      Call Symput("Fdate",Left(Put("&Sysdate"d,&Fmt)));
      Call Symput("FdateTime",Left(Put("&Sysdate"d,&Fmt2)));
  Run;
%Mend Fdate;
%Fdate(worddate12., datetime.);

/*
*--- Put FDate values in log to confirm dates values are correct ---;
%let fname = %sysfunc(DateTime(),datetime.);
%put fname= &fname;
*/
*=====================================================================================================================================================
--- Proc Template creates the style SASWeb and the macro is called by Proc Report ---
======================================================================================================================================================;
%Macro Template;
Proc Template;
 	Define style Style.Sasweb;
	End;
Run; 
%Mend Template;
%Template;


%Macro SQM_Standard(URL,Dsn);

Filename API Temp;
 
*--- Proc HTTP assigns the GET method in the URL to access the data contained within the Schema ---;
Proc HTTP
	Url = "&Url."
 	Method = "GET" Verbose
 	Out = API;
Run;
 
*--- The JSON engine will extract the data from the JSON script ---; 
Libname LibAPIs JSON Fileref=API;

*--- Proc datasets will create the datasets to examine resulting tables and structures ---;
Proc Datasets Lib = LibAPIs; 
Quit;

*--- Capture any error codes at this point, specifically if the Schema file did no load ---;
%If &SYSERR > 0 %Then
%Do;
	%Let SYSTEM_ERROR = &SYSERR;
%End;

*--- Create the SQM Schema dataset ---;
Data Work.SQM_Standard;
	Set LibAPIs.Alldata;
Run;

*--- Sort the file by P1 tp P6 values ---;
Proc Sort Data = Work.SQM_Standard(Drop=P)
	Out = SQM_Subset(Where=(P3 EQ 'properties' and V NE 0 and P5 EQ 'enum'));
	By P1 - P6;
Run;

*--- Create the count variables to count the enum values per question ---;
Data Work.SQM_Subset1;
	Set Work.SQM_Subset;
	By P1 - P6;
	*--- Total row count value to use in Do-Loops ---;
	Row_Count + 1;
	If First.P4 Then
	Do;
	*--- Count the number of P4 enum values per P4 question ---;
		Var_Count + 1;
		Value_Count = 1;
	End;
	Else Do;
		Value_Count + 1;
	End;
Run;


*--- Create the count variables to count the enum values per question ---;
Data Work.SQM_Subset2;
	Set Work.SQM_Subset1;
	By P1 - P6;
	*--- Total row count value to use in Do-Loops ---;
	Row_Count + 1;
	If First.P4 Then
	Do;
	*--- Count the number of P4 enum values per P4 question ---;
		NewVar = Compress('P4_Vars'||'_'||Put(Var_Count,2.));
		Call Symput(Compress('P4_Vars'||'_'||Put(Var_Count,2.)),P4);
		Call Symput(Compress('P4_Value'||'_'||Put(Var_Count,2.)||'_'||Put(Value_Count,2.)),Strip(Value));
		Call Symput(Compress('Last_Value'||'_'||Put(Var_Count,2.)),Strip(Value_Count));
	End;
	Else Do;
		Call Symput(Compress('P4_Value'||'_'||Put(Var_Count,2.)||'_'||Put(Value_Count,2.)),Strip(Value));
		If Last.P4 Then 
		Do;
			Last_Count = Value_Count;
			Call Symput(Compress('Last_Value'||'_'||Put(Var_Count,2.)),Strip(Value_Count));
		End;
	End;

*--- Save Row_count and Var_Count values in macro variables ---;
	Call Symput(Compress('Row_Count'),Put(Row_Count,3.));
	Call Symput(Compress('Var_Count'),Put(Var_Count,3.));
Run;

*--- Create a counter and save values in macro variables in memory ---;
Data Work.Sqm_Subset3;
	Length Question $17. Value $121.;
	%Do i = 1 %To &Var_Count;
		Question = Strip("&&P4_Vars_&i");
		%Do j = 1 %To &&Last_Value_&i;
			Value = Strip("&&P4_Value_&i._&j");
			SQM_Value = Value;
			Output;
		%End;
	%End;
Run;

*--- Create Macro variables to store the P4 enum values ---;
Proc Sort Data = Work.Sqm_Subset3;
	By Question Value;
Run;

%Mend SQM_Standard;
%SQM_Standard(http://&_Host/sasweb/data/temp/ob/sqm/v1_0/sqm_swagger.json,SQM);

%Macro SQM_Agency(URL,Dsn);

Filename API Temp;
 
*--- Proc HTTP assigns the GET method in the URL to access the data contained within the Schema ---;
Proc HTTP
	Url = "&Url."
 	Method = "GET" Verbose
 	Out = API;
Run;
 
*--- The JSON engine will extract the data from the JSON script ---; 
Libname LibAPIs JSON Fileref=API;

*--- Proc datasets will create the datasets to examine resulting tables and structures ---;
Proc Datasets Lib = LibAPIs; 
Quit;

Data Work.&Dsn(Where=(V NE 0) /*Keep = V P4 PCA_Value Value Row_Count*/ Rename = (P4 = Question));
	Set LibAPIs.Alldata;
	If P3 EQ 'BrandName' Then 
	Do;
		BrandName_Count + 1;
		Brand_Count = 0;
	End;
	If P4 EQ 'Brand' Then Brand_Count + 1;

	PCA_Value = Strip(Value);
	P4 = Strip(P4);

/*	If _N_ EQ 50456 then PCA_Value = Strip(Value)||'_TEST';*/

	Row_Count + 1;
	Record_Cnt = _N_;
	Call Symput('_Record_Cnt',Record_Cnt);
Run;

Proc Sort Data = Work.&Dsn;
	By Question Value;
Run;

*--- Combine BCA-PCA Data with BCA-PCA Standards to list only values in the PCA-BCA API ---;
Data Work.&Dsn._STD_Combined;
	Length Question $17. Flag $16.;
	Merge Work.&Dsn(In=a)
	Work.SQM_Subset3(In=b);
	By Question Value;
	If a and b then Flag = 'MATCH';
	If b and not a then Flag = 'ONLY_SQM';
	If a and not b then Flag = "ONLY_&Dsn.";

	If Question in ('Brand' 'Age' 'Weight') and SQM_Value EQ '' Then Flag = 'IGNORE';

	Test_Flag = "&_Record_Cnt";
Run;
*--- Sort data by Row_Count ---;
Proc Sort Data = Work.&Dsn._STD_Combined(Keep= Question
	Flag 
	P1
	P2
	P3
	Value
	Row_Count
	Test_Flag
	Where=(Flag EQ "ONLY_&Dsn."));
	By Row_Count;
Run;

*--- Sort the dataset and keep only the unique variables ---;
Proc Sort Data = Work.&Dsn._STD_Combined/*(Where=(Question NE ''))*/
	Out = Work.&Dsn._Final NoDupKey;
	By Question Value;
Run;
*--- Sort the dataset and keep only the unique variables ---;
Proc Sort Data = Work.SQM_Subset3/*(Where=(Question NE ''))*/
	Out = Work.SQM_Subset4 NoDupKey;
	By Question Value;
Run;

Data Work.&Dsn._Final_Options(Drop=Row_Count Value P3);
	Merge Work.&Dsn._Final(In=a Rename=(Value = &Dsn._Value))
	Work.SQM_Subset4(In=b);
	By Question;
*--- Only keep records if there are matches of the 'By Question variable' between the 2 datasets ---;
	If a and b/* or P1 EQ 'Meta'*/;

*--- Create variables with the value 0 and 1. If _N_<1 then there are no records ---;
	No_Records = '0';
	Records = '1';

	If _N_ < 1 Then
	Do;
		Call Symput("_&Dsn._Records",No_Records);
	End;
	Else Do;
		Call Symput("_&Dsn._Records",Records);
	End;

	*--- Create a comparison variable to indicate if the first 6 chars PCA/BCA_Value = SQM_Value ---;
	if &Dsn._Value NE '' Then
	Do;
		If Substr(Trim(Left(&Dsn._Value)),1,6) EQ Substr(Trim(Left(SQM_Value)),1,6) Then
		Do;
			Compare = 1;
		End;
		Else Do;
			Compare = 0;
		End;
	End;
Run;

/*%Put _&Dsn._Records = "&&_&Dsn._Records";*/

%Mend SQM_Agency;
%SQM_Agency(https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/GB/export-type/full/wave/latest,PCA_GB_FULL);
%SQM_Agency(https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/bca/area/GB/export-type/full/wave/latest,BCA_GB_FULL);
%SQM_Agency(https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/pca/area/NI/export-type/full/wave/latest,PCA_NI_FULL);
%SQM_Agency(https://sqm.openbanking.org.uk/cma-service-quality-metrics/v1.0/product-type/bca/area/NI/export-type/full/wave/latest,BCA_NI_FULL);

*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
======================================================================================================================================================;
ODS _All_ Close;
%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
=====================================================================================================================================================;
*ODS _All_ Close;
ods listing close; 

*--- The ODS tagsets set the screen format and colour schemes ---;
ods tagsets.tableeditor file=_Webout
    style=styles.SASWeb 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            );

%Macro SQM_Errors(Dsn);

		Title1 "OPEN BANKING - SERVICE QUALITY METRICS (SQM)";
		Title2 "%Sysfunc(UPCASE(&Dsn)) SQM REPORT - %Sysfunc(UPCASE(&Fdate))";
		Footnote1 "POWERED BY QLICK2";

*--- Craete empty dataset to indicate if there were zero mismatches in the PCA/BCA files ---;
		Data Work.No_Records;
			QUESTION = "There are no record mismatches in the &Dsn dataset";
			ERROR_FILE = "&Dsn File";
			META_DATA = "&Dsn N/A";
			DATA_TYPE = "&Dsn N/A";
			&Dsn._VALUE = "&Dsn N/A";
			SQM_VALUE = "SQM N/A";
		Run;

		%Put &&_&Dsn._FULL_Records = "&&_&Dsn._FULL_Records";

		%If "&&_&Dsn._FULL_Records" EQ "" %Then
		%Do;

*--- Write the dataset to a pdf file ---;
		ODS PDF File = "C:\inetpub\wwwroot\sasweb\Data\Results\OB\SQM\&Dsn._FULL_Final_Options.pdf"
		style=styles.SASWeb; 


		Proc Report Data =  Work.&Dsn._FULL_Final(Where=(P1 EQ 'Meta')) nowd;

*--- Set the column order in the report output ---;
		Columns Compare=Compare_n
		Flag
		P1
		P2
		Value
		Test_Flag;

*--- Define the data elements in the headings ---;
		Define Compare_n / Noprint;
		Define Flag / display 'ERROR FILE' left;
		Define P1 / display 'META DATA' left;
		Define P2 / display 'DATA TYPE' left;
		Define Value / display 'HEADER VALUE' left;
		Define Test_Flag / display 'TEST FLAG' left;

/*		Compute Before;
			_C5_ = Value;
		EndComp;

		Compute Test_Flag;
			Test_Flag = _C5_;
		EndComp;
*/
		Run;


*--- Create the Web report for the zero mismatches in the PCA-BCA file ---;
		Proc Report Data =  Work.No_Records nowd;

*--- Set the column order in the report output ---;
		Columns QUESTION
		ERROR_FILE
		META_DATA
		DATA_TYPE
		&Dsn._VALUE
		SQM_VALUE;

*--- Define the data elements in the headings ---;
		Define QUESTION / display "SQM QUESTION" left;
		Define ERROR_FILE / display 'ERROR FILE' left;
		Define META_DATA / display 'META DATA' left;
		Define DATA_TYPE / display 'DATA TYPE' left;
		Define &Dsn._VALUE / display "&Dsn QUESTION" left;
		Define SQM_VALUE / display 'SQM VALUE' left;

		Run;
*--- Close the PDF output ---;
		ODS PDF CLOSE;
		%End;
		%If "&&_&Dsn._FULL_Records" EQ "1" %Then
		%Do;

		ODS PDF File = "C:\inetpub\wwwroot\sasweb\Data\Results\OB\SQM\&Dsn._FULL_Final_Options.pdf"
		style=styles.SASWeb; 


		Proc Report Data =  Work.&Dsn._FULL_Final(Where=(P1 EQ 'Meta')) nowd;

*--- Set the column order in the report output ---;
		Columns Compare=Compare_n
		Flag
		P1
		P2
		Value
		Test_Flag;

*--- Define the data elements in the headings ---;
		Define Compare_n / Noprint;
		Define Flag / display 'ERROR FILE' left;
		Define P1 / display 'META DATA' left;
		Define P2 / display 'DATA TYPE' left;
		Define Value / display 'HEADER VALUE' left;
		Define Test_Flag / display 'TEST FLAG' left;

/*		Compute Before;
			_C5_ = Value;
		EndComp;

		Compute Test_Flag;
			If Test_Flag = _C5_ Then Test_Flag = 'Match';
		EndComp;
*/
		Run;




*--- Create the Web report for the zero mismatches in the PCA-BCA file ---;
		Proc Report Data =  Work.&Dsn._FULL_Final_Options nowd;

*--- Set the column order in the report output ---;
		Columns Compare=Compare_n
		Question
		Flag
		P1
		P2
		&Dsn._FULL_Value
		SQM_Value;

*--- Define the data elements in the headings ---;
		Define Compare_n / Noprint;
		Define Question / display 'SQM QUESTION' left;
		Define Flag / display 'ERROR FILE' left;
		Define P1 / display 'META DATA' left;
		Define P2 / display 'DATA TYPE' left;
		Define &Dsn._FULL_Value / display "&Dsn VALUE" left;
		Define SQM_Value / display 'SQM VALUE' left;

*--- Compute the ourput colours in the report to show error records (blue) ---;
		Compute &Dsn._FULL_Value;
			If Compare_n = 1 Then
			Do;
				call define(_col_,'style',"style=[foreground=blue background=#D4E6F1 font_weight=bold]");
			End;
		Endcomp;
*--- Compute the ourput colours in the report to show the correct options (red) ---;
		Compute SQM_Value;
			If Compare_n = 1 Then
			Do;
				call define(_col_,'style',"style=[foreground=red background=#D4E6F1 font_weight=bold]");
			End;
		Endcomp;

		Run;
/*
		Proc Print Data = Work.&Dsn._GB_FULL_STD_COMBINED;
		Run;
*/
		ODS PDF CLOSE;
		%End;

%Mend SQM_Errors;
%SQM_Errors(PCA_GB);
%SQM_Errors(BCA_GB);
%SQM_Errors(PCA_NI);
%SQM_Errors(BCA_NI);


*=====================================================================================================================================================
--- Add bottom of report Menu ReturnButton code here ---
======================================================================================================================================================;
%ReturnButton();
*=====================================================================================================================================================
--- Open Output Delivery Parameters  ---
======================================================================================================================================================;
*		ODS HTML Close;	
*		ODS Listing;	

ods tagsets.tableeditor close; 
ods listing; 

