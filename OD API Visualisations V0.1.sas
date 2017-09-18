Libname OBData "C:\inetpub\wwwroot\sasweb\data\perm";
Options MPrint MLogic Symbolgen Source Source2;


%Macro Main();
%Global _APIVisual;
%Let _APIVisual = PCA;
%Put _APIVisual = &_APIVisual;

*=====================================================================================================
								ATM DATA EXTRACT FOR VISUALISATION
=====================================================================================================;
%If "&_APIVisual" = "ATM" %Then
%Do;

Data Work.ATM;
Length Hierarchy $ 250 
Bank_API $ 8
Data_Element $ 50
RowCnt
P
Count 8
Bank_of_Scotland
Barclays
Danske_Bank
Halifax
HSBC
Lloyds_Bank
Nationwide
Natwest
RBS
Santander
Ulster_Bank $ 250;
Set OBData.CMA9_ATM(Where=(Data_Element in ('Latitude','Longitude','PostCode','ATMID','StreetName','ATMServic',
'Accessibi','TownName','BuildingNumberOrName','CountrySubDivision','Country','MinimumValueDispensed',
'BranchIdentification','LegalName','LEI','BIC','SiteID','Currency1','Currency2','Supported')));
Run;

%Macro SplitData(Dsn);
Proc Sort Data=Work.ATM
Out = Work.&Dsn(Keep = Data_Element RowCnt &Dsn);
By RowCnt;
Run;

Data Work.ATMID(Keep = Bank Data_Element RowCnt Count ATM_Count ATMID)
Work.Latitude(Keep = Bank Data_Element RowCnt Count ATM_Count Latitude)
Work.Longitude(Keep = Bank Data_Element RowCnt Count ATM_Count Longitude)
Work.PostCode(Keep = Bank Data_Element RowCnt Count ATM_Count PostCode)
Work.StreetName(Keep = Bank Data_Element RowCnt Count ATM_Count StreetName)
Work.ATMServices(Keep = Bank Data_Element RowCnt Count ATM_Count ATMServices)
Work.Accessibility(Keep = Bank Data_Element RowCnt Count ATM_Count Accessibility)
Work.TownName(Keep = Bank Data_Element RowCnt Count ATM_Count TownName)
Work.BuildingNumberOrName(Keep = Bank Data_Element RowCnt Count ATM_Count BuildingNumberOrName)
Work.CountrySubDivision(Keep = Bank Data_Element RowCnt Count ATM_Count CountrySubDivision)
Work.Country(Keep = Bank Data_Element RowCnt Count ATM_Count Country)
Work.MinimumValueDispensed(Keep = Bank Data_Element RowCnt Count ATM_Count MinimumValueDispensed)
Work.BranchIdentification(Keep = Bank Data_Element RowCnt Count ATM_Count BranchIdentification)
Work.LegalName(Keep = Bank Data_Element RowCnt Count ATM_Count LegalName)
Work.LEI(Keep = Bank Data_Element RowCnt Count ATM_Count LEI)
Work.BIC(Keep = Bank Data_Element RowCnt Count ATM_Count BIC)
Work.SiteID(Keep = Bank Data_Element RowCnt Count ATM_Count SiteID)
Work.Currency1(Keep = Bank Data_Element RowCnt Count ATM_Count Currency1)
Work.Currency2(Keep = Bank Data_Element RowCnt Count ATM_Count Currency2)
Work.Supported(Keep = Bank Data_Element RowCnt Count ATM_Count Supported);

Length Bank $ 25;

Set Work.&Dsn;
By RowCnt;

If Data_Element = 'ATMID' Then Count + 1;

If Data_Element = 'ATMID' Then 
Do;
ATM_Count = Count;
ATMID = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.ATMID;
End;
If Data_Element = 'Latitude' Then 
Do;
ATM_Count = Count;
Latitude = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.Latitude;
End;
If Data_Element = 'Longitude' Then 
Do;
ATM_Count = Count;
Longitude = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.Longitude;
End;

If Data_Element = 'StreetName' Then 
Do;
ATM_Count = Count;
StreetName = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.StreetName;
End;

If Data_Element = 'PostCode' Then 
Do;
ATM_Count = Count;
PostCode = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.PostCode;
End;

If Data_Element = 'ATMServic' Then 
Do;
ATM_Count = Count;
ATMServices = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.ATMServices;
End;

If Data_Element = 'Accessibi' Then 
Do;
ATM_Count = Count;
Accessibility = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.Accessibility;
End;

If Data_Element = 'TownName' Then 
Do;
ATM_Count = Count;
TownName = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.TownName;
End;

If Data_Element = 'BuildingNumberOrName' Then 
Do;
ATM_Count = Count;
BuildingNumberOrName = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.BuildingNumberOrName;
End;

If Data_Element = 'CountrySubDivision' Then 
Do;
ATM_Count = Count;
CountrySubDivision = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.CountrySubDivision;
End;

If Data_Element = 'Country' Then 
Do;
ATM_Count = Count;
Country = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.Country;
End;

If Data_Element = 'MinimumValueDispensed' Then 
Do;
ATM_Count = Count;
If MinimumValueDispensed Ne '' then MinimumValueDispensed = Substr(&Dsn,2);
Bank = Tranwrd("&Dsn",'_','');
Output Work.MinimumValueDispensed;
End;

If Data_Element = 'BranchIdentification' Then 
Do;
ATM_Count = Count;
BranchIdentification = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.BranchIdentification;
End;

If Data_Element = 'LegalName' Then 
Do;
ATM_Count = Count;
LegalName = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.LegalName;
End;

If Data_Element = 'LEI' Then 
Do;
ATM_Count = Count;
LEI = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.LEI;
End;

If Data_Element = 'BIC' Then 
Do;
ATM_Count = Count;
BIC = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.BIC;
End;

If Data_Element = 'SiteID' Then 
Do;
ATM_Count = Count;
SiteID = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.SiteID;
End;

If Data_Element = 'Currency1' Then 
Do;
ATM_Count = Count;
Currency1 = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.Currency1;
End;

If Data_Element = 'Currency2' Then 
Do;
ATM_Count = Count;
Currency2 = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.Currency2;
End;

If Data_Element = 'Supported' Then 
Do;
ATM_Count = Count;
Supported = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.Supported;
End;

Run;

Data Work.&Dsn;
Merge Work.ATMID
Work.Latitude
Work.Longitude
Work.StreetName
Work.PostCode
Work.ATMServices
Work.Accessibility
Work.TownName
Work.BuildingNumberOrName
Work.CountrySubDivision
Work.Country
Work.MinimumValueDispensed
Work.BranchIdentification
Work.LegalName
Work.LEI
Work.BIC
Work.SiteID
Work.Currency1
Work.Supported;

By ATM_Count;
Run;

%Mend SplitData;
%SplitData(Bank_of_Scotland);
%SplitData(Barclays);
%SplitData(Danske_Bank);
%SplitData(Halifax);
%SplitData(HSBC);
%SplitData(Lloyds_Bank);
%SplitData(Nationwide);
%SplitData(Natwest);
%SplitData(RBS);
%SplitData(Santander);
%SplitData(Ulster_Bank);


%Let Datasets =;
%Macro ATMS(DsName);
%If %Sysfunc(exist(&DsName)) %Then
%Do;
%Let DSNX = &DsName;
%Put DSNX = &DSNX;

%Let Datasets = &Datasets &DSNX;
%Put Datasets = &Datasets;
%End;
%Mend ATMS;
%ATMS(Bank_of_Scotland);
%ATMS(Barclays);
%ATMS(Danske_Bank);
%ATMS(Halifax);
%ATMS(HSBC);
%ATMS(Lloyds_Bank);
%ATMS(Nationwide);
%ATMS(Natwest);
%ATMS(RBS);
%ATMS(Santander);
%ATMS(Ulster_Bank);

Data OBData.ATM_Geographic;
Set &Datasets;
Run;

%End;



*=====================================================================================================
								BRANCH DATA EXTRACT FOR VISUALISATION
=====================================================================================================;

%If "&_APIVisual" = "BCH" %Then
%Do;


Data Work.BCH;
Length Hierarchy $ 250 
Bank_API $ 8
Data_Element $ 50
RowCnt
P
Count 8
Bank_of_Scotland
Barclays
Danske_Bank
Halifax
HSBC
Lloyds_Bank
Nationwide
Natwest
RBS
Santander
Ulster_Bank $ 250;
Set OBData.CMA9_BCH(Where=(Data_Element in ('Latitude','Longitude','PostCode','BranchName','StreetName','BranchType',
'TownName','BuildingNumberOrName','CountrySubDivision','Country',
'BranchIdentification','LegalName','LEI','BIC','ATMAtBranch','BranchMe','BranchSe','BranchSelfS','BranchSelfServeServic','BranchMedia','OpeningTime',
'ClosingTime')));
Run;

%Macro SplitData(Dsn);
Proc Sort Data=Work.BCH
Out = Work.&Dsn(Keep = Data_Element RowCnt &Dsn);
By RowCnt;
Run;

%Macro Variables(Var);

Data Work.&Var(Keep = Bank Data_Element RowCnt Count BCH_Count &Var); 

Length Bank $ 25;

Set Work.&Dsn;
By RowCnt;

If Data_Element = 'LEI' Then Count + 1;

If Data_Element in ('BranchMe','BranchMedia','BranchMediatedService') Then Data_Element = 'BranchMediatedService';
If Data_Element in ('BranchSe','BranchSelfS','BranchSelfServeServic') Then Data_Element = 'BranchSelfServeService';


If Data_Element = "&Var" Then 
Do;
BCH_Count = Count;
&Var = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.&Var;
End;
%Mend Variables;
%Variables(Latitude);
%Variables(Longitude);
%Variables(StreetName);
%Variables(PostCode);
%Variables(TownName);
%Variables(BuildingNumberOrName);
%Variables(CountrySubDivision);
%Variables(Country);
%Variables(BranchIdentification);
%Variables(BranchName);
%Variables(LegalName);
%Variables(LEI);
%Variables(BIC);
%Variables(ATMAtBranch);
%Variables(BranchType);
%Variables(BranchSelfServeService);
%Variables(BranchMediatedService);
%Variables(OpeningTime);
%Variables(ClosingTime);

Run;

Data Work.&Dsn;
Merge Work.LEI
Work.BIC
Work.Latitude
Work.Longitude
Work.StreetName
Work.PostCode
Work.TownName
Work.BuildingNumberOrName
Work.CountrySubDivision
Work.Country
Work.BranchIdentification
Work.BranchName
Work.LegalName
Work.ATMAtBranch
Work.BranchType
Work.BranchSelfServeService
Work.BranchMediatedService
Work.OpeningTime
Work.ClosingTime;

By BCH_Count;
Run;

%Mend SplitData;
%SplitData(Bank_of_Scotland);
%SplitData(Barclays);
%SplitData(Danske_Bank);
%SplitData(Halifax);
%SplitData(HSBC);
%SplitData(Lloyds_Bank);
%SplitData(Nationwide);
%SplitData(Natwest);
%SplitData(RBS);
%SplitData(Santander);
%SplitData(Ulster_Bank);

%Let Datasets =;
%Macro BRANCH(DsName);
%If %Sysfunc(exist(&DsName)) %Then
%Do;
%Let DSNX = &DsName;
%Put DSNX = &DSNX;

%Let Datasets = &Datasets &DSNX;
%Put Datasets = &Datasets;
%End;
%Mend BRANCH;
%BRANCH(Bank_of_Scotland);
%BRANCH(Barclays);
%BRANCH(Danske_Bank);
%BRANCH(Halifax);
%BRANCH(HSBC);
%BRANCH(Lloyds_Bank);
%BRANCH(Nationwide);
%BRANCH(Natwest);
%BRANCH(RBS);
%BRANCH(Santander);
%BRANCH(Ulster_Bank);

Data OBData.BCH_Geographic;
Set &Datasets;
Run;

%End;


*=====================================================================================================
								PCA DATA EXTRACT FOR VISUALISATION
=====================================================================================================;
%If "&_APIVisual" = "PCA" %Then
%Do;


Data Work.PCA;
Length Hierarchy $ 250 
Bank_API $ 8
Data_Element $ 50
RowCnt
P
Count 8
Bank_of_Scotland
Barclays
Danske_Bank
Halifax
HSBC
Lloyds_Bank
Nationwide
Natwest
RBS
Santander
Ulster_Bank $ 250;
Set OBData.CMA9_PCA(Where=(Data_Element in ('LastUpdated','ProductName','Produ','LegalName','LEI','BIC',
'MaximumOpeningAmount','Acces','CardT','Contactless','ProductDescription','Mobil','CardNotes','MaximumMonthlyCharge',
'MinimumAge','FeeAmount','InterestNotes','PreviousBankruptcy','FeeMax','FeeMin','Rate','FeeFrequency','FeeType','CardWithdrawalLimit')));
Run;


%Macro SplitData(Dsn);
Proc Sort Data=Work.PCA
Out = Work.&Dsn(Keep = Data_Element RowCnt &Dsn);
By RowCnt;
Run;

%Macro Variables(Var);

Data Work.&Var(Keep = Bank Data_Element RowCnt Count PCA_Count &Var); 

Length Bank $ 25;

Set Work.&Dsn;
By RowCnt;

If Data_Element = 'LEI' Then Count + 1;

If Data_Element in ('Acces') Then Data_Element = 'Access';
If Data_Element in ('CardT') Then Data_Element = 'CardType';
If Data_Element in ('Mobil') Then Data_Element = 'Mobile';


If Data_Element = "&Var" Then 
Do;
PCA_Count = Count;
&Var = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.&Var;
End;
%Mend Variables;
%Variables(LastUpdated);
%Variables(ProductName);
%Variables(ProductDescription);
%Variables(Produ);
%Variables(LegalName);
%Variables(LEI);
%Variables(BIC);
%Variables(MaximumOpeningAmount);
%Variables(Acces);
%Variables(CardT);
%Variables(Contactless);
%Variables(Mobil);
%Variables(CardNotes);
%Variables(MaximumMonthlyCharge);
%Variables(MinimumAge);
%Variables(FeeAmount);
%Variables(InterestNotes);
%Variables(PreviousBankruptcy);
%Variables(FeeMax);
%Variables(FeeMin);
%Variables(Rate);
%Variables(FeeFrequency);
%Variables(FeeType);
%Variables(CardWithdrawalLimit);

Run;

Data Work.&Dsn;
Merge Work.LastUpdated
Work.ProductName
Work.ProductDescription
Work.Produ
Work.LegalName
Work.LEI
Work.BIC
Work.MaximumOpeningAmount
Work.Acces
Work.CardT
Work.Contactless
Work.Mobil
Work.CardNotes
Work.MaximumMonthlyCharge
Work.MinimumAge
Work.FeeAmount
Work.InterestNotes
Work.PreviousBankruptcy
Work.FeeMax
Work.FeeMin
Work.Rate
Work.FeeFrequency
Work.FeeType
Work.CardWithdrawalLimit;

By PCA_Count;
Run;

%Mend SplitData;
%SplitData(Bank_of_Scotland);
%SplitData(Barclays);
%SplitData(Danske_Bank);
%SplitData(Halifax);
%SplitData(HSBC);
%SplitData(Lloyds_Bank);
%SplitData(Nationwide);
%SplitData(Natwest);
%SplitData(RBS);
%SplitData(Santander);
%SplitData(Ulster_Bank);

%Let Datasets =;
%Macro PCA(DsName);
%If %Sysfunc(exist(&DsName)) %Then
%Do;
%Let DSNX = &DsName;
%Put DSNX = &DSNX;

%Let Datasets = &Datasets &DSNX;
%Put Datasets = &Datasets;
%End;
%Mend PCA;
%PCA(Bank_of_Scotland);
%PCA(Barclays);
%PCA(Danske_Bank);
%PCA(Halifax);
%PCA(HSBC);
%PCA(Lloyds_Bank);
%PCA(Nationwide);
%PCA(Natwest);
%PCA(RBS);
%PCA(Santander);
%PCA(Ulster_Bank);

Data OBData.PCA_Geographic;
Set &Datasets;
Run;

%End;




*=====================================================================================================
								BCA DATA EXTRACT FOR VISUALISATION
=====================================================================================================;
%If "&_APIVisual" = "BCA" %Then
%Do;


Data Work.BCA;
Length Hierarchy $ 250 
Bank_API $ 8
Data_Element $ 50
RowCnt
P
Count 8
Bank_of_Scotland
Barclays
Danske_Bank
Halifax
HSBC
Lloyds_Bank
Nationwide
Natwest
RBS
Santander
Ulster_Bank $ 250;
Set OBData.CMA9_BCA/*(Where=(Data_Element in ('LastUpdated','ProductName','Produ','LegalName','LEI','BIC',
'MaximumOpeningAmount','Acces','CardT','Contactless','ProductDescription','Mobil','CardNotes','MaximumMonthlyCharge','ItemCharge'
'MinimumAge','FeeAmount','InterestNotes','PreviousBankruptcy','FeeMax','FeeMin','Rate','FeeFrequency','FeeType',
'FeeRate','CardWithdrawalLimit','MinimumAge','MaximumAge','MonthlyCharge')))*/;
Run;

%Macro SplitData(Dsn);
Proc Sort Data=Work.BCA
Out = Work.&Dsn(Keep = Data_Element RowCnt &Dsn);
By RowCnt;
Run;

%Macro Variables(Var);

Data Work.&Var(Keep = Bank Data_Element RowCnt Count BCA_Count &Var); 

Length Bank $ 25;

Set Work.&Dsn;
By RowCnt;

If Data_Element = 'LEI' Then Count + 1;

If Data_Element in ('Acces') Then Data_Element = 'Access';
If Data_Element in ('CardT') Then Data_Element = 'CardType';
If Data_Element in ('Mobil') Then Data_Element = 'Mobile';


If Data_Element = "&Var" Then 
Do;
BCA_Count = Count;
&Var = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.&Var;
End;
%Mend Variables;
%Variables(LastUpdated);
%Variables(ProductName);
%Variables(ProductDescription);
%Variables(Produ);
%Variables(LegalName);
%Variables(LEI);
%Variables(BIC);
%Variables(MaximumOpeningAmount);
%Variables(Acces);
%Variables(CardT);
%Variables(Contactless);
%Variables(Mobil);
%Variables(CardNotes);
%Variables(MaximumMonthlyCharge);
%Variables(MinimumAge);
%Variables(FeeAmount);
%Variables(InterestNotes);
%Variables(PreviousBankruptcy);
%Variables(FeeMax);
%Variables(FeeMin);
%Variables(Rate);
%Variables(FeeFrequency);
%Variables(FeeType);
%Variables(CardWithdrawalLimit);
%Variables(FeeRate);
%Variables(CardWithdrawalLimit);
%Variables(MinimumAge);
%Variables(MaximumAge);
%Variables(MonthlyCharge);
Run;

Data Work.&Dsn;
Merge Work.LastUpdated
Work.ProductName
Work.ProductDescription
Work.Produ
Work.LegalName
Work.LEI
Work.BIC
Work.MaximumOpeningAmount
Work.Acces
Work.CardT
Work.Contactless
Work.Mobil
Work.CardNotes
Work.MaximumMonthlyCharge
Work.MinimumAge
Work.FeeAmount
Work.InterestNotes
Work.PreviousBankruptcy
Work.FeeMax
Work.FeeMin
Work.Rate
Work.FeeFrequency
Work.FeeType
Work.CardWithdrawalLimit
Work.CardWithdrawalLimit
Work.FeeRate
Work.CardWithdrawalLimit
Work.MinimumAge
Work.MaximumAge
Work.MonthlyCharge;

By BCA_Count;
Run;

%Mend SplitData;
%SplitData(Bank_of_Scotland);
%SplitData(Barclays);
%SplitData(Danske_Bank);
%SplitData(Halifax);
%SplitData(HSBC);
%SplitData(Lloyds_Bank);
%SplitData(Nationwide);
%SplitData(Natwest);
%SplitData(RBS);
%SplitData(Santander);
%SplitData(Ulster_Bank);

%Let Datasets =;
%Macro BCA(DsName);
%If %Sysfunc(exist(&DsName)) %Then
%Do;
%Let DSNX = &DsName;
%Put DSNX = &DSNX;

%Let Datasets = &Datasets &DSNX;
%Put Datasets = &Datasets;
%End;
%Mend BCA;
%BCA(Bank_of_Scotland);
%BCA(Barclays);
%BCA(Danske_Bank);
%BCA(Halifax);
%BCA(HSBC);
%BCA(Lloyds_Bank);
%BCA(Nationwide);
%BCA(Natwest);
%BCA(RBS);
%BCA(Santander);
%BCA(Ulster_Bank);

Data OBData.BCA_Geographic;
Set &Datasets;
Run;

%End;


*=====================================================================================================
								CCC DATA EXTRACT FOR VISUALISATION
=====================================================================================================;
%If "&_APIVisual" = "CCC" %Then
%Do;

Data Work.CCC;
Length Hierarchy $ 250 
Bank_API $ 8
Data_Element $ 50
RowCnt
P
Count 8
Bank_of_Ireland
Barclays
HSBC
Lloyds_Bank
Natwest
RBS
Santander $ 250;
Set OBData.CMA9_CCC(Where=(Data_Element in ('LEI','BIC','LegalName','ProductName','ProductType','Produ','ProductIdentifier','PaymentHoliday',
'MinimumCreditLimit','RepaymentFrequency','APRRate','PurchaseRate','CashAdvanceRate','CardScheme',
'AnnualFeeAmount','MinimumRepaymentPercentage','MinimumRepaymentAmount','PaymentDaysAfterStatement','MinimumLendingAmount','AnnualBusinessTurnover',
'MinimumAge','ExchangeRateAdjustment','NonSterlingTransactionFeeRate','NonSterlingCashFeeRate','BenefitValue','MinimumCriteria','MaximumCriteria')));
Run;

%Macro SplitData(Dsn);
Proc Sort Data=Work.CCC
Out = Work.&Dsn(Keep = Data_Element RowCnt &Dsn);
By RowCnt;
Run;

%Macro Variables(Var);

Data Work.&Var(Keep = Bank Data_Element RowCnt Count CCC_Count &Var); 

Length Bank $ 25;

Set Work.&Dsn;
By RowCnt;

If Data_Element = 'LEI' Then Count + 1;

If Data_Element = "&Var" Then 
Do;
CCC_Count = Count;
&Var = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.&Var;
End;
%Mend Variables;
%Variables(LEI);
%Variables(BIC);
%Variables(LegalName);
%Variables(ProductName);
%Variables(ProductType);
%Variables(Produ);
%Variables(ProductIdentifier);
%Variables(PaymentHoliday);
%Variables(MinimumCreditLimit);
%Variables(RepaymentFrequency);
%Variables(APRRate);
%Variables(PurchaseRate);
%Variables(CashAdvanceRate);
%Variables(CardScheme);
%Variables(AnnualFeeAmount);
%Variables(MinimumRepaymentPercentage);
%Variables(MinimumRepaymentAmount);
%Variables(PaymentDaysAfterStatement);
%Variables(MinimumLendingAmount);
%Variables(AnnualBusinessTurnover);
%Variables(MinimumAge);
%Variables(ExchangeRateAdjustment);
%Variables(NonSterlingTransactionFeeRate);
%Variables(NonSterlingCashFeeRate);
%Variables(BenefitValue);
%Variables(MinimumCriteria);
%Variables(MaximumCriteria);
Run;

Data Work.&Dsn;
Merge Work.LEI
Work.BIC
Work.LegalName
Work.ProductName
Work.ProductType
Work.Produ
Work.ProductIdentifier
Work.PaymentHoliday
Work.MinimumCreditLimit
Work.RepaymentFrequency
Work.APRRate
Work.PurchaseRate
Work.CashAdvanceRate
Work.CardScheme
Work.AnnualFeeAmount
Work.MinimumRepaymentPercentage
Work.MinimumRepaymentAmount
Work.PaymentDaysAfterStatement
Work.MinimumLendingAmount
Work.AnnualBusinessTurnover
Work.MinimumAge
Work.ExchangeRateAdjustment
Work.NonSterlingTransactionFeeRate
Work.NonSterlingCashFeeRate
Work.BenefitValue
Work.MinimumCriteria
Work.MaximumCriteria;
By CCC_Count;
Run;

%Mend SplitData;
%SplitData(Bank_of_Ireland);
%SplitData(Barclays);
%SplitData(HSBC);
%SplitData(Lloyds_Bank);
%SplitData(Natwest);
%SplitData(RBS);
%SplitData(Santander);

%Let Datasets =;
%Macro CCC(DsName);
%If %Sysfunc(exist(&DsName)) %Then
%Do;
%Let DSNX = &DsName;
%Put DSNX = &DSNX;

%Let Datasets = &Datasets &DSNX;
%Put Datasets = &Datasets;
%End;
%Mend CCC;
%CCC(Bank_of_Ireland);
%CCC(Barclays);
%CCC(HSBC);
%CCC(Lloyds_Bank);
%CCC(Natwest);
%CCC(RBS);
%CCC(Santander);

Data OBData.CCC_Geographic;
Set &Datasets;
Run;

%End;


*=====================================================================================================
								SME DATA EXTRACT FOR VISUALISATION
=====================================================================================================;
%If "&_APIVisual" = "SME" %Then
%Do;

Data Work.SME;
Length Hierarchy $ 250 
Bank_API $ 8
Data_Element $ 50
RowCnt
P
Count 8
Bank_of_Ireland
Bank_of_Scotland
Barclays
Danske_Bank
First_Trust_Bank
HSBC
Lloyds_Bank
Natwest
RBS
Santander 
Ulster_Bank $ 250;
Set OBData.CMA9_SME(Where=(Data_Element in ('LEI','BIC','LegalName','ProductName','ProductTypeName','Produ','FeeMin','ProductDescription',
'Custo','FeeAmount','SizeIncrement','ProductSubType','LoanLengthIncrement','MinimumLoanTerm','MaximumLoanTerm','MinimumLoanAmount',
'MaximumLoanAmount','PaymentHoliday','Repayment','LoanSizeBandLower','LoanLengthIncrementLower','LoanLengthIncrementUpper',
'IndicativeRate','RateComaprisonType','Negotiable','IsThisAnInterestOnlyLoan')));
Run;

%Macro SplitData(Dsn);
Proc Sort Data=Work.SME
Out = Work.&Dsn(Keep = Data_Element RowCnt &Dsn);
By RowCnt;
Run;

%Macro Variables(Var);

Data Work.&Var(Keep = Bank Data_Element RowCnt Count SME_Count &Var); 

Length Bank $ 25;

Set Work.&Dsn;
By RowCnt;

If Data_Element = 'LEI' Then Count + 1;

If Data_Element = "&Var" Then 
Do;
SME_Count = Count;
&Var = &Dsn;
Bank = Tranwrd("&Dsn",'_','');
Output Work.&Var;
End;
%Mend Variables;
%Variables(LEI);
%Variables(BIC);
%Variables(LegalName);
%Variables(ProductName);
%Variables(ProductTypeName);
%Variables(Produ);
%Variables(FeeMin);
%Variables(ProductDescription);
%Variables(Custo);
%Variables(FeeAmount);
%Variables(SizeIncrement);
%Variables(ProductSubType);
%Variables(LoanLengthIncrement);
%Variables(MinimumLoanTerm);
%Variables(MaximumLoanTerm);
%Variables(MinimumLoanAmount);
%Variables(MaximumLoanAmount);
%Variables(PaymentHoliday);
%Variables(Repayment);
%Variables(LoanSizeBandLower);
%Variables(LoanLengthIncrementLower);
%Variables(LoanLengthIncrementUpper);
%Variables(IndicativeRate);
%Variables(RateComaprisonType);
%Variables(Negotiable);
%Variables(IsThisAnInterestOnlyLoan);
Run;

Data Work.&Dsn;
Merge Work.LEI
Work.BIC
Work.LegalName
Work.ProductName
Work.ProductTypeName
Work.Produ
Work.FeeMin
Work.ProductDescription
Work.Custo
Work.FeeAmount
Work.SizeIncrement
Work.ProductSubType
Work.LoanLengthIncrement
Work.MinimumLoanTerm
Work.MaximumLoanTerm
Work.MinimumLoanAmount
Work.MaximumLoanAmount
Work.PaymentHoliday
Work.Repayment
Work.LoanSizeBandLower
Work.LoanLengthIncrementLower
Work.LoanLengthIncrementUpper
Work.IndicativeRate
Work.RateComaprisonType
Work.Negotiable
Work.IsThisAnInterestOnlyLoan;
By SME_Count;
Run;

%Mend SplitData;
%SplitData(Bank_of_Ireland);
%SplitData(Bank_of_Scotland);
%SplitData(Barclays);
%SplitData(Danske_Bank);
%SplitData(First_Trust_Bank);
%SplitData(HSBC);
%SplitData(Lloyds_Bank);
%SplitData(Natwest);
%SplitData(RBS);
%SplitData(Santander);
%SplitData(Ulster_Bank);


%Let Datasets =;
%Macro SME(DsName);
%If %Sysfunc(exist(&DsName)) %Then
%Do;
%Let DSNX = &DsName;
%Put DSNX = &DSNX;

%Let Datasets = &Datasets &DSNX;
%Put Datasets = &Datasets;
%End;
%Mend SME;
%SME(Bank_of_Ireland);
%SME(Bank_of_Scotland);
%SME(Barclays);
%SME(Danske_Bank);
%SME(First_Trust_Bank);
%SME(HSBC);
%SME(Lloyds_Bank);
%SME(Natwest);
%SME(RBS);
%SME(Santander);
%SME(Ulster_Bank);

Data OBData.SME_Geographic;
Set &Datasets;
Run;

%End;
%Mend Main;
%Main();
