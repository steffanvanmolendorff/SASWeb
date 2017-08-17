%Macro Valid();
		File _Webout;

		Put '<HTML>';
		Put '<HEAD>';
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

		Put '<script type="text/javascript" src="http://localhost/sasweb/js/jquery.js">';
		Put '</script>';

		Put '<link rel="stylesheet" type="text/css" href="http://localhost/sasweb/css/style.css">';

		Put '</HEAD>';
		Put '<BODY>';

		Put '<BODY>';
		Put '<table style="width: 100%; height: 5%" border="0">';
		Put '<tr>';
		Put '<td valign="top" style="background-color: lightblue; color: orange">';
		Put '<img src="http://localhost/sasweb/images/london.jpg" alt="Cannot find image" style="width:100%;height:8%px;">';
		Put '</td>';
		Put '</tr>';
		Put '</table>';

		Put '<table style="width: 100%; height: 40%" border="0">';
		Put '<tr>';
		Put '<td valign="middle" style="background-color: White; color: black">';
		Put '<p><br><br></p>';
		Put '<H1 align="center">OPEN BANKING - API STANDARDS</H1>';
		Put '<p><br><br></p>';
		Put '<H2 valign="top" align="center">API TEST APPLICATION</H2>';
		Put '<p><br><br></p>';
		Put '</td>';
		Put '</tr>';
		Put '<tr>';
		Put '<td valign="center" align="center" style="background-color: lightblue; color: White">';

		Put '<FORM NAME=check METHOD=get ACTION="http://localhost/scripts/broker.exe">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=submit NAME=_action VALUE="API LIVE APP">';
		Put '<INPUT TYPE=submit NAME=_action VALUE="API TEST APP">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=submit NAME=_action VALUE="CMA9 COMPARISON">';
		Put '<INPUT TYPE=submit NAME=_action VALUE="PARAMETERS">';
		Put '<INPUT TYPE=submit NAME=_action VALUE="STATISTICS">';
		Put '<INPUT TYPE=submit NAME=_action VALUE="OBPaySet JSON COMPARE">';
		Put '<INPUT TYPE=submit NAME=_action VALUE="ATM BRA JSON COMPARE">';
		Put '<INPUT TYPE=submit NAME=_action VALUE="CODELIST COMPARISON">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.SelectSASProgram.sas">';
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
		Put '<td valign="top" style="background-color: White; color: black">';
		Put '<H3>All Rights Reserved</H3>';
		Put '<A HREF="http://www.openbanking.org.uk">Open Banking Limited</A>';
		Put '</td>';
		Put '</table>';

		Put '</BODY>';
		Put '<HTML>';
%Mend Valid;


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

		Put '<script type="text/javascript" src="http://localhost/sasweb/js/jquery.js">';
		Put '</script>';

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



%Macro CodeList();
Libname OBData "C:\inetpub\wwwroot\sasweb\Data\Temp";
/*
PROC IMPORT OUT= WORK.PCA_CodeList_NonFees 
            DATAFILE= "C:\inetpub\wwwroot\sasweb\Data\Temp\UML\PCA_CodeList_NonFees.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

PROC IMPORT OUT= WORK.PCA_CodeList_Fees 
            DATAFILE= "C:\inetpub\wwwroot\sasweb\Data\Temp\UML\PCA_CodeList_Fees.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
*/

    data WORK.PCA_CODELIST_NONFEES    ;
    %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
    infile 'C:\inetpub\wwwroot\sasweb\Data\Temp\UML\PCA_CodeList_NonFees.csv'
	delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 TermStr = CRLF;
       informat CodelistName $50. ;
       informat Endpoint_CodeName $50. ;
       informat Endpoint_Code $4. ;
       informat Description $1000. ;
       informat Include_in_v2_0_ $1. ;
       informat Added_in_v2_0 $1. ;
       informat Notes $121. ;
       informat ISO20022_CodeLIst $1. ;
       informat ISO20022_CodeName $1. ;
       format CodelistName $50. ;
       format Endpoint_CodeName $50. ;
       format Endpoint_Code $4. ;
       format Description $1000. ;
       format Include_in_v2_0_ $1. ;
       format Added_in_v2_0 $1. ;
       format Notes $121. ;
       format ISO20022_CodeLIst $1. ;
       format ISO20022_CodeName $1. ;
    input
                CodelistName $
                Endpoint_CodeName $
                Endpoint_Code $
                Description $
                Include_in_v2_0_ $
                Added_in_v2_0 $
                Notes $
                ISO20022_CodeLIst $
                ISO20022_CodeName $
    ;
    if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
    run;




data WORK.PCA_CODELIST_FEES;
    %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
    infile 'C:\inetpub\wwwroot\sasweb\Data\Temp\UML\PCA_CodeList_Fees.csv' 
	delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 TermStr = CRLF;
       informat CodelistName $50. ;
       informat CodeName $50. ;
       informat CodeCategory $6. ;
       informat Code_Mnemonic $4. ;
       informat Description $1000. ;
       informat Include_in_v2_0_ $1. ;
       informat Added_in_v2_0 $1. ;
       informat Notes $89. ;
       informat ISO20022_CodeLIst $1. ;
       informat ISO20022_CodeName $1. ;
       format CodelistName $50. ;
       format CodeName $50. ;
       format CodeCategory $6. ;
       format Code_Mnemonic $4. ;
       format Description $1000. ;
       format Include_in_v2_0_ $1. ;
       format Added_in_v2_0 $1. ;
       format Notes $89. ;
       format ISO20022_CodeLIst $1. ;
       format ISO20022_CodeName $1. ;

	   Input @;
		If Substr(Description,1,1) EQ '"' then
	  	Do;
			_Infile_ = Tranwrd(_Infile_,',','');
	  	End;


		input
                CodelistName $
                CodeName $
                CodeCategory $
                Code_Mnemonic $
                Description $
                Include_in_v2_0_ $
                Added_in_v2_0 $
                Notes $
                ISO20022_CodeLIst $
                ISO20022_CodeName $
    ;
    if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
run;


Data WORK.Constraints    ;
    %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
    infile 'C:\inetpub\wwwroot\sasweb\Data\Perm\pca_001_001_01_Constraints.csv' delimiter = ',' 
	MISSOVER DSD lrecl=32767 firstobs=2 TermStr=CRLF;
       informat Section $50. ;
       informat ID $3. ;
       informat Description $250. ;
       informat VAR4 $20. ;
       informat Steffan_Notes $106. ;
       format Section $50. ;
       format ID $3. ;
       format Description $250. ;
       format VAR4 $20. ;
       format Steffan_Notes $106. ;

	   Input @;
		If Substr(Description,1,1) EQ '"' then
	  	Do;
			_Infile_ = Tranwrd(_Infile_,',','');
	  	End;

    input
                Section $
                ID $
                Description $
                VAR4 $
                Steffan_Notes $
    ;
    if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
 Run;



Data Work.PCA_CodeList_Fees1(Drop = Description);
	Set Work.PCA_CodeList_Fees;
	CodeDescription = Description;
	If Include_in_v2_0_ EQ 'N' or CodeName EQ '' then Delete;
/*	Where CodeListName = 'OB_CardType1Code';*/
Run;

Data Work.PCA_CodeList_NonFees1(Drop = Description Rename=(EndPoint_CodeName = CodeName));
	Set Work.PCA_CodeList_NonFees;
	CodeDescription = Description;
	If Include_in_v2_0_ EQ 'N' or EndPoint_CodeName EQ '' then Delete;
/*	Where CodeListName = 'OB_CardType1Code';*/
Run;


Data Work.PCA_CodeList;
	Length CodelistName $ 50 CodeName CodeDescription $ 1000;
	Set Work.PCA_CodeList_Fees1(In=a Drop = Notes)
	Work.PCA_CodeList_NonFees1(In=b Drop = Notes);
	Length Infile $ 8;
	If a then InFile = 'Fees';
	If b then Infile = 'Non-Fees';
	CodeListName = Trim(Left(CodeListName));
	CodeName = Trim(Left(CodeName));
	CodeDescription = Trim(Left(CodeDescription));

	CodeListName_CL = CodeListName;
	CodeName_CL = CodeName;
	CodeDescription_CL = CodeDescription;


/*	Where CodeListName = 'OB_CardType1Code';*/
Run;

Proc Sort Data = Work.PCA_CodeList(Keep = CodeName CodeListName CodeDescription
	CodeName_CL CodeListName_CL CodeDescription_CL Include_in_v2_0_) ;
	By CodeListName CodeName CodeDescription;
Run;



*--- Get data from API_PCA Data Dictionary data ---;
Proc Sort Data = OBData.API_PCA
	Out = Work.API_PCA(Keep = Hierarchy Data_Type CodeName CodeDescription
	Rename = (Data_Type = CodeListName)) NoDupKey;
	By Hierarchy Data_Type CodeName CodeDescription;
/*	Where Data_Type EQ 'OB_CardType1Code';*/
Run;


Data Work.API_PCA1(Drop = CodeListName Rename = (NewVar = CodeListName));
	Set Work.API_PCA;
	By Hierarchy CodeListName CodeName CodeDescription;

	Retain NewVar;	

	If Not Missing(CodeListName) Then NewVar = CodeListName;

	CodeListName_DD = CodeListName;
	CodeName_DD = CodeName;
	CodeDescription_DD = CodeDescription;

Run;

Proc Sort Data = Work.API_PCA1
		Out = Work.API_PCA2 NoDupKey;
	By CodeListName CodeName CodeDescription;
Run;





%Macro Validate();
Options Symbolgen MLogic MPrint Source Source2;
Data OBData.PCA_Code_Compare Work.PCA_Code_Compare;
	Length Count 4 Hierarchy $ 1000 CodeListName $ 50 CodeName CodeDescription $ 1000;

	Merge Work.API_PCA2(In=b Keep = Hierarchy CodeListName CodeName CodeDescription
	CodeListName_DD CodeName_DD CodeDescription_DD)

	Work.PCA_CodeList(In=a Keep = CodeListName CodeName CodeDescription
	CodeListName_CL CodeName_CL CodeDescription_CL Include_in_v2_0_);

	By CodeListName CodeName CodeDescription;
	If a and not b Then Infile = 'CodeList';
	If b and not a Then Infile = 'DD';
	If a and b Then Infile = 'Both';

	Count = _N_;

	If Trim(Left(CodeName_DD)) NE Trim(Left(CodeName_CL)) Then
	Do;
		CodeName_Flag = 'Mismatch';
	End;
	Else Do;
		CodeName_Flag = 'Match';
	End;

	If Trim(Left(CodeDescription_DD)) NE Trim(Left(CodeDescription_CL)) Then
	Do;
		CodeDesc_Flag = 'Mismatch';
	End;
	Else Do;
		CodeDesc_Flag = 'Match';
	End;

	If Trim(Left(CodeListName_DD)) NE Trim(Left(CodeListName_CL)) Then
	Do;
		CodeListName_Flag = 'Mismatch';
	End;
	Else Do;
		CodeListName_Flag = 'Match';
	End;

	If Trim(Left(Include_in_v2_0_)) NE 'Y' Then
	Do;
		InVersion_Flag = 'Mismatch';
	End;
	Else Do;
		InVersion_Flag = 'Match';
	End;

/*	Where CodeListName = 'OB_CardType1Code';*/
Run;

/*
Data Work.PCA_Code_Compare1;
	Set Work.PCA_Code_Compare;

	CountWords_DD = CountW(CodeDescription_DD);
	CountWords_CL = CountW(CodeDescription_CL);

	%Let CntWrd = %Sysfunc(CountW(CodeDescription_DD));
	%Put CntWrd = &CntWrd;
	%Do i = 1 %To &CntWrd;
		Word_&CntWrd = Scan(Trim(Left(CodeDescription_DD)),&CntWrd,'');
		Output;
	%End;

	LengthWords_DD = Length(Trim(Left(CodeDescription_DD)));
	LengthWords_CL = Length(Trim(Left(CodeDescription_CL)));
	Length_Diff = LengthWords_DD - LengthWords_CL;

Run;
*/
%Mend Validate;
%Validate();


%Macro Template;
Proc Template;
 define style OBStyle;
 notes "My Simple Style";
 class body /
 backgroundcolor = white
 color = black
 fontfamily = "Palatino"
 ;
 class systemtitle /
 fontfamily = "Verdana, Arial"
 fontsize = 16pt
 fontweight = bold
 ;
 class table /
 backgroundcolor = #f0f0f0
 bordercolor = red
 borderstyle = solid
 borderwidth = 1pt
 cellpadding = 5pt
 cellspacing = 0pt
 frame = void
 rules = groups
 ;
 class header, footer /
 backgroundcolor = #c0c0c0
 fontfamily = "Verdana, Arial"
 fontweight = bold
 ;
 class data /
 fontfamily = "Palatino"
 ;
 end; 

Run;
%Mend Template
%Template;


%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
title "Listing of Product Sales"; 
*--- Set Output Delivery Parameters  ---;
ODS _All_ Close;
ods listing close; 

ods tagsets.tableeditor file=_Webout
    style=styles.OBStyle 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ); 


Proc Report Data = OBData.PCA_Code_Compare nowd
	style(report)=[width=100%]
	style(report)=[rules=all cellspacing=0 bordercolor=gray] 
	style(header)=[background=lightskyblue foreground=black] 
	style(column)=[background=lightcyan foreground=black];

	Title1 "Open Banking - CodeList Comparison";
	Title2 "Data Dictionary vs. CodeList Comparison Reports - %Sysfunc(UPCASE(&Fdate))";

	Columns Count Infile 
	Hierarchy 
	CodeListName 
	CodeName 
	CodeDescription
	CodeListName_DD 
	CodeListName_CL 
	CodeName_DD 
	CodeName_CL 
	CodeDescription_DD
	CodeDescription_CL
	CodeName_Flag CodeDesc_Flag
	Include_in_v2_0_
	InVersion_Flag;

	Define Count / display 'Row Count' left style(column)=[width=5%];
	Define Infile / display 'Infile' left style(column)=[width=5%];
	Define Hierarchy / display 'Data Level' left style(column)=[width=5%];
	Define CodeListName / display 'CodeList Name' left style(column)=[width=5%];
	Define CodeName / display 'Code Name' left style(column)=[width=5%];
	Define CodeDescription / display 'Code Description' left style(column)=[width=5%];
/*	Define CodeListName_Flag / display 'CodeList Name Flag' left style(column)=[width=5%];*/
	Define CodeName_Flag / display 'Code Name Flag' left style(column)=[width=5%];
	Define CodeDesc_Flag / display 'Code Description Flag' left style(column)=[width=5%];
	Define CodeListName_DD  / display 'CodeListName DD' left style(column)=[width=5%];
	Define CodeName_DD / display 'CodeName DD' left style(column)=[width=5%];
	Define CodeDescription_DD / display 'CodeDescription DD' left style(column)=[width=5%];
	Define CodeListName_CL  / display 'CodeListName CL' left style(column)=[width=5%];
	Define CodeName_CL  / display 'CodeName CL' left style(column)=[width=5%];
	Define CodeDescription_CL / display 'CodeDescription CL' left style(column)=[width=5%];
	Define Include_in_v2_0_ / display 'Inversion V2.0' left style(column)=[width=5%];
	Define Inversion_Flag / display 'Inversion Flag' left style(column)=[width=5%];

	Compute Infile;
	If Infile = 'DD' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=green background=lightyellow font_weight=bold]");
	End;
	If Infile = 'Both' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=blue background=lightcyan font_weight=bold]");
	End;
	If Infile = 'CodeList' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeName_Flag;
	If CodeName_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeDesc_Flag;
	If CodeDesc_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute Inversion_Flag;
	If Inversion_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

Run; 

ods tagsets.tableeditor close; 
ods listing; 

%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
title "Listing of Product Sales"; 
*--- Set Output Delivery Parameters  ---;
ODS _All_ Close;
ods listing close; 

ods tagsets.tableeditor file=_Webout
    style=styles.OBStyle 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ); 


Proc Report Data = OBData.PCA_Code_Compare(Where=(Infile='Both')) nowd
	style(report)=[width=100%]
	style(report)=[rules=all cellspacing=0 bordercolor=gray] 
	style(header)=[background=lightskyblue foreground=black] 
	style(column)=[background=lightcyan foreground=black];

	Title1 "Open Banking - CodeList Comparison";
	Title2 "Records Both In Data Dictionary (DD) and CodeList Reports - %Sysfunc(UPCASE(&Fdate))";

	Columns Count Infile 
	Hierarchy 
	CodeListName 
	CodeName 
	CodeDescription
	CodeListName_DD 
	CodeListName_CL 
	CodeName_DD 
	CodeName_CL 
	CodeDescription_DD
	CodeDescription_CL
	CodeName_Flag CodeDesc_Flag
	Include_in_v2_0_
	InVersion_Flag;

	Define Count / display 'Row Count' left style(column)=[width=5%];
	Define Infile / display 'Infile' left style(column)=[width=5%];
	Define Hierarchy / display 'Data Level' left style(column)=[width=5%];
	Define CodeListName / display 'CodeList Name' left style(column)=[width=5%];
	Define CodeName / display 'Code Name' left style(column)=[width=5%];
	Define CodeDescription / display 'Code Description' left style(column)=[width=5%];
/*	Define CodeListName_Flag / display 'CodeList Name Flag' left style(column)=[width=5%];*/
	Define CodeName_Flag / display 'Code Name Flag' left style(column)=[width=5%];
	Define CodeDesc_Flag / display 'Code Description Flag' left style(column)=[width=5%];
	Define CodeListName_DD  / display 'CodeListName DD' left style(column)=[width=5%];
	Define CodeName_DD / display 'CodeName DD' left style(column)=[width=5%];
	Define CodeDescription_DD / display 'CodeDescription DD' left style(column)=[width=5%];
	Define CodeListName_CL  / display 'CodeListName CL' left style(column)=[width=5%];
	Define CodeName_CL  / display 'CodeName CL' left style(column)=[width=5%];
	Define CodeDescription_CL / display 'CodeDescription CL' left style(column)=[width=5%];
	Define Include_in_v2_0_ / display 'Inversion V2.0' left style(column)=[width=5%];
	Define Inversion_Flag / display 'Inversion Flag' left style(column)=[width=5%];

	Compute Infile;
	If Infile = 'DD' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=green background=lightyellow font_weight=bold]");
	End;
	If Infile = 'Both' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=blue background=lightcyan font_weight=bold]");
	End;
	If Infile = 'CodeList' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeName_Flag;
	If CodeName_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeDesc_Flag;
	If CodeDesc_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute Inversion_Flag;
	If Inversion_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

Run; 

ods tagsets.tableeditor close; 
ods listing; 

%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
title "Listing of Product Sales"; 
*--- Set Output Delivery Parameters  ---;
ODS _All_ Close;
ods listing close; 

ods tagsets.tableeditor file=_Webout
    style=styles.OBStyle 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ); 

/*	ODS HTML File="C:\inetpub\wwwroot\sasweb\data\Results\CodeList Results.xls";*/

Proc Report Data = OBData.PCA_Code_Compare(Where=(Infile='CodeList')) nowd
	style(report)=[width=100%]
	style(report)=[rules=all cellspacing=0 bordercolor=gray] 
	style(header)=[background=lightskyblue foreground=black] 
	style(column)=[background=lightcyan foreground=black];

	Title1 "Open Banking - CodeList Comparison";
	Title2 "Records only in the CodeList Excel Reports - %Sysfunc(UPCASE(&Fdate))";

	Columns Count Infile 
	Hierarchy 
	CodeListName 
	CodeName 
	CodeDescription
	CodeListName_DD 
	CodeListName_CL 
	CodeName_DD 
	CodeName_CL 
	CodeDescription_DD
	CodeDescription_CL
	CodeName_Flag CodeDesc_Flag
	Include_in_v2_0_
	InVersion_Flag;

	Define Count / display 'Row Count' left style(column)=[width=5%];
	Define Infile / display 'Infile' left style(column)=[width=5%];
	Define Hierarchy / display 'Data Level' left style(column)=[width=5%];
	Define CodeListName / display 'CodeList Name' left style(column)=[width=5%];
	Define CodeName / display 'Code Name' left style(column)=[width=5%];
	Define CodeDescription / display 'Code Description' left style(column)=[width=5%];
/*	Define CodeListName_Flag / display 'CodeList Name Flag' left style(column)=[width=5%];*/
	Define CodeName_Flag / display 'Code Name Flag' left style(column)=[width=5%];
	Define CodeDesc_Flag / display 'Code Description Flag' left style(column)=[width=5%];
	Define CodeListName_DD  / display 'CodeListName DD' left style(column)=[width=5%];
	Define CodeName_DD / display 'CodeName DD' left style(column)=[width=5%];
	Define CodeDescription_DD / display 'CodeDescription DD' left style(column)=[width=5%];
	Define CodeListName_CL  / display 'CodeListName CL' left style(column)=[width=5%];
	Define CodeName_CL  / display 'CodeName CL' left style(column)=[width=5%];
	Define CodeDescription_CL / display 'CodeDescription CL' left style(column)=[width=5%];
	Define Include_in_v2_0_ / display 'Inversion V2.0' left style(column)=[width=5%];
	Define Inversion_Flag / display 'Inversion Flag' left style(column)=[width=5%];

	Compute Infile;
	If Infile = 'DD' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=green background=lightyellow font_weight=bold]");
	End;
	If Infile = 'Both' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=blue background=lightcyan font_weight=bold]");
	End;
	If Infile = 'CodeList' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeName_Flag;
	If CodeName_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeDesc_Flag;
	If CodeDesc_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute Inversion_Flag;
	If Inversion_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

Run; 

ods tagsets.tableeditor close; 
ods listing; 

%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
title "Listing of Product Sales"; 
*--- Set Output Delivery Parameters  ---;
ODS _All_ Close;
ods listing close; 

ods tagsets.tableeditor file=_Webout
    style=styles.OBStyle 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ); 

Proc Report Data = OBData.PCA_Code_Compare(Where=(Infile='DD')) nowd
	style(report)=[width=100%]
	style(report)=[rules=all cellspacing=0 bordercolor=gray] 
	style(header)=[background=lightskyblue foreground=black] 
	style(column)=[background=lightcyan foreground=black];

	Title1 "Open Banking - CodeList Comparison";
	Title2 "Records only in the Data Dictionary (DD) Excel Reports - %Sysfunc(UPCASE(&Fdate))";

	Columns Count Infile 
	Hierarchy 
	CodeListName 
	CodeName 
	CodeDescription
	CodeListName_DD 
	CodeListName_CL 
	CodeName_DD 
	CodeName_CL 
	CodeDescription_DD
	CodeDescription_CL
	CodeName_Flag CodeDesc_Flag
	Include_in_v2_0_
	InVersion_Flag;

	Define Count / display 'Row Count' left style(column)=[width=5%];
	Define Infile / display 'Infile' left style(column)=[width=5%];
	Define Hierarchy / display 'Data Level' left style(column)=[width=5%];
	Define CodeListName / display 'CodeList Name' left style(column)=[width=5%];
	Define CodeName / display 'Code Name' left style(column)=[width=5%];
	Define CodeDescription / display 'Code Description' left style(column)=[width=5%];
/*	Define CodeListName_Flag / display 'CodeList Name Flag' left style(column)=[width=5%];*/
	Define CodeName_Flag / display 'Code Name Flag' left style(column)=[width=5%];
	Define CodeDesc_Flag / display 'Code Description Flag' left style(column)=[width=5%];
	Define CodeListName_DD  / display 'CodeListName DD' left style(column)=[width=5%];
	Define CodeName_DD / display 'CodeName DD' left style(column)=[width=5%];
	Define CodeDescription_DD / display 'CodeDescription DD' left style(column)=[width=5%];
	Define CodeListName_CL  / display 'CodeListName CL' left style(column)=[width=5%];
	Define CodeName_CL  / display 'CodeName CL' left style(column)=[width=5%];
	Define CodeDescription_CL / display 'CodeDescription CL' left style(column)=[width=5%];
	Define Include_in_v2_0_ / display 'Inversion V2.0' left style(column)=[width=5%];
	Define Inversion_Flag / display 'Inversion Flag' left style(column)=[width=5%];

	Compute Infile;
	If Infile = 'DD' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=green background=lightyellow font_weight=bold]");
	End;
	If Infile = 'Both' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=blue background=lightcyan font_weight=bold]");
	End;
	If Infile = 'CodeList' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeName_Flag;
	If CodeName_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeDesc_Flag;
	If CodeDesc_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute Inversion_Flag;
	If Inversion_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

Run; 



Data _Null_;
	%ReturnButton;
Run;

ods tagsets.tableeditor close; 
ods listing; 


%Mend CodeList;
%CodeList();
