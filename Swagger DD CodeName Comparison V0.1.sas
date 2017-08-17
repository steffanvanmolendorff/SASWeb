Libname OBData "C:\inetpub\wwwroot\sasweb\Data\Perm";
Options MPrint MLogic Source Source2 Symbolgen;

*%Let API_DSN = SME;
%Let API_DSN = CCC;
*%Let API_DSN = BCA;
*%Let API_DSN = PCA;
*%Let API_DSN = ATM;
*%Let API_DSN = BCH;

%Macro Import(Filename,Dsn);
/**********************************************************************
*   PRODUCT:   SAS
*   VERSION:   9.4
*   CREATOR:   External File Interface
*   DATE:      22JUN17
*   DESC:      Generated SAS Datastep Code
*   TEMPLATE SOURCE:  (None Specified.)
***********************************************************************/
     data Work.&Dsn._DD;
     %let _EFIERR_ = 0; 
     infile "&Filename" delimiter = ','
  	MISSOVER DSD lrecl=32767 firstobs=2 Termstr=CRLF;
        informat XPath $1000. ;
        informat FieldName $91. ;
        informat ConstraintID $25. ;
        informat MinOccurs best32. ;
        informat MaxOccurs $9. ;
        informat DataType $50. ;
        informat Length $5. ;
        informat MinLength $25. ;
        informat MaxLength $25. ;
        informat Pattern $25. ;
        informat CodeName $100. ;
        informat CodeDescription $1000. ;
        informat EnhancedDefinition $1000. ;
        informat XMLTag $25. ;
        format XPath $1000. ;
        format FieldName $91. ;
        format ConstraintID $25. ;
        format MinOccurs best12. ;
        format MaxOccurs $9. ;
        format DataType $50. ;
        format Length $5. ;
        format MinLength $25. ;
        format MaxLength $25. ;
        format Pattern $25. ;
        format CodeName $100. ;
        format CodeDescription $1000. ;
        format EnhancedDefinition $1000. ;
        format XMLTag $25. ;

		If Substr(Xpath,1,1) EQ '"' then
	  	Do;
			_Infile_ = Tranwrd(_Infile_,',','');
	  	End;

     input
                 XPath $
                 FieldName $
                 ConstraintID $
                 MinOccurs
                 MaxOccurs $
                 DataType $
                 Length $
                 MinLength
                 MaxLength
                 Pattern $
                 CodeName $
                 CodeDescription $
                 EnhancedDefinition $
                 XMLTag $
     ;
     if _ERROR_ then call symputx('_EFIERR_',1);  
     run;


Data Work.&Dsn._DD(Keep = CodeName Hierarchy);
	Length Pattern Hierarchy $ 1000 &DSN._Lev1 $ 1000;
	Set Work.&Dsn._DD;

	If CodeName NE '';

	If "&Dsn" EQ "BCH" Then 
	Do;
		Hierarchy = Tranwrd(Substr(Trim(Left(XPath)),19),'/','-');
	End;
	Else If "&Dsn" EQ "SME" Then 
	Do;
		Hierarchy = Tranwrd(Substr(Trim(Left(XPath)),20),'/','-');
	End;
	Else If "&Dsn" EQ "BCA" Then 
	Do;
		Hierarchy = Tranwrd(Substr(Trim(Left(XPath)),16),'/','-');
	End;
	Else If "&Dsn" EQ "CCC" Then 
	Do;
		Hierarchy = Tranwrd(Substr(Trim(Left(XPath)),16),'/','-');
	End;
	Else If "&Dsn" EQ "PCA" Then 
	Do;
		Hierarchy = Tranwrd(Substr(Trim(Left(XPath)),16),'/','-');
	End;
	Else If "&Dsn" EQ "ATM" Then 
	Do;
		Hierarchy = Tranwrd(Substr(Trim(Left(XPath)),16),'/','-');
	End;

	&DSN._Lev1 = Hierarchy;

Run;


Data Work.&Dsn._DD(Keep = Hier2 CodeName
	Rename = (Hier2 = Hierarchy));
	Set Work.&Dsn._DD;

	NumVal = Find(Reverse(Trim(Left(Hierarchy))),':');

	Hier = Substr(Reverse(Trim(Left(Hierarchy))),NumVal);

	Hier2 = Trim(Left(Reverse(Substr(Hier,8))));

Run;

Proc Sort Data = Work.&Dsn._DD
	Out = OBData.&Dsn._DD;
	By Hierarchy CodeName;
Run;



Data Work.&Dsn._SWA(Keep = Hierarchy Value
	Rename = (Value = CodeName));
	Length Data_Element Hierarchy $ 1000;
	Set OBData.&Dsn._SWA;
	
	If Reverse(Substr(Reverse(Trim(Left(Var2))),1,4)) = 'enum';

	Data_Element = Compress(Tranwrd(Tranwrd(Tranwrd(Trim(Left(Var2)),'data-',''),'properties-',''),'items-',''));

	NumVal = Find(Data_Element,'Brand-');
	If NumVal = 0 then Delete;

	Hierarchy = Reverse(Substr(Trim(Left(Reverse(Substr(Data_Element,NumVal)))),6));

Run;

Proc Sort Data = Work.&Dsn._SWA
	Out = Work.&Dsn._SWA;
	By Hierarchy CodeName;
Run;


Data OBData.&Dsn._SWA_DD_Compare;
	Merge Work.&Dsn._SWA(Rename=(CodeName = CodeName_SWA))
	OBData.&Dsn._DD(Rename=(CodeName = CodeName_DD));
	By Hierarchy;

	If Codename_SWA NE CodeName_DD Then 
	Do;
		CodeName_Flag = 'Mismatch';
	End;
	Else If Codename_SWA EQ CodeName_DD Then 
	Do;
		CodeName_Flag = 'Match';
	End;
Run;

ods listing close; 

Proc Export Data = OBData.&Dsn._SWA_DD_Compare
 	Outfile = "C:\inetpub\wwwroot\sasweb\Data\Results\&Dsn._SWA_DD_Comparison_Final.csv"
	DBMS = CSV REPLACE;
	PUTNAMES=YES;
Run;

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

Proc Print Data = OBData.&Dsn._SWA_DD_Compare;
Run;

ods tagsets.tableeditor close; 
ods listing; 

%Mend Import;
%Import(C:\inetpub\wwwroot\sasweb\Data\Temp\UML\&API_DSN.l_001_001_01DD.csv,&API_DSN);


