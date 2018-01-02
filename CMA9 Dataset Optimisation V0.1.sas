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
         Bank $50. 
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
 	Input Data_Element $31. 
         RowCnt best32. 
         Count best32. 
         ATM_Count best32. 
         APRAERRate best32. 
         Bank $50. 
         AccessChannels1 $25. 
         AccessChannels2 $25. 
         AccessChannels3 $25. 
         AccessChannels4 $25. 
         AccessChannels5 $25. 
         AccessChannels6 $25. 
         AccessChannels7 $25. 
         AccessChannels8 $25. 
         AccessChannels9 $25. 
         AgeRestricted $10.
         Agreement $150.
         AnnualBusinessTurnoverCurrency $10.
		 AnnualRenewalFee $10.
         ArrangedOverdraftInterestTier $10.
         ArrangementType $25.
         BIC $50.
         Benefit $25.
         BenefitDescription $50.
         BenefitName $25.
         BenefitSubType $25.
         BenefitType $25.
         BenefitValue $10.
         BufferAmount $10.
         CMADefinedIndicator $25.
         CalculationFrequency $25.
         CalculationMethod $25.
         CardNotes $150.
         CardType1 $25.
         CardType2 $25. 
         CardType3 $25. 
         CardType4 $25. 
         CardWithdrawalLimit $10. 
         ChequeBookAvailable $10. 
         Contactless $10.
         Counter $10.
         CreditCharged $10.
         CreditScoringPartOfAccountOpe38 $25.
         CreditScoringPartOfAccountOpe39 $25.
         CreditScoringPartOfAccountOpe40 $25.
         CreditScoringPartOfAccountOpe41 $25.
         CreditScoringPartOfAccountOpe42 $25.
         CreditScoringPartOfAccountOpe43 $25.
         CriteriaType $10.
         CriteriaType1 $10.
         CriteriaType2 $10.
         Currency1 $10.
         DailyCharge $10.
         DefaultToAccounts $10.
         Description $150.
         EAR $10.
         EligibilityName $25.
         EligibilityNotes $150.
         EligibilityType $10.
         ExchangeRateAdjustment best32.
         ExistingFeature $10.
         FeatureDescription $50.;
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
         RowCnt best32.
         Count best32.
         _Record_ID best32.
         ATMAtBranch $10.
         Bank $50.
         AccessibilityTypes $25.
         Agreement $150.
         ArrivalTime $10.
         BIC $50.
         BranchDescription $50.
         BranchFacilitiesName1 $10.
         BranchFacilitiesName2 $10.
         BranchIdentification $25.
         BranchMediatedServiceName1 $25.
         BranchMediatedServiceName2 $25.
         BranchMediatedServiceName3 $25.
         BranchMediatedServiceName4 $25.
         BranchMediatedServiceName5 $25.
         BranchName $50.
         BranchOtherMediatedServices1 $10.
         BranchOtherMediatedServices2 $10.
         BranchOtherSelfServices1 $10.
         BranchPhoto $300.
         BranchSelfServeServiceName1 $25.
         BranchSelfServeServiceName2 $25.
         BranchSelfServeServiceName3 $25.
         BranchSelfServeServiceName4 $25.
         BranchSelfServeServiceName5 $10.
         BranchSelfServeServiceName6 $10.
         BranchSelfServeServiceName7 $10.
         BranchType $25.
         BuildingNumberOrName $10.
         ClosingTime $25.
         Country $10.
         CountrySubDivision $10.
         CustomerSegment1 $10.
         CustomerSegment2 $10.
         CustomerSegment3 $10.
         CustomerSegment4 $10.
         CustomerSegment5 $10.
         CustomerSegment6 $10.
         CustomerSegment7 $10.
         CustomerSegment8 $10.
         DaysOfTheWeek $10.
         DepartureTime $10.
         EndDate $10.
         FaxNumber1 $25.
         LEI $10.
         LastUpdated $25.
         Latitude $10.
         LegalName $50.
         License $50.
         Longitude $10.
         OpeningDay $10.
         OpeningTime $25.
         OptionalAddressField $25.
         ParkingLocation $10.
         PostCode $10.
         StartDate $10.
         StopName $10.
         StreetName $10.
         TelephoneNumber $25.
         TermsOfUse $50.
         TotalResults $10.
         TownName $25.
         TrademarkID $25.
         TrademarkIPOCode $10.
         UnavailableFinishTime $25.
         UnavailableStartTime $25.
         Record_Count best32.;
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
         RowCnt best32. 
         Count best32. 
         SME_Count best32. 
         AgeRestricted $10. 
         Bank $50. 
         Agreement $150. 
         AnnualBusinessTurnover $10. 
         AnnualBusinessTurnoverCurrency $10. 
         ArrearsTreatment $10. 
         BIC $50. 
         Benefit $10. 
         BenefitDescription $150. 
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
         Record_Count best32.;
		Datalines;
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
