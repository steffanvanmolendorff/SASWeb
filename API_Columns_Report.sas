%Macro Main();
Libname OBData "C:\inetpub\wwwroot\sasweb\data\perm";
Options MPrint MLogic Symbolgen Source Source2;

%Global _Host;
%Global _Path;

%Let _Host = &_SRVNAME;
%Put _Host = &_Host;

%Let _Path = http://&_Host/sasweb;
%Put _Path = &_Path;

%Global _Multiple;

*--- This section will determine which report to run based on a single or multiple columns selection that
	 ---;
%If "&_API_Field0" GT "0" %Then
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

%Macro API_Report();
%If "&_Multiple" EQ "Yes" %Then
%Do;

*--- Concatenate columns to create subset of columns in the report ---;
%Let Columns =;
/*%Macro Concat(Dsn);*/
	%Do i = 1 %to &_API_Field0;
			%Let ColX = &&_API_Field&i;
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

				Data Work.Bank_API;
					Set OBData.&_API_Val._geographic(Keep = Bank &Columns);
					API_Bank_Name = Upcase(Tranwrd(Trim(Left(Bank)),' ','_'));
				Run;
				Proc Print Data=Work.Bank_API(Drop = Bank
					Where=(API_Bank_Name EQ "&_Bank_Selected"));
					Title1 "Open Banking - &_API_VAL Ad-hoc Report";
					Title2 "&_API_Val Columns - %Sysfunc(UPCASE(&Fdate))";
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

				Proc Print Data=OBData.&_API_Val._geographic
				(Keep = Bank Data_Element &_API_Val._Count);
					Title1 "Open Banking - &_API_VAL Ad-hoc Report";
					Title2 "&_API_Val Columns - %Sysfunc(UPCASE(&Fdate))";
				Run;

		%ReturnButton;

		ods tagsets.tableeditor close; 
		ods listing; 

	Run;
%End;


%Mend API_Report;
%API_Report();

%Mend Main;
%Main();
