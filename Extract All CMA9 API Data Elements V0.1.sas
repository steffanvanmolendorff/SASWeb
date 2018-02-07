Options MPrint MLogic Symbolgen Source Source2;

*--- Assign Permanent library path to save perm datasets ---;
Libname OBData "C:\inetpub\wwwroot\sasweb\data\perm";

*--- Assign Global macro variables to use in the scripts below ---;
%Global Start;
%Global ATM_Data_Element_Total;
%Global BCH_Data_Element_Total;
%Global BCA_Data_Element_Total;
%Global PCA_Data_Element_Total;
%Global CCC_Data_Element_Total;
%Global SME_Data_Element_Total;
%Global DataSetName;

*--- Assign Global maro variables to save total number of banks per product type ---;
%Global ATM_Bank_Name_Total;
%Global BCH_Bank_Name_Total;
%Global BCA_Bank_Name_Total;
%Global PCA_Bank_Name_Total;
%Global CCC_Bank_Name_Total;
%Global SME_Bank_Name_Total;

*--- Main Macro that wraps all the code ---;
%Macro Main();

*--- Uncomment this line to run program locally ---;

%Global _APIVisual;
%Let _APIVisual = BCH;
%Put _APIVisual = &_APIVisual;

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
	Var Count;
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

*--- Test if the Data_Element only contains numeric values ---;
*--- If it does then (i.e. = 0) then concatenate an underscore to the values ---;
*--- Because the program below will create a dataset for each value ---;
*--- If the value is only numbers the program will create an Error and stop executing ---;
	If Verify(Trim(Left(Data_Element)),"1234567890") = 0 Then
	Do;
		Data_Element = '_'||Data_Element;
	End;
Run;

*--- Create a dataset with only the Bank names in the tables ---;
Proc Contents Data = &API_Dsn
	(Drop = Hierarchy Bank_API Data_Element Rowcnt P Count) Noprint
     out = Work.Names(keep = Name Rename=(Name=Bank_Name));
Run;
Quit;
*--- Delete any P values Bank names i.e. P8-P9 etc ---;
Data Work.Names;
	Set Work.Names;
	If Length(Bank_Name) < 3 or Substr(Bank_Name,1,1) = '_' then delete;
Run;

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
	_Record_ID = &_Record_ID;
*--- Save all the Bank_Names and Data_Elements names in the macro variables created in rows 32 to 40 ---;
	Call Symput(Compress("&API"||'_'||"&_Var"||Put(&i,3.)),"&_Start");
*--- Save the total counts of Bank_Names and Data_Element names in Macro variabe ---;
	Call Symput(Compress("&API"||'_'||"&_Var"||'_'||"Total"),Put(&API._Total,3.));
%Mend;

%Macro Banks(_Dsn, _Var);
Data Work.&API._&_Var;
*--- Set variable lengths to 32 characters, API value to length 3 and Total to numeric 3 ---; 
	Length &_VAR $ 32 API $ 3 _Record_ID 6 &API._Count &API._Total 3 ;

				*--- Read Dataset UniqueNames ---;
				 	%Let Dsn = %Sysfunc(Open(&_Dsn));
					%Put Dsn = &Dsn;
				*--- Count Observations ---;
				    %Let Count = %Sysfunc(Attrn(&Dsn,Nobs));
					%Put Count = &Count;
				*--- Count Observations ---;
				    %Let _Record_ID = %Sysfunc(Attrn(&Dsn,_Record_ID));
					%Put _Record_ID = &_Record_ID;

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
	Out = &Dsn(Keep = Data_Element RowCnt _Record_ID Count &Dsn);
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
			Data Work.&&&API._Data_Element&l(Keep = Bank Data_Element RowCnt _Record_ID Count &&&API._Data_Element&l);
				Set &&&API._Bank_Name&k(Where=(Data_Element = "&&&API._Data_Element&l"));
			*--- Create a API_Count variable per product type ---;
					&API._Count = Count;
			*--- Create the Record ID field to use in the merge of all data_element datasets ---;
					_Record_ID = _Record_ID;
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
			By _Record_ID;
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

*--- Create the OBData.&API_Geographic datasets ---;
Data OBData.&API._Geographic;
	Set &Datasets;
	Record_Count = 1;
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


******************************************************************************************
*	OPEN DATA: BCA
*   PRODUCT:   SAS
*   VERSION:   9.4
*   CREATOR:   External File Interface
*   DATE:      29DEC17
*   DESC:      Generated SAS Datastep Code
*   TEMPLATE SOURCE:  (None Specified.)
******************************************************************************************;
*--- Assign Dataset Library ---; 
Libname OBData "C:\inetpub\wwwroot\sasweb\Data\Perm";

*--- Create Blank dataset and set variable lenghts ---;
Data WORK.BCA_TEST1;
	Input Data_Element $31.
         RowCnt best32. 
         Count best32. 
         BCA_Count best32. 
         APRAERRate $25. 
         Bank $50. 
         AccessChannels1 $25. 
         AccessChannels10 $25. 
         AccessChannels11 $25. 
         AccessChannels12 $25. 
         AccessChannels2 $25. 
         AccessChannels3 $25. 
         AccessChannels4 $25. 
         AccessChannels5 $25. 
         AccessChannels6 $25. 
         AccessChannels7 $25. 
         AccessChannels8 $25. 
         AccessChannels9 $25. 
         AgeRestricted $25. 
         Agreement $300. 
         AnnualBusinessTurnoverCurrency $25. 
         AnnualRenewalFee $25. 
         AnnualRenewalRate $25. 
         ArrangedOverdraftInterestTier $25. 
         ArrangementType $25. 
         BIC $25. 
         Benefit $25. 
         BenefitDescription $300. 
         BenefitID $25. 
         BenefitName $25. 
         BenefitSubType $25. 
         BenefitType $25. 
         BenefitValue $25. 
         BufferAmount $25. 
         CMADefinedIndicator $25. 
         CalculationFrequency $25. 
         CalculationMethod $25. 
         CardNotes $25. 
         CardType1 $25. 
         CardType2 $25. 
         CardType3 $25. 
         CardWithdrawalLimit $25. 
         ChequeBookAvailable $25. 
         Contactless $25. 
         Counter $25. 
         CreditCharged $25. 
         CreditScoringPartOfAccountOpe42 $25. 
         CreditScoringPartOfAccountOpe43 $25. 
         CreditScoringPartOfAccountOpe44 $25. 
         CreditScoringPartOfAccountOpe45 $25. 
         CreditScoringPartOfAccountOpe46 $25. 
         CreditScoringPartOfAccountOpe47 $25. 
         CreditScoringPartOfAccountOpe48 $25. 
         CriteriaType1 $25. 
         Currency1 $25. 
         DefaultToAccounts $25. 
         Description $300. 
         EAR $25. 
         EligibilityName $25. 
         EligibilityNotes $300. 
         EligibilityType $25. 
         ExchangeRateAdjustment $25. 
         ExistingFeature $25. 
         FeatureDescription $300. 
         FeatureName $25. 
         FeatureSubType $25. 
         FeatureType $25. 
         FeatureValue $25. 
         FeeAmount $10. 
         FeeChargeAmount $25. 
         FeeChargeApplicationFrequency $25. 
         FeeChargeCalculationFrequency $25. 
         FeeChargeNegotiableIndicator $25. 
         FeeChargeRate $25. 
         FeeChargeRateType $25. 
         FeeChargeType $25. 
         FeeFrequency $25. 
         FeeMax $10. 
         FeeMin $10. 
         FeeRate $10. 
         FeeSubType $25. 
         FeeType $50. 
         FeesAndChargesNotes $300. 
         IncomeCondition $25. 
         IncomeTurnoverRelated $25. 
         IndicativeRate $25. 
         InterestApplicationFrequency $25. 
         InterestNotes $300. 
         InterestProductSubType $10. 
         InterestRate $25. 
         InterestRateCalculationFrequency $25. 
         InterestRateEARpa $10. 
         InterestRateType $25. 
         InterestTier $25. 
         InterestTierPersonal $25. 
         InterestTierSME $7. 
         InterestTierSubType $25. 
         InternationalPaymentsSupported $25. 
         ItemCharge $25. 
         LEI $25. 
         LastUpdated $25. 
         LegalName $50. 
         LengthPromotionalInDays $10. 
         License $100. 
         MarketingEligibility1 $25. 
         MaxNumberOfAccounts $25. 
         MaximumAge $25. 
         MaximumAgeToOpen $25. 
         MaximumCriteria $25. 
         MaximumMonthlyCharge $25. 
         MaximumMonthlyOverdraftCharge $25. 
         MaximumOpeningAmount $25. 
         MinIncomeTurnoverPaidIntoAccount $25. 
         MinUnarrangedOverdraftAmount $25. 
         MinimumAge $25. 
         MinimumCriteria $25. 
         MinimumDeposit $25. 
         MinimumFee $25. 
         MinimumIncomeFrequency $25. 
         MinimumIncomeTurnoverAmount $25. 
         MinimumIncomeTurnoverCurrency $25. 
         MinimumOperatingBalance $25. 
         MinimumOperatingBalanceCurrency $25. 
         MinimumOperatingBalanceExists $25. 
         MinimumRenewalFee $25. 
         MinimumSetupFee $25. 
         MobileWallet1 $25. 
         MobileWallet2 $25. 
         MobileWallet3 $25. 
         MobileWallet4 $25. 
         MobileWallet5 $25. 
         MonthlyCharge $25. 
         Negotiable $25. 
         Notes $300. 
         OpeningDepositMaximumCurrency $25. 
         OpeningDepositMinimum $25. 
         OpeningDepositMinimumCurrency $25. 
         Other $25. 
         OtherCharge $25. 
         OtherFinancialHoldingRequired $25. 
         OverdraftNotes $300. 
         OverdraftOffered $25. 
         OverdraftProductState $25. 
         OverdraftType $25. 
         PaymentMethod $25. 
         PreviousBankruptcy $25. 
         ProductDescription $300. 
         ProductIdentifier $25. 
         ProductName $100. 
         ProductSegment1 $25. 
         ProductState $25. 
         ProductSubType $25. 
         ProductType $25. 
         ProductURL1 $250. 
         ProductURL2 $250. 
         ProductURL3 $250. 
         PromotionEndDate $25. 
         PromotionStartDate $25. 
         Rate $25. 
         RateComparisonType $25. 
         RatesAreNegotiable $25. 
         RepresentativeRate $25. 
         ResidencyRestricted $25. 
         ResidencyRestrictedRegion $25. 
         ReviewFee $25. 
         SetUpFeesAmount $25. 
         SetUpFeesRate $25. 
         SingleJointIncome $25. 
         Term $25. 
         TermsOfUse $32. 
         ThirdSectorOrganisations $25. 
         TierBandIdentification $25. 
         TierBandSetIdentification $25. 
         TierValueMaximum $25. 
         TierValueMinimum $25. 
         TotalOverdraftChargeAmount $25. 
         TotalResults $10. 
         TrademarkID $25. 
         TrademarkIPOCode $25. 
         TsandCs1 $300. 
         UnarrangedOverdraftInterestTier $25. 
         Record_Count best32.;
	Datalines;
	;
Run;
*--- Write permanent dataset variable values to blank dataset with preset variable lengths ---;
Data OBData.BCA_Geographic;
	Set Work.BCA_Test1
	OBData.BCA_Geographic;
Run;


******************************************************************************************
*	OPEN DATA: PCA
*   PRODUCT:   SAS
*   VERSION:   9.4
*   CREATOR:   External File Interface
*   DATE:      29DEC17
*   DESC:      Generated SAS Datastep Code
*   TEMPLATE SOURCE:  (None Specified.)
******************************************************************************************;
*--- Create Blank dataset and set variable lenghts ---;
Data WORK.PCA_TEST1; 
	Input Data_Element $31. 
         RowCnt best32. 
         Count best32. 
         PCA_Count best32. 
         APRAERRate $10. 
         Bank $25. 
         AccessChannels1 $100. 
         AccessChannels2 $100. 
         AccessChannels3 $100. 
         AccessChannels4 $100. 
         AccessChannels5 $100. 
         AccessChannels6 $100. 
         AccessChannels7 $100. 
         AccessChannels8 $100. 
         AccessChannels9 $100. 
         AgeRestricted $10. 
         Agreement $300. 
         AnnualBusinessTurnoverCurrency $10. 
         AnnualRenewalFee $10. 
         ArrangedOverdraftInterestTier $10. 
         ArrangementType $25. 
         BIC $50. 
         Benefit $50. 
         BenefitDescription $300. 
         BenefitName $25. 
         BenefitSubType $25. 
         BenefitType $25. 
         BenefitValue $25. 
         BufferAmount $10. 
         CMADefinedIndicator $10. 
         CalculationFrequency $25. 
         CalculationMethod $25. 
         CardNotes $300. 
         CardType1 $25. 
         CardType2 $25. 
         CardType3 $25. 
         CardType4 $25. 
         CardWithdrawalLimit $10. 
         ChequeBookAvailable $10. 
         Contactless $10. 
         Counter $25. 
         CreditCharged $10. 
         CreditScoringPartOfAccountOpe38 $25. 
         CreditScoringPartOfAccountOpe39 $25. 
         CreditScoringPartOfAccountOpe40 $25. 
         CreditScoringPartOfAccountOpe41 $25. 
         CreditScoringPartOfAccountOpe42 $25. 
         CreditScoringPartOfAccountOpe43 $25. 
         CriteriaType $25. 
         CriteriaType1 $25. 
         CriteriaType2 $25. 
         Currency1 $10. 
         DailyCharge $25. 
         DefaultToAccounts $25. 
         Description $100. 
         EAR $25. 
         EligibilityName $25. 
         EligibilityNotes $300. 
         EligibilityType $25. 
         ExchangeRateAdjustment $10. 
         ExistingFeature $10. 
         FeatureDescription $50.;
		Datalines;
		;
run;
*--- Write permanent dataset variable values to blank dataset with preset variable lengths ---;
Data OBData.PCA_Geographic;
	Set Work.PCA_Test1
	OBData.PCA_Geographic;
Run;


******************************************************************************************
*	OPEN DATA: ATM
*   PRODUCT:   SAS
*   VERSION:   9.4
*   CREATOR:   External File Interface
*   DATE:      29DEC17
*   DESC:      Generated SAS Datastep Code
*   TEMPLATE SOURCE:  (None Specified.)
******************************************************************************************;
*--- Create Blank dataset and set variable lenghts ---;
 Data WORK.ATM_TEST1;
 	Input Data_Element $100. 
		RowCnt best12. 
		Count best12. 
		_Record_ID best12. 
		ATMServices1 $25. 
		Bank $25. 
		ATMServices10 $25. 
		ATMServices11 $25. 
		ATMServices2 $25. 
		ATMServices3 $25. 
		ATMServices4 $25. 
		ATMServices5 $25. 
		ATMServices6 $25. 
		ATMServices7 $25. 
		ATMServices8 $25. 
		ATMServices9 $25. 
		Access24HoursIndicator $10. 
		Accessibility1 $25. 
		Accessibility2 $25. 
		Accessibility3 $25. 
		Accessibility4 $25. 
		Accessibility5 $25. 
		Accessibility6 $25. 
		Accessibility7 $25. 
		AddressLine1 $50. 
		AddressLine2 $50. 
		AddressLine3 $50. 
		AddressLine4 $10. 
		Agreement $300. 
		BrandName $30. 
		BuildingNumber $30. 
		Code $10. 
		Country $3. 
		CountrySubDivision1 $50. 
		Description $100. 
		Identification $30. 
		LastUpdated $30. 
		Latitude $15. 
		License $100. 
		LocationCategory $25. 
		LocationCategory1 $25. 
		Longitude $15. 
		MinimumPossibleAmount $10. 
		Name $30. 
		Note $30. 
		PostCode $10. 
		StreetName $50. 
		SupportedCurrencies1 $3. 
		SupportedCurrencies2 $3. 
		SupportedLanguages1 $3. 
		SupportedLanguages2 $3. 
		SupportedLanguages3 $3. 
		SupportedLanguages4 $3. 
		SupportedLanguages5 $3. 
		TermsOfUse $100. 
		TotalResults $10. 
		TownName $50. 
		Record_Count best12. ;
		Datalines;
;
Run;
*--- Write permanent dataset variable values to blank dataset with preset variable lengths ---;
Data OBData.ATM_Geographic;
	Set Work.ATM_Test1
	OBData.ATM_Geographic;
Run;


******************************************************************************************
*	OPEN DATA: BCH
*   PRODUCT:   SAS
*   VERSION:   9.4
*   CREATOR:   External File Interface
*   DATE:      29DEC17
*   DESC:      Generated SAS Datastep Code
*   TEMPLATE SOURCE:  (None Specified.)
******************************************************************************************;
*--- Create Blank dataset and set variable lenghts ---;
Data WORK.BCH_TEST1;
	Input Data_Element $31. 
		RowCnt best12. 
		Count best12. 
		_Record_ID best12. 
		Accessibility1 $30. 
		Bank $25. 
		Accessibility2 $30. 
		Accessibility3 $30. 
		Accessibility4 $30. 
		Accessibility5 $30. 
		Accessibility6 $30. 
		Accessibility7 $30. 
		AddressLine1 $50. 
		AddressLine2 $50. 
		AddressLine3 $50. 
		AddressLine4 $50. 
		Agreement $300. 
		BrandName $30. 
		BuildingNumber $30. 
		ClosingTime $30. 
		Code $300. 
		ContactContent $300. 
		ContactDescription $100. 
		ContactType $15. 
		Country $3. 
		CountrySubDivision1 $50. 
		CustomerSegment1 $30. 
		CustomerSegment2 $30. 
		CustomerSegment3 $30. 
		CustomerSegment4 $30. 
		CustomerSegment5 $30. 
		CustomerSegment6 $30. 
		CustomerSegment7 $30. 
		CustomerSegment8 $30. 
		CustomerSegment9 $30. 
		Description $100. 
		Identification $30. 
		LastUpdated $30. 
		Latitude $15. 
		License $100. 
		Longitude $15. 
		Name $50. 
		Notes $100. 
		OpeningTime $30. 
		Photo $100. 
		PostCode $10. 
		SequenceNumber $10. 
		ServiceAndFacility1 $30. 
		ServiceAndFacility10 $30. 
		ServiceAndFacility11 $30. 
		ServiceAndFacility12 $30. 
		ServiceAndFacility2 $30. 
		ServiceAndFacility3 $30. 
		ServiceAndFacility4 $30. 
		ServiceAndFacility5 $30. 
		ServiceAndFacility6 $30. 
		ServiceAndFacility7 $30. 
		ServiceAndFacility8 $30. 
		ServiceAndFacility9 $30. 
		StartDate $30. 
		StreetName $30. 
		TermsOfUse $100. 
		TotalResults $10. 
		TownName $50. 
		Type $10. 
		Record_Count best12.; 
		Datalines;
		;
     run;
*--- Write permanent dataset variable values to blank dataset with preset variable lengths ---;
Data OBData.BCH_Geographic;
	Set Work.BCH_Test1
	OBData.BCH_Geographic;
Run;

******************************************************************************************
*	OPEN DATA: SME
*   PRODUCT:   SAS
*   VERSION:   9.4
*   CREATOR:   External File Interface
*   DATE:      29DEC17
*   DESC:      Generated SAS Datastep Code
*   TEMPLATE SOURCE:  (None Specified.)
******************************************************************************************;
*--- Create Blank dataset and set variable lenghts ---;
Data WORK.SME_TEST1; 
	Input Data_Element $31. 
		RowCnt best12. 
		Count best12. 
		SME_Count best12. 
		AgeRestricted $10. 
		Bank $25. 
		Agreement $300. 
		AnnualBusinessTurnover $15. 
		AnnualBusinessTurnoverCurrency $3. 
		ArrearsTreatment $100. 
		BIC $25. 
		Benefit $5. 
		BenefitDescription $300. 
		BenefitName $25. 
		BenefitSubType $25. 
		BenefitType $10. 
		CCARegulatedEntity $10. 
		Currency1 $10. 
		CustomerAccessChannels1 $25. 
		CustomerAccessChannels2 $25. 
		CustomerAccessChannels3 $25. 
		CustomerAccessChannels4 $25. 
		CustomerAccessChannels5 $25. 
		CustomerAccessChannels6 $25. 
		DefaultToAccounts $10. 
		Description $25. 
		EligibilityName $25. 
		EligibilityNotes $150. 
		EligibilityType $25. 
		FeeAmount $10. 
		FeeFrequency $25. 
		FeeMax $10. 
		FeeMin $10. 
		FeeRate $10. 
		FeeSubType $25. 
		FeeType $25. 
		FeesAndChargesNotes $300. 
		IncomeCondition $10. 
		IncomeTurnoverRelated $25. 
		IndicativeRate $150. 
		IsALowInterestRepaymentStartP36 $10. 
		IsThisAnInterestOnlyLoan $10. 
		LEI $25. 
		LastUpdated $10. 
		LegalName $50. 
		License $50. 
		LoanLengthIncrement $10. 
		LoanLengthIncrementLower $10. 
		LoanLengthIncrementUpper $10. 
		LoanSizeBandLower $10. 
		LoanSizeBandUpper $10. 
		MarketingEligibility1 $10. 
		MaxNumberOfAccounts $10. 
		MaximumAge $10. 
		MaximumAgeToOpen $10. 
		MaximumLoanAmount $10. 
		MaximumLoanTerm $10. 
		MaximumOpeningAmount $10. 
		MinimumAge $10. 
		MinimumDeposit $10. 
		MinimumIncomeTurnoverAmount $10. 
		MinimumIncomeTurnoverCurrency $10. 
		MinimumLoanAmount $10. 
		MinimumLoanTerm $10. 
		MinimumOperatingBalanceExists $10. 
		Negotiable $10. 
		OpeningDepositMaximumAmount $10. 
		OpeningDepositMaximumCurrency $10. 
		OpeningDepositMinimum $10. 
		OpeningDepositMinimumCurrency $10. 
		Other $10. 
		OtherFinancialHoldingRequired $10. 
		PaymentHoliday $10. 
		PreviousBankruptcy $10. 
		ProductDescription $150. 
		ProductIdentifier $10. 
		ProductName $50. 
		ProductSegment1 $10. 
		ProductSegment2 $10. 
		ProductSegment3 $10. 
		ProductSegment4 $10. 
		ProductSegment5 $10. 
		ProductSegment6 $10. 
		ProductSegment7 $10. 
		ProductState $10. 
		ProductSubType $25. 
		ProductTypeName $25. 
		ProductURL1 $300. 
		RateComaprisonType $25. 
		RateComparisonType $25. 
		RepaymentFrequency1 $10. 
		RepaymentFrequency2 $10. 
		RepaymentFrequency3 $10. 
		RepaymentFrequency4 $10. 
		RepaymentFrequency5 $10. 
		ResidencyRestricted $10. 
		ResidencyRestrictedRegion $10. 
		SizeIncrement $10. 
		TermsOfUse $50. 
		ThirdSectorOrganisations $10. 
		TotalResults $10. 
		TrademarkID $10. 
		TrademarkIPOCode $25. 
		TsandCs1 $150. 
		WillTheLoanBePaidInTrancheDra100 $10. 
		Record_Count best12.;

		;
 Run;
*--- Write permanent dataset variable values to blank dataset with preset variable lengths ---;
Data OBData.SME_Geographic;
	Set Work.SME_Test1
	OBData.SME_Geographic;
Run;

******************************************************************************************
*	OPEN DATA: CCC
*   PRODUCT:   SAS
*   VERSION:   9.4
*   CREATOR:   External File Interface
*   DATE:      29DEC17
*   DESC:      Generated SAS Datastep Code
*   TEMPLATE SOURCE:  (None Specified.)
******************************************************************************************;
*--- Create Blank dataset and set variable lenghts ---;
Data WORK.CCC_TEST1;  
	Input Data_Element $31. 
        RowCnt best32. 
        Count best32. 
        _Record_ID best32. 
        APRRate $10. 
        Bank $50. 
        AbilityToSetIndividualLimits $10. 
        AccessToOnlineDataReportingTool $10. 
        AgeRestricted $10. 
        Agreement $150. 
        AllocationofRepayment $10. 
        AnnualAccountFeeType $100. 
        AnnualBusinessTurnover $10. 
        AnnualBusinessTurnoverCurrency $10.
        AnnualFeeAmount $10.
        BIC $50. 
        BalanceTransferInterestRatePe12 $10. 
        BalanceTransferRate $10. 
        Benefit $10. 
        BenefitDescription $50. 
        BenefitID $10. 
        BenefitName $25. 
        BenefitSubType $25. 
        BenefitType $10. 
        BenefitValue $10. 
        CCSubType $25. 
        CardScheme $25. 
        CashAdvanceRate $10. 
        CashWithdrawalsAllowed $10. 
        CashbackPercent $10. 
        ChequeFeePercent $25. 
        ConvenienceCheque $25. 
        DaysInterestFreeCreditIfPayme28 $10. 
        DefaultToAccounts $25. 
        Description $100. 
        EligibilityName $25. 
        EligibilityNotes $150. 
        EligibilityType $10. 
        ExchangeRateAdjustment $10. 
        FeesOnCheque $10. 
        ForeignCashFeeRate $10. 
        ForeignPurchaseFeeRate $10. 
        IncomeCondition $10. 
        IncomeTurnoverRelated $10. 
        IssuingEmergencyCardsFees $10.  
        KeyFeatures $300. 
        LEI $25. 
        LastUpdated $10. 
        LegalName $50. 
        License $50. 
        MarketingEligibility1 $25. 
        MarketingEligibility2 $25. 
        MarketingEligibility3 $25. 
        MaxNumberOfAccounts $10. 
        MaximumAgeToOpen $10. 
        MaximumCriteria $10. 
        MaximumNumberOfCardsPermitted $10. 
        MinimumAge $10. 
        MinimumCreditLimit $10. 
        MinimumCriteria $10. 
        MinimumDeposit $10. 
        MinimumLendingAmount $10. 
        MinimumRepaymentAmount $10. 
        MinimumRepaymentPercentage $10. 
        NonSterlingCashFee $10. 
        NonSterlingCashFeeRate $10. 
        NonSterlingPurchaseFeeRate $10. 
        NonSterlingTransactionFeeRate $10. 
        OtherFinancialHoldingRequired $10. 
        OtherKeyFeatures $10. 
        OverLimitFee $10. 
        PaymentDaysAfterStatement $10. 
        PaymentHoliday $10. 
        PaymentHolidayDescription $10. 
        PreviousBankruptcy $10. 
        ProductIdentifier $10. 
        ProductName $10. 
        ProductSegment1 $10. 
        ProductType $10. 
        ProductURL1 $150. 
        PurchaseRate $10. 
        RepaymentFrequency $10. 
        RepaymentNotes $10. 
        ResidencyRestricted $10. 
        ResidencyRestrictedRegion $10. 
        StatementAtAccountLevel $10. 
        StatementAtPersonalLevel $10. 
        TermsOfUse $50. 
        ThirdSectorOrganisations $10. 
        TotalResults $10. 
        TrademarkID $10. 
        TrademarkIPOCode $10. 
        TsandCs1 $150. 
        TsandCs2 $150. 
        Record_Count best32.;
		Datalines;
		;
Run;
*--- Write permanent dataset variable values to blank dataset with preset variable lengths ---;
Data OBData.CCC_Geographic;
	Set Work.CCC_Test1
	OBData.CCC_Geographic;
Run;

*/



*****************************************************************************************************
		CREATE THE CMA9_LAST UPDATED DATASET
*****************************************************************************************************;

*--- Extract Last Updated Date from each API and create Perm Datasets ---;
%Macro LastUpDate(Dsn);
Data Work.&Dsn._LastUpdated;
	Set OBData.&Dsn._Geographic(Keep = Bank LastUpdated Where=(LastUpdated NE ''));
	Bank = Upcase(Bank);
	&Dsn._Date = Scan(LastUpdated,1,'T');
Run;
Proc Sort Data = Work.&Dsn._LastUpdated;
	By Bank; 
Run;
%Mend LastUpDate;
%LastUpDate(ATM);
%LastUpDate(BCH);
%LastUpDate(PCA);
%LastUpDate(BCA);
%LastUpDate(SME);
%LastUpDate(CCC);

Data OBData.CMA9_LastUpdated;
	Merge ATM_LastUpdated
	BCH_LastUpdated
	PCA_LastUpdated
	BCA_LastUpdated
	SME_LastUpdated
	CCC_LastUpdated;
	By Bank;

Run;

