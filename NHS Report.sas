%Macro Main();
Libname NHSData "C:\inetpub\wwwroot\sasweb\data\NHS";
Options MPrint MLogic Symbolgen Source Source2;

%Global _Host;
%Global _Path;

%Let _Host = &_SRVNAME;
%Put _Host = &_Host;

%Let _Path = http://&_Host/sasweb;
%Put _Path = &_Path;

%Global _Multiple;

*--- This section will determine which report to run based on a single or multiple columns selection that ---;
%If "&_NHS_Selected0" GT "0" %Then
%Do;
	%Let _Multiple = Yes;
	%Put _Multiple = "&_Multiple";
%End;
%Else %Do;
	%Let _Multiple = No;
	%Put _Multiple = "&_Multiple";
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

		Put '</HEAD>';
		Put '<BODY>';

		Put '<p></p>';
		Put '<HR>';
		Put '<p></p>';

		Put '<Table align="center" style="width: 100%; height: 15%" border="0">';
		Put '<td valign="center" align="center" style="background-color: lightblue; color: White">';
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
	Define style style.OBStyle;
 	notes "My Simple Style";
 	class body /
 	backgroundcolor = white
 	color = black
 	fontfamily = "Palatino";

 	Class systemtitle /
 	fontfamily = "Verdana, Arial"
 	fontsize = 16pt
 	fontweight = bold;

 	Class table /
 	backgroundcolor = #f0f0f0
 	bordercolor = red
 	borderstyle = solid
 	borderwidth = 1pt
 	cellpadding = 5pt
 	cellspacing = 0pt
 	frame = void
 	rules = groups;

 	Class header, footer /
 	backgroundcolor = #c0c0c0
 	fontfamily = "Verdana, Arial"
 	fontweight = bold;

	Class data /
 	fontfamily = "Palatino";
 	End; 
Run;

%Mend Template;
%Template;

%Macro NHS_Report();
%If "&_Multiple" EQ "Yes" %Then
%Do;

*--- Concatenate columns to create subset of columns in the report ---;
%Let Columns =;
/*%Macro Concat(Dsn);*/
	%Do i = 1 %to &_NHS_Selected0;
			%Let ColX = &&_NHS_Selected&i;
			%Put ColX = &ColX;

			%Let Columns = &Columns &ColX;
			%Put Columns = &Columns;
	%End;
/*%Mend Concat;*/
/*%Concat(OBACCOUNT);*/

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
	Put '<FORM NAME=check METHOD=get ACTION="'"http://&_Host/scripts/broker.exe"'">';


		Put '<table align="center" style="width: 75%; height: 15%" border="1">';
		Put '<td>';
		Put '<tr>';

		Put '<div class="dropdown" align="center" style="float:center; width: 70%">';
		Put '<H1>TEST</H1>';
		Put '<p><br></p>';
		Put '<H2>SELECT FORESCAST %</H2>';
		Put '<SELECT NAME="_forecast" size="10" "</option>';/*onchange="this.form.submit()*/
		Put '<OPTION VALUE="0"> </option>';
		Put '<OPTION VALUE="05"> 0.5 % </option>';
		Put '<OPTION VALUE="1"> 1 % </option>';
		Put '<OPTION VALUE="5"> 5 % </option>';
		Put '<OPTION VALUE="10"> 10 % </option>';
		Put '<OPTION VALUE="15"> 15 % </option>';
		Put '<OPTION VALUE="20"> 20 % </option>';
		Put '<OPTION VALUE="25"> 25 % </option>';
		Put '<OPTION VALUE="50"> 50 % </option>';
		Put '<OPTION VALUE="75"> 75 % </option>';
		Put '<OPTION VALUE="100"> 100 % </option>';
		Put '</SELECT>';
		Put '</div>';
		Put '<p><br></p>';

		Put '</td>';




	*--- Table 2 - Drop Down Table ---;
	Put '<table align = "center" style="width: 60%; height: 5%" border="1">';
	Put '<tr>';


	Put '<td valign="top" style="background-color: white; color: black" border="1">';
		Put '<div class="dropdown" align="center" style="float:center; width: 70%">';
		Put '<b>SELECT BANK NAME</b>';
		Put '<p></p>';


	*--- Read Dataset UniqueNames ---;
		 	%Let Dsn = %Sysfunc(Open(NHSData.NHS_1));
	*--- Count Observations ---;
		    %Let Count = %Eval(%Sysfunc(Attrn(&Dsn,Nobs))+1);

			Put	'<select name="_NHS_Selected" size="15" multiple>' /;
	*--- Populate Drop Down Box on HTML Page ---;
			%Do I = 1 %To &Count;
		        %Let Rc = %Sysfunc(fetch(&Dsn,&i));
				%Let Start=%Sysfunc(GETVARC(&Dsn,%Sysfunc(VARNUM(&Dsn,Name))));
				%Let Label=%Sysfunc(GETVARC(&Dsn,%Sysfunc(VARNUM(&Dsn,Name))));
					%If "&Start" ne " " %Then
					%Do;
						%If &I=1 %Then 
						%Do;
							Put '<option value='
								"&Start"
								'>' /
								"&Label"
								'</option>' /;
						%End;
						%Else
						%Do;
				            Put '<option value='
								"&Start"
								'>' /
								"&Label"
								'</option>' /;
						%End;
					%End;
						%Else %Let I = &Count;
					%End;

					%Let Rc = %Sysfunc(Close(&Dsn));

		Put '</div>';
	Put '</td>';
	Put '</tr>';
	Put '</table>';


	Put '<p><br></p>';

	*--- Table 3 - Submit button ---;
	Put '<table style="width: 100%; height: 5%" border="0">';
	Put '<td valign="center" align="center" border="1" style="background-color: lightblue; color: Black">';
	Put '<INPUT TYPE=submit VALUE="Submit Details" valign="center">';

	Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.NHS Report Percentage.sas">';
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

		ODS _ALL_ Close;

		/*ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;*/

		ods listing close; 
		/*ods tagsets.tableeditor file="C:\inetpub\wwwroot\sasweb\Data\Results\Sales_Report_1.html" */
		ods tagsets.tableeditor file=_Webout 
		    style=styles./*meadow*/OBStyle 
		    options(autofilter="YES" 
		 	    autofilter_table="1" 
		            autofilter_width="10em" 
		 	    autofilter_endcol= "50" 
		            frozen_headers="0" 
		            frozen_rowheaders="0" 
		            ) ; 

				Data Work.NHS;
					Set NHSData.NHS(Keep = &Columns);
				Run;
				Proc Print Data=Work.NHS;
					Title1 "Test Ad-hoc Report";
					Title2 "%Sysfunc(UPCASE(&Fdate))";
				Run;

		%ReturnButton;

		ods tagsets.tableeditor close; 
		ods listing; 

	Run;

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

		ods listing close; 
		/*ods tagsets.tableeditor file="C:\inetpub\wwwroot\sasweb\Data\Results\Sales_Report_1.html" */
		ods tagsets.tableeditor file=_Webout 
		    style=styles./*meadow*/OBStyle 
		    options(autofilter="YES" 
		 	    autofilter_table="1" 
		            autofilter_width="10em" 
		 	    autofilter_endcol= "50" 
		            frozen_headers="0" 
		            frozen_rowheaders="0" 
		            ) ; 

				Proc Print Data=NHSData.NHS;
					Title1 "Test - Ad-hoc Report";
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
