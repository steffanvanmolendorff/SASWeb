Data _NULL_;
File 'H:\StV\Open Banking\SAS\SAS Intrnet\Report.html';

/*Put '<!doctype html>';*/
/*Put '<!--[if lt IE 7 ]><html class="ie ie6" lang="en"> <![endif]-->';*/
/*Put '<!--[if IE 7 ]><html class="ie ie7" lang="en"> <![endif]-->';*/
/*Put '<!--[if IE 8 ]><html class="ie ie8" lang="en"> <![endif]-->';*/
/*Put '<!--[if (gte IE 9)|!(IE)]><!--><html lang="en"> <!--<![endif]-->';*/
Put '<head>';

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
Put '<link rel="stylesheet" href="stylesheets/base.css">';
Put '<link rel="stylesheet" href="stylesheets/skeleton.css">';
Put '<link rel="stylesheet" href="stylesheets/layout.css">';
	
/*Put '<!-- Favicons ================================================== -->';*/
/*Put '<link rel="shortcut icon" href="images/favicon.ico">';*/
/*Put '<link rel="apple-touch-icon" href="images/apple-touch-icon.png">';*/
/*Put '<link rel="apple-touch-icon" sizes="72x72" href="images/apple-touch-icon-72x72.png" />';*/
/*Put '<link rel="apple-touch-icon" sizes="114x114" href="images/apple-touch-icon-114x114.png" />';*/
	
Put '</head>';

Put '<body>';

/*Put '<!-- Primary Page Layout ================================================== -->';*/
	
/*Put '<!-- Delete everything in this .container and get started on your own site! -->';*/

Put '<div class="container">	';
		
Put '<div id="logo" class="sixteen columns">';
Put '<h1>Open Banking</h1>';
Put '</div>';
	
Put '<p></p>';
Put '<HR>';
Put '<p></p>';
	
Put '<div style="float:left; width:100%;">';

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

Put '</div>';
	

Put '<p></p>';
Put '<HR>';
Put '<p></p>';

	
Put '<h2>Open Data Test Harness</h2>';

Put '<div style="width: 100%;">';

Put '<div style="float:left; width: 25%">';
Put '<b>SELECT BANK:</b>';
Put '<SELECT NAME="Bank_Name">';
Put '<OPTION VALUE="Barclays">BARCLAYS';
Put '<OPTION VALUE="Santander">SANTANDER';
Put '<OPTION VALUE="Lloyds">LLOYDS BANKING GROUP';
Put '<OPTION VALUE="NBS">NATIONWIDE BUILDING SOCIETY';
Put '<OPTION VALUE="AIB">ALLIED IRISH';
Put '<OPTION VALUE="RBS">ROYAL BANK OF SCOTLAND';
Put '<OPTION VALUE="RBS">ULSTER BANK';
Put '<OPTION VALUE="BOI">BANK OF IRELAND';
Put '<OPTION VALUE="Danske">DANSKE BANK';
Put '</SELECT>';
Put '</div>';

Put '<div style="float:left; width: 25%">';
Put '<b>SELECT API:</b>';
Put '<SELECT NAME="API_Name">';
Put '<OPTION VALUE="ATM">ATMS';
Put '<OPTION VALUE="BCH">BRANCHES';
Put '<OPTION VALUE="BCA">BUSINESS CURRENT ACCOUNTS';
Put '<OPTION VALUE="PCA">PERSONAL CURRENT ACCOUNTS';
Put '<OPTION VALUE="CCC">COMMERCIAL CREDIT CARDS';
Put '<OPTION VALUE="SME">UNSECURED SME LOANS';
Put '</SELECT>';
Put '</div>';

Put '<div style="float:left; width: 15%">';
Put '<b>SELECT VERSION:</b>';
Put '<SELECT NAME="Version_No">';
Put '<OPTION VALUE="V1_2_2">Version 1.2.2';
Put '<OPTION VALUE="V1_2_2">Version 1.2.3';
Put '<OPTION VALUE="V1_2_3">Version 1.2.4';
Put '<OPTION VALUE="V1_3_0">Version 1.3';
Put '<OPTION VALUE="V2_0_0">Version 2.0';
Put '</SELECT>';
Put '</div>';

/*Put '<div id="bigphoto" class="seven columns add-bottom offset-by-one">';*/
/*Put '<img src="http://lorempixum.com/400/400/city/1" />';*/
/*Put '</div>';*/
	
Put '</div>';


Put '<p></p>';
Put '<HR>';
Put '<p></p>';


Put '<INPUT TYPE="SUBMIT" VALUE=" EXECUTE ">';
Put '<INPUT TYPE="CHECKBOX" NAME="_DEBUG" VALUE="131">SHOW SAS LOG';

/*Put '<!-- JS ================================================== -->';*/
/*Put '<script src="//ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.js"></script>';*/
/*Put '<script>window.jQuery || document.write("<script src="javascripts/jquery-1.5.1.min.js">\x3C/script>")</script>';*/
/*Put '<script src="javascripts/app.js"></script>';*/
	
/*Put '<!-- End Document>================================================== -->';*/
Put '</body>';
Put '</html>';

Run;

