Libname OBData "C:\inetpub\wwwroot\sasweb\data\perm";
*=================================================================================================
	THIS SECTION CREATES THE API_COLUMNS TABLE IN THE OBDATA LIBRARY TO POPULATE THE ADHOC
	REPORTS DROP DOWN BOXES IN THE SAS AD-HOC REPORT SECTION
==================================================================================================;
%Macro Columns(Dsn);
Proc Contents Data=OBData.&Dsn 
	Out=Work.&Dsn (Keep=Name); 
Run; 
Data Work.&Dsn(Keep=&Dsn);
	Set Work.&Dsn;
	&Dsn = Name;
Run;
%Mend Columns;
%Columns(ATM_geographic);
%Columns(BCH_geographic);
%Columns(BCA_geographic);
%Columns(PCA_geographic);
%Columns(CCC_geographic);
%Columns(SME_geographic);

Data OBData.API_Columns;
	Merge ATM_geographic
	BCH_geographic
	BCA_geographic
	PCA_geographic
	CCC_geographic
	SME_geographic;
Run;


%Macro Populate();

%If "&_action" EQ "ATM" %Then
%Do;
	%Let _API_Val = ATM;
%End;
%Else %If "&_action" EQ "BRANCH" %Then
%Do;
	%Let _API_Val = BCH;
%End;
%Else %If "&_action" EQ "PERSONAL CURRENT ACCOUNT" %Then
%Do;
	%Let _API_Val = PCA;
%End;
%Else %If "&_action" EQ "BUSINESS CURRENT ACCOUNT" %Then
%Do;
	%Let _API_Val = BCA;
%End;
%Else %If "&_action" EQ "COMMERCIAL CREDIT CARD" %Then
%Do;
	%Let _API_Val = CCC;
%End;
%Else %If "&_action" EQ "SME LOAN" %Then
%Do;
	%Let _API_Val = SME;
%End;

Data _NULL_;
File _Webout;

		Put '<HTML>';
		Put '<HEAD>';
		Put '<html xmlns="http://www.w3.org/1999/xhtml">';
		Put '<head>';
		Put '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
		Put '<meta http-equiv="X-UA-Compatible" content="IE=10"/>';
		Put '<title>OB TESTING</title>';

		Put '<meta charset="utf-8" />';
		Put '<title>Open Data Test Application</title>';
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

		Put '<table style="width: 100%; height: 5%" border="1">';
		Put '<tr>';
		Put '<td valign="top" style="background-color: lightblue; color: orange">';
		Put '<img src="http://localhost/sasweb/images/london.jpg" alt="Cannot find image" style="width:100%;height:8%px;">';
		Put '</td>';
		Put '</tr>';
		Put '</table>';

		Put '<p></p>';


		Put '<Table align="center" style="width: 100%; height: 10%" border="0">';
		Put '<tr>';

		Put '<td>';
		Put '<div style="float:left; width: 10%">';
		Put '<a href="https://www.openbanking.org.uk/">Home</a>';
		Put '</div>';
		Put '<div style="float:left; width: 10%">';
		Put '<a href="https://www.openbanking.org.uk/about/">About</a>';
		Put '</div>';
		Put '<div style="float:left; width: 10%">';
		Put '<a href="https://www.openbanking.org.uk/industry/">Portfolio</a>';
		Put '</div>';
		Put '<div style="float:left; width: 10%">';
		Put '<a href="https://www.openbanking.org.uk/contact/">Contact</a>';
		Put '</div>';
		Put '</td>';
		Put '</tr>';
		Put '</table>';


	/*	Put '<p><br></p>';*/
		Put '<HR>';
	/*	Put '<p><br></p>';*/

		Put '<FORM NAME=check METHOD=GET ACTION="http://localhost/scripts/broker.exe">';

		Put '<Table align="center" style="width: 70%; height: 30%" border="1">';
		Put '<tr>';
	/**/
	/*	Put '<div id="myProgress">' /*/
	/*  			'<div id="myBar"></div>' /*/
	/*		'</div>';	*/
	/**/

	Put '<td>';
	Put '<div class="dropdown" align="center" style="float:center; width: 70%">';
	Put '<b>SELECT ' /
	"&_API_Val." 
	' FIELD NAMES</b>';
	Put '<p></p>';

/*	%If "&_action" in ("&_action") %then*/
/*	%Do;*/
				*--- Read Dataset UniqueNames ---;
				 	%Let Dsn = %Sysfunc(Open(OBData.API_Columns(Keep = &_API_Val._geographic)));
				*--- Count Observations ---;
				    %Let Count = %Eval(%Sysfunc(Attrn(&Dsn,Nobs))+1);

				*--- Populate Drop Down Box on HTML Page ---;
				Put	'<select name="_API_Field" size="12" multiple>' /;
				    %Do I = 1 %To &Count;
				        %Let Rc = %Sysfunc(fetch(&Dsn,&i));
				        %Let Start=%Sysfunc(GETVARC(&Dsn,%Sysfunc(VARNUM(&Dsn,&_API_Val._geographic))));
				        %Let Label=%Sysfunc(GETVARC(&Dsn,%Sysfunc(VARNUM(&Dsn,&_API_Val._geographic))));
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
/*		%End;*/

	Put '</div>';
	Put '</td>';

	Put '</FORM>';
	Put '</td>';
	Put '</tr>';
	Put '<td valign="top" style="background-color: White; color: black">';
	Put '<H3>All Rights Reserved</H3>';
	Put '<A HREF="http://www.openbanking.org.uk">Open Banking Limited</A>';
	Put '</td>';
	Put '</table>';


Put '</body>';
Put '</html>';

Run;

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

ODS Listing Close; 
/*ods tagsets.tableeditor file="C:\inetpub\wwwroot\sasweb\Data\Results\Sales_Report_1.html" */
ODS tagsets.tableeditor File=_Webout 
    Style=styles./*meadow*/OBStyle 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="10em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ) ; 

%ReturnButton;

ODS tagsets.tableeditor Close; 
ODS Listing; 

%Mend Populate;
%Populate();


