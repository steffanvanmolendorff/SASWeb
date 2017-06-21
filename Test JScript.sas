

%Macro Test_JScript();
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


		Put '<SCRIPT LANGUAGE="JavaScript">'
		 'function goToURL() {'
		 'window.location = "http://www.census.gov";'
		 '}'
		 '</SCRIPT>';


/*		Put '<script type="text/javascript" src="http://localhost/sasweb/js/jquery.js">';*/
/*		Put '</script>';*/

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

		*--- JSCRPT Function Call---;
		Put '<p><br></p>';
 		Put '<INPUT TYPE=button VALUE="Visit Census Site" onClick="goToURL()">';
		Put '<p><br></p>';


		Put '<INPUT TYPE=hidden NAME=_program VALUE="Login.sas">';
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
%Mend Test_JScript;
%Test_JScript;
