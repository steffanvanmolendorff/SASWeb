%Macro Main();
Libname NHSData "C:\inetpub\wwwroot\sasweb\data\NHS";
Options MPrint MLogic Symbolgen Source Source2;

%Global _Host;
%Global _Path;
%Global _Dimension0;
%Global _Fact0;
%Global _Dimension1;
%Global _Fact1;

%Let _Host = &_SRVNAME;
%Put _Host = &_Host;

%Let _Path = http://&_Host/sasweb;
%Put _Path = &_Path;


%Macro ReturnButton();
Data _Null_;
		File _Webout;

		Put '<html xmlns="http://www.w3.org/1999/xhtml">';
		Put '<head>';
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

		Put '<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>';


		Put '<p></p>';
		Put '<HR>';
		Put '<p></p>';
		Put '<p><br></p>';

		Put '<Table align="center" style="width: 100%; height: 8%" border="0">';
		Put '<td valign="center" align="center" style="background-color: lightblue; color: White">';
		Put '<FORM NAME=check METHOD=get ACTION="'"http://&_Host/scripts/broker.exe"'">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=submit VALUE="Return" align="center">';
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

		Put '<Table align="center" style="width: 100%; height: 8%" border="0">';
		Put '<td valign="top" style="background-color: White; color: black">';
		Put '<H3>All Rights Reserved</H3>';
		Put '<A HREF="http://www.openbanking.org.uk">Open Banking Limited</A>';
		Put '</td>';
		Put '</Table>';

		Put '</BODY>';
		Put '<HTML>';
		
Run;
%Mend ReturnButton;

*--- Set Title Date in Proc Print ---;
%Macro Fdate(Fmt,Fmt2);
   %Global Fdate FdateTime;
   Data _Null_;
      Call Symput("Fdate",Left(Put("&Sysdate"d,&Fmt)));
      Call Symput("FdateTime",Left(Put("&Sysdate"d,&Fmt2)));
  Run;
%Mend Fdate;
%Fdate(worddate12., datetime.);

%Macro Template;
Proc Template;
 define style styles.OBStyle;
 parent = styles.BarrettsBlue;
 notes "My Simple Style";

 class body /
 backgroundcolor = white
 color = black
 fontfamily = "Palatino"
 ;
 class systemtitle /
 fontfamily = "Verdana, Arial"
 fontsize = 16pt
 fontweight = bold
 ;
 class table /
 backgroundcolor = #f0f0f0
 bordercolor = black
 borderstyle = solid
 borderwidth = 1pt
 cellpadding = 5pt
 cellspacing = 1pt
 frame = void
 rules = groups
 fontfamily = "Verdana"
;
 class header, footer /
 backgroundcolor = #c0c0c0
 fontfamily = "Verdana, Arial"
 fontweight = bold
 ;
 class data /
 fontfamily = "Palatino"
 ;
 end; 

Run;
%Mend Template;
%Template;

%Macro NHS_Report();

	Data _NULL_;
	File _Webout;
		Put '<HTML>';
		Put '<HEAD>';
		Put '<html xmlns="http://www.w3.org/1999/xhtml">';
		Put '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
		Put '<meta http-equiv="X-UA-Compatible" content="IE=10"/>';
		Put '<title>OB TESTING</title>';

		Put '<meta charset="utf-8" />';
		Put '<title>Open Data Test Application</title>';
		Put '<meta name="description" content="">';
		Put '<meta name="author" content="">';
			
		Put '<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />'; 
			
		Put '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
		Put '<title>QLICK2 NHS</title>';

		Put '<script type="text/javascript" src="'"&_Path/js/jquery.js"'">';
		Put '</script>';

		Put '<link rel="stylesheet" type="text/css" href="'"&_Path/css/style.css"'">';

		Put '</HEAD>';

		Put '<BODY>';

		*--- Table 1 - Image ---;
		Put '<table style="width: 100%; height: 5%" border="0">';
		Put '<tr>';
		Put '<td valign="top" style="background-color: lightblue; color: black">';
		Put '<img src="'"&_Path/images/london.jpg"'" alt="Cannot find image" style="width:100%;height:8%px;">';
		Put '</td>';
		Put '</tr>';
		Put '</table>';

	*--- Space below image ---;
		Put '<p><br></p>';


	*--- Space below image ---;
	Put '<p><br></p>';
	Put '<FORM ID=NHS NAME=NHS METHOD=get ACTION="'"http://&_Host/scripts/broker.exe"'">';


		%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
		title "Listing of Product Sales"; 
		ods listing close; 
		ods tagsets.tableeditor file=_Webout
		    style=styles.OBStyle 
		    options(autofilter="YES" 
		 	    autofilter_table="0" 
		            autofilter_width="9em" 
		 	    autofilter_endcol= "50" 
		            frozen_headers="0" 
		            frozen_rowheaders="0" 
		            ); 

				Data Work.NHS_Percentage_1;
					Set NHSData.NHS(Where=(Tranwrd(Trim(Left(&_DimName)),' ','_') EQ "&_DimVal"));
				Run;

				Proc Report Data = Work.NHS_Percentage_1 nowd
					style(report)=[rules=all cellspacing=0 bordercolor=gray] 
					style(header)=[background=lightskyblue foreground=black] 
					style(column)=[background=lightcyan foreground=black];

					Title1 "Test Ad-hoc &_forecast Summary Proc Report";
					Title2 "%Sysfunc(UPCASE(&Fdate))";

					Column &_DimName
					Elect_Ordinary_Admis
					Elect_Daycase_Admis	
					Elect_Total_Admis
					Elect_Plan_Ordinary_Admi	
					Elect_Plan_Daycase_Admis
					Elect_Plan_Total_Admis	
					Elect_Admis_NHS_TreatCentre	
					Total_Non_elect_Admis
/*					GPRefer_Special*/
					GPRefer_Seen_Special
					GPRefer_Made_GA
/*					GPRefer_Seen_GA*/
					Other_Refer_Made_GA
					All_1st_Outpat_Att_GA;

					Define &_DimName / Display "&_DimVal";
					Define Elect_Ordinary_Admis/ Display "Elect Ordinary Admis";
					Define Elect_Daycase_Admis/ Display "Elect Daycase Admis";	
					Define Elect_Total_Admis/ Display "Elect Total Admis";
					Define Elect_Plan_Ordinary_Admis/ Display "Elect Plan Ordinary Admis";	
					Define Elect_Plan_Daycase_Admis/ Display "Elect Plan Daycase Admis";
					Define Elect_Plan_Total_Admis/ Display "Elect Plan Total Admis";	
					Define Elect_Admis_NHS_TreatCentre/ Display "Elect Admis NHS TreatCentre";	
					Define Total_Non_elect_Admis/ Display "Total Non elect Admis";
/*					Define GPRefer_Special/ Display "GPRefer Special"; 	*/
					Define GPRefer_Seen_Special/ Display "GPRefer Seen Special";
					Define GPRefer_Made_GA/ Display "GPRefer Made GA";
/*					Define GPRefer_Seen_GA/ Display "GPRefer Seen GA";*/
					Define Other_Refer_Made_GA/ Display "Other Refer Made GA";
					Define All_1st_Outpat_Att_GA/ Display "All 1st Outpat Att GA";
				Run;

		%ReturnButton;

		ODS HTML;



%Mend NHS_Report;
%NHS_Report();

%Mend Main;
%Main();
