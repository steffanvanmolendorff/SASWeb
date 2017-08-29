Libname OBData "C:\inetpub\wwwroot\sasweb\data\perm";
Options MPrint MLogic Symbolgen Source Source2;


%Macro Main();
%Global _APIVisual;
%Let _APIVisual = BCH;
%Put _APIVisual = &_APIVisual;

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
/*	Work.Currency2*/
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
	'BranchIdentification','LegalName','LEI','BIC','ATMAtBranch')));
Run;

%Macro SplitData(Dsn);
Proc Sort Data=Work.BCH
	Out = Work.&Dsn(Keep = Data_Element RowCnt &Dsn);
	By RowCnt;
Run;

Data Work.Latitude(Keep = Bank Data_Element RowCnt Count BCH_Count Latitude)
	Work.Longitude(Keep = Bank Data_Element RowCnt Count BCH_Count Longitude)
	Work.PostCode(Keep = Bank Data_Element RowCnt Count BCH_Count PostCode)
	Work.BranchName(Keep = Bank Data_Element RowCnt Count BCH_Count BranchName)
	Work.StreetName(Keep = Bank Data_Element RowCnt Count BCH_Count StreetName)
	Work.BranchType(Keep = Bank Data_Element RowCnt Count BCH_Count BranchType)
	Work.TownName(Keep = Bank Data_Element RowCnt Count BCH_Count TownName)
	Work.BuildingNumberOrName(Keep = Bank Data_Element RowCnt Count BCH_Count BuildingNumberOrName)
	Work.CountrySubDivision(Keep = Bank Data_Element RowCnt Count BCH_Count CountrySubDivision)
	Work.Country(Keep = Bank Data_Element RowCnt Count BCH_Count Country)
	Work.BranchIdentification(Keep = Bank Data_Element RowCnt Count BCH_Count BranchIdentification)
	Work.LegalName(Keep = Bank Data_Element RowCnt Count BCH_Count LegalName)
	Work.LEI(Keep = Bank Data_Element RowCnt Count BCH_Count LEI)
	Work.BIC(Keep = Bank Data_Element RowCnt Count BCH_Count BIC)
	Work.ATMAtBranch(Keep = Bank Data_Element RowCnt Count BCH_Count ATMAtBranch);

	Length Bank $ 25;

	Set Work.&Dsn;
	By RowCnt;

	If Data_Element = 'LEI' Then Count + 1;

	If Data_Element = 'Latitude' Then 
	Do;
		BCH_Count = Count;
		Latitude = &Dsn;
		Bank = Tranwrd("&Dsn",'_','');
		Output Work.Latitude;
	End;

	If Data_Element = 'Longitude' Then 
	Do;
		BCH_Count = Count;
		Longitude = &Dsn;
		Bank = Tranwrd("&Dsn",'_','');
		Output Work.Longitude;
	End;

	If Data_Element = 'StreetName' Then 
	Do;
		BCH_Count = Count;
		StreetName = &Dsn;
		Bank = Tranwrd("&Dsn",'_','');
		Output Work.StreetName;
	End;

	If Data_Element = 'PostCode' Then 
	Do;
		BCH_Count = Count;
		PostCode = &Dsn;
		Bank = Tranwrd("&Dsn",'_','');
		Output Work.PostCode;
	End;

	If Data_Element = 'TownName' Then 
	Do;
		BCH_Count = Count;
		TownName = &Dsn;
		Bank = Tranwrd("&Dsn",'_','');
		Output Work.TownName;
	End;

	If Data_Element = 'BuildingNumberOrName' Then 
	Do;
		BCH_Count = Count;
		BuildingNumberOrName = &Dsn;
		Bank = Tranwrd("&Dsn",'_','');
		Output Work.BuildingNumberOrName;
	End;

	If Data_Element = 'CountrySubDivision' Then 
	Do;
		BCH_Count = Count;
		CountrySubDivision = &Dsn;
		Bank = Tranwrd("&Dsn",'_','');
		Output Work.CountrySubDivision;
	End;

	If Data_Element = 'Country' Then 
	Do;
		BCH_Count = Count;
		Country = &Dsn;
		Bank = Tranwrd("&Dsn",'_','');
		Output Work.Country;
	End;

	If Data_Element = 'BranchIdentification' Then 
	Do;
		BCH_Count = Count;
		BranchIdentification = &Dsn;
		Bank = Tranwrd("&Dsn",'_','');
		Output Work.BranchIdentification;
	End;

	If Data_Element = 'LegalName' Then 
	Do;
		BCH_Count = Count;
		LegalName = &Dsn;
		Bank = Tranwrd("&Dsn",'_','');
		Output Work.LegalName;
	End;

	If Data_Element = 'LEI' Then 
	Do;
		BCH_Count = Count;
		LEI = &Dsn;
		Bank = Tranwrd("&Dsn",'_','');
		Output Work.LEI;
	End;

	If Data_Element = 'BIC' Then 
	Do;
		BCH_Count = Count;
		BIC = &Dsn;
		Bank = Tranwrd("&Dsn",'_','');
		Output Work.BIC;
	End;

	If Data_Element = 'ATMAtBranch' Then 
	Do;
		BCH_Count = Count;
		ATMAtBranch = &Dsn;
		Bank = Tranwrd("&Dsn",'_','');
		Output Work.ATMAtBranch;
	End;

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
	Work.LegalName
	Work.ATMAtBranch;

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

%Mend Main;
%Main();


/*

Data Work.Test;
	Set OBData.ATM_Geographic(Where=(ATMID = 'LDFCFC11'));

Run;
