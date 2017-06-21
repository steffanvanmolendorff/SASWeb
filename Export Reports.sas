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

*--- The Main macro will execute the code to extract data from the API end points ---;
%Macro Main(Api);
 
*--- Set Default Data Library as macro variable ---;
Option Source Source2 MLogic MPrint Symbolgen;
*--- Alternatively set the Data library in Proc Appsrv ---;

%Let Path = C:\inetpub\wwwroot\sasweb\Data\Perm;

*--- Set X path variable to the default directory ---;
X "cd &Path";

*--- Set the Library path where the permanent datasets will be saved ---;
Libname OBData "&Path";

*--- Close Output Delivery Parameters  ---;
ODS HTML Close;

*--- Set Title Date in Proc Print ---;
%Macro Fdate(Fmt);
   %Global Fdate;
   Data _Null_;
      Call Symput("Fdate",Left(Put("&Sysdate"d,&Fmt)));
   Run;
%Mend Fdate;
%Fdate(Worddate.)

/*
ODS CSV File="&Path\CMA9_&API..csv";
Proc Print Data=OBData.CMA9_&API(Drop=Bank_API P Count RowCnt);
	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";
Run;
ODS CSV Close;


ODS HTML File="&Path\CMA9_&API..xls";
Proc Print Data=OBData.CMA9_&API(Drop=Bank_API P Count RowCnt);
	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";
Run;
*/



ods excel file="&Path\CMA9_&API..xlsx" 
 /* will apply an appearance style */
 style=pearl
 options(
  /* for multiple procs/sheet */
  sheet_interval="none" 
  /* name the sheet tab */
  sheet_name="CMA9_Compare"
 );
 
/* add some formatted text */
ods escapechar='~';
ods text="~S={font_size=14pt font_weight=bold}~CMA9 Comparison Report";
 
Proc Print Data=OBData.CMA9_&API(Drop=Bank_API P Count RowCnt);
	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";
Run;

 
ods excel close;

/*
FILENAME outbox EMAIL ("steffan.vanmolendorff@qlick2.com");
DATA _NULL_;
FILE outbox
TO=("&_WebUser")
FROM=("steffan.vanmolendorff@qlick2.com")
SUBJECT=("CMA9 Comparison Report" )
ATTACH=("&Path\CMA9_&API..xlsx");
PUT " ";
PUT "Hello Boss,";
PUT " ";
PUT "Attached are the Daily Operational Reports.";
PUT " ";
PUT "Steffan";
RUN;
*/


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

		Put '<script type="text/javascript" src="http://localhost/sasweb/js/jquery.js">';
		Put '</script>';

		Put '<link rel="stylesheet" type="text/css" href="http://localhost/sasweb/css/style.css">';

		Put '</HEAD>';
		Put '<BODY>';


		Put '<p></p>';
		Put '<HR>';
		Put '<p></p>';

		Put '<Table align="center" style="width: 100%; height: 15%" border="0">';
		Put '<td valign="center" align="center" style="background-color: lightblue; color: White">';
		Put '<FORM NAME=check METHOD=get ACTION="http://localhost/scripts/broker.exe">';
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
	    Put '<INPUT TYPE=hidden NAME=_WebUser VALUE="vamola@mac.com">';
	    Put '<INPUT TYPE=hidden NAME=_WebPass VALUE="Test">';
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
%ReturnButton;

ODS HTML Close;
ODS Listing;

%Mend Main;
*%CMA9_Reports(ATMS);
*%CMA9_Reports(BRANCHES);
%Main(PCA);
