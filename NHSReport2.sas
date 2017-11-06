Libname NHSData "C:\inetpub\wwwroot\sasweb\data\NHS";
Options MPrint MLogic Symbolgen Source Source2;

%Global _Host;
%Global _Path;
%Global _Dimension0;
%Global _Fact0;
%Global _Dimension1;
%Global _Fact1;
%Global _USerPerc;

%Let _Host = &_SRVNAME;
%Put _Host = &_Host;

%Let _Path = http://&_Host/sasweb;
%Put _Path = &_Path;

%Global _Multiple;
%Global _Forecast;

%Let _Forecast = &_Forecast;
%Let _Interval = &_Interval;

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
 	Define style Style.Sasweb;
	End;
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
	Put '<FORM ID=NHS NAME=NHS METHOD=get ACTION="'"http://&_Host/scripts/broker.exe"'">';

/*
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
*/

/*
*--- Concatenate all fact variables into a macro variable ---;
			%Let Perc_FactCols =;
			%Do i = 1 %to &_Fact0;
					%Let ColX = &&_Fact&i;
					%Put ColX = &ColX;

					%Let Perc_FactCols = &Perc_FactCols _&_Forecast._&ColX;
					%Put Perc_FactCols = &Perc_FactCols;
			%End;
*/
/*
*--- Create 12 month interval Forecast values to use in Proc Report ---;
			%Let Month_Int =;
			%Do i = 1 %to 12;
					%Let ColX = Month&i;
					%Put ColX = &ColX;

					%Let Month_Int = &Month_Int &ColX;
					%Put Month_Int = &Month_Int;
			%End;
*/

				Data Work.NHS_Percentage_1;
					Set NHSDATA.NHS(Keep = &DimCols &FactCols /*&Perc_FactCols*/);
					RowCnt = 1;
					Format &FactCols /*&Perc_FactCols*/ Dollar12.2;
					Region_Name = Tranwrd(Trim(Left(Region_Name)),' ','_');
				Run;


				Proc Summary Data = Work.NHS_Percentage_1 Nway Missing;
					Class &DimCols;
					Var &FactCols /*&Perc_FactCols*/;
					Output Out = Work.NHS_Percentage_1_Sum(Drop = _Freq_ _Type_) Sum=;
				Run;

				Data Work.NHS_Percentage_2_Sum;
					Set Work.NHS_Percentage_1_Sum;

					%Do k = 1 %To &_Interval;
					_Month_ = &k;
						%Do j = 1 %To &_Fact0;
							%If &k = 1 %Then
							%Do;
								_Perc_&j = &&_Fact&j * (&_Forecast/100);
								_&_forecast._Forecast_&j = &&_Fact&j + _Perc_&j;
								_Month_ = &k;
							%End;
							%Else %Do;
								_&_forecast._Forecast_&j = _&_forecast._Forecast_&j;
								_Perc_&j = _&_forecast._Forecast_&j * (&_Forecast/100);
								_&_forecast._Forecast_&j = _Perc_&j + _&_forecast._Forecast_&j;
								_Month_ = &k;
							%End;
							Format _&_forecast._Forecast_&j _Perc_&j Dollar12.2;
						%End;
						Output;
					%End;
				Run;

/*
*--- Use this code to add hyperlink in proc gchart ---;
				Data Work.NHS_Percentage_1;
					Set Work.NHS_Percentage_1;

					If Region_Code EQ 'XDH' Then
					Do;
						htmlvar='href="http://www.sas.com"';
					End;
					If Region_Code EQ 'Y54' Then
					Do;
						htmlvar='href="http://www.sas.com"';
					End;
					If Region_Code EQ 'Y55' Then
					Do;
						htmlvar='href="http://www.sas.com"';
					End;
					If Region_Code EQ 'Y56' Then
					Do;
						htmlvar='href="http://www.sas.com"';
					End;
					If Region_Code EQ 'Y57' Then
					Do;
						htmlvar='href="http://www.sas.com"';
					End;
				Run;
*/
*		ODS _ALL_ Close;


*		%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
		title "Listing of Product Sales"; 
*		ods listing close; 
		/*ods tagsets.tableeditor file="C:\inetpub\wwwroot\sasweb\Data\Results\Sales_Report_1.html" */
		ods tagsets.tableeditor file=_Webout
		    style=styles.SASWeb 
		    options(autofilter="YES" 
		 	    autofilter_table="0" 
		            autofilter_width="9em" 
		 	    autofilter_endcol= "50" 
		            frozen_headers="0" 
		            frozen_rowheaders="0" 
		            ); 

				Proc Print Data=Work.NHS_Percentage_2_Sum;
					Title1 "Test Ad-hoc &_forecast Summary Report";
					Title2 "%Sysfunc(UPCASE(&Fdate))";
				Run;

*=========================================================================================================
					START PROC REPORT HERE
==========================================================================================================;
*--- Create a unique URLSTRING(1) value to use in proc report. this is to create a unique _C1_ value ---;
				%Macro Urlstring1();
								urlstring&k=	"http://localhost/scripts/broker.exe"||
											'?_Service='||
											"&_Service"||
											'&_Program='||
											"Source.NHSReport3.sas"||
											'&_Debug='||
											"&_Debug"||
											'&_WebUser='||
											"&_WebUser"||
											'&_WebPass='||
											"&_WebPass"||
											'&_Forecast='||
											"&_Forecast"||
											'&_DimName='||
											"&_DimName"||
											'&_DimVal='||
											_C1_;
							Call define(_col_, 'URL', urlstring&k);
							Call define(_col_, 'style',
									 'style={flyover="Click to drill down to &_DimName detail data"}');
				%Mend Urlstring1;
				%Macro Urlstring2();
								urlstring&k=	"http://localhost/scripts/broker.exe"||
											'?_Service='||
											"&_Service"||
											'&_Program='||
											"Source.NHSReport3.sas"||
											'&_Debug='||
											"&_Debug"||
											'&_WebUser='||
											"&_WebUser"||
											'&_WebPass='||
											"&_WebPass"||
											'&_Forecast='||
											"&_Forecast"||
											'&_DimName='||
											"&_DimName"||
											'&_DimVal='||
											_C2_;
							Call define(_col_, 'URL', urlstring&k);
							Call define(_col_, 'style',
									 'style={flyover="Click to drill down to &_DimName detail data"}');
				%Mend Urlstring2;
				%Macro Urlstring3();
								urlstring&k=	"http://localhost/scripts/broker.exe"||
											'?_Service='||
											"&_Service"||
											'&_Program='||
											"Source.NHSReport3.sas"||
											'&_Debug='||
											"&_Debug"||
											'&_WebUser='||
											"&_WebUser"||
											'&_WebPass='||
											"&_WebPass"||
											'&_Forecast='||
											"&_Forecast"||
											'&_DimName='||
											"&_DimName"||
											'&_DimVal='||
											_C3_;
							Call define(_col_, 'URL', urlstring&k);
							Call define(_col_, 'style',
									 'style={flyover="Click to drill down to &_DimName detail data"}');
				%Mend Urlstring3;
				%Macro Urlstring4();
								urlstring&k=	"http://localhost/scripts/broker.exe"||
											'?_Service='||
											"&_Service"||
											'&_Program='||
											"Source.NHSReport3.sas"||
											'&_Debug='||
											"&_Debug"||
											'&_WebUser='||
											"&_WebUser"||
											'&_WebPass='||
											"&_WebPass"||
											'&_Forecast='||
											"&_Forecast"||
											'&_DimName='||
											"&_DimName"||
											'&_DimVal='||
											_C4_;
							Call define(_col_, 'URL', urlstring&k);
							Call define(_col_, 'style',
									 'style={flyover="Click to drill down to &_DimName detail data"}');
				%Mend Urlstring4;
				%Macro Urlstring5();
								urlstring&k=	"http://localhost/scripts/broker.exe"||
											'?_Service='||
											"&_Service"||
											'&_Program='||
											"Source.NHSReport3.sas"||
											'&_Debug='||
											"&_Debug"||
											'&_WebUser='||
											"&_WebUser"||
											'&_WebPass='||
											'&_Forecast='||
											"&_Forecast"||
											"&_WebPass"||
											'&_DimName='||
											"&_DimName"||
											'&_DimVal='||
											_C5_;
							Call define(_col_, 'URL', urlstring&k);
							Call define(_col_, 'style',
									 'style={flyover="Click to drill down to &_DimName detail data"}');
				%Mend Urlstring5;
				%Macro Urlstring6();
								urlstring&k=	"http://localhost/scripts/broker.exe"||
											'?_Service='||
											"&_Service"||
											'&_Program='||
											"Source.NHSReport3.sas"||
											'&_Debug='||
											"&_Debug"||
											'&_WebUser='||
											"&_WebUser"||
											'&_WebPass='||
											"&_WebPass"||
											'&_Forecast='||
											"&_Forecast"||
											'&_DimName='||
											"&_DimName"||
											'&_DimVal='||
											_C6_;
							Call define(_col_, 'URL', urlstring&k);
							Call define(_col_, 'style',
									 'style={flyover="Click to drill down to &_DimName detail data"}');
				%Mend Urlstring6;
				%Macro Urlstring7();
								urlstring&k=	"http://localhost/scripts/broker.exe"||
											'?_Service='||
											"&_Service"||
											'&_Program='||
											"Source.NHSReport3.sas"||
											'&_Debug='||
											"&_Debug"||
											'&_WebUser='||
											"&_WebUser"||
											'&_WebPass='||
											"&_WebPass"||
											'&_Forecast='||
											"&_Forecast"||
											'&_DimName='||
											"&_DimName"||
											'&_DimVal='||
											_C7_;
							Call define(_col_, 'URL', urlstring&k);
							Call define(_col_, 'style',
									 'style={flyover="Click to drill down to &_DimName detail data"}');
				%Mend Urlstring7;

				Proc Report Data = Work.NHS_Percentage_2_Sum nowd/*
					style(report)=[rules=all cellspacing=0 bordercolor=gray] 
					style(header)=[background=lightskyblue foreground=black] 
					style(column)=[background=lightcyan foreground=black]*/;

					Title1 "Test Ad-hoc &_forecast Summary Proc Report";
					Title2 "%Sysfunc(UPCASE(&Fdate))";
					Column &DimCols &FactCols /*&Perc_FactCols*/ Forecast /*&Month_Int*/;
					 
					%Do i = 1 %to &_Dimension0;
						Define &&_Dimension&i / group "&&_Dimension&i" left;
					%End;
					%Do j = 1 %to &_Fact0;
						Define &&_Fact&j / sum "&&_Fact&j" left;
						Define _&_forecast._&&_Fact&j / analysis "&_forecast._&&_Fact&j" left;
					%End;

					Define Forecast / Computed format=Dollar15.2;

/*					Define Month_Int / Computed format=Dollar15.2;*/

					Compute Forecast;
						Forecast = &_Fact1..sum * (&_Forecast/100);
					Endcomp;

					%Do i = 1 %To 12;
						%If &i = 1 %Then
						%Do;
					
							Compute Month&i;
								Month&i = &&_Fact.&i..sum + (&&_Fact.&i..sum * (&_Forecast/100));
							Endcomp;

						%End;
						%Else %If &i >= 2 %Then 
						%Do;
					
							Compute Month&i;
								Month&i = &&_Fact.&i..sum + (&&_Fact.&i..sum * (&_Forecast/100));
							Endcomp;

						%End;
					%End;
					
					%Do k = 1 %to &_Dimension0;
						%Let _DimName = &&_Dimension&k;
						%Let _DimVal = &_DimName;
						Compute &&_Dimension&k;
							%If &k = 1 %Then
							%Do;
								%Urlstring1();
							%End;
							%If &k = 2 %Then
							%Do;
								%Urlstring2();
							%End;
							%If &k = 3 %Then
							%Do;
								%Urlstring3();
							%End;
							%If &k = 4 %Then
							%Do;
								%Urlstring4();
							%End;
							%If &k = 5 %Then
							%Do;
								%Urlstring5();
							%End;
							%If &k = 6 %Then
							%Do;
								%Urlstring6();
							%End;
							%If &k = 7 %Then
							%Do;
								%Urlstring7();
							%End;
						Endcomp;
					%End;
			Run;

		ODS tagsets.tableeditor close; 



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


			proc sgplot data=Work.NHS_Percentage_2_Sum;
			   title "Region Code vs Total Non Elective Admissions";

			   	%Do i = 1 %to &_Fact0;
				   	VLine _Month_ / response = _Perc_&i y2axis;
					VBar _Month_ / response = _&_forecast._Forecast_&i;
				%End;
			run;

/*
			proc gchart data=Work.NHS_Percentage_1;                                                                                                                
			   	%Do i = 1 %to &_Fact0;
			   		vbar Region_Code / sumvar=&&_Fact&i html=htmlvar width=20;                                                                           
				%End;
			run;                                                                                                                                    
			quit; 
*/
*---- Close the _webout location ---;
	ODS HTML Close;

	%ReturnButton;

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


		%ReturnButton;

		ods tagsets.tableeditor close; 
		ods listing; 

	Run;
%End;


%Mend NHS_Report;
%NHS_Report();

%Mend Main;
%Main();
