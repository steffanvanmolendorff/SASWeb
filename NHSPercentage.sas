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

%Global _Multiple;
%Global _Forecast;
%Let _Forecast = &_Forecast;

%Macro Main();
*--- This section will determine which report to run based on a single or multiple columns selection that ---;
%If "&_Dimension0" GT "0" and "&_Fact0" GT "0" %Then
%Do;
	%Let _Multiple = Yes;
	%Put _Multiple = "&_Multiple";
%End;
%Else %If "&_Dimension0" GT "0" and "&_Fact0" LT "1" %Then
%Do;
	%Let _Multiple = Yes;
	%Put _Multiple = "&_Multiple";
	%Let _Fact0 = 1;
	%Let _Fact1 = &_Fact;

%End;
%Else %If "&_Dimension0" LT "1" and "&_Fact0" GT "0" %Then
%Do;
	%Let _Multiple = Yes;
	%Put _Multiple = "&_Multiple";
	%Let _Dimension0 = 1;
	%Let _Dimension1 = &_Dimension;
%End;
%Else %Do;
	%Let _Multiple = No;
	%Put _Multiple = "&_Multiple";
	%Let _Fact0 = 1;
	%Let _Dimension0 = 1;
	%Let _Fact1 = &_Fact;
	%Let _Dimension1 = &_Dimension;
%End;

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
%If "&_Multiple" EQ "Yes" %Then
%Do;

*--- Concatenate columns to create subset of Dimension columns in the report ---;
%Let DimCols =;
	%Do i = 1 %to &_Dimension0;
			%Let ColX = &&_Dimension&i;
			%Put ColX = &ColX;

			%Let DimCols = &DimCols &ColX;
			%Put DimCols = &DimCols;
	%End;
*--- Concatenate columns to create subset of Dimension columns in the report ---;
%Let FactCols =;
	%Do i = 1 %to &_Fact0;
			%Let ColX = &&_Fact&i;
			%Put ColX = &ColX;

			%Let FactCols = &FactCols &ColX;
			%Put FactCols = &FactCols;
	%End;

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

		Put '<SCRIPT language="javascript">' /
		'function MySubmit()' /
		'{document.NHS.submit();} ' /
		'</SCRIPT>' /;

		*--- Create styles for HTML links on page ---;
		Put '<style>' /
		'td{font-size:"25";color:"green"}' /

		'a' /
		'{' /
			'font-family:arial;' /
			'font-size:10px;' /
			'color:black;' /
			'font-weight:normal;' /
			'font-style:normal;' /
			'text-decoration:none;' /
		'}' /
		'a:hover' /
		'{' /
			'font-family:arial;' /
			'font-size:10px;' /
			'color:blue;' /
			'text-decoration:none;' /
		'}' /
		'.nav' /
		'{' /
			'font-family:arial;' /
			'font-size:10px;' /
			'color:#ffffff;' /
			'font-weight:normal;' /
			'font-style:normal;' /
			'text-decoration:none;' /
			'border:inset 0px #ececec;' /
			'cursor:hand;' /
		'}' /
		'</style>' /
		'</HEAD>';

		Put '<BODY>';

		*--- Include horizontal line under image ---;
		Put '<hr size="2" color="blue">'  /;

		*--- Create Progress Bar ---;
		Put '<table align="center"><tr><td>' /
			'<div style="font-size:8pt;padding:2px;border:solid black 0px">' /
			'<span id="progress1"> &nbsp; &nbsp;</span>' /
			'<span id="progress2"> &nbsp; &nbsp;</span>' /
			'<span id="progress3"> &nbsp; &nbsp;</span>' /
			'<span id="progress4"> &nbsp; &nbsp;</span>' /
			'<span id="progress5"> &nbsp; &nbsp;</span>' /
			'<span id="progress6"> &nbsp; &nbsp;</span>' /
			'<span id="progress7"> &nbsp; &nbsp;</span>' /
			'<span id="progress8"> &nbsp; &nbsp;</span>' /
			'<span id="progress9"> &nbsp; &nbsp;</span>'
			'</div>' /
			'</td></tr></table>';

		Put '<script language="javascript">' /
		'var progressEnd = 9;' /		
		'var progressColor = "blue";' /	
		'var progressInterval = 1000;' /	
		'var progressAt = progressEnd;' /
		'var progressTimer;' /

		'function progress_clear() {' /
		'	for (var i = 1; i <= progressEnd; i++) ' /
		"	document.getElementById('progress'+i).style.backgroundColor = 'transparent';" /
		'	progressAt = 0;' /
		'}' /

		'function progress_update() {' /
		'	progressAt++;' /
		'	if (progressAt > progressEnd) progress_clear();' /
		"	else document.getElementById('progress'+progressAt).style.backgroundColor = progressColor;" /
		"	progressTimer = setTimeout('progress_update()',progressInterval);" /
		'}' /

		'function progress_stop() {' /
		'	clearTimeout(progressTimer);' /
		'	progress_clear();' /
		'}' /

		'progress_update();' /		
		'</script>' /
		'<p>' /;


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
/*

		Put '<table align="center" style="width: 75%; height: 15%" border="1">';
		Put '<td>';
		Put '<tr>';

		Put '<div class="dropdown" align="center" style="float:center; width: 70%">';
		Put '<H1>TEST</H1>';
		Put '<p><br></p>';
		Put '<H2>FORESCAST % SELECTED</H2>';
		Put '<SELECT NAME="_forecast" size="1" </option>';
		Put '<OPTION VALUE="&_forecast"> '
			"&_forecast"
			'</option>';
		Put '</SELECT>';
		Put '</div>';
		Put '<p><br></p>';

		Put '</td>';
/*

		Put '<td valign="center" align="center" border="1" style="background-color: lightblue; color: Black">';
		Put '<INPUT TYPE=submit VALUE="Submit Details" valign="center">';

		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.NHS Report_Percentage.sas">';
		Put '<INPUT TYPE=hidden NAME=_service VALUE=' /
			"&_service"
			'>';

		Put '<INPUT TYPE=hidden NAME=_debug VALUE=' /
			"&_debug"
			'>';
		Put '<INPUT TYPE=hidden NAME=_API_Val VALUE=' /
			"&_API_Val"
			'>';
		Put '<INPUT TYPE=hidden NAME=_WebUser VALUE=' /
			"&_WebUser"
			'>';
		Put '<INPUT TYPE=hidden NAME=_WebPass VALUE=' /
			"&_WebPass"
			'>';

		Put '</FORM>';
		Put '</td>';
		Put '</tr>';
		Put '</table>';
*/

				Data Work.NHS_Percentage;
				Length
				_&_forecast._Elect_Ordinary_Admis
				Elect_Ordinary_Admis
				_&_forecast._Elect_Daycase_Admis
				Elect_Daycase_Admis
				_&_forecast._Elect_Total_Admis
				Elect_Total_Admis
				_&_forecast._Elect_Plan_Ordinary_Admis
				Elect_Plan_Ordinary_Admis	
				_&_forecast._Elect_Plan_Daycase_Admis
				Elect_Plan_Daycase_Admis
				_&_forecast._Elect_Plan_Total_Admis 
				Elect_Plan_Total_Admis	
				_&_forecast._Elect_Admis_NHS_TreatCentre
				Elect_Admis_NHS_TreatCentre	
				_&_forecast._Total_Non_elect_Admis
				Total_Non_elect_Admis
				_&_forecast._GPRefer_All_Special
				GPRefer_All_Special 	
				_&_forecast._GPRefer_Seen_Special
				GPRefer_Seen_Special	
				_&_forecast._GPRefer_Made_GA
				GPRefer_Made_GA
				_&_forecast._GPRefer_Seen_GA
				GPRefer_Seen_GA	
				_&_forecast._Other_Refer_Made_GA
				Other_Refer_Made_GA	
				_&_forecast._All_1st_Outpat_Att_GA
				All_1st_Outpat_Att_GA 8;


				Set NHSData.NHS;
						
				_&_forecast._Elect_Ordinary_Admis = (Elect_Ordinary_Admis * (&_forecast/100));
				_&_forecast._Elect_Daycase_Admis = (Elect_Daycase_Admis * (&_forecast/100));	
				_&_forecast._Elect_Total_Admis = (Elect_Total_Admis * (&_forecast/100));
				_&_forecast._Elect_Plan_Ordinary_Admis = (Elect_Plan_Ordinary_Admis * (&_forecast/100));	
				_&_forecast._Elect_Plan_Daycase_Admis = (Elect_Plan_Daycase_Admis * (&_forecast/100));
				_&_forecast._Elect_Plan_Total_Admis = (Elect_Plan_Total_Admis * (&_forecast/100));	
				_&_forecast._Elect_Admis_NHS_TreatCentre = (Elect_Admis_NHS_TreatCentre * (&_forecast/100));	
				_&_forecast._Total_Non_elect_Admis = (Total_Non_elect_Admis * (&_forecast/100));
				_&_forecast._GPRefer_Special = (GPRefer_Special * (&_forecast/100)); 	
				_&_forecast._GPRefer_Seen_Special = (GPRefer_Seen_Special * (&_forecast/100));
				_&_forecast._GPRefer_Made_GA = (GPRefer_Made_GA * (&_forecast/100));
				_&_forecast._GPRefer_Seen_GA = (GPRefer_Seen_GA * (&_forecast/100));
				_&_forecast._Other_Refer_Made_GA = (Other_Refer_Made_GA * (&_forecast/100));
				_&_forecast._All_1st_Outpat_Att_GA = (All_1st_Outpat_Att_GA * (&_forecast/100));

				Run;



			%Let Perc_FactCols =;
			%Do i = 1 %to &_Fact0;
					%Let ColX = &&_Fact&i;
					%Put ColX = &ColX;

					%Let Perc_FactCols = &Perc_FactCols _&_Forecast._&ColX;
					%Put Perc_FactCols = &Perc_FactCols;

				%If i = 1 %Then
				%Do;
					%Let PlotBubble = Year*Total_Non_elect_Admis;
				%End;
			%End;

				Data Work.NHS_Percentage_1;
					Set Work.NHS_Percentage(Keep = &DimCols &FactCols &Perc_FactCols);
					RowCnt = 1;
					Format &FactCols &Perc_FactCols Dollar12.2;
					Region_Name = Tranwrd(Trim(Left(Region_Name)),' ','_');
				Run;


				Proc Summary Data = Work.NHS_Percentage_1 Nway Missing;
					Class &DimCols;
					Var &FactCols &Perc_FactCols;
					Output Out = Work.NHS_Percentage_1_Sum(Drop = _Freq_ _Type_) Sum=;
				Run;

*		ODS _ALL_ Close;


*		%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
		title "Listing of Product Sales"; 
*		ods listing close; 
		/*ods tagsets.tableeditor file="C:\inetpub\wwwroot\sasweb\Data\Results\Sales_Report_1.html" */
		ods tagsets.tableeditor file=_Webout
		    style=styles.OBStyle 
		    options(autofilter="YES" 
		 	    autofilter_table="0" 
		            autofilter_width="9em" 
		 	    autofilter_endcol= "50" 
		            frozen_headers="0" 
		            frozen_rowheaders="0" 
		            ); 

				Proc Print Data=Work.NHS_Percentage_1_Sum;
					Title1 "Test Ad-hoc &_forecast Summary Report";
					Title2 "%Sysfunc(UPCASE(&Fdate))";
				Run;

				Proc Report Data = Work.NHS_Percentage_1_Sum;
					Title1 "Test Ad-hoc &_forecast Summary Proc Report";
					Title2 "%Sysfunc(UPCASE(&Fdate))";
					Column &DimCols &FactCols &Perc_FactCols;
					 
					%Do i = 1 %to &_Dimension0;
						Define &&_Dimension&i / display "&&_Dimension&i" left;
					%End;
					%Do i = 1 %to &_Fact0;
						Define &&_Fact&i / display "&&_Fact&i" left;
						Define _&_forecast._&&_Fact&i / display "&_forecast._&&_Fact&i" left;
					%End;
/*
					Compute Region_Name;
						Href= trim(Region_Name)||".html";
						Call Define(_col_,"url",Href);
					Endcomp;
*/
					%Do i = 1 %to &_Dimension0;
					%Let _DimName = &&_Dimension&i;
					%Let _DimVal = &_DimName;

					Compute &&_Dimension&i;
						urlstring=	"http://localhost/scripts/broker.exe"||
									'?_Service='||
									"&_Service"||
									'&_Program='||
									"Source.NHSPercDetail.sas"||
									'&_Debug='||
									"&_Debug"||
									'&_WebUser='||
									"&_WebUser"||
									'&_WebPass='||
									"&_WebPass"||
									'&_DimName='||
									"&_DimName"||
									'&_DimVal='||
									&_DimVal;
					call define(_col_, 'URL', urlstring);
					call define(_col_, 'style',
					 'style={flyover="Click to drill down to &_DimName detail data"}');
					Endcomp;
					%End;

				Run;
		ods tagsets.tableeditor close; 



*---- Open the _webout location ---;
	ODS HTML body=_webout (no_bottom_matter) path=&_tmpcat  (url=&_replay);

*==================================================================
  Set Graphic options for Graph
===================================================================;
			Goptions
				reset=global
				gunit=pct
				border
				cback=white
			    colors=(black blue green red)
			    ftext=swiss
				ftitle=swissb
				htitle=4
				htext=3
				device=png
				Rotate=Landscape;

/*
			Proc gchart data=Work.NHS_Percentage_1;                                                                                                                
	 			hbar region_code / sumvar=Total_Non_elect_Admis; 
			Title1 "Test Ad-hoc &_forecast Proc GCHART Graph Report";
			Title2 "%Sysfunc(UPCASE(&Fdate))";

			Run;
			Quit;
*/

			proc sgplot data=Work.NHS_Percentage_1;
			   title "Region Code vs Total Non Elective Admissions";

			   	%Do i = 1 %to &_Fact0;
					VBar Region_Code / response = &&_Fact&i;
				   	VLine Region_Code / response=_&_forecast._&&_Fact&i y2axis;
				%End;
			run;

*---- Close the _webout location ---;
	ODS HTML Close;


*--- Stop Progress Bar and close HTML page ---;
		Data _Null_;
		File _Webout;
		Put '<SCRIPT language="javascript">' /
			'progress_stop();' /
			'</SCRIPT>';
		Run;

		%ReturnButton;


		*		ods listing; 


*		ods listing close; 
/*
			/*Open the _webout location*/


%End;
%Else %If "&_Multiple" EQ "No" %Then
%Do;
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
		Put '<title>OBIE</title>';

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

		ODS _ALL_ Close;

		/*ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;*/

		%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
		title "Listing of Product Sales"; 
		ods listing close; 
		/*ods tagsets.tableeditor file="C:\inetpub\wwwroot\sasweb\Data\Results\Sales_Report_1.html" */
		ods tagsets.tableeditor file=_Webout
		    style=styles.OBStyle 
		    options(autofilter="YES" 
		 	    autofilter_table="1" 
		            autofilter_width="9em" 
		 	    autofilter_endcol= "50" 
		            frozen_headers="0" 
		            frozen_rowheaders="0" 
		            ); 

				Data Work.NHS_Percentage;
				Length
				_&_forecast._Elect_Ordinary_Admis
				Elect_Ordinary_Admis
				_&_forecast._Elect_Daycase_Admis
				Elect_Daycase_Admis
				_&_forecast._Elect_Total_Admis
				Elect_Total_Admis
				_&_forecast._Elect_Plan_Ordinary_Admis
				Elect_Plan_Ordinary_Admis	
				_&_forecast._Elect_Plan_Daycase_Admis
				Elect_Plan_Daycase_Admis
				_&_forecast._Elect_Plan_Total_Admis 
				Elect_Plan_Total_Admis	
				_&_forecast._Elect_Admis_NHS_TreatCentre
				Elect_Admis_NHS_TreatCentre	
				_&_forecast._Total_Non_elect_Admis
				Total_Non_elect_Admis
				_&_forecast._GPRefer_All_special
				GPRefer_All_specialties 	
				_&_forecast._GPRefer_Seen_special
				GPRefer_Seen_All_special	
				_&_forecast._GPRefer_Made_GA
				GPRefer_Made_GA
				_&_forecast._GP_Refer_Seen_GA
				GP_Refer_Seen_GA	
				_&_forecast._Other_Refer_Made_GA
				Other_Refer_Made_GA	
				_&_forecast._All_1st_Outpat_Att_GA
				All_1st_Outpat_Att_GA 8;


				Set NHSData.NHS;
						
				_&_forecast._Elect_Ordinary_Admis = (Elect_Ordinary_Admis * (&_forecast/100));
				_&_forecast._Elect_Daycase_Admis = (Elect_Daycase_Admis * (&_forecast/100));	
				_&_forecast._Elect_Total_Admis = (Elect_Total_Admis * (&_forecast/100));
				_&_forecast._Elect_Plan_Ordinary_Admis = (Elect_Plan_Ordinary_Admis * (&_forecast/100));	
				_&_forecast._Elect_Plan_Daycase_Admis = (Elect_Plan_Daycase_Admis * (&_forecast/100));
				_&_forecast._Elect_Plan_Total_Admis = (Elect_Plan_Total_Admis * (&_forecast/100));	
				_&_forecast._Elect_Admis_NHS_TreatCentre = (Elect_Admis_NHS_TreatCentre * (&_forecast/100));	
				_&_forecast._Total_Non_elective_Admis = (Total_Non_elect_Admis * (&_forecast/100));
				_&_forecast._GPRefer_special = (GPRefer_special * (&_forecast/100)); 	
				_&_forecast._GPRefer_Seen_special = (GPRefer_Seen_special * (&_forecast/100));
				_&_forecast._GPRefer_Made_GA = (GPRefer_Made_GA * (&_forecast/100));
				_&_forecast._GPRefer_Seen_GA = (GP_Refer_Seen_GA * (&_forecast/100));
				_&_forecast._Other_Refer_Made_GA = (Other_Refer_Made_GA * (&_forecast/100));
				_&_forecast._All_1st_Outpat_Att_GA = (All_1st_Outpat_Att_GA * (&_forecast/100));

				Run;

				Proc Print Data=Work.NHS_Percentage;
					Title1 "Test - &_Forecast % Ad-hoc Report";
					Title2 "%Sysfunc(UPCASE(&Fdate))";
				Run;

		%ReturnButton;

		ods tagsets.tableeditor close; 
		ods listing; 

	Run;
%End;


%Mend NHS_Report;
%NHS_Report();

%Mend Main;
%Main();
