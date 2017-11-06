%Global _Host;
%Let _Host = &_SRVNAME;
%Put _Host = &_Host;

%Let _Path = http://&_Host/sasweb;
%Put _Path = &_Path;

%Macro Main();

Libname NHSData "C:\inetpub\wwwroot\sasweb\Data\NHS";

  /**********************************************************************
  *   PRODUCT:   SAS
  *   VERSION:   9.4
  *   CREATOR:   External File Interface
  *   DATE:      09OCT17
  *   DESC:      Generated SAS Datastep Code
  *   TEMPLATE SOURCE:  (None Specified.)
  ***********************************************************************/
     data NHSData.NHS    ;
     %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
     infile 'C:\inetpub\wwwroot\sasweb\Data\NHS\MAR2017_Comm_Web_file.csv' delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
        informat Year $7. ;
        informat Period $5. ;
        informat Region_Code $3. ;
        informat Region_Name $50. ;
        informat Org_Code $3. ;
        informat Org_Name $50. ;
        informat Elect_Ordinary_Admis best32. ;
        informat Elect_Daycase_Admis best32. ;
        informat Elect_Total_Admis best32. ;
        informat Elect_Plan_Ordinary_Admis best32. ;
        informat Elect_Plan_Daycase_Admis best32. ;
        informat Elect_Plan_Total_Admis best32. ;
        informat Elect_Admis_NHS_TreatCentre best32. ;
        informat Total_Non_elect_Admis best32. ;
        informat GPRefer_All_special best32. ;
        informat GPRefer_Seen_special best32. ;
        informat GPRefer_Made_GA best32. ;
        informat GP_Refer_Seen_GA best32. ;
        informat Other_Refer_Made_GA best32. ;
        informat All_1st_Outpat_Att_GA best32. ;
        format Year $7. ;
        format Period $5. ;
        format Region_Code $3. ;
        format Region_Name $50. ;
        format Org_Code $3. ;
        format Org_Name $50. ;
        format Elect_Ordinary_Admis best12. ;
        format Elect_Daycase_Admis best12. ;
        format Elect_Total_Admis best12. ;
        format Elect_Plan_Ordinary_Admis best12. ;
        format Elect_Plan_Daycase_Admis best12. ;
        format Elect_Plan_Total_Admis best12. ;
        format Elect_Admis_NHS_TreatCentre best12. ;
        format Total_Non_elect_Admis best12. ;
        format GPRefer_All_Special best12. ;
        format GPRefer_Seen_Special best12. ;
        format GPRefer_Made_GA best12. ;
        format GP_Refer_Seen_GA best12. ;
        format Other_Refer_Made_GA best12. ;
        format All_1st_Outpat_Att_GA best12. ;
     input
                 Year $
                 Period $
                 Region_Code $
                 Region_Name $
                 Org_Code $
                 Org_Name $
                 Elect_Ordinary_Admis
                 Elect_Daycase_Admis
                 Elect_Total_Admis
                 Elect_Plan_Ordinary_Admis
                 Elect_Plan_Daycase_Admis
                 Elect_Plan_Total_Admis
                 Elect_Admis_NHS_TreatCentre
                 Total_Non_elect_Admis
                 GPRefer_All_Special
                 GPRefer_Seen_Special
                 GPRefer_Made_GA
                 GP_Refer_Seen_GA
                 Other_Refer_Made_GA
                 All_1st_Outpat_Att_GA
     ;
     if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */

	 	Region_Name = Trim(Left(Region_Name));
	 	Region_Code = Trim(Left(Region_Code));

		Length Region_Name_Code $5.;

		If Region_Name EQ 'DEPARTMENT OF HEALTH' Then Region_Name_Code = 'DOH';
		If Region_Name EQ 'NORTH OF ENGLAND COMMISSIONING REGION' Then Region_Name_Code = 'NECR';
		If Region_Name EQ 'MIDLANDS AND EAST OF ENGLAND COMMISSIONING REGION' Then Region_Name_Code = 'MEECR';
		If Region_Name EQ 'LONDON COMMISSIONING REGION' Then Region_Name_Code = 'LCR';
		If Region_Name EQ 'SOUTH OF ENGLAND COMMISSIONING REGION' Then Region_Name_Code = 'SECR';

Run;

	 Proc Format;
	 Value $Dept 	'DOH' = 'DEPARTMENT OF HEALTH'
              		'NECR' = 'NORTH OF ENGLAND COMMISSIONING REGION'
             		'MEECR' = 'MIDLANDS AND EAST OF ENGLAND COMMISSIONING REGION'
					'LCR' = 'LONDON COMMISSIONING REGION'
					'SECR' = 'SOUTH OF ENGLAND COMMISSIONING REGION';
	Run;


*=================================================================================================
	THIS SECTION CREATES THE API_COLUMNS TABLE IN THE OBDATA LIBRARY TO POPULATE THE ADHOC
	REPORTS DROP DOWN BOXES IN THE SAS AD-HOC REPORT SECTION
==================================================================================================;
%Macro Columns(Dsn);
Proc Contents Data=NHSData.&Dsn 
	Out=NHSData.&Dsn._1 (Keep=Name); 
Run; 
%Mend Columns;
%Columns(NHS);
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
/*
		Put '<p></p>';
		Put '<HR>';
		Put '<p></p>';
*/
		Put '<Table valign="center" align="center" style="width: 100%; height: 8%" border="0">';
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

		Put '<Table align="center" style="width: 100%; height: 10%" border="0">';
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
/*		Put '<p><br></p>';*/

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


	*--- Space below image ---;
/*	Put '<p><br></p>';*/
	Put '<FORM NAME=check METHOD=get ACTION="'"http://&_Host/scripts/broker.exe"'">';

	*--- Table 2 - Drop Down Table ---;
	Put '<table align = "center" style="width: 100%; height: 8%" border="1">';
	Put '<tr>';

	Put '<td valign="center" align="center" style="background-color: lightblue; color: Blue" border="1">';
		Put '<div class="dropdown" align="center" style="float:center; width: 70%">';
		Put '<p><br></p>';
		Put '<b>SELECT AD-HOC REPORT COLUMNS</b>';
		Put '<p><br></p>';


	*--- Read Dataset UniqueNames ---;
		 	%Let Dsn = %Sysfunc(Open(NHSData.NHS_1));
	*--- Count Observations ---;
		    %Let Count = %Eval(%Sysfunc(Attrn(&Dsn,Nobs))+1);

			Put	'<select name="_NHS_Selected" size='"&Count"' multiple>' /;
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

	*--- Space below image ---;

	*--- Table 3 - Submit button ---;
		Put '<Table valign="center" align="center" style="width: 100%; height: 8%" border="0">';
		Put '<td valign="center" align="center" style="background-color: lightblue; color: White">';
		Put '<FORM NAME=check METHOD=get ACTION="'"http://&_Host/scripts/broker.exe"'">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=submit VALUE="Submit Detail" align="center">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.NHS Report.sas">';
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

	Put '</FORM>';
	Put '</td>';
	Put '</tr>';
	Put '</table>';

	Put '</BODY>';
	Put '<HTML>';

Run;

		%ReturnButton;

		ods tagsets.tableeditor close; 
		ods listing; 

	Run;

%Mend NHS_Report;
%NHS_Report();

%Mend Main;
%Main();



