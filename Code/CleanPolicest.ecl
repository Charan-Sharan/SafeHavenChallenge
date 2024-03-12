// #OPTION('obfuscateOutput',TRUE);

import $,STD;
EXPORT CleanPolicest:=MODULE
SHARED police:=$.File_AllData.PoliceDS;
SHARED City:=$.File_AllData.City_DS;

EXPORT policerec:=RECORD
    UNSIGNED3 ID;
    STRING133 NAME;
    STRING80 STREET;
    UNSIGNED3 ZIP;
    STRING29 CITY;
    STRING2 STATE;
    UNSIGNED3 PrimaryFips; 
    STRING14 TELEPHONE;
    // STRING STATUS;       skip all those which are not avilable  23043 available 443-not available
      
   
END;

SHARED CleanPolice:=PROJECT(Police(STD.STR.CleanSpaces(STATUS)!='NOT AVAILABLE'),TRANSFORM(PoliceRec,
                                      SELF.ID:=LEFT.ID,
                                      SELF.NAME:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.NAME)),
                                      SELF.STREET:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.address)),
                                      SELF.ZIP:=(UNSIGNED3)LEFT.ZIP,
                                      SELF.CITY:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.CITY)),
                                      SELF.STATE:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.STATE)),
                                      SELF.PrimaryFIPS:=(UNSIGNED3)LEFT.countyfips,
                                      SELF.TELEPHONE:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.TELEPHONE))
                                      ));
// OUTPUT(CleanPolice);
// OUTPUT(COUNT(CleanPolice)); 
EXPORT WRITEPolice:=OUTPUT(CleanPolice,,'~SAFE::DWC::OUT::PoliceStns',OVERWRITE);
EXPORT CleanPoliceDs:=DATASET('~SAFE::DWC::OUT::PoliceStns',policeRec,THOR);


END;