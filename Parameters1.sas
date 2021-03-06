%Global _service;
%Global _Host;
%Global _Path;

%Let _Host = &_SRVNAME;
%Put _Host = &_Host;

%Let _Path = http://&_Host/sasweb;
%Put _Path = &_Path;

Options MPrint MLogic Source Source2 Symbolgen;

%Macro Import(Filename);
/*
PROC IMPORT DATAFILE="&Filename"
 	OUT=OBData.Bank_API_List
 	DBMS=csv
 	REPLACE;
 	GETNAMES=Yes;
RUN;
*/

 /**********************************************************************
 *   PRODUCT:   SAS
 *   VERSION:   9.4
 *   CREATOR:   External File Interface
 *   DATE:      21JUN17
 *   DESC:      Generated SAS Datastep Code
 *   TEMPLATE SOURCE:  (None Specified.)
 ***********************************************************************/
 data Work.BANK_API_LIST    ;
    %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
    infile "&Filename" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
       informat Bank_Name $10. ;
       informat Bank_Description $30. ;
       informat API_Name $3. ;
       informat API_Desc $25. ;
       informat Version_No $6. ;
       informat Version_No_Desc $20. ;
       format Bank_Name $10. ;
       format Bank_Description $30. ;
       format API_Name $3. ;
       format API_Desc $25. ;
       format Version_No $6. ;
       format Version_No_Desc $20. ;
    input
                Bank_Name $
                Bank_Description $
                API_Name $
                API_Desc $
				Version_No $
	       		Version_No_Desc $;

    ;
    if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
 run;	
 
/*Data Work.Dummy;*/
/*	Length Bank_Name $ 3*/
/*	Bank_Description $ 30*/
/*	API_Name $ 8*/
/*	API_Desc $ 25;*/
/*Run;*/


Proc Sort Data = Work.Bank_API_List;
	By Bank_Name;
Run;

	*--- Get Unique Version Number from Dataset ---;
	Proc Sort Data = Work.Bank_API_List(Where=(Bank_Name = "&_BankName"))
		Out = Work.Unique_No NoDupKey;
		By Version_No;
	Run;
	*--- Get Unique Version Number from Dataset for SQM ---;
	Proc Sort Data = Work.Bank_API_List(Where=(Bank_Name = "&_BankName"))
		Out = Work.Unique_No_SQM NoDupKey;
		By Version_No Version_No_Desc;
	Run;

	


/*
Data AAA;
	Set Work.Bank_API_List;
	By Bank_Name;
	Retain Bank_Cnt;
	If First.Bank_Name Then
	Do;
		Bank_Cnt+1;
		API_Cnt = 1;
		Call Symput(Compress('Bank_API_List'||Put(Bank_Cnt,3.)),Trim(Left(Bank_Name)));
		Call Symput(Compress('API_List_Name'||Put(Bank_Cnt,3.)||Put(API_Cnt,3.)),Trim(Left(API_Name)));
		Call Symput(Compress('API_Count'||Put(Bank_Cnt,3.)||Put(API_Cnt,3.)),Put(API_Cnt,3.));
	End;
	If Not First.Bank_Name Then
	Do;
		API_Cnt + 1;
		Call Symput(Compress('Bank_API_List'||Put(Bank_Cnt,3.)),Trim(Left(Bank_Name)));
		Call Symput(Compress('API_List_Name'||Put(Bank_Cnt,3.)||Put(API_Cnt,3.)),Trim(Left(API_Name)));
		Call Symput(Compress('API_Count'||Put(Bank_Cnt,3.)||Put(API_Cnt,3.)),Put(API_Cnt,3.));
	End;
	If Last.Bank_Name Then
	Do;
		Call Symput('Tot_Bank_Cnt',Put(Bank_Cnt,3.));
		Call Symput(Compress('Tot_API_Count'||Put(Bank_Cnt,3.)),Put(API_Cnt,3.));
	End;
Run;

%Macro Loop();
%Do i = 1 %To &Tot_Bank_Cnt;
	Data _Null_;

		%Put Bank_API_List&i = "&&Bank_API_List&i";

		%Do j = 1 %To &&Tot_API_Count&i;
				%Put API_List_Name&i&j = "&&API_List_Name&i&j";
		%End;

	Run;
%End;
%Mend Loop;
%Loop();
*/


%Mend Import;
%Import(C:\inetpub\wwwroot\sasweb\Data\Perm\Bank_API_List.csv);

*%Put _All_;



%Macro Populate();
Data _NULL_;
*File 'H:\StV\Open Banking\SAS\SAS Intrnet\Report.html';
File _Webout;

Put '<HTML>';
Put '<HEAD>';
Put '<html xmlns="http://www.w3.org/1999/xhtml">';
Put '<head>';
Put '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
Put '<meta http-equiv="X-UA-Compatible" content="IE=10"/>';
Put '<title>OB TESTING</title>';

/*Put '<!-- Basic Page Needs ================================================== -->';*/
Put '<meta charset="utf-8" />';
Put '<title>Open Data Test Harness</title>';
Put '<meta name="description" content="">';
Put '<meta name="author" content="">';
/*Put '<!--[if lt IE 9]>';*/
/*Put '<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>';*/
/*Put '<![endif]-->';*/
	
/*Put '<!-- Mobile Specific Metas ================================================== -->';*/
Put '<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />'; 
	
/*Put '<!-- CSS ================================================== -->';*/
*Put '<link rel="stylesheet" href="http://localhost/sasweb/css/style.css">';
*Put '<link rel="stylesheet" href="stylesheets/skeleton.css">';
*Put '<link rel="stylesheet" href="stylesheets/layout.css">';
	
/*Put '<!-- Favicons ================================================== -->';*/
/*Put '<link rel="shortcut icon" href="images/favicon.ico">';*/
/*Put '<link rel="apple-touch-icon" href="images/apple-touch-icon.png">';*/
/*Put '<link rel="apple-touch-icon" sizes="72x72" href="images/apple-touch-icon-72x72.png" />';*/
/*Put '<link rel="apple-touch-icon" sizes="114x114" href="images/apple-touch-icon-114x114.png" />';*/

Put '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
Put '<title>LRM</title>';

Put '<script type="text/javascript" src="'"&_Path/js/jquery.js"'">';
Put '</script>';

Put '<link rel="stylesheet" type="text/css" href="'"&_Path/css/style.css"'">';

Put '</HEAD>';
Put '<BODY>';

Put '<table style="width: 100%; height: 5%" border="0">';
Put '<tr>';
Put '<td valign="top" style="background-color: #D4E6F1; color: orange">';
Put '<img src="'"&_Path/images/london.jpg"'" alt="Cannot find image" style="width:100%;height:8%px;">';
Put '</td>';
Put '</tr>';
Put '</table>';


	Put '<FORM NAME=check METHOD=GET ACTION="'"http://&_Host/scripts/broker.exe"'">';

	Put '<Table align="center" style="width: 100%; height: 40%" border="0">';
	Put '<tr>';
	Put '<td valign="center" align="center" style="background-color: #D4E6F1; color: Blue" border="0">';
	Put '<div class="header" align="center" style="float:left; width: 100%">';
	Put '<H3>SELECTED BANK NAME</H3>';
	Put '<p></p>';
	
				*--- Read Dataset UniqueNames ---;
				 	%Let Dsn = %Sysfunc(Open(Work.Bank_API_List(Where=(Bank_Name = "&_BankName"))));
					%Put Dsn = "&Dsn";
				*--- Count Observations ---;
				    %Let Count = %Sysfunc(Attrn(&Dsn,Nobs));

				*--- Populate Drop Down Box on HTML Page ---;
				Put	'<select name="_BankName" size="7" style="width: 80%; height: 30%">' /;
				    %Do I = 1 %To 1 /*&Count*/;
				        %Let Rc = %Sysfunc(fetch(&Dsn,&i));
				        %Let Start=%Sysfunc(GETVARC(&Dsn,%Sysfunc(VARNUM(&Dsn,Bank_Name))));
				        %Let Label=%Sysfunc(GETVARC(&Dsn,%Sysfunc(VARNUM(&Dsn,Bank_Description))));
				        %If "&Start" ne " " %Then
				        %Do;
							%If &I=1 %Then 
							%Do;
					            Put '<option selected value='
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

	Put '</SELECT>';
	Put '</div>';
	Put '</td>';


	Put '<td valign="center" align="center" style="background-color: #D4E6F1; color: Blue" border="0">';
	Put '<div class="header" align="center" style="float:left; width: 100%">';
	Put '<H3>SELECT API NAME</H3>';
	Put '<p></p>';

				*--- Read Dataset UniqueNames ---;
				%If %Sysfunc(Compress("&_BankName")) = "Test_Bank" %Then
				%Do;
				 	%Let Dsn = %Sysfunc(Open(Work.Bank_API_List(Where=(Bank_Name = "&_BankName" and Version_No = "v1.3"))));
				*--- Count Observations ---;
				    %Let Count = %Sysfunc(Attrn(&Dsn,Nobs));
				%End;
/*

				%Else %If %Sysfunc(Compress("&_BankName")) = "RBS" %Then
				%Do;
				 	%Let Dsn = %Sysfunc(Open(Work.Bank_API_List(Where=(Bank_Name = "&_BankName" and Version_No = "v1.3"))));
				*--- Count Observations ---;
				    %Let Count = %Sysfunc(Attrn(&Dsn,Nobs));
				%End;

				%Else %If %Sysfunc(Compress("&_BankName")) = "Coutts" %Then
				%Do;
				 	%Let Dsn = %Sysfunc(Open(Work.Bank_API_List(Where=(Bank_Name = "&_BankName" and Version_No = "v1.3"))));
				*--- Count Observations ---;
				    %Let Count = %Sysfunc(Attrn(&Dsn,Nobs));
				%End;

				%Else %If %Sysfunc(Compress("&_BankName")) = "Natwest" %Then
				%Do;
				 	%Let Dsn = %Sysfunc(Open(Work.Bank_API_List(Where=(Bank_Name = "&_BankName" and Version_No in ("v1.3","v1.0")))));
				*--- Count Observations ---;
				    %Let Count = %Sysfunc(Attrn(&Dsn,Nobs));
				%End;
				%Else %If %Sysfunc(Compress("&_BankName")) = "Esme" %Then
				%Do;
				 	%Let Dsn = %Sysfunc(Open(Work.Bank_API_List(Where=(Bank_Name = "&_BankName" and Version_No = "v1.3"))));
				*--- Count Observations ---;
				    %Let Count = %Sysfunc(Attrn(&Dsn,Nobs));
				%End;
				%Else %If %Sysfunc(Compress("&_BankName")) = "AdamCo" %Then
				%Do;
				 	%Let Dsn = %Sysfunc(Open(Work.Bank_API_List(Where=(Bank_Name = "&_BankName" and Version_No = "v1.3"))));
				*--- Count Observations ---;
				    %Let Count = %Sysfunc(Attrn(&Dsn,Nobs));
				%End;
*/
				%Else %Do;
				 	%Let Dsn = %Sysfunc(Open(Work.Bank_API_List(Where=(Bank_Name = "&_BankName" and Version_No in ("v1.0","v1.1","v2.1","v2.2")))));
				*--- Count Observations ---;
				    %Let Count = %Sysfunc(Attrn(&Dsn,Nobs));
				%End;

				*--- Populate Drop Down Box on HTML Page ---;
				Put	'<select name="_APIName" size="7" style="width: 80%; height: 30%">' /;
				    %Do I = 1 %To &Count;
				        %Let Rc = %Sysfunc(fetch(&Dsn,&i));
				        %Let Start=%Sysfunc(GETVARC(&Dsn,%Sysfunc(VARNUM(&Dsn,API_Name))));
				        %Let Label=%Sysfunc(GETVARC(&Dsn,%Sysfunc(VARNUM(&Dsn,API_Desc))));
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
							%Else %If &I > 1 %Then
							%Do;
					            Put '<option value='
					            "&Start"
					            '>' /
					            "&Label"
					            '</option>' /;
							%End;
							%Else %If &I = &Count+1 %Then
							%Do;
					            Put '<option Selected value='
					            "&Start"
					            '>' /
					            "&Label"
					            '</option>' /;
							%End;
				        %End;
				        %Else %Let I = &Count;
				    %End;

				    %Let Rc = %Sysfunc(Close(&Dsn));


	Put '</SELECT>';

	Put '</div>';
	Put '</td>';

	Put '<td valign="center" align="center" style="background-color: #D4E6F1; color: Blue" border="0">';
	Put '<div class="header" align="center" style="float:left; width: 100%">';
	Put '<H3>SELECT API VERSION</H3>';
	Put '<p></p>';

					*--- Read Dataset UniqueNames ---;
				 	%Let Dsn = %Sysfunc(Open(Work.Unique_No_SQM(Where=(Bank_Name = "&_BankName"))));
					%Put Dsn = "&Dsn";
				*--- Count Observations ---;
				    %Let Count = %Sysfunc(Attrn(&Dsn,Nobs));

				*--- Populate Drop Down Box on HTML Page ---;
				Put	'<select name="_VersionNo" size="7" style="width: 80%; height: 30%" onchange="this.form.submit()">' /;
				    %Do I = 1 %To &Count+1 /*&Count*/;
				        %Let Rc = %Sysfunc(fetch(&Dsn,&i));
				        %Let Start=%Sysfunc(GETVARC(&Dsn,%Sysfunc(VARNUM(&Dsn,Version_No))));
				        %Let Label=%Sysfunc(GETVARC(&Dsn,%Sysfunc(VARNUM(&Dsn,Version_No_Desc))));
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
							%Else %If &I > 1 %Then
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
	Put '</SELECT>';

	Put '</div>';
	Put '</td>';

	Put '</td>';
	Put '</tr>';
	Put '</table>';

	Put '<Table align="center" style="width: 100%; height: 5%" border="0">';
	Put '<tr>';
	%If "&_Bankname" EQ "OB" %Then
	%Do;
		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.SQM_METRICS_SWAGGER_V01_DEV.sas">';
*		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.SQM_METRICS_SWAGGER_V01_PRD.sas">';
	%End;
	%If "&_Bankname" NE "OB" %Then
	%Do;
*		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.API_LIVE_APP_V09_FCA_DEV.sas">';
		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.API_LIVE_APP_V09_FCA_PRD.sas">';
	%End;
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
	Put '<td valign="top" style="background-color: White; color: black">';
	Put '<H3>All Rights Reserved</H3>';
	Put '<A HREF="http://www.openbanking.org.uk">Open Banking Limited</A>';
	Put '</td>';
	Put '</tr>';
	Put '</table>';


Put '</body>';
Put '</html>';

Run;
%Mend Populate;
%Populate();
