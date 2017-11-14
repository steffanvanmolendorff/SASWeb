/*
*===============================================================================================*
*																								*
*	Program Name: CMA9 Product Comparison V1.0													*																							*
*	Version 1.0																					*
*	Open Data APIs': PCA, BCA, SME and CCC														*
*																								*
*	During the last CMA9 Steering Committee meeting LBG raised some								*
*	concerns in relation to the interpretation of the Open Data									*
*	Data Dictionary. It was agreed that Open Banking will perform								*
*	some comparison analysis on the data fields and values present								*
*	within the CMA9 API end points.																*
*																								*
*	The SAS code below extracts information from the CMA9 Open Data API end points.				*
*																								*
*	Author: Steffan van Molendorff																*
*	Date: 27 March 2017																			*
*																								*
*	Updates - 7 April 2017:																		*
*	Version 1.1 created on 7 April 2017.														*
*	Includes an update of the ODS CSV export code. This was implemented because Proc Export		*
*	include new line characters from Excel and splits the data over multiple lines whereby the	*
*	structure of the CSV file is broken. ODS CSV functionality does a direct export of the		*
*	data in SAS to Excel/CSV.																	*
*																								*
*																								*
*	Nex Update:																					*
*																								*
*===============================================================================================;
*/
%Global _Host;
%Global _Path;

%Let _Host = &_SRVNAME;
%Put _Host = &_Host;

%Let _Path = http://&_Host/sasweb;
%Put _Path = &_Path;

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

Put '</HTML>';

Run;
%Mend Header;

*--- Set Title Date in Proc Print ---;
%Macro Fdate(Fmt);
   %Global Fdate;
   Data _Null_;
      Call Symput("Fdate",Left(Put("&Sysdate"d,&Fmt)));
   Run;
%Mend Fdate;
%Fdate(Worddate.)

%Macro Template;
Proc Template;
 	Define style Style.Sasweb;
	End;
Run; 
%Mend Template
%Template;

%Macro CMA9_Reports(API);

*--- Assign Library Path ---;
/*Libname OBData "C:\inetpub\wwwroot\sasweb\Data\Perm";*/


/*
ODS HTML Body="Compare_CMA9_&API..html" 
	Contents="Compare_contents_&API..html" 
	Frame="Compare_frame_&API..html" 
	Style=HTMLBlue;
*/

/*ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;*/

/*%Header();*/

%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
title "Listing of Product Sales"; 
*--- Set Output Delivery Parameters  ---;
ODS _All_ Close;
ods listing close; 

ods tagsets.tableeditor file=_Webout
    style=styles.SASWeb 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="Yes" 
            frozen_rowheaders="Yes" 
            ); 

/*
*--- Print ATMS Report ---;
Proc Print Data = OBData.Stats;
	Title1 "Open Banking";
	Title2 "Error Report Statistics";
Run;
*/
	
Proc Report Data = OBData.Stats nowd/*
	style(report)=[width=100%]
	style(report)=[rules=all cellspacing=0 bordercolor=gray] 
	style(header)=[background=lightskyblue foreground=black] 
	style(column)=[background=lightcyan foreground=black]*/;

	Title1 "OPEN BANKING - STATUS REPORT";
	Title2 "Statistical Analysis of API/SCHEMA Validations - %Sysfunc(UPCASE(&Fdate))";


	Columns Date_Time
	User_Name
	Bank_Name
	API_Name
	Version_No
	Fail_Obs
	Nobs_Api
	Nobs_Sch
	API_LInk
	SCH_Link;

	Define Date_Time/ display 'Date Time' left style(column)=[width=5%];
	Define User_Name / display 'User Name' left style(column)=[width=5%];
	Define Bank_Name / display 'Bank Name' left style(column)=[width=5%];
	Define API_Name / display 'API Name' left style(column)=[width=5%];
	Define Version_No / display 'Version No' left style(column)=[width=5%];
	Define Fail_Obs / display 'Failed Obervation No' left style(column)=[width=5%];
	Define Nobs_Api / display 'API Observations Only' left style(column)=[width=5%];
	Define Nobs_Sch / display 'SCH Observation Only' left style(column)=[width=5%];
	Define API_LInk / display 'API End Point Link' left style(column)=[width=5%];
	Define SCH_Link / display 'Github Schema Link' left style(column)=[width=5%];
Run;

%ReturnButton();

/*
PROC EXPORT DATA = OPENDATA.CMA9_&API(Drop=Bank_API P Count RowCnt) 
            OUTFILE= "H:\STV\Open Banking\SAS\Temp\CMA9_&API..csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
*/

/*
ODS CSV File="&Path\CMA9_&API..csv";
Proc Print Data=OpenData.CMA9_&API(Drop=Bank_API P Count RowCnt);
	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";
Run;
ODS CSV Close;

ODS HTML File="&Path\CMA9_&API..xls";
Proc Print Data=OpenData.CMA9_&API(Drop=Bank_API P Count RowCnt);
	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";
Run;
*/

ods tagsets.tableeditor close; 
ods listing; 

%Mend CMA9_Reports;
*%CMA9_Reports(ATMS);
*%CMA9_Reports(BRANCHES);
%CMA9_Reports(PCA);
