#OPTION('obfuscateOutput',TRUE);
import $,STD;

Hospital:=$.CleanHospitals.WriteHosp;
Hospital;

Churches:=$.CleanChurches.WriteChurches;
Churches;

Police:=$.CleanPolicest.WRITEPolice;
Police;

Fire:=$.CleanFireStns.WriteFire;
Fire;

Food:=$.CleanFoodBanks.writeFOOD;
Food;
createfile:=$.AnalyzeSocialFactors.createDS;
createfile;

BaseFile:=$.AnalyzeResources.WriteBaseData;
BaseFile;

