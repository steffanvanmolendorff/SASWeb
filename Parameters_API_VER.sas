Options MPrint MLogic Source Source2 Symbolgen;

*--- Set a Gloabl macro variable to determine if DD vs JSON or SWAGGER file will be executed ---;
%Global _Swagger;
%Let _Swagger=;

%Macro Import(Filename);

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
       informat Bank_Description $27. ;
       informat API_Name $3. ;
       informat API_Desc $30. ;
       format Bank_Name $10. ;
       format Bank_Description $27. ;
       format API_Name $3. ;
       format API_Desc $30. ;
    input
                Bank_Name $
                Bank_Description $
                API_Name $
                API_Desc $
    ;
    if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
 run;	

Proc Sort Data = Work.Bank_API_List(Keep = API_Name API_Desc) NoDupKey;
	By API_Name;
Run;



%Mend Import;
%Import(C:\inetpub\wwwroot\sasweb\Data\Perm\Bank_API_List.csv);

*%Put _All_;


%Macro Populate();
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
		Put '<title>OBIE</title>';

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

/*Put '<p></p>';*/

/*
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
*/

/*	Put '<p><br></p>';*/
/*	Put '<HR>';*/
/*	Put '<p><br></p>';*/

	Put '<FORM NAME=check METHOD=GET ACTION="http://localhost/scripts/broker.exe">';

/*	Put '<Table align="center" style="width: 100%; height: 30%" border="1">';*/
/*	Put '<tr>';*/
/**/
/*	Put '<div id="myProgress">' /*/
/*  			'<div id="myBar"></div>' /*/
/*		'</div>';	*/
/**/

	Put '<Table align="center" style="width: 100%; height: 40%" border="1">';
	Put '<tr>';
	Put '<td valign="center" align="center" style="background-color: lightblue; color: Blue" border="1">';
	Put '<div class="dropdown" align="center" style="float:left; width: 100%">';

/*	Put '<td>';*/
/*	Put '<div class="dropdown" align="center" style="float:center; width: 100%">';*/
	Put '<b>SELECT API CATEGORY</b>';
	Put '<p></p>';

	%If "&_action" EQ "ATM BRA PCA DD JSON COMPARE" %then
	%Do;
				*--- Read Dataset UniqueNames ---;
				 	%Let Dsn = %Sysfunc(Open(Work.Bank_API_List(Where=(API_Name in ('ATM','BCH','PCA')))));
				*--- Count Observations ---;
				    %Let Count = %Sysfunc(Attrn(&Dsn,Nobs));
	%End;
*=============================================================================================================================
			Read Dataset for the JSON Comparison
=============================================================================================================================;
	%If "&_action" EQ "API_ALL DD JSON COMPARE" %then
	%Do;
				*--- Read Dataset UniqueNames ---;
				 	%Let Dsn = %Sysfunc(Open(Work.Bank_API_List(Where=(API_Name in ('ATM','BCH','PCA','BCA','SME','CCC')))));
				*--- Count Observations ---;
				    %Let Count = %Sysfunc(Attrn(&Dsn,Nobs));
	%End;
*=============================================================================================================================
			Read Dataset for the PCA and BCA CodeList Comparison
=============================================================================================================================;
/*	%If "&_action" EQ "API CODELIST COMPARISON" %then*/
	%If "&_action" EQ "PCA BCA CODELIST COMPARISON" %then
	%Do;
				*--- Read Dataset UniqueNames ---;
				 	%Let Dsn = %Sysfunc(Open(Work.Bank_API_List(Where=(API_Name in ('PCA','BCA')))));
				*--- Count Observations ---;
				    %Let Count = %Sysfunc(Attrn(&Dsn,Nobs));
	%End;
*=============================================================================================================================
			Read Dataset for the PCA and BCA CodeList Comparison
=============================================================================================================================;
	%If "&_action" EQ "API CODELIST COMPARISON" %then
	%Do;
				*--- Read Dataset UniqueNames ---;
				 	%Let Dsn = %Sysfunc(Open(Work.Bank_API_List(Where=(API_Name in ('ATM','BCH','SME','CCC','FCA')))));
				*--- Count Observations ---;
				    %Let Count = %Sysfunc(Attrn(&Dsn,Nobs));
	%End;
*=============================================================================================================================
			Read Dataset for the JSON Comparison
=============================================================================================================================;
	%If "&_action" EQ "API_PAI_BAI DD JSON COMPARE" %then
	%Do;
				*--- Read Dataset UniqueNames ---;
				 	%Let Dsn = %Sysfunc(Open(Work.Bank_API_List(Where=(API_Name in ('PAI','BAI')))));
				*--- Count Observations ---;
				    %Let Count = %Sysfunc(Attrn(&Dsn,Nobs));
	%End;
*=============================================================================================================================
			Read Dataset for the SWAGGER Comparison
=============================================================================================================================;
	%If "&_action" EQ "API_ALL DD SWAGGER COMPARE" %then
	%Do;
				*--- Read Dataset UniqueNames ---;
				 	%Let Dsn = %Sysfunc(Open(Work.Bank_API_List(Where=(API_Name in ('ATM','BCH','PCA','BCA','SME','CCC')))));
				*--- Count Observations ---;
				    %Let Count = %Sysfunc(Attrn(&Dsn,Nobs));
*--- Set Macro Variable to pass SWAGGER value to API_ALL DD JSON Comparison V03.sas file to execute DD vs. SWAGGER comparison ---;
					%Let _Swagger = SWAGGER;
	%End;
	%If "&_action" EQ "API_SQM DD SWAGGER COMPARE" %then
	%Do;
				*--- Read Dataset UniqueNames ---;
				 	%Let Dsn = %Sysfunc(Open(Work.Bank_API_List(Where=(API_Name in ('SQP','SQB')))));
				*--- Count Observations ---;
				    %Let Count = %Sysfunc(Attrn(&Dsn,Nobs));
*--- Set Macro Variable to pass SWAGGER value to API_ALL DD JSON Comparison V03.sas file to execute DD vs. SWAGGER comparison ---;
					%Let _Swagger = SQMSWAGGER;
	%End;
	%If "&_action" EQ "BCA DD JSON COMPARE" %then
	%Do;
				*--- Read Dataset UniqueNames ---;
				 	%Let Dsn = %Sysfunc(Open(Work.Bank_API_List(Where=(API_Name in ('BCA')))));
				*--- Count Observations ---;
				    %Let Count = %Eval(%Sysfunc(Attrn(&Dsn,Nobs))+1);
	%End;

				*--- Populate Drop Down Box on HTML Page ---;
				Put	'<select name="_APIName" size="7">' /;
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

	Put '<td valign="center" align="center" style="background-color: lightblue; color: Blue" border="1">';
	Put '<div class="dropdown" align="center" style="float:left; width: 100%">';
	Put '<b>SELECT VERSION</b>';
	Put '<p></p>';
	Put '<SELECT NAME="_APIVersion" size="7" onchange="this.form.submit()"</option>';
/*	Put '<OPTION VALUE="V1_3"> Version 1.3 </option>';*/
/*	Put '<OPTION VALUE="V2_0"> Version 2.0 </option>';*/
	Put '<OPTION VALUE="V1_0"> Version 1.0 </option>';
	Put '<OPTION VALUE="V2_1"> Version 2.1 </option>';
/*	Put '<OPTION VALUE="V2_1_1"> Version 2.1.1 </option>';*/
	Put '<OPTION VALUE="V2_2"> Version 2.2 </option>';
	Put '<OPTION VALUE="V2_3"> Version 2.3 </option>';
	Put '</SELECT>';
	Put '</div>';
	Put '</td>';
	Put '</tr>';
	Put '</table>';

/*	Put '<p><br></p>';*/
/*	Put '<p><br></p>';*/
/**/
/*	Put '<p></p>';*/
/*	Put '<HR>';*/
/*	Put '<p></p>';*/

	Put '<Table align="center" style="width: 100%; height: 10%" border="1">';
	Put '<tr>';
/*	Put '<td valign="center" align="center" style="background-color: lightblue; color: White">';*/
*=============================================================================================================================
			Call SAS program for the ATM BCH PCA BCA SME CCC CodeList Comparison
=============================================================================================================================;
	%If "&_action" EQ "PCA BCA CODELIST COMPARISON" %Then
	%Do;
/*		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.API_ALL CodeList Comparison.sas">';*/
		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.PCA_BCA CodeList Comparison.sas">';
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
	%End;


*=============================================================================================================================
			Call SAS program for the PCA BCA CodeList Comparison
=============================================================================================================================;
	%If "&_action" EQ "API CODELIST COMPARISON" %Then
	%Do;
		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.API_ALL CodeList Comparison.sas">';
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
	%End;


	%If "&_action" EQ "API_ALL DD JSON COMPARE" %Then
	%Do;
		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.API_ALL DD JSON Compare V03.sas">';
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
	%End;

	%Else %If "&_action" EQ "API_PAI_BAI DD JSON COMPARE" %Then
	%Do;
		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.API_ALL DD JSON Compare V03 PAI-BAI.sas">';
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
	%End;

	%Else %If "&_SWAGGER" EQ "SWAGGER" %Then
	%Do;
		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.API_ALL DD JSON Compare V03.sas">';
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
		Put '<INPUT TYPE=hidden NAME=_Swagger VALUE=' /
			"&_Swagger"
			'>';
	%End;

	%Else %If "&_SWAGGER" EQ "FCASWAGGER" %Then
	%Do;
		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.API_FCA DD SWAGGER Compare V01.sas">';
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
		Put '<INPUT TYPE=hidden NAME=_Swagger VALUE=' /
			"&_Swagger"
			'>';
	%End;

	%Else %If "&_SWAGGER" EQ "SQMSWAGGER" %Then
	%Do;
		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.API_SQM DD SWAGGER Compare V01.sas">';
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
		Put '<INPUT TYPE=hidden NAME=_Swagger VALUE=' /
			"&_Swagger"
			'>';
	%End;



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
