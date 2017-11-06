
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
      Put '<td valign="top" style="background-color: lightblue; color: orange">';
	Put '<img src="http://localhost/sasweb/images/london.jpg" alt="Cant find image" style="width:100%;height:8%px;">';
      Put '</td>';
   Put '</tr>';
Put '</table>';
Put '</BODY>';

/*Put '<p><br></p>';*/

Put '</HTML>';

Run;
%Mend Header;
%Header();

%Macro Import(Filename);


data Work.BANK_API_LIST;
    %let _EFIERR_ = 0;
    infile "&Filename" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
       informat Bank_Name $10. ;
       informat Bank_Description $27. ;
       informat API_Name $3. ;
       informat API_Desc $25. ;
       informat Version_No $4. ;
       informat Version_No_Desc $16. ;
       format Bank_Name $10. ;
       format Bank_Description $27. ;
       format API_Name $3. ;
       format API_Desc $25. ;
       format Version_No $4. ;
       format Version_No_Desc $16. ;
    input
                Bank_Name $
                Bank_Description $
                API_Name $
                API_Desc $
				Version_No $
	       		Version_No_Desc $;

    ;
    if _ERROR_ then call symputx('_EFIERR_',1);
 run;	

Proc Sort Data = Work.Bank_API_List NoDupKey;
	By Bank_Name;
Run;
%Mend Import;
%Import(C:\inetpub\wwwroot\sasweb\Data\Perm\Bank_API_List.csv);

*=====================================================================================================================================================
--- Macro code for the Resubmit-Return button at the bottom of the reports ---
======================================================================================================================================================;
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

%Macro Populate();
Data _NULL_;
File _Webout;

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

	Put '<FORM Name="param" ID="param" METHOD=GET ACTION="http://localhost/scripts/broker.exe">';

	Put '<Table align="center" style="width: 100%; height: 60%" border="1">';
	Put '<tr>';
/*	Put '<td>';*/
	Put '<td valign="center" align="center" style="background-color: lightblue; color: Blue" border="1">';
	Put '<div class="dropdown" align="center" style="float:center; width: 100%">';
	Put '<b>SELECT  BANK</b>';	
	Put '<p></p>';

	Put '<select name="_BankName" size="18" style="width: 25%; height: 30%" onchange="this.form.submit()">' /;

*===============================================================================================================================
		New Automated process to populate HTML dropdown list box
================================================================================================================================;

	*--- Read Dataset UniqueNames ---;
		%Let Dsn = %Sysfunc(Open(Work.Bank_API_List));
		%Put Dsn = "&Dsn";
	*--- Count Observations ---;
		%Let Count = %Sysfunc(Attrn(&Dsn,Nobs));
	*--- Populate Drop Down Box on HTML Page ---;

				    %Do I = 1 %To &Count;
				        %Let Rc = %Sysfunc(fetch(&Dsn,&i));
				        %Let Start=%Sysfunc(GETVARC(&Dsn,%Sysfunc(VARNUM(&Dsn,Bank_Name))));
				        %Let Label=%Sysfunc(GETVARC(&Dsn,%Sysfunc(VARNUM(&Dsn,Bank_Description))));
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


	Put '</div>';
	Put '</td>';
	Put '</tr>';
	Put '</table>';

*=====================================================================================================================================================
--- Add bottom of report Menu ReturnButton code here ---
======================================================================================================================================================;
/*	%ReturnButton();*/


/*
	Put '<td>';
	Put '<div class="dropdown" align="center" style="float:left; width: 50%">';

	Put '<b>SELECT API</b>';
	Put '<SELECT NAME="_APIName" Size="6"</option>';
	Put '<OPTION VALUE="ATM">ATMS</option>';
	Put '<OPTION VALUE="BCH">BRANCHES</option>';
	Put '<OPTION SELECTED VALUE="BCA">BUSINESS CURRENT ACCOUNTS</option>';
	Put '<OPTION VALUE="PCA">PERSONAL CURRENT ACCOUNTS</option>';
	Put '<OPTION VALUE="CCC">COMMERCIAL CREDIT CARDS</option>';
	Put '<OPTION VALUE="SME">UNSECURED SME LOANS</option>';
	Put '</SELECT>';

	Put '</div>';
	Put '</td>';


	Put '<td>';
	Put '<div class="dropdown" align="center" style="float:left; width: 50%">';
	Put '<b>SELECT VERSION</b>';
	Put '<SELECT NAME="_VersionNo" Size="6">';
	Put '<OPTION SELECTED VALUE="v1.2">API VERSION 1.2.4</option>';
	Put '<OPTION VALUE="v1.3">API VERSION 1.3</option>';
	Put '<OPTION VALUE="v2.0">API VERSION 2.0</option>';
	Put '</SELECT>';

	Put '</div>';
	Put '</td>';
*/
*	Put '</div>';
*	Put '</td>';
*	Put '</tr>';
*	Put '</table>';
/*
	Put '<p><br></p>';

	Put '<p><br></p>';

	Put '<p></p>';
	Put '<HR>';
	Put '<p></p>';
*/
*=====================================================================================================================================================
--- Add bottom of report Menu ReturnButton code here ---
======================================================================================================================================================;

/*	Put '<Table align="center" style="width: 100%; height: 20%" border="0">';*/
	Put '<Table>';
	Put '<tr>';
	Put '<td>';
/*	Put '<td valign="center" align="center" style="background-color: lightblue; color: White">';*/
*	Put '<p><br></p>';
/*	Put '<INPUT TYPE=submit VALUE=Submit align="center">';*/
*	Put '<p><br></p>';
	Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.Parameters1.sas">';
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
	Put '</table>';


	Put '<table>';
	Put '<tr>';
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
