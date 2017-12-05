/*Options MPrint MLogic Symbolgen Source Source2;*/

*--- Assign Permanent library path to save perm datasets ---;
Libname OBData "C:\inetpub\wwwroot\sasweb\data\perm";

/*
*--- Assign Global macro variables to use in the scripts below ---;
%Global Start;
%Global ATM_Data_Element_Total;
%Global BCH_Data_Element_Total;
%Global BCA_Data_Element_Total;
%Global PCA_Data_Element_Total;
%Global CCC_Data_Element_Total;
%Global SME_Data_Element_Total;
%Global DataSetName;
/*%Global _APIVisual;*/
/*
*--- Assign Global maro variables to save total number of banks per product type ---;
%Global ATM_Bank_Name_Total;
%Global BCH_Bank_Name_Total;
%Global BCA_Bank_Name_Total;
%Global PCA_Bank_Name_Total;
%Global CCC_Bank_Name_Total;
%Global SME_Bank_Name_Total;
*/
*--- Main Macro that wraps all the code ---;
%Macro Main();

*--- Uncomment this line to run program locally ---;
/*
%Let _APIVisual = ATM;
%Put _APIVisual = &_APIVisual;
*/

*--- Assign Global Macro variables for storing data values and process in other data/proc steps ---;
%Macro Global_Banks(API);
*--- Create Global macro variables to save the bank names in each macro variable ---;
*--- If the number of banks increase to more than 20 the Do Loop To value must also be increased ---;
*--- Current bankk name count = 13 ---;
%Do i = 1 %To 20;
	%Global &API._Bank_Name&i;
%End;
*--- Create Global macro variables to save the data_elements values within each banks ---;
*--- If the number of banks increase to more than 20 the Do Loop To value must also be increased ---;
*--- Current max data_element count per bank is = 175 ---;
%Do i = 1 %To 200;
	%Global &API._Data_Element&i;
%End;
%Mend Global_Banks;
%Global_Banks(ATM);
%Global_Banks(BCH);
%Global_Banks(BCA);
%Global_Banks(PCA);
%Global_Banks(CCC);
%Global_Banks(SME);

%Macro APIs(API_Dsn,API);

*--- Get a unique list of data elements per Open Data product type ---;
Proc Summary Data = &API_Dsn Nway Missing;
	Class Data_Element;
	Var Rowcnt;
	Output Out = Work.Data_Elements(Drop=_type_ _Freq_) Sum=;
Run;

*--- Change the length of some values as they will be transposed into variables ---;
*--- Dataset variables has a max length of 32 characters ---;
Data Work.Data_Elements;
	Set Work.Data_Elements;
	If Length(Data_Element) > 32 Then
	Do;
		Data_Element = Compress(Substr(Data_Element,1,29)||Put(_N_,3.));
	End;
Run;

*--- Create a dataset with only the Bank names in the tables ---;
Proc Contents Data = &API_Dsn
	(Drop = Hierarchy Bank_API Data_Element Rowcnt P Count) Noprint
     out = Work.Names(keep = Name Rename=(Name=Bank_Name));
Run;
Quit;

*--- The LiastAll macro will list all the Bank_Names and Data_Element names and save into the Global 
	Macro variables created in rows 7-17 ---;
%Macro ListAll(_Start);
*--- List the actual Bank value and save in Macrio variabe ---;
	&_Var = "&_Start";
*--- Save the API product name in the API_Count variable ---;
	API = "&API";
*--- Save the current i = (1,2,3,etc) value ---;
	&API._Count = &i;
	&API._Total = &Count;
*--- Save all the Bank_Names and Data_Elements names in the macro variables created in rows 32 to 40 ---;
	Call Symput(Compress("&API"||'_'||"&_Var"||Put(&i,3.)),"&_Start");
*--- Save the total counts of Bank_Names and Data_Element names in Macro variabe ---;
	Call Symput(Compress("&API"||'_'||"&_Var"||'_'||"Total"),Put(&API._Total,3.));
%Mend;

%Macro Banks(_Dsn, _Var);
Data Work.&API._&_Var;
*--- Set variable lengths to 32 characters, API value to length 3 and Total to numeric 3 ---; 
	Length &_VAR $ 32 API $ 3 &API._Count &API._Total 3 ;

				*--- Read Dataset UniqueNames ---;
				 	%Let Dsn = %Sysfunc(Open(&_Dsn));
					%Put Dsn = &Dsn;
				*--- Count Observations ---;
				    %Let Count = %Sysfunc(Attrn(&Dsn,Nobs));
					%Put Count = &Count;

				*--- Populate Drop Down Box on HTML Page ---;
				    %Do i = 1 %To &Count;
					%Put i = &i;
					
				        %Let Rc = %Sysfunc(fetch(&Dsn,&i));
				        %Let Start=%Sysfunc(GETVARC(&Dsn,%Sysfunc(VARNUM(&Dsn,&_Var))));
				*--- Call macro ListAll to save Bank_Names and Data_Element values and output to tables ---;
						%ListAll(&Start);
						Output;
				    %End;

				    %Let Rc = %Sysfunc(Close(&Dsn));
Run;

*--- This Code resolves the Macro Variables for testing purposes ---;
/*
%Put _All_;
%Macro Test;
%Do i = 1 %To &&&API._&_Var._Total;
	Data Work.&API._&_Var.&i;
		&API._Total = &&&API._&_Var._Total;
		&API._&_Var. = "&&&API._&_Var.&i";
		Output;
	Run;
%End;

%Mend;
%Test;
*/


%Macro Split_Banks(Dsn);
*--- Sort Dataset by RowCnt variable and output to each Data_Element dataset ---;
Proc Sort Data=&API_Dsn
	Out = &Dsn(Keep = Data_Element RowCnt &Dsn);
	By RowCnt;
Run;
%Mend Split_Banks;
*--- &_Var resolves to either Bank_Name or Data_Element ---;
*--- If _Var = Bank_Name then execute the %Split_Banks macro ---;
%If "&_Var" = "Bank_Name" %Then
%Do;
	%Do i = 1 %To &&&API._Bank_Name_Total;
		%Split_Banks(&&&API._Bank_Name&i);
	%End;
%End;

%Macro Split_Values(_Value);

*--- List all Data_Element values in the log to verify the values are accurately 
	populated in the macro variables ---;
	%Put Value = &_Value;

%Mend Split_Values;
*--- &_Var resolves to either Bank_Name or Data_Element ---;
*--- If _Var = Data_Element then execute the %Split_Values macro ---;
%If "&_Var" = "Data_Element" %Then
%Do;
	%Do j = 1 %To &&&API._Data_Element_Total;
		%Split_Values(&&&API._Data_Element&j);
	%End;
%End;

%Put _ALL_;

%Mend Banks;
*--- Execute the macro to run the data on the Bank_Names values ---;
%Banks(Work.Names,Bank_Name);
*--- Execute the macro to run the data on the Data_Element values ---;
%Banks(Work.Data_Elements,Data_Element);


*--- Split API Banks data into Data_Element tables ---;
%Do k = 1 %To &&&API._Bank_Name_Total;
		%Do l = 1 %To &&&API._Data_Element_Total;
			Data Work.&&&API._Data_Element&l(Keep = Bank Data_Element RowCnt Count &API._Count &&&API._Data_Element&l);
				Set &&&API._Bank_Name&k(Where=(Data_Element = "&&&API._Data_Element&l"));
			*--- The count for ATM values in the tables start with ATMID ---;
					%If "&API" EQ "ATM" %Then
					%Do;
						If Data_Element = 'ATMID' Then Count + 1;
					%End;
			*--- The count for ATM values in the tables start with LEI ---;
					%If "&API" NE "ATM" %Then
					%Do;
						If Data_Element = 'LEI' Then Count + 1;
					%End;
			*--- Create a API_Count variable per product type ---;
					&API._Count = Count;
			*--- Save the Bank_Name in the Data_Element variable name to list the Bank_Name as a row ---;
					&&&API._Data_Element&l = &&&API._Bank_Name&k;
			*--- Save the Bank_Name value in the column Bank ---;
					Bank = Tranwrd("&&&API._Bank_Name&k",'_','');
			*--- Create a dataset for each Data_Element value i.e. transposing the data ---;
					Output Work.&&&API._Data_Element&l;
			Run;
		%End;

			*--- Merge all datasets to create one dataset with all the values ---;
		Data Work.&&&API._Bank_Name&k;
			Merge 
			%Do l = 1 %To &&&API._Data_Element_Total;
				Work.&&&API._Data_Element&l
			%End;
			;
			By &API._Count;
		Run;
%End;

*--- Concatenate datasets to output to perm library OBData.API_Geographic ---;
%Let Datasets =;
%Macro API_Concat(DsName);
%If %Sysfunc(exist(&DsName)) %Then
%Do;
	%Let DSNX = &DsName;
	%Put DSNX = &DSNX;

	%Let Datasets = &Datasets &DSNX;
	%Put Datasets = &Datasets;
%End;
%Mend API_Concat;
%Do k = 1 %To &&&API._Bank_Name_Total;
	%API_Concat(&&&API._Bank_Name&k)
%End;

*--- Create the OBData.ATM dataset ---;
Data OBData.&API._Geographic;
	Set &Datasets;
Run;
*--- Execute the macro for all API product types ---;
%Mend APIs;
%If "&_APIVisual" = "ATM" %Then
%Do;
	%APIs(OBData.CMA9_ATM,ATM);
%End;

%If "&_APIVisual" = "BCH" %Then
%Do;
	%APIs(OBData.CMA9_BCH,BCH);
%End;

%If "&_APIVisual" = "BCA" %Then
%Do;
	%APIs(OBData.CMA9_BCA,BCA);
%End;

%If "&_APIVisual" = "PCA" %Then
%Do;
	%APIs(OBData.CMA9_PCA,PCA);
%End;

%If "&_APIVisual" = "CCC" %Then
%Do;
	%APIs(OBData.CMA9_CCC,CCC);
%End;

%If "&_APIVisual" = "SME" %Then
%Do;
	%APIs(OBData.CMA9_SME,SME);
%End;

%Mend Main;
%Main();

