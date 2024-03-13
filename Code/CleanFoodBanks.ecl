// #OPTION('obfuscateOutput',TRUE);
EXPORT CleanFoodBanks:=MODULE
import $,STD;
SHARED Food:=$.File_AllData.FoodBankDS;
SHARED City:=$.BaseCityInfo.BaseInfo;
SHARED Police:=$.File_AllData.PoliceDS;
SHARED Church:=$.File_AllData.ChurchDS;



SHARED FORMATCITY:=$.FORMATWORDS.FORMATCITY_V1;


EXPORT FoodRec:=RECORD
    STRING63 NAME;
    STRING42 STREET;
    UNSIGNED3 ZIP;
    STRING16 City;
    STRING2 State;
    // STRING60 WEBSITE;
    UNSIGNED3 PrimaryFips;
END;

CleanFood:=PROJECT(Food,TRANSFORM(FoodRec,
                                  SELF.NAME:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.food_bank_name)),
                                  SELF.STREET:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.address)),
                                  SELF.ZIP:=(UNSIGNED3)LEFT.zip_code,
                                  SELF.CITY:=FORMATCITY(LEFT.CITY),
                                //   SELF.WEBSITE:=(STD.STR.CleanSpaces(LEFT.web_page)),
                                  SELF.STATE:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.STATE)),
                                  SELF.PrimaryFIPS:=0));


FoodDS1:=JOIN(CleanFood,City,
                STD.STR.ToUpperCase(LEFT.CITY)= STD.STR.ToUpperCase(RIGHT.city)AND
                STD.STR.ToUpperCase(LEFT.STATE)=RIGHT.STATE_ID,TRANSFORM(FoodRec,
                SELF.PrimaryFIPS:=(UNSIGNED3)RIGHT.county_fips,
                SELF:=LEFT
                ),LEFT OUTER,LOOKUP);

// output(FOOdDS(PrimaryFips=0),{City,state});
ds:=DATASET([
    {'CT', 'WALLINGFORD', '09009'},
    {'CT', 'BLOOMFIELD', '09003'},
    {'MA', 'HATFIELD', '25015'},
    {'MA', 'SHREWSBURY', '25027'},
    {'NJ', 'HILLSIDE', '34039'},
    {'NJ', 'PENNSAUKEN', '34007'},
    {'NJ', 'NEPTUNE', '34025'},
    {'FL', 'FT. MYERS', '12071'},               //Manually filled the missing data 
    {'FL', 'FT. PIERCE', '12111'},
    {'GA', 'MIDLAND', '13215'},
    {'AR', 'BETHEL HEIGHTS', '05007'},
    {'AR', 'FT. SMITH', '05131'},
    {'TX', 'FT. WORTH', '48439'}
],{STRING2 STATE,STRING city,UNSIGNED3 county_fips});
FoodDs2:=JOIN(FoodDs1,ds,
               STD.STR.ToUpperCase(LEFT.CITY)= STD.STR.ToUpperCase(RIGHT.city)AND
               LEFT.PrimaryFIPS=0 AND
                STD.STR.ToUpperCase(LEFT.STATE)=RIGHT.STATE,
                TRANSFORM(FoodRec,
                 SELF.PrimaryFIPS:=(UNSIGNED3)RIGHT.county_fips,
                 SELF.NAME:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.name)),
                 SELF.STREET:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.street)),
                 SELF.ZIP:=(UNSIGNED3)LEFT.zip,
                 SELF.CITY:=FORMATCITY(LEFT.CITY),
                // /SELF.WEBSITE:=(STD.STR.CleanSpaces(LEFT.website)),
                 SELF.STATE:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.STATE)),
               ));
// output(FoodDs1);       
// output(FoodDs2);
CleanFoodDs:=FoodDS1(PrimaryFips!=0)+FoodDS2;
// count(FoodDS1);           //201 recs including 13 null primaryfips
// count(CleanFoodDs);       //201 recs including 13 primary fips with proper value

EXPORT writeFOOD:=OUTPUT(CleanFoodDs,,'~SAFE::DWC::OUT::FoodBanks',OVERWRITE);
EXPORT CleanFoodBanksDs:=DATASET('~SAFE::DWC::OUT::FoodBanks',FoodRec,THOR);
END;