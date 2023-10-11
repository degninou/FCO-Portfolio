****The first part of this do file was the code used to clean and merge the Matam IPD, Donka IPD, Matam CR database and the Tiernet databases. Below is the analysis (from around line 2300)


import excel "D:\Users\msfuser\or GUINEA\IPD FU\BDD Master.xlsx", sheet("Matam Hospi") firstrow clear
rename Column1 FOLDER_NUMBER

drop if FOLDER_NUMBER==""
drop Ntel BDDDonka Tiernet Code CentredeSuivi Cohorte Duréedeséjour Statutàladmission  suivivirologique Prisedetraitement dernierCD41an Signesneurologiquesfocaux DiminutiondeconscienceGCS Méningisme Fièvre SignesRespiratoires SignesGIabdominaux Signescutanées Malnutrition Autre Symptomes2semaines Tuberculose Hbdadmission Transfusion GenXpert TBLAM CRAG PL Entretenpsipendanthospitalisa Diagnosticfinalprincipal1 Diagnosticfinalprincipal2 AutresDiagnostics EtiologiedeMortalité CommentairesSpécifications Column2 Column3
drop Sexe Ageamj
drop Numerodevisit

sort FOLDER_NUMBER DatedAdmission
by FOLDER_NUMBER : gen j=_n

rename DatedAdmission DatedAdmissionMatam
rename Datedesortie DatedesortieMatam
rename TypedeSortie TypedeSortieMatam

reshape wide Nom DatedAdmissionMatam DatedesortieMatam  datedinitiation ARV TypedeSortieMatam, i(FOLDER_NUMBER) j(j)

drop Nom2 Nom3 Nom4 Nom5 Nom6
merge 1:m FOLDER_NUMBER using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\DEM.dta", keepusing(PATIENT)

drop if _merge==2
drop _merge

save "D:\Users\msfuser\or GUINEA\IPD FU\Matamhospireshape.dta", replace


import excel "D:\Users\msfuser\or GUINEA\IPD FU\BDD Master.xlsx", sheet("BdD Donka") firstrow clear
drop  BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW BX BY BZ CA CB CC CD CE CF CG CH CI CJ CK CL CM CN CO CP CQ CR CS CT CU CV CW CX CY CZ DA DB DC DD DE DF DG 


drop Outcome
drop outcomedate
drop if FOLDER_NUMBER==""
replace Namematch="y" if Namematch=="Y"

gen deces=0
replace deces=1 if TypedeSortie=="Décédé"
replace Sexe="F" if Sexe=="f"


replace Ageamj="0.75" if Ageamj=="9MOIS"
replace Ageamj="0.6667" if Ageamj=="8 mois"
replace Ageamj="0.5" if Ageamj=="6MOIS"
replace Ageamj="0.33333" if Ageamj=="4 MOIS"
replace Ageamj="2" if Ageamj=="2,41" 
replace Ageamj="1.5" if Ageamj=="18 mois"
replace Ageamj="1.41667" if Ageamj=="17MOIS"
replace Ageamj="1.333" if Ageamj=="16MOIS"
replace Ageamj="1.16667" if Ageamj=="14 MOIS"
replace Ageamj="1.6" if Ageamj=="1,6"
replace Ageamj="1.33" if Ageamj=="1.33"
replace Ageamj="1.58" if Ageamj=="1,58"
replace Ageamj="1.16" if Ageamj=="1,16"
replace Ageamj="1.08333" if Ageamj=="13MOIS"
replace Ageamj="0.08" if Ageamj=="22 jours"
replace Ageamj="1.8" if Ageamj=="22 mois"
replace Ageamj="0.3" if Ageamj=="4 mois"

destring Ageamj, generate(Age)
drop Ageamj

gen Agecat=.
replace Agecat=1 if Age>=0 & Age<5
replace Agecat=2 if Age>=5 & Age<10
replace Agecat=3 if Age>=10 & Age<20
replace Agecat=4 if Age>=20 & Age<30
replace Agecat=5 if Age>=30 & Age<45
replace Agecat=6 if Age>=45 & Age<60
replace Agecat=7 if Age>=60 
replace Agecat=. if Age==.







label define Agecat 1"0-4" 2"5-10" 3"10-19" 4"20-29" 5"30-44" 6"45-59" 7"60+"
label values Agecat Agecat

encode CENTREDEREFERENCE, generate(Centrederef)
encode Cohorte, generate(MSF)
drop CENTREDEREFERENCE Cohorte

replace MSF=. if MSF==1
gen depisté=.
replace depisté=1 if strmatch(Statutàladmission,"*expos*")==1
replace depisté=2 if strmatch(Statutàladmission,"*VIH connu*")==1
replace depisté=3 if strmatch(Statutàladmission,"*VIH dépisté*")==1
replace depisté=. if strmatch(Statutàladmission,"*nconnu*")==1
label define depisté 1"Enfant exposé" 2"VIH connu > 4 semaines" 3"VIH dépisté < 4 semaines" 4"Inconnu"
label values depisté depisté


drop  Statutàladmission
encode DernierCV, generate(lastVL)

replace lastVL=1 if DernierCV=="<40/ND"
replace lastVL=2 if DernierCV==" 40-999"
replace lastVL=3 if DernierCV=="1.000-50.000"
replace lastVL=2 if DernierCV==" <1.000"
replace lastVL=4 if DernierCV==">50.000"

replace lastVL=2 if lastVL==3
drop DernierCV

label define VLCAT 1"<40/ND" 2"40-999" 3"1.000-50.000" 4">50.000"
label values lastVL VLCAT

encode ARVàladmission, generate(ARVadmission)
gen ARVstatut=.

replace ARVadmission=3 if ARVadmission==4


encode datedinitiation, generate(dateinitiation)

replace ARVstatut=2 if ARVadmission==2
replace ARVstatut=1 if ARVadmission==3 & dateinitiation==5
replace ARVstatut=3 if ARVadmission!=2 & dateinitiation==3
replace ARVstatut=4 if ARVadmission!=2 & dateinitiation==4
replace ARVstatut=4 if ARVadmission!=2 & dateinitiation==2


gen ARVsortie=ARVstatut

replace CVàladmission="500" if CVàladmission=="<1.000"
replace CVàladmission="125" if CVàladmission=="<250"
replace CVàladmission="39" if CVàladmission=="<40/ND"
replace CVàladmission="50000" if CVàladmission==">50.000"
replace CVàladmission="39" if CVàladmission=="TND"
replace CVàladmission="39" if CVàladmission=="nd"
replace CVàladmission="39" if CVàladmission=="ND"
replace CVàladmission="500" if CVàladmission=="40-999"
replace CVàladmission="1500" if CVàladmission=="1.000-50.000"


destring CVàladmission, generate(CVadmis) 

replace CVadmis=1 if CVadmis<40
replace CVadmis=2 if CVadmis>=40 & CVadmis<1000
replace CVadmis=3 if CVadmis>=1000 & CVadmis<50000
replace CVadmis=4 if CVadmis>=50000 & CVadmis<500000000
replace CVadmis=. if CVàladmission==""


gen CVcat=.
replace CVcat=0 if CVadmis==1
replace CVcat=0 if CVadmis==2
replace CVcat=1 if CVadmis==3
replace CVcat=1 if CVadmis==4
replace CVcat=. if CVàladmission==""

drop CVàladmission
label values CVadmis VL

gen switch=0 if lastVL==3 & ARVàladmission=="premier ligne" | lastVL==4 & ARVàladmission=="premier ligne" | CVadmis==3 & ARVàladmission=="premier ligne" | CVadmis==4 & ARVàladmission=="premier ligne"
gen init=0


replace ARVsortie=2 if ARVàlasortie=="deuxième ligne"
replace ARVsortie=3 if ARVàlasortie=="premier ligne" & ARVsortie==1
replace ARVsortie=3 if ARVàlasortie=="premier ligne" & ARVsortie==.

replace switch=1 if ARVstatut==4 & ARVsortie==2
replace switch=1 if ARVstatut==3 & ARVsortie==2
replace init=1 if ARVstatut==1 & ARVsortie==3


label define ARVstatut 1"Pas initié" 2"2ieme ligne" 3"<6 mo 1 ligne" 4">6 mo 1 ligne" 5"Inconnu"
label values ARVstatut ARVstatut
label values ARVsortie ARVstatut

drop ARVàladmission
encode NotiondinterruptionsdesARV, generate(interruption)
drop NotiondinterruptionsdesARV
replace interruption=. if interruption==1

encode Temperatureàladmission380, generate(temp)
replace temp=. if temp==1

drop Temperatureàladmission380

encode Signescutanées, generate(signcutanées)
replace signcutanées=. if signcutanées==1

encode SignesRespiratoires, generate(signresp)
replace signresp=. if signresp==1

drop SignesRespiratoires
encode Malnutrition , generate(malnut)
replace malnut=. if malnut==1


encode SignesGIabdominaux , generate(signesGI)
replace signesGI=. if signesGI==1

drop SignesGIabdominaux

encode DiminutiondeconscienceGCS, generate(GCS)
replace GCS=. if GCS==3

drop DiminutiondeconscienceGCS

encode Signesmeningés , generate(meninges)
replace meninges=. if meninges==1

drop Signesmeningés

encode Signesneurologiquesfocaux , generate(signesneuro)
replace signesneuro=. if signesneuro==1
replace signesneuro=3 if signesneuro==4

drop Signesneurologiquesfocaux

encode Symptomes2semaines, generate(symp2sem)
replace symp2sem=. if symp2sem==1

drop Symptomes2semaines

gen LAMdone=.
gen LAM=.
replace LAMdone=0 if TBLAM=="Pas fait"
replace LAMdone=0 if TBLAM=="pas fait"
replace LAMdone=1 if TBLAM=="Pos."
replace LAMdone=1 if TBLAM=="Neg."
replace LAM=1 if TBLAM=="Pos."
replace LAM=0 if TBLAM=="Neg."

label define test 0"pas fait" 1"fait"
label values LAMdone test

drop TBLAM

label define lab 0"Neg" 1"Pos"
label values LAM lab

replace CD4àladmission="" if CD4àladmission=="INCONNUE"
replace CD4àladmission="" if CD4àladmission=="PAS FAIT"
replace CD4àladmission="" if CD4àladmission=="pas fait"
replace CD4àladmission="" if CD4àladmission=="Pas Fait"

destring CD4àladmission, generate(CD4admis) 

drop CD4àladmission

gen CD4cat=.
replace CD4cat=1 if CD4admis>=0 & CD4admis<100
replace CD4cat=2 if CD4admis>=100 & CD4admis<200
replace CD4cat=3 if CD4admis>=200 & CD4admis<350
replace CD4cat=4 if CD4admis>=350 & CD4admis<10000

gen CD4cat2=.
replace CD4cat2=1 if CD4admis>=0 & CD4admis<50
replace CD4cat2=2 if CD4admis>=50 & CD4admis<100
replace CD4cat2=3 if CD4admis>=100 & CD4admis<200
replace CD4cat2=4 if CD4admis>=200 & CD4admis<350
replace CD4cat2=5 if CD4admis>=350 & CD4admis<500
replace CD4cat2=6 if CD4admis>=500 & CD4admis<100000

label define CD4cat 1"<100" 2"100-199" 3"200-349" 4">350"
label values CD4cat CD4cat

label define CD4cat2 1"<50" 2"50-99" 3"100-199" 4"200-349" 5"350-499" 6">500"
label values CD4cat2 CD4cat2

gen Xpertdone=.
gen Xpert=.
replace Xpertdone=0 if GenXpert=="Pas fait"
replace Xpertdone=0 if GenXpert=="Fait avant"
replace Xpertdone=1 if GenXpert=="T+, RR"
replace Xpertdone=1 if GenXpert=="T+, RS"
replace Xpertdone=1 if GenXpert=="T-"
replace Xpertdone=1 if GenXpert=="Fait"
replace Xpertdone=1 if GenXpert=="Fait "

label values Xpertdone test

label values Xpert lab
replace Xpert=1 if GenXpert=="T+, RR"
replace Xpert=1 if GenXpert=="T+, RS"
replace Xpert=0 if GenXpert=="T-"


drop GenXpert
gen Cragsang=.
gen Cragsangdone=.
gen CragLCR=.
gen CragLCRdone=.

replace Cragsang=0 if CRAGSANG=="Neg."
replace Cragsang=1 if CRAGSANG=="Pos."
replace Cragsangdone=1 if CRAGSANG=="Pos."
replace Cragsangdone=1 if CRAGSANG=="Neg."
replace Cragsangdone=0 if CRAGSANG=="Pas fait"
replace Cragsangdone=0 if CRAGSANG=="pas fait"

drop CRAGSANG

replace CragLCR=0 if CRAGLCR=="Neg."
replace CragLCR=1 if CRAGLCR=="Pos."
replace CragLCR=1 if CRAGLCR=="Pos"

replace CragLCRdone=1 if CRAGLCR=="Neg."
replace CragLCRdone=1 if CRAGLCR=="Pos."
replace CragLCRdone=1 if CRAGLCR=="Pos"
replace CragLCRdone=0 if CRAGLCR=="Pas fait"
label values CragLCRdone test
label values Cragsangdone test
label values Cragsang lab
label values CragLCR lab

drop CRAGLCR

encode Entretenpsi, generate(PSI)
replace PSI=2 if PSI==4
replace PSI=3 if PSI==5
replace PSI=. if PSI==1

drop Entretenpsi

encode TypedeSortie, generate(Sortie)

drop TypedeSortie

*gen mois=month(DatedAdmission)
*gen semaine=week(DatedAdmission)
*gen année=year(DatedAdmission)

*sort Foldernumber DatedAdmission
*bys Foldernumber: gen numvisc=_n

*gsort Foldernumber -DatedAdmission
*bys Foldernumber: gen numvisd=_n

encode Sexe, generate(Sex)
drop Sexe

drop if  DatedAdmission <d(01/08/2017) 




sort FOLDER_NUMBER DatedAdmission
by FOLDER_NUMBER : gen j=_n
sort FOLDER_NUMBER DatedAdmission
by FOLDER_NUMBER : gen numberhosp=_N

drop Ntel  
drop Code  Column4 Column5  

*drop Namematch Cohorte
*drop IsitintheBDDCR 

*generate datesortie = date(Datedesortie, "MDY")

drop  datedinitiation

format Datedesortie %td
format DatedAdmission %td


gen anémie=0
gen Autre=0
gen CandidOeso=0
gen Diarr=0
gen Encéphalite=0
gen Gale=0
gen Hépatite=0
gen Insuffcardiaque=0
gen Insuffrénale=0
gen IRIS=0
gen Meningitecryp=0
gen Meningitebact=0
gen Malnut=0
gen Paludisme=0
gen PCP=0
gen Pneumbact=0
gen Sepsis=0
gen SK=0
gen TypeTB=0
gen Toxoplasmose=0


encode TableaudeDCD, generate(RaisDCD)
gen Diagmaj=Diagnosticfinalprincipal1
replace anémie=1 if strmatch(Diagnosticfinalprincipal1,"*némie*")==1
replace Diagmaj="Anémie" if strmatch(Diagnosticfinalprincipal1,"*némie*")==1
replace Autre=1 if strmatch(Diagnosticfinalprincipal1,"*Autre*")==1
replace Autre=1 if strmatch(Diagnosticfinalprincipal1,"*AVC*")==1
replace CandidOeso=1 if strmatch(Diagnosticfinalprincipal1,"*Candidiose Oesophagienne*")==1
replace Autre=1 if strmatch(Diagnosticfinalprincipal1,"*Cholécystite, cholangite, syndrome de*")==1
replace Diarr=1 if strmatch(Diagnosticfinalprincipal1,"*Diarrhée NS*")==1
replace Diarr=1 if strmatch(Diagnosticfinalprincipal1,"*Diarrhée NS chronique*")==1
replace Diarr=1 if strmatch(Diagnosticfinalprincipal1,"*Diarrhée S*")==1
replace Diagmaj="Diarrhée" if strmatch(Diagnosticfinalprincipal1,"*Diarrhée S*")==1
replace Diagmaj="Diarrhée" if strmatch(Diagnosticfinalprincipal1,"*Diarrhée NS chronique*")==1
replace Diagmaj="Diarrhée" if strmatch(Diagnosticfinalprincipal1,"*Diarrhée NS*")==1
replace Encéphalite=1 if strmatch(Diagnosticfinalprincipal1,"*Encéphalite à VIH*")==1
replace Gale=1 if strmatch(Diagnosticfinalprincipal1,"*Gale*")==1
replace Hépatite=1 if strmatch(Diagnosticfinalprincipal1,"*Hépatite medicamenteuse où toxique*")==1
replace Hépatite=1 if strmatch(Diagnosticfinalprincipal1,"*Hépatite virale*")==1
replace Diagmaj="Hépatite" if strmatch(Diagnosticfinalprincipal1,"*Hépatite medicamenteuse où toxique*")==1
replace Diagmaj="Hépatite" if strmatch(Diagnosticfinalprincipal1,"*Hépatite virale*")==1
replace Insuffcardiaque=1 if strmatch(Diagnosticfinalprincipal1,"*Insuffisance cardiaque*")==1
replace Insuffrénale=1 if strmatch(Diagnosticfinalprincipal1,"*Insuffisance rénale aigue*")==1
replace Insuffrénale=1 if strmatch(Diagnosticfinalprincipal1,"*Insuffisance rénale chronique*")==1
replace Diagmaj="Insuffrénale" if strmatch(Diagnosticfinalprincipal1,"*Insuffisance rénale aigue*")==1
replace Diagmaj="Insuffrénale" if strmatch(Diagnosticfinalprincipal1,"*Insuffisance rénale chronique*")==1
replace IRIS=1 if strmatch(Diagnosticfinalprincipal1,"*IRIS*")==1
replace Meningitecryp=1 if strmatch(Diagnosticfinalprincipal1,"*Méningite à cryptococque*")==1
replace Meningitebact=2 if strmatch(Diagnosticfinalprincipal1,"*Meningite bactérienne*")==1
replace Malnut=1 if strmatch(Diagnosticfinalprincipal1,"*alnutrition*")==1
replace Autre=1 if strmatch(Diagnosticfinalprincipal1,"*MST*")==1
replace Autre=1 if strmatch(Diagnosticfinalprincipal1,"*Mycose cutané*")==1
replace Autre=1 if strmatch(Diagnosticfinalprincipal1,"*Neuropathies périphériques : polyradi*")==1
replace Paludisme=1 if strmatch(Diagnosticfinalprincipal1,"*Paludisme*")==1
replace PCP=1 if strmatch(Diagnosticfinalprincipal1,"*PCP*")==1
replace Pneumbact=1 if strmatch(Diagnosticfinalprincipal1,"*Pneumonie*")==1
replace Pneumbact=1 if strmatch(Diagnosticfinalprincipal1,"*Pneumonie bacterienne*")==1
replace Pneumbact=1 if strmatch(Diagnosticfinalprincipal1,"*Pneumonie virale*")==1
replace Diagmaj="Pneumbact" if strmatch(Diagnosticfinalprincipal1,"*Pneumonie*")==1
replace Diagmaj="Pneumbact" if strmatch(Diagnosticfinalprincipal1,"*Pneumonie bacterienne*")==1
replace Diagmaj="Pneumbact" if strmatch(Diagnosticfinalprincipal1,"*Pneumonie virale*")==1
replace Autre=1 if strmatch(Diagnosticfinalprincipal1,"*Pyelonephrite*")==1
replace Sepsis=1 if strmatch(Diagnosticfinalprincipal1,"*Sepsis sévère*")==1
replace SK=1 if strmatch(Diagnosticfinalprincipal1,"*Sarcome de Kaposi*")==1
replace SK=1 if strmatch(Diagnosticfinalprincipal1,"*Sarcome de Kaposi (Peau) sans signes*")==1
replace SK=1 if strmatch(Diagnosticfinalprincipal1,"*Sarcome de Kaposi sévère/intestinal/*")==1
replace Diagmaj="SK" if strmatch(Diagnosticfinalprincipal1,"*Sarcome de Kaposi*")==1
replace Diagmaj="SK" if strmatch(Diagnosticfinalprincipal1,"*Sarcome de Kaposi (Peau) sans signes*")==1
replace Diagmaj="SK" if strmatch(Diagnosticfinalprincipal1,"*Sarcome de Kaposi sévère/intestinal/*")==1

replace TypeTB=6 if strmatch(Diagnosticfinalprincipal1,"*Mise au point d'une TB suspecté*")==1
replace TypeTB=6 if strmatch(Diagnosticfinalprincipal1,"*TB sous traitement*")==1
replace TypeTB=3 if strmatch(Diagnosticfinalprincipal1,"*Tuberculose abdominale (nouveau diagn*")==1
replace TypeTB=4 if strmatch(Diagnosticfinalprincipal1,"*Tuberculose cérébrale (nouveau diagno*")==1
replace TypeTB=5 if strmatch(Diagnosticfinalprincipal1,"*Tuberculose cliniquement diagnostiqué*")==1
replace TypeTB=6 if strmatch(Diagnosticfinalprincipal1,"*Tuberculose dissiminé (nouveau diagno*")==1
replace TypeTB=3 if strmatch(Diagnosticfinalprincipal1,"*Tuberculose extrapulmonaire autre (no*")==1
replace TypeTB=6 if strmatch(Diagnosticfinalprincipal1,"*Tuberculose IRS*")==1
replace IRIS=1 if strmatch(Diagnosticfinalprincipal1,"*Tuberculose IRS*")==1
replace TypeTB=9 if strmatch(Diagnosticfinalprincipal1,"*Tuberculose pulmonaire (nouveau diagn*")==1
replace TypeTB=6 if strmatch(Diagnosticfinalprincipal1,"*Tuberculose rechute*")==1
replace TypeTB=11 if strmatch(Diagnosticfinalprincipal1,"*Tuberculose résistant*")==1
replace Toxoplasmose=1 if strmatch(Diagnosticfinalprincipal1,"*Toxoplasmose*")==1
replace Autre=1 if strmatch(Diagnosticfinalprincipal1,"*Zona*")==1
replace Diagmaj="TB EP" if strmatch(Diagnosticfinalprincipal1,"*Mise au point d'une TB suspecté*")==1
replace Diagmaj="TB EP" if strmatch(Diagnosticfinalprincipal1,"*TB sous traitement*")==1
replace Diagmaj="TB EP" if strmatch(Diagnosticfinalprincipal1,"*Tuberculose abdominale (nouveau diagn*")==1
replace Diagmaj="TB Cerebrale" if strmatch(Diagnosticfinalprincipal1,"*Tuberculose cérébrale (nouveau diagno*")==1
replace Diagmaj="TB EP" if strmatch(Diagnosticfinalprincipal1,"*Tuberculose cliniquement diagnostiqué*")==1
replace Diagmaj="TB EP" if strmatch(Diagnosticfinalprincipal1,"*Tuberculose dissiminé (nouveau diagno*")==1
replace Diagmaj="TB EP" if strmatch(Diagnosticfinalprincipal1,"*Tuberculose extrapulmonaire autre (no*")==1
replace Diagmaj="TB EP" if strmatch(Diagnosticfinalprincipal1,"*Tuberculose IRS*")==1
replace Diagmaj="TB pulm" if strmatch(Diagnosticfinalprincipal1,"*Tuberculose pulmonaire (nouveau diagn*")==1
replace Diagmaj="TB EP" if strmatch(Diagnosticfinalprincipal1,"*Tuberculose rechute*")==1
replace Diagmaj="TB resist" if strmatch(Diagnosticfinalprincipal1,"*Tuberculose résistant*")==1



replace anémie=1 if strmatch(Diagnosticfinalprincipal2,"*némie*")==1
replace Autre=1 if strmatch(Diagnosticfinalprincipal2,"*Autre*")==1

replace CandidOeso=1 if strmatch(Diagnosticfinalprincipal2,"*Candidiose Oesophagienne*")==1
replace Autre=1 if strmatch(Diagnosticfinalprincipal2,"*Cholécystite, cholangite, syndrome de*")==1

replace Diarr=1 if strmatch(Diagnosticfinalprincipal2,"*Diarrhée NS*")==1
replace Diarr=1 if strmatch(Diagnosticfinalprincipal2,"*Diarrhée NS chronique*")==1
replace Diarr=1 if strmatch(Diagnosticfinalprincipal2,"*Diarrhée S*")==1
replace Encéphalite=1 if strmatch(Diagnosticfinalprincipal2,"*Encéphalite à VIH*")==1
replace Gale=1 if strmatch(Diagnosticfinalprincipal2,"*Gale*")==1
replace Hépatite=1 if strmatch(Diagnosticfinalprincipal2,"*Hépatite medicamenteuse où toxique*")==1
replace Hépatite=1 if strmatch(Diagnosticfinalprincipal2,"*Hépatite virale*")==1
replace Insuffcardiaque=1 if strmatch(Diagnosticfinalprincipal2,"*Insuffisance cardiaque*")==1
replace Insuffrénale=1 if strmatch(Diagnosticfinalprincipal2,"*Insuffisance rénale aigue*")==1
replace Insuffrénale=1 if strmatch(Diagnosticfinalprincipal2,"*Insuffisance rénale chronique*")==1
replace IRIS=1 if strmatch(Diagnosticfinalprincipal2,"*IRIS*")==1
replace Meningitecryp=1 if strmatch(Diagnosticfinalprincipal2,"*Méningite à cryptococque*")==1
replace Meningitebact=2 if strmatch(Diagnosticfinalprincipal2,"*Meningite bactérienne*")==1
replace Malnut=1 if strmatch(Diagnosticfinalprincipal2,"*alnutrition*")==1
replace Malnutrition="Oui" if Malnut==1
replace Autre=1 if strmatch(Diagnosticfinalprincipal2,"*MST*")==1
replace Autre=1 if strmatch(Diagnosticfinalprincipal2,"*Mycose cutané*")==1
replace Autre=1 if strmatch(Diagnosticfinalprincipal2,"*Neuropathies périphériques : polyradi*")==1
replace Paludisme=1 if strmatch(Diagnosticfinalprincipal2,"*Paludisme*")==1
replace PCP=1 if strmatch(Diagnosticfinalprincipal2,"*PCP*")==1
replace Pneumbact=1 if strmatch(Diagnosticfinalprincipal2,"*Pneumonie*")==1
replace Pneumbact=1 if strmatch(Diagnosticfinalprincipal2,"*Pneumonie bacterienne*")==1
replace Pneumbact=1 if strmatch(Diagnosticfinalprincipal2,"*Pneumonie virale*")==1
replace Autre=1 if strmatch(Diagnosticfinalprincipal2,"*Pyelonephrite*")==1
replace Sepsis=1 if strmatch(Diagnosticfinalprincipal2,"*Sepsis sévère*")==1
replace SK=1 if strmatch(Diagnosticfinalprincipal2,"*Sarcome de Kaposi*")==1
replace SK=1 if strmatch(Diagnosticfinalprincipal2,"*Sarcome de Kaposi (Peau) sans signes*")==1
replace SK=1 if strmatch(Diagnosticfinalprincipal2,"*Sarcome de Kaposi sévère/intestinal/*")==1
replace TypeTB=6 if strmatch(Diagnosticfinalprincipal2,"*Mise au point d'une TB suspecté*")==1
replace TypeTB=6 if strmatch(Diagnosticfinalprincipal2,"*TB sous traitement*")==1
replace TypeTB=3 if strmatch(Diagnosticfinalprincipal2,"*Tuberculose abdominale (nouveau diagn*")==1
replace TypeTB=4 if strmatch(Diagnosticfinalprincipal2,"*Tuberculose cérébrale (nouveau diagno*")==1
replace TypeTB=5 if strmatch(Diagnosticfinalprincipal2,"*Tuberculose cliniquement diagnostiqué*")==1
replace TypeTB=6 if strmatch(Diagnosticfinalprincipal2,"*Tuberculose dissiminé (nouveau diagno*")==1
replace TypeTB=3 if strmatch(Diagnosticfinalprincipal2,"*Tuberculose extrapulmonaire autre (no*")==1
replace TypeTB=6 if strmatch(Diagnosticfinalprincipal2,"*Tuberculose IRS*")==1
replace IRIS=1 if strmatch(Diagnosticfinalprincipal2,"*Tuberculose IRS*")==1
replace TypeTB=9 if strmatch(Diagnosticfinalprincipal2,"*Tuberculose pulmonaire (nouveau diagn*")==1
replace TypeTB=6 if strmatch(Diagnosticfinalprincipal2,"*Tuberculose rechute*")==1
replace TypeTB=11 if strmatch(Diagnosticfinalprincipal2,"*Tuberculose résistant*")==1
replace Toxoplasmose=1 if strmatch(Diagnosticfinalprincipal2,"*Toxoplasmose*")==1
replace Autre=1 if strmatch(Diagnosticfinalprincipal2,"*Zona*")==1

label define TypeTB 3"TB EP autre" 4"TB cerebrale" 5"TB clinique" 6"TB disseminé" 9"TB pulmonaire" 11"TB resist" 
label values TypeTB TypeTB



replace RaisDCD=2 if RaisDCD==7
replace TableaudeDCD="Choc hypovolémique" if TableaudeDCD=="Shock hypovolémique"


tab Diagmaj if deces==0
edit Diagmaj Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Malnutrition "
edit Diagmaj Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Anémie"
replace Diagmaj=Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Anémie" & Diagnosticfinalprincipal2=="Pneumonie"
replace Diagmaj=Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Anémie" & Diagnosticfinalprincipal2=="Hépatite medicamenteuse où toxique"
replace Diagmaj="Diarrhée" if deces==0 & Diagmaj=="Malnutrition " & Diagnosticfinalprincipal2=="Diarrhée NS"
replace Diagmaj=Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Malnutrition " & Diagnosticfinalprincipal2=="Pneumonie virale"
replace Diagmaj=Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Malnutrition " & Diagnosticfinalprincipal2=="Tuberculose pulmonaire (nouveau diagnostic)"



edit Diagmaj Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Gale"
replace Diagmaj=Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Gale" & Diagnosticfinalprincipal2=="Diarrhée NS"
edit Diagmaj Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Candidiose Oesophagienne"
replace Diagmaj=Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Candidiose Oesophagienne" & Diagnosticfinalprincipal2=="Sepsis sévère"
edit Diagmaj Diagnosticfinalprincipal2 if deces==0 & strmatch(Diagmaj,"*DEG avec tableau d'échec thérapeutiqu*")==1
replace Diagmaj=Diagnosticfinalprincipal2 if deces==0 & strmatch(Diagmaj,"*DEG avec tableau d'échec thérapeutiqu*")==1

edit Diagmaj Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Infection virale "
replace Diagmaj=Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Infection virale " & Diagnosticfinalprincipal2=="Pneumonie virale"
replace Diagmaj=Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Infection virale " & Diagnosticfinalprincipal2=="Tuberculose pulmonaire (nouveau diagnostic)"
edit Diagmaj Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Autre"
replace Diagmaj=Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Autre" & strmatch(Diagnosticfinalprincipal2,"*TB*")==1
replace Diagmaj=Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Autre" & strmatch(Diagnosticfinalprincipal2,"*uber*")==1
replace Diagmaj=Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Autre" & strmatch(Diagnosticfinalprincipal2,"*ané*")==1


edit Diagmaj Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Mise au point d'une TB suspecté "
replace Diagmaj="TB site inconnu" if deces==0 & Diagmaj=="Mise au point d'une TB suspecté " & strmatch(Diagnosticfinalprincipal2,"*TB*")==1

edit Diagmaj Diagnosticfinalprincipal2 if deces==0 & Diagmaj=="Zona "

replace ARVadmission=. if ARVadmission==1
replace dateinitiation=. if dateinitiation==1


tab Diagmaj if TableaudeDCD=="Autre "
edit Diagmaj Diagnosticfinalprincipal2 TableaudeDCD if TableaudeDCD=="Autre " & Diagmaj=="Autre"
replace Diagmaj=Diagnosticfinalprincipal2  if TableaudeDCD=="Autre " & Diagmaj=="Autre" & strmatch(Diagnosticfinalprincipal2,"*uber*")==1


tab Diagmaj if TableaudeDCD=="Choc hypovolémique"
edit Diagmaj Diagnosticfinalprincipal2 TableaudeDCD if TableaudeDCD=="Choc hypovolémique" & Diagmaj=="Méningite à cryptococque"
replace Diagmaj=Diagnosticfinalprincipal2 if TableaudeDCD=="Choc hypovolémique" & Diagmaj=="Candidiose Oesophagienne"
edit Diagmaj Diagnosticfinalprincipal2 TableaudeDCD if TableaudeDCD=="Choc hypovolémique" & Diagmaj=="Malnutrition "

tab Diagmaj if TableaudeDCD=="Détresse respiratoire"

edit Diagmaj Diagnosticfinalprincipal2 if TableaudeDCD=="Détresse respiratoire" & Diagmaj=="Toxoplasmose"
replace Diagmaj=Diagnosticfinalprincipal2 if TableaudeDCD=="Détresse respiratoire" & Diagmaj=="Toxoplasmose" & strmatch(Diagnosticfinalprincipal2,"*uber*")==1
replace Diagmaj=Diagnosticfinalprincipal2 if TableaudeDCD=="Détresse respiratoire" & Diagmaj=="Toxoplasmose" & strmatch(Diagnosticfinalprincipal2,"*Sepsis*")==1
replace Diagmaj=Diagnosticfinalprincipal2 if TableaudeDCD=="Détresse respiratoire" & Diagmaj=="Toxoplasmose" & strmatch(Diagnosticfinalprincipal2,"*nsuffis*")==1

edit Diagmaj Diagnosticfinalprincipal2 if TableaudeDCD=="Détresse respiratoire" & Diagmaj=="Hépatite"
replace Diagmaj=Diagnosticfinalprincipal2 if TableaudeDCD=="Détresse respiratoire" & Diagmaj=="Hépatite"
replace Diagmaj=Diagnosticfinalprincipal2 if TableaudeDCD=="Détresse respiratoire" & Diagmaj=="Encéphalite à VIH"
replace Diagmaj=Diagnosticfinalprincipal2 if TableaudeDCD=="Détresse respiratoire" & Diagmaj=="IRIS"

replace Diagmaj=Diagnosticfinalprincipal2 if TableaudeDCD=="Détresse respiratoire" & Diagmaj=="Candidiose Oesophagienne" & strmatch(Diagnosticfinalprincipal2,"*Malnu*")==1

tab Diagmaj if TableaudeDCD=="Etiologie neurologique suspecté"
replace Diagmaj=Diagnosticfinalprincipal2 if TableaudeDCD=="Etiologie neurologique suspecté" & Diagmaj=="Autre" & strmatch(Diagnosticfinalprincipal2,"*TB*")==1
replace Diagmaj=Diagnosticfinalprincipal2 if TableaudeDCD=="Etiologie neurologique suspecté" & Diagmaj=="Autre" & strmatch(Diagnosticfinalprincipal2,"*uber*")==1
edit Diagmaj Diagnosticfinalprincipal2 if TableaudeDCD=="Etiologie neurologique suspecté" & Diagmaj=="PCP "
replace Diagmaj=Diagnosticfinalprincipal2 if TableaudeDCD=="Etiologie neurologique suspecté" & Diagmaj=="PCP "



gen MSFcat=.
replace MSFcat=2 if CentredeSuivi=="Coléah"
replace MSFcat=2 if CentredeSuivi=="FLAMBOYANT"
replace MSFcat=2 if CentredeSuivi=="Flamboyant"
replace MSFcat=2 if CentredeSuivi=="Gbessia Port"
replace MSFcat=2 if CentredeSuivi=="MATAM"
replace MSFcat=2 if CentredeSuivi=="Matam"
replace MSFcat=2 if CentredeSuivi=="Minière"
replace MSFcat=2 if CentredeSuivi=="Tombolia"
replace MSFcat=2 if CentredeSuivi=="Wanidara"
replace MSFcat=3 if CentredeSuivi=="Autre"
replace MSFcat=3 if CentredeSuivi=="DREAM"
replace MSFcat=3 if CentredeSuivi=="De l`interieur"
replace MSFcat=3 if CentredeSuivi=="Dermato"
replace MSFcat=3 if CentredeSuivi=="Dermato Donka"
replace MSFcat=3 if CentredeSuivi=="Ignace Deen"
replace MSFcat=3 if CentredeSuivi=="Nongo"
replace MSFcat=. if CentredeSuivi==""
replace MSFcat=. if CentredeSuivi=="Pas clair/inconnu"


tab Diagmaj if TableaudeDCD=="Inconnu"

replace TableaudeDCD="Etiologie neurologique suspecté" if TableaudeDCD=="Inconnu" & Diagmaj=="Hépatite"
replace TableaudeDCD="Etiologie neurologique suspecté" if TableaudeDCD=="Inconnu" & Diagmaj=="Hépatite medicamenteuse où toxique"
replace TableaudeDCD="Etiologie neurologique suspecté" if TableaudeDCD=="Inconnu" & Diagmaj=="TB Cerebrale"
replace TableaudeDCD="Etiologie neurologique suspecté" if TableaudeDCD=="Inconnu" & Diagmaj=="TB disseminé"
replace TableaudeDCD="Détresse respiratoire" if TableaudeDCD=="Inconnu" & Diagmaj=="TB pulm"
replace TableaudeDCD="Détresse respiratoire" if TableaudeDCD=="Inconnu" & Diagmaj=="TB resist"
replace TableaudeDCD="Détresse respiratoire" if TableaudeDCD=="Inconnu" & Diagmaj=="Pneumbact"


tab Diagmaj if TableaudeDCD=="Sepsis"
edit Diagmaj Diagnosticfinalprincipal2 if TableaudeDCD=="Sepsis" & Diagmaj=="Toxoplasmose"
replace Diagmaj=Diagnosticfinalprincipal2 if TableaudeDCD=="Sepsis" & Diagmaj=="Toxoplasmose" & strmatch(Diagnosticfinalprincipal2,"*TB*")==1

edit Diagmaj Diagnosticfinalprincipal2 if RaisDCD==1 & Diagmaj=="" 

tab Diagmaj

replace Diagmaj="Autre" if strmatch(Diagmaj,"*AVC*")==1
replace Diagmaj="Autre" if strmatch(Diagmaj,"*Zona*")==1
replace Diagmaj="Anémie" if strmatch(Diagmaj,"*anémie*")==1
replace Diagmaj="Autre" if strmatch(Diagmaj,"*CMV*")==1
replace Diagmaj="Diarrhée" if strmatch(Diagmaj,"*Diarrhée*")==1
replace Diagmaj="TB disseminé" if strmatch(Diagmaj,"*Mise au point d'une TB suspecté *")==1
replace Diagmaj="Insuffrénale" if strmatch(Diagmaj,"*Insuffisance rénale chronique*")==1
replace Diagmaj="Insuffrénale" if strmatch(Diagmaj,"*Insuffisance rénale aigue*")==1
replace Diagmaj="Autre" if strmatch(Diagmaj,"*Infection virale*")==1
replace Diagmaj="Autre" if strmatch(Diagmaj,"*Infection cutanée bactérienne*")==1
replace Diagmaj="Hépatite" if strmatch(Diagmaj,"*Hépatite medicamenteuse où toxique*")==1
replace Diagmaj="Autre" if strmatch(Diagmaj,"*Gale*")==1
replace Diagmaj="Autre" if strmatch(Diagmaj,"*Encéphalite à VIH*")==1
replace Diagmaj="TB EP" if strmatch(Diagmaj,"*TB sous trait*")==1
replace Diagmaj="TB EP" if strmatch(Diagmaj,"*TB site inconnu*")==1
replace Diagmaj="TB EP" if strmatch(Diagmaj,"*erculose dissiminé*")==1
replace Diagmaj="TB EP" if strmatch(Diagmaj,"*culose extrapulmonaire autr*")==1
replace Diagmaj="TB EP" if strmatch(Diagmaj,"*TB abdominal*")==1
replace Diagmaj="TB " if strmatch(Diagmaj,"*Tuberculose rechute*")==1
replace Diagmaj="TB pulm" if strmatch(Diagmaj,"*ulmonaire (nouve*")==1
replace Diagmaj="Pneumbact" if strmatch(Diagmaj,"*Pneumonie*")==1
replace Diagmaj="TB disseminé" if Diagmaj=="TB"
replace Diagmaj="Mengcrypt" if strmatch(Diagmaj,"*Méningite à cryptococque*")==1
replace Diagmaj="Mengbact" if strmatch(Diagmaj,"*Meningite bactérienne*")==1
replace Malnut=1 if Malnutrition=="Oui"

drop Malnutrition
gen autreTB=""
replace autreTB=Diagmaj if TypeTB!=0
replace autreTB=Diagnosticfinalprincipal2 if strmatch(autreTB,"*TB*")==1
replace autreTB="Diarrhée" if strmatch(autreTB,"*Diarrhée*")==1
replace autreTB="Hépatite" if strmatch(autreTB,"*Hépatite medicamenteuse où toxique*")==1
replace autreTB="Autre" if strmatch(autreTB,"*Zona*")==1
replace autreTB="Anémie" if strmatch(autreTB,"*anémie*")==1

replace autreTB="Autre" if strmatch(autreTB,"*Pas clai*")==1
replace autreTB="" if strmatch(autreTB,"*TB*")==1
replace autreTB="" if strmatch(autreTB,"*uberculose *")==1
replace autreTB="Insuffrénale" if strmatch(autreTB,"*rénale*")==1
replace autreTB="Pneumbact" if strmatch(autreTB,"*Pneumonie*")==1
replace autreTB="" if strmatch(autreTB,"*DEG*")==1
replace autreTB="Mengbact" if strmatch(autreTB,"*ngite bacté*")==1
replace autreTB="Mengcrypt" if strmatch(autreTB,"*ngite à cryp*")==1
replace autreTB="SK" if strmatch(autreTB,"*rcome de K*")==1





gen autreToxo=""
replace autreToxo=Diagmaj if Toxoplasmose==1
replace autreToxo=Diagnosticfinalprincipal2 if autreToxo=="Toxoplasmose"
replace autreToxo="TB pulm" if strmatch(autreToxo,"*naire (nouvea*")
replace autreToxo="TB EP autre" if strmatch(autreToxo,"*ose extrapulmona*")
replace autreToxo="TB disseminé" if strmatch(autreToxo,"*e dissiminé (nouve*")
replace autreToxo="TB Cerebrale" if strmatch(autreToxo,"*lose cérébrale (nouvea*")
replace autreToxo="TB disseminé" if strmatch(autreToxo,"*TB sous traitement*")
replace autreToxo="TB disseminé" if strmatch(autreToxo,"*Tuberculose IRS*")
replace autreToxo="TB clinique" if strmatch(autreToxo,"*lose cliniquement di*")
replace autreToxo="Mengbact" if strmatch(autreToxo,"*gite bactéri*")
replace autreToxo="Mengcrypt" if strmatch(autreToxo,"*gite à crypt*")
replace autreToxo="Pneumbact" if strmatch(autreToxo,"*Pneumonie*")
replace autreToxo="SK" if strmatch(autreToxo,"*Sarcome de Kaposi*")
replace autreToxo="" if autreToxo=="Toxoplasmose"

gen autrerenal=""
replace autrerenal=Diagmaj if Insuffrénale==1
replace autrerenal=Diagnosticfinalprincipal2 if autrerenal=="Insuffrénale"
replace autrerenal=Diagnosticfinalprincipal1 if strmatch(autrerenal,"*rénal*")
replace autrerenal="" if strmatch(autrerenal,"*rénal*")
replace autrerenal="TB pulm" if strmatch(autrerenal,"*naire (nouvea*")
replace autrerenal="TB EP autre" if strmatch(autrerenal,"*ose extrapulmona*")
replace autrerenal="TB disseminé" if strmatch(autrerenal,"*e dissiminé (nouve*")
replace autrerenal="TB Cerebrale" if strmatch(autrerenal,"*lose cérébrale (nouvea*")
replace autrerenal="TB disseminé" if strmatch(autrerenal,"*TB sous traitement*")

replace alternativecode="742" if FOLDER_NUMBER=="TBL1592"	
replace alternativecode="513" if FOLDER_NUMBER=="FLB1469M"	

merge m:m FOLDER_NUMBER using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\DEM.dta", keepusing(PATIENT)


**not matches but files were confirmed to exist, therefore referred straight to donka:


*15938
*15938
*16014MAT
*16105MAT
*16137MAT
*16199MAT
rename _merge mergeDEM
drop if mergeDEM==2

save "D:\Users\msfuser\or GUINEA\IPD FU\Donkaanalysis.dta", replace

use "D:\Users\msfuser\or GUINEA\IPD FU\Donkaanalysis.dta", clear
drop Duréedeséjour ARVàlasortie Diagnosticfinalprincipal1 Diagnosticfinalprincipal2 TableaudeDCD deces Agecat Centrederef MSF depisté lastVL ARVadmission ARVstatut dateinitiation ARVsortie CVcat switch init interruption temp signcutanées signresp malnut signesGI GCS meninges signesneuro symp2sem LAMdone LAM CD4cat CD4cat2 Xpertdone Xpert Cragsang Cragsangdone CragLCR CragLCRdone PSI Sortie Sex j numberhosp anémie Autre CandidOeso Diarr Encéphalite Gale Hépatite Insuffcardiaque Insuffrénale IRIS Meningitecryp Meningitebact Malnut Paludisme PCP Pneumbact Sepsis SK TypeTB Toxoplasmose RaisDCD Diagmaj MSFcat autreTB autreToxo autrerenal Age CentredeSuivi dernierCD41an DatedernierCV Signescutanées Hbdadmission CD4admis

rename DatedAdmission date_LABDMY
rename CVadmis LAB_CAT

drop if Namematch=="nm"
drop if Namematch==""
drop if Namematch=="chn"



*drop _merge

drop if Namematch==""


save "D:\Users\msfuser\or GUINEA\IPD FU\Donkalab.dta", replace
*** this is to drop the variables that ultimately we will want to include in the analysis

use "D:\Users\msfuser\or GUINEA\IPD FU\Donkaanalysis.dta", clear

*drop if _merge==2
sort FOLDER_NUMBER DatedAdmission


drop Signescutanées Hbdadmission CD4admis  Duréedeséjour  Diagnosticfinalprincipal1 Diagnosticfinalprincipal2 TableaudeDCD deces Agecat Centrederef MSF depisté lastVL ARVadmission dateinitiation ARVàlasortie CVcat switch init interruption temp signcutanées signresp malnut signesGI GCS meninges signesneuro symp2sem LAMdone LAM CD4cat CD4cat2 Xpertdone Xpert Cragsang Cragsangdone CragLCR CragLCRdone PSI  Age CentredeSuivi dernierCD41an DatedernierCV Sex
drop anémie Autre CandidOeso Diarr Encéphalite Gale Hépatite Insuffcardiaque Insuffrénale IRIS Meningitecryp Meningitebact Malnut Paludisme PCP Pneumbact Sepsis SK TypeTB Toxoplasmose RaisDCD Diagmaj MSFcat autreTB autreToxo autrerenal
drop  NamematchBDDCRR IsitintheBDDCR OutcomeBDDCR Column1 Afterhosp alternativecode D
drop NOM
reshape wide  Namematch  ARVstatut ARVsortie DatedAdmission CVadmis Datedesortie Sortie, i(FOLDER_NUMBER) j(j)



save "D:\Users\msfuser\or GUINEA\IPD FU\Donkareshape.dta", replace
***demographic import
import excel "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\DEM.xlsx", sheet("DEM") firstrow clear

*FOLDER_NUMBER	
*1119	TBL1957 
*replace PATIENT="48cf3956-a034-491a-9293-60c9919ae24a" if PATIENT=="749504e9-731e-4ac8-b20a-a19ff7af9a0f"
*12540	TBL1711 
*replace PATIENT="fc913d80-bef8-40c2-862d-09f8a52ec349" if PATIENT=="51c841ac-87fc-4f10-aecf-416c356b047d"
*14129	TBL1723 
*replace PATIENT="048ddb4e-fd1e-4b8f-b14d-c49eb6ba8774" if PATIENT=="12895791-769d-4788-8ef5-b398a677e21e"
*14641	MIN3538 
*replace PATIENT="58016668-77a7-48df-b4b8-1cccc17e75fb" if PATIENT=="e6edb8c9-0580-4dfe-ac28-545c86e8cac9"
*14656	TBL2056 
*replace PATIENT="0e148d5c-5afa-4f7a-86ea-9293d087ea5f" if PATIENT=="4763cc0e-edcf-46af-a2c8-43d96f71e555"
*14901	FLB2892M 
*replace PATIENT="4c2cdc76-4ac8-4f03-9706-aa0be844c7fd" if PATIENT=="62175593-e3d1-4e76-8cc5-7d44eb177799"
*15061	TBL1822 
*replace PATIENT="b95fda07-20b2-4fb2-94ed-67c4911f6455" if PATIENT=="8a388864-6415-4a83-9e77-f18d113f2d11"
*15513	TBL1753 
*replace PATIENT="6bf22e91-5a14-45b5-a0ef-079891d261ed" if PATIENT=="0aeda05b-7b59-4f07-9a51-a210b159f8be"
*329	    CLY1680M 
*replace PATIENT="84eb14eb-0280-4593-aba3-01b735ee4830" if PATIENT=="e7c58db7-6b3a-4c56-87b2-fb705b91c1bb"
*9378	TBL1640 
*replace PATIENT="7209dc91-ddfa-4708-a18b-e620c260169f" if PATIENT=="39ced0fb-69f5-4111-a514-9476204a310e"

save "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\DEM.dta", replace


*rename FOLDER_NUMBER FOLDER_NUMBER2
*rename FIRST_NAME FIRST_NAME2
*rename SURNAME SURNAME2
*rename OTHER_NUMBER FOLDER_NUMBER
*rename PATIENT PATIENT2


 
*drop if OTHER_NUMBER==""

*save "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\DEMalt.dta", replace

*use "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\DEM.dta", clear
*merge m:m FOLDER_NUMBER using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\DEMalt.dta", keepusing(PATIENT2 FIRST_NAME2 SURNAME2 FOLDER_NUMBER2)

*drop HOME_ADDRESS_1 HOME_ADDRESS_2 HOME_ADDRESS_3 HOME_ADDRESS_3 POST_CODE HOME_ADDRESS_4 HOME_NUMBER
*replace PATIENT2=PATIENT if PATIENT2==""
*browse if PATIENT2!=""
*save "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\DEMalt.dta", replace
***ARV data import and clean
import excel "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\ART.xlsx", sheet("ART") firstrow clear

*merge m:m PATIENT using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\DEMalt.dta", keepusing(PATIENT2)

*replace PATIENT=PATIENT2
*drop _merge
*drop PATIENT2

*FOLDER_NUMBER	
*1119	TBL1957 
replace PATIENT="48cf3956-a034-491a-9293-60c9919ae24a" if PATIENT=="749504e9-731e-4ac8-b20a-a19ff7af9a0f"
*12540	TBL1711 
replace PATIENT="fc913d80-bef8-40c2-862d-09f8a52ec349" if PATIENT=="51c841ac-87fc-4f10-aecf-416c356b047d"
*14129	TBL1723 
replace PATIENT="048ddb4e-fd1e-4b8f-b14d-c49eb6ba8774" if PATIENT=="12895791-769d-4788-8ef5-b398a677e21e"
*14641	MIN3538 
replace PATIENT="58016668-77a7-48df-b4b8-1cccc17e75fb" if PATIENT=="e6edb8c9-0580-4dfe-ac28-545c86e8cac9"
*14656	TBL2056 
replace PATIENT="0e148d5c-5afa-4f7a-86ea-9293d087ea5f" if PATIENT=="4763cc0e-edcf-46af-a2c8-43d96f71e555"
*14901	FLB2892M 
replace PATIENT="4c2cdc76-4ac8-4f03-9706-aa0be844c7fd" if PATIENT=="62175593-e3d1-4e76-8cc5-7d44eb177799"
*15061	TBL1822 
replace PATIENT="b95fda07-20b2-4fb2-94ed-67c4911f6455" if PATIENT=="8a388864-6415-4a83-9e77-f18d113f2d11"
*15513	TBL1753 
replace PATIENT="6bf22e91-5a14-45b5-a0ef-079891d261ed" if PATIENT=="0aeda05b-7b59-4f07-9a51-a210b159f8be"
*329	    CLY1680M 
replace PATIENT="84eb14eb-0280-4593-aba3-01b735ee4830" if PATIENT=="e7c58db7-6b3a-4c56-87b2-fb705b91c1bb"
*9378	TBL1640 
replace PATIENT="7209dc91-ddfa-4708-a18b-e620c260169f" if PATIENT=="39ced0fb-69f5-4111-a514-9476204a310e"

generate date_ARTED = date(ART_ED_DMY, "YMD")
generate date_ARTSD = date(ART_SD_DMY , "YMD")
format date_ARTSD %td
format date_ARTED %td
drop ART_SD_DMY ART_RS ART_RS ART_FORM ART_COMB NO_DOSES NO_WEEKS ART_END_RS INFO_SOURCE ART_ED_DMY

replace ART_ID="ATV" if ART_ID=="J05AE-ATV"
replace ART_ID="RTV" if ART_ID=="J05AE03"
replace ART_ID="LPVr" if ART_ID=="J05AE06"
replace ART_ID="AZT" if ART_ID=="J05AF01"
replace ART_ID="ddI" if ART_ID=="J05AF02"
replace ART_ID="d4T" if ART_ID=="J05AF04"
replace ART_ID="3TC" if ART_ID=="J05AF05"
replace ART_ID="ABC" if ART_ID=="J05AF06"
replace ART_ID="TDF" if ART_ID=="J05AF07"
replace ART_ID="FTC" if ART_ID=="J05AF09"
replace ART_ID="NVP" if ART_ID=="J05AG01"
replace ART_ID="EFV" if ART_ID=="J05AG03"
replace ART_ID="RAL" if ART_ID=="J05AX08"

merge m:1 PATIENT using  "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\DEM.dta", keepusing(FOLDER_NUMBER OTHER_NUMBER)
drop if _merge==2
drop _merge

duplicates drop PATIENT date_ARTSD ART_ID, force

sort PATIENT date_ARTSD
by PATIENT : gen j=_n
sort PATIENT date_ARTSD

sort PATIENT

reshape wide ART_ID REGIMEN_LINE date_ARTSD date_ARTED , i(PATIENT) j(j)



save "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\artwide.dta", replace
 

***import and clean for patient data
import excel "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\PAT.xlsx", sheet("PAT") firstrow clear
*merge m:m PATIENT using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\DEMalt.dta", keepusing(PATIENT2)

*FOLDER_NUMBER	
*1119	TBL1957 

*browse if FOLDER_NUMBER=="1119"	| FOLDER_NUMBER=="TBL1957" | FOLDER_NUMBER=="12540"	| FOLDER_NUMBER=="TBL1711" | FOLDER_NUMBER=="14129"	| FOLDER_NUMBER=="TBL1723" | FOLDER_NUMBER=="14641"	| FOLDER_NUMBER=="MIN3538" | FOLDER_NUMBER=="14656"	| FOLDER_NUMBER=="TBL2056" | FOLDER_NUMBER=="14901"	| FOLDER_NUMBER=="FLB2892M" | FOLDER_NUMBER=="15061"	| FOLDER_NUMBER=="TBL1822" | FOLDER_NUMBER=="15513"	| FOLDER_NUMBER=="TBL1753" |  FOLDER_NUMBER=="329"	| FOLDER_NUMBER=="CLY1680M" | FOLDER_NUMBER=="9378" | 	FOLDER_NUMBER=="TBL1640" 
*replace PATIENT=PATIENT2
*drop if _merge==2
*drop _merge
*drop PATIENT2

sort PATIENT

generate date_BIRTH = date(BIRTH_DMY , "YMD")
format date_BIRTH %td
generate date_FRSVIS = date(FRSVIS_DMY , "YMD")
format date_FRSVIS %td
generate date_HIVP = date(HIVP_DMY , "YMD")
format date_HIVP %td
generate date_HAART = date(HAART_DMY , "YMD")
format date_HAART %td
generate date_OUTCOME = date(OUTCOME_DMY , "YMD")
format date_OUTCOME %td
generate R6M=.
replace R6M=1 if USER_DEFINED_PATIENT_VAR2=="R6M"
generate date_R6M = date(USER_DEFINED_PATIENT_VAR2 , "DM20Y"), 

format date_R6M %td
replace R6M=1 if date_R6M!=.

generate date_TRANSFER = date(TRANSFER_IN_DMY , "YMD")
format date_TRANSFER %td
    
destring (GENDER ), replace
destring (HAART ), replace
destring (FHV_STAGE_WHO ), replace
destring (TB_FHV), replace
destring (PREG_FHV), replace
destring (OUTCOME), replace

drop BIRTH_DMY FRSVIS_DMY HAART_DMY HIVP_DMY HIV_TEST MODE MODE ENTRY FHV_SDI_1 FHV_SDI_3 FHV_SDI_2 FHV_SDI_4  MTCT_Y PEP_Y METHOD_INTO_ART DISCL_CG LAST_CONTACT_T FROM_LOCATION FROM_LOCATION FROM_LOCATION OUTCOME_DMY OUTCOME_Y OUTCOME_M DEATH_C1 DEATH_N1 DEATH_N2 DEATH_C2 DEATH_C3 DEATH_N3 CAREG DISCL_CHILD WEIGHT_BIRTH DELIV_M BRSTFD BRSTFD_EST_DUR USER_DEFINED_PATIENT_VAR2 USER_DEFINED_PATIENT_VAR3 USER_DEFINED_PATIENT_VAR1 TRANSFER_IN_DMY


*sort PATIENT date_OUTCOME
*by PATIENT : gen j=_n
*sort PATIENT date_OUTCOME
*by PATIENT : gen N=_N

*gen decentralised=""
*replace decentralised="yes" if N>1
*replace date_HIVP=date_HIVP[n-1] if j=N-1
*replace date_HIVP=date_HIVP[n-1] if j=N-1	date_HAART

replace PATIENT="48cf3956-a034-491a-9293-60c9919ae24a" if PATIENT=="749504e9-731e-4ac8-b20a-a19ff7af9a0f"
*12540	TBL1711 
replace PATIENT="fc913d80-bef8-40c2-862d-09f8a52ec349" if PATIENT=="51c841ac-87fc-4f10-aecf-416c356b047d"
*14129	TBL1723 
replace PATIENT="048ddb4e-fd1e-4b8f-b14d-c49eb6ba8774" if PATIENT=="12895791-769d-4788-8ef5-b398a677e21e"
*14641	MIN3538 
replace PATIENT="58016668-77a7-48df-b4b8-1cccc17e75fb" if PATIENT=="e6edb8c9-0580-4dfe-ac28-545c86e8cac9"
*14656	TBL2056 
replace PATIENT="0e148d5c-5afa-4f7a-86ea-9293d087ea5f" if PATIENT=="4763cc0e-edcf-46af-a2c8-43d96f71e555"
*14901	FLB2892M 
replace PATIENT="4c2cdc76-4ac8-4f03-9706-aa0be844c7fd" if PATIENT=="62175593-e3d1-4e76-8cc5-7d44eb177799"
*15061	TBL1822 
replace PATIENT="b95fda07-20b2-4fb2-94ed-67c4911f6455" if PATIENT=="8a388864-6415-4a83-9e77-f18d113f2d11"
*15513	TBL1753 
replace PATIENT="6bf22e91-5a14-45b5-a0ef-079891d261ed" if PATIENT=="0aeda05b-7b59-4f07-9a51-a210b159f8be"
*329	    CLY1680M 
replace PATIENT="84eb14eb-0280-4593-aba3-01b735ee4830" if PATIENT=="e7c58db7-6b3a-4c56-87b2-fb705b91c1bb"
*9378	TBL1640 
replace PATIENT="7209dc91-ddfa-4708-a18b-e620c260169f" if PATIENT=="39ced0fb-69f5-4111-a514-9476204a310e"

sort PATIENT
gen decentralisationdate=date_OUTCOME if PATIENT=="7209dc91-ddfa-4708-a18b-e620c260169f" | PATIENT=="84eb14eb-0280-4593-aba3-01b735ee4830" | PATIENT=="6bf22e91-5a14-45b5-a0ef-079891d261ed" | PATIENT=="48cf3956-a034-491a-9293-60c9919ae24a" | PATIENT=="7209dc91-ddfa-4708-a18b-e620c260169f" | PATIENT=="fc913d80-bef8-40c2-862d-09f8a52ec349" | PATIENT=="048ddb4e-fd1e-4b8f-b14d-c49eb6ba8774" | PATIENT=="58016668-77a7-48df-b4b8-1cccc17e75fb" | PATIENT=="0e148d5c-5afa-4f7a-86ea-9293d087ea5f" | PATIENT=="4c2cdc76-4ac8-4f03-9706-aa0be844c7fd" | PATIENT=="b95fda07-20b2-4fb2-94ed-67c4911f6455" 
format decentralisationdate %td
replace date_OUTCOME=. if PATIENT=="7209dc91-ddfa-4708-a18b-e620c260169f" | PATIENT=="84eb14eb-0280-4593-aba3-01b735ee4830" | PATIENT=="6bf22e91-5a14-45b5-a0ef-079891d261ed" | PATIENT=="48cf3956-a034-491a-9293-60c9919ae24a" | PATIENT=="7209dc91-ddfa-4708-a18b-e620c260169f" | PATIENT=="fc913d80-bef8-40c2-862d-09f8a52ec349" | PATIENT=="048ddb4e-fd1e-4b8f-b14d-c49eb6ba8774" | PATIENT=="58016668-77a7-48df-b4b8-1cccc17e75fb" | PATIENT=="0e148d5c-5afa-4f7a-86ea-9293d087ea5f" | PATIENT=="4c2cdc76-4ac8-4f03-9706-aa0be844c7fd" | PATIENT=="b95fda07-20b2-4fb2-94ed-67c4911f6455" 
browse if PATIENT=="7209dc91-ddfa-4708-a18b-e620c260169f" | PATIENT=="84eb14eb-0280-4593-aba3-01b735ee4830" | PATIENT=="6bf22e91-5a14-45b5-a0ef-079891d261ed" | PATIENT=="48cf3956-a034-491a-9293-60c9919ae24a" | PATIENT=="7209dc91-ddfa-4708-a18b-e620c260169f" | PATIENT=="fc913d80-bef8-40c2-862d-09f8a52ec349" | PATIENT=="048ddb4e-fd1e-4b8f-b14d-c49eb6ba8774" | PATIENT=="58016668-77a7-48df-b4b8-1cccc17e75fb" | PATIENT=="0e148d5c-5afa-4f7a-86ea-9293d087ea5f" | PATIENT=="4c2cdc76-4ac8-4f03-9706-aa0be844c7fd" | PATIENT=="b95fda07-20b2-4fb2-94ed-67c4911f6455" 
replace OUTCOME=20 if PATIENT=="7209dc91-ddfa-4708-a18b-e620c260169f" | PATIENT=="84eb14eb-0280-4593-aba3-01b735ee4830" | PATIENT=="6bf22e91-5a14-45b5-a0ef-079891d261ed" | PATIENT=="48cf3956-a034-491a-9293-60c9919ae24a" | PATIENT=="7209dc91-ddfa-4708-a18b-e620c260169f" | PATIENT=="fc913d80-bef8-40c2-862d-09f8a52ec349" | PATIENT=="048ddb4e-fd1e-4b8f-b14d-c49eb6ba8774" | PATIENT=="58016668-77a7-48df-b4b8-1cccc17e75fb" | PATIENT=="0e148d5c-5afa-4f7a-86ea-9293d087ea5f" | PATIENT=="4c2cdc76-4ac8-4f03-9706-aa0be844c7fd" | PATIENT=="b95fda07-20b2-4fb2-94ed-67c4911f6455" 
replace OUTCOME=95 if PATIENT=="4c2cdc76-4ac8-4f03-9706-aa0be844c7fd"
drop if (PATIENT=="7209dc91-ddfa-4708-a18b-e620c260169f" & FACILITY!="CMC Matam") | (PATIENT=="84eb14eb-0280-4593-aba3-01b735ee4830" & FACILITY!="CMC Matam") | (PATIENT=="6bf22e91-5a14-45b5-a0ef-079891d261ed" & FACILITY!="CMC Matam") | (PATIENT=="48cf3956-a034-491a-9293-60c9919ae24a" & FACILITY!="CMC Matam") | (PATIENT=="7209dc91-ddfa-4708-a18b-e620c260169f" & FACILITY!="CMC Matam") | (PATIENT=="fc913d80-bef8-40c2-862d-09f8a52ec349" & FACILITY!="CMC Matam") | (PATIENT=="048ddb4e-fd1e-4b8f-b14d-c49eb6ba8774" & FACILITY!="CMC Matam") | (PATIENT=="58016668-77a7-48df-b4b8-1cccc17e75fb" & FACILITY!="CMC Matam") | (PATIENT=="0e148d5c-5afa-4f7a-86ea-9293d087ea5f" & FACILITY!="CMC Matam") | (PATIENT=="4c2cdc76-4ac8-4f03-9706-aa0be844c7fd" & FACILITY!="CMC Matam") | (PATIENT=="b95fda07-20b2-4fb2-94ed-67c4911f6455" & FACILITY!="CMC Matam")
 

*drop if j<N

save "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\PAT.dta", replace


***visit import and clean
*import excel "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\VIS.xlsx", sheet("VIS") firstrow clear
*save "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\VIS", replace
use "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\VIS.dta", clear
drop CTX FLU SCHOOL_Y USER_DEFINED_VISIT_VAR1 USER_DEFINED_VISIT_VAR2 USER_DEFINED_VISIT_VAR3
generate date_NXTVIS = date( NEXT_VISIT_DMY, "YMD"), 

format date_NXTVIS %td
generate date_VISIT = date(VISIT_DMY, "YMD"), 

format date_VISIT %td
*drop F G H
*FOLDER_NUMBER	
*1119	TBL1957 
replace PATIENT="48cf3956-a034-491a-9293-60c9919ae24a" if PATIENT=="749504e9-731e-4ac8-b20a-a19ff7af9a0f"
*12540	TBL1711 
replace PATIENT="fc913d80-bef8-40c2-862d-09f8a52ec349" if PATIENT=="51c841ac-87fc-4f10-aecf-416c356b047d"
*14129	TBL1723 
replace PATIENT="048ddb4e-fd1e-4b8f-b14d-c49eb6ba8774" if PATIENT=="12895791-769d-4788-8ef5-b398a677e21e"
*14641	MIN3538 
replace PATIENT="58016668-77a7-48df-b4b8-1cccc17e75fb" if PATIENT=="e6edb8c9-0580-4dfe-ac28-545c86e8cac9"
*14656	TBL2056 
replace PATIENT="0e148d5c-5afa-4f7a-86ea-9293d087ea5f" if PATIENT=="4763cc0e-edcf-46af-a2c8-43d96f71e555"
*14901	FLB2892M 
replace PATIENT="4c2cdc76-4ac8-4f03-9706-aa0be844c7fd" if PATIENT=="62175593-e3d1-4e76-8cc5-7d44eb177799"
*15061	TBL1822 
replace PATIENT="b95fda07-20b2-4fb2-94ed-67c4911f6455" if PATIENT=="8a388864-6415-4a83-9e77-f18d113f2d11"
*15513	TBL1753 
replace PATIENT="6bf22e91-5a14-45b5-a0ef-079891d261ed" if PATIENT=="0aeda05b-7b59-4f07-9a51-a210b159f8be"
*329	    CLY1680M 
replace PATIENT="84eb14eb-0280-4593-aba3-01b735ee4830" if PATIENT=="e7c58db7-6b3a-4c56-87b2-fb705b91c1bb"
*9378	TBL1640 
replace PATIENT="7209dc91-ddfa-4708-a18b-e620c260169f" if PATIENT=="39ced0fb-69f5-4111-a514-9476204a310e"


merge m:1 PATIENT using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\artwide.dta"


sort PATIENT date_VISIT


***So i tried another option, where i created another variable that shows if a patient is on each drug or not at each visit

  gen TDF=""
  
   forvalues i=24(-1)1 {

  replace TDF=ART_ID`i' if date_ARTED`i'>date_VISIT   & date_ARTSD`i'<=date_VISIT & ART_ID`i'=="TDF"  
}

  
gen ATV=""  
 forvalues i=24(-1)1 {

  replace ATV=ART_ID`i' if date_ARTED`i'>date_VISIT   & date_ARTSD`i'<=date_VISIT & ART_ID`i'=="ATV"  
}
gen RTV=""
 forvalues i=24(-1)1 {

  replace RTV=ART_ID`i' if date_ARTED`i'>date_VISIT   & date_ARTSD`i'<=date_VISIT & ART_ID`i'=="RTV"  
}
gen LPVr="" 
 forvalues i=24(-1)1 {

  replace LPVr=ART_ID`i' if date_ARTED`i'>date_VISIT   & date_ARTSD`i'<=date_VISIT & ART_ID`i'=="LPVr"  
}
gen AZT="" 
 forvalues i=24(-1)1 {

  replace AZT=ART_ID`i' if date_ARTED`i'>date_VISIT   & date_ARTSD`i'<=date_VISIT & ART_ID`i'=="AZT"  
}
gen ddI="" 
 forvalues i=24(-1)1 {

  replace ddI=ART_ID`i' if date_ARTED`i'>date_VISIT   & date_ARTSD`i'<=date_VISIT & ART_ID`i'=="ddI"  
}
gen d4T="" 
 forvalues i=24(-1)1 {

  replace d4T=ART_ID`i' if date_ARTED`i'>date_VISIT   & date_ARTSD`i'<=date_VISIT & ART_ID`i'=="d4T"  
}
gen TC="" 
 forvalues i=24(-1)1 {

  replace TC=ART_ID`i' if date_ARTED`i'>date_VISIT   & date_ARTSD`i'<=date_VISIT & ART_ID`i'=="3TC"  
}
gen ABC="" 
 forvalues i=24(-1)1 {

  replace ABC=ART_ID`i' if date_ARTED`i'>date_VISIT   & date_ARTSD`i'<=date_VISIT & ART_ID`i'=="ABC"  
}
gen FTC="" 
 forvalues i=24(-1)1 {

  replace FTC=ART_ID`i' if date_ARTED`i'>date_VISIT   & date_ARTSD`i'<=date_VISIT & ART_ID`i'=="FTC"  
}
gen NVP="" 
 forvalues i=24(-1)1 {

  replace NVP=ART_ID`i' if date_ARTED`i'>date_VISIT   & date_ARTSD`i'<=date_VISIT & ART_ID`i'=="NVP"  
}
gen EFV="" 
 forvalues i=24(-1)1 {

  replace EFV=ART_ID`i' if date_ARTED`i'>date_VISIT   & date_ARTSD`i'<=date_VISIT & ART_ID`i'=="EFV"  
}
gen RAL="" 
 forvalues i=24(-1)1 {

  replace RAL=ART_ID`i' if date_ARTED`i'>date_VISIT   & date_ARTSD`i'<=date_VISIT & ART_ID`i'=="RAL"  
}

gen regimen=""
 forvalues i=1/24 {

  replace regimen=REGIMEN_LINE`i' if date_ARTED`i'>date_VISIT   & date_ARTSD`i'<=date_VISIT 
}



***then at the end I merged it into one variable
egen regimecat=concat(TDF AZT ABC d4T TC FTC EFV NVP ATV RTV LPVr ddI RAL)
browse PATIENT date_VISIT date_NXTVIS regimecat regimen ART_ID1 REGIMEN_LINE1 date_ARTED1 date_ARTSD1 ART_ID2 REGIMEN_LINE2 date_ARTED2 date_ARTSD2 ART_ID3 REGIMEN_LINE3 date_ARTED3 date_ARTSD3 ART_ID4 REGIMEN_LINE4 date_ARTED4 date_ARTSD4 ART_ID5 REGIMEN_LINE5 date_ARTED5 date_ARTSD5 ART_ID6 REGIMEN_LINE6 date_ARTED6 date_ARTSD6 ART_ID7 REGIMEN_LINE7 date_ARTED7 date_ARTSD7 ART_ID8 REGIMEN_LINE8 date_ARTED8 date_ARTSD8 ART_ID9 REGIMEN_LINE9 date_ARTED9 date_ARTSD9 ART_ID10 REGIMEN_LINE10 date_ARTED10 date_ARTSD10 ART_ID11 REGIMEN_LINE11 date_ARTED11 date_ARTSD11 ART_ID12 REGIMEN_LINE12 date_ARTED12 date_ARTSD12 ART_ID13 REGIMEN_LINE13 date_ARTED13 date_ARTSD13 ART_ID14 REGIMEN_LINE14 date_ARTED14 date_ARTSD14 ART_ID15 REGIMEN_LINE15 date_ARTED15 date_ARTSD15 ART_ID16 REGIMEN_LINE16 date_ARTED16 date_ARTSD16 ART_ID17 REGIMEN_LINE17 date_ARTED17 date_ARTSD17 ART_ID18 REGIMEN_LINE18 date_ARTED18 date_ARTSD18 ART_ID19 REGIMEN_LINE19 date_ARTED19 date_ARTSD19 ART_ID20 REGIMEN_LINE20 date_ARTED20 date_ARTSD20 ART_ID21 REGIMEN_LINE21 date_ARTED21 date_ARTSD21 ART_ID22 REGIMEN_LINE22 date_ARTED22 date_ARTSD22 ART_ID23 REGIMEN_LINE23 date_ARTED23 date_ARTSD23 ART_ID24 REGIMEN_LINE24 date_ARTED24 date_ARTSD24  
***


drop _merge
merge m:m PATIENT  using "D:\Users\msfuser\or GUINEA\IPD FU\Donkalab.dta", keepusing(FOLDER_NUMBER)

drop if _merge!=3
drop _merge

replace regimecat="TDF3TCEFV" if PATIENT=="12b50ad2-f9eb-46f2-b01b-67b0752df234" & date_VISIT==d(28jun2014)	
replace regimecat="TDF3TCEFV" if PATIENT=="12b50ad2-f9eb-46f2-b01b-67b0752df234" & date_VISIT==d(23jun2015)	
replace regimecat="TDF3TCEFV" if PATIENT=="2545a343-247b-432f-958d-1db49998b261" & date_VISIT==d(23nov2015)	
replace regimecat="TDF3TCEFV" if PATIENT=="2545a343-247b-432f-958d-1db49998b261" & date_VISIT==d(03aug2017)	
replace regimecat="TDF3TCEFV" if PATIENT=="2545a343-247b-432f-958d-1db49998b261" & date_VISIT==d(04aug2017)	
replace regimecat="TDF3TCEFV" if PATIENT=="2545a343-247b-432f-958d-1db49998b261" & date_VISIT==d(07aug2017)	
replace regimecat="AZT3TCEFV" if PATIENT=="2bc0050d-84f7-4da3-86eb-2fefb02ca17d" & regimecat=="EFV"
replace regimecat="AZT3TCEFV" if PATIENT=="2bc0050d-84f7-4da3-86eb-2fefb02ca17d" & regimecat=="AZT3TCEFVNVP"
replace regimecat="ABC3TCLPVr" if PATIENT=="3b721303-9d07-4db0-937f-1e869f077b3f" & regimecat=="ABCLPVr"
replace regimecat="AZT3TCNVP" if PATIENT=="5426ff32-897c-4c6c-a1f6-449bd11fbeab" & regimecat=="AZT"
replace regimecat="TDF3TCEFV" if PATIENT=="5f28db45-8f07-42c2-9d95-42fbd18bd322" & regimecat=="TDF3TC"
replace regimecat="AZT3TCNVP" if PATIENT=="7209dc91-ddfa-4708-a18b-e620c260169f" & regimecat=="3TCNVP"
replace regimecat="TDF3TCEFV" if PATIENT=="84df9d0b-0db5-409a-9e12-3cfee7b81479" & regimecat=="3TCEFV"
replace regimecat="TDF3TCEFV" if PATIENT=="9f4a754a-53d2-41ea-9a01-3e70cc02eabf" & regimecat=="3TCEFV"
replace regimecat="d4T3TCNVP" if PATIENT=="a01f2287-276a-434f-a33a-d824cb2928be" & date_VISIT<=d(13jan2013)
replace regimecat="TDF3TCEFV" if PATIENT=="a01f2287-276a-434f-a33a-d824cb2928be" & date_VISIT>d(13jan2013)

replace regimecat="AZT3TCNVP" if PATIENT=="bda6aed7-c703-45cf-b2e6-9c8409fea90a" & regimecat=="3TC"
replace regimecat="AZT3TCNVP" if PATIENT=="bda6aed7-c703-45cf-b2e6-9c8409fea90a" & regimecat=="AZTNVP"
replace regimecat="TDF3TCEFV" if PATIENT=="c4214c8d-dfcb-4d82-83ab-f82a4360fcb8" & regimecat=="3TCEFV"
replace regimecat="AZT3TCNVP" if PATIENT=="e236b94d-7c2e-4f73-be4f-83f7085a2f8f" & regimecat=="AZTNVP"
replace regimecat="AZT3TCEFV" if PATIENT=="e50a64a7-8929-444e-928f-4630d09b7edb" & regimecat=="AZT3TC"
replace regimecat="TDF3TCEFV" if PATIENT=="e92b63e0-9bee-49e5-996f-38faf0125620" & regimecat=="TDF"
replace regimecat="AZT3TCNVP" if PATIENT=="0c94e17f-dbcb-4224-9348-c3e3d504e1aa" & regimecat=="AZTABC3TC"
replace regimecat="ABC3TCLPVr" if PATIENT=="58016668-77a7-48df-b4b8-1cccc17e75fb" & regimecat=="AZTABC3TC"
replace regimecat="AZT3TCNVP" if PATIENT=="a9e8c350-8df2-4864-b111-6b7bd57b1ffc" & regimecat=="AZTABC3TC"

replace regimen="1" if PATIENT=="bda6aed7-c703-45cf-b2e6-9c8409fea90a" & regimecat=="d4T3TCNVP" & regimen=="4"
replace regimen="1" if PATIENT=="bda6aed7-c703-45cf-b2e6-9c8409fea90a" & regimecat=="AZT3TCNVP" & regimen=="4"
replace regimen="1" if PATIENT=="c4214c8d-dfcb-4d82-83ab-f82a4360fcb8" & regimecat=="TDF3TCEFV" & regimen=="4"
replace regimen="1" if PATIENT=="e92b63e0-9bee-49e5-996f-38faf0125620" & regimecat=="TDF3TCEFV" & regimen=="4"
replace regimen="1" if PATIENT=="12b50ad2-f9eb-46f2-b01b-67b0752df234" & regimecat=="TDF3TCEFV" & regimen=="4"
replace regimen="1" if PATIENT=="2545a343-247b-432f-958d-1db49998b261" & regimecat=="TDF3TCEFV" & regimen=="4"
replace regimen="1" if PATIENT=="2bc0050d-84f7-4da3-86eb-2fefb02ca17d" & regimecat=="AZT3TCEFV" & regimen=="4"
replace regimen="1" if PATIENT=="3b721303-9d07-4db0-937f-1e869f077b3f" & regimecat=="ABC3TCLPVr" & regimen=="4"
replace regimen="1" if PATIENT=="5426ff32-897c-4c6c-a1f6-449bd11fbeab" & regimecat=="AZT3TCNVP" & regimen=="4"
replace regimen="1" if PATIENT=="5f28db45-8f07-42c2-9d95-42fbd18bd322" & regimecat=="TDF3TCEFV" & regimen=="4"
replace regimen="1" if PATIENT=="7209dc91-ddfa-4708-a18b-e620c260169f" & regimecat=="AZT3TCNVP" & regimen=="4"
replace regimen="1" if PATIENT=="84df9d0b-0db5-409a-9e12-3cfee7b81479" & regimecat=="TDF3TCEFV" & regimen=="4"
replace regimen="1" if PATIENT=="9f4a754a-53d2-41ea-9a01-3e70cc02eabf" & regimecat=="TDF3TCEFV" & regimen=="4"
replace regimen="1" if PATIENT=="a01f2287-276a-434f-a33a-d824cb2928be" & regimecat=="TDF3TCEFV" & regimen=="4"
replace regimen="1" if PATIENT=="a01f2287-276a-434f-a33a-d824cb2928be" & regimecat=="d4T3TCNVP" & regimen=="4"

replace regimen="2" if PATIENT=="bf8e9a66-93e3-46c3-8695-90868e9677f0" & regimecat=="AZT3TCLPVr" & regimen=="1"
replace regimen="2" if PATIENT=="d816fedc-4435-4de0-941e-ca736546f5a2" & regimecat=="TDF3TCLPVr" & regimen=="1"

replace regimecat="TDF3TCEFV" if PATIENT=="2c22d369-ca12-4271-bbfc-d7bb42c46363" & regimecat=="TDF3TC"	
replace regimecat="AZT3TCNVP" if PATIENT=="5426ff32-897c-4c6c-a1f6-449bd11fbeab" & regimecat=="NVP"	
replace regimecat="AZT3TCNVP" if PATIENT=="7209dc91-ddfa-4708-a18b-e620c260169f" & regimecat=="AZT3TC"	
replace regimecat="TDF3TCEFV" if PATIENT=="7258df6b-0b16-4de4-9003-b399ee92c3f0" & regimecat=="TDF"	
replace regimecat="TDF3TCEFV" if PATIENT=="84df9d0b-0db5-409a-9e12-3cfee7b81479" & regimecat=="EFV"	
replace regimen="1" if PATIENT=="84df9d0b-0db5-409a-9e12-3cfee7b81479" & regimecat=="TDF3TCEFV" & regimen=="4"

replace regimecat="TDF3TCEFV" if PATIENT=="9f4a754a-53d2-41ea-9a01-3e70cc02eabf" & regimecat=="3TC"	
replace regimen="1" if PATIENT=="9f4a754a-53d2-41ea-9a01-3e70cc02eabf" & regimecat=="TDF3TCEFV" & regimen=="4"

replace regimecat="AZT3TCNVP" if PATIENT=="bda6aed7-c703-45cf-b2e6-9c8409fea90a" & regimecat=="AZT3TC"	
replace regimen="1" if PATIENT=="bda6aed7-c703-45cf-b2e6-9c8409fea90a" & regimecat=="AZT3TCNVP" & regimen=="4"


replace regimecat="AZT3TCLPVr" if PATIENT=="c01e7e9d-9562-4d37-9097-91a6267dc471" & regimecat=="LPVr"	
replace regimen="1" if PATIENT=="c01e7e9d-9562-4d37-9097-91a6267dc471" & regimecat=="AZT3TCLPVr" & regimen=="4"

replace regimecat="TDF3TCEFV" if PATIENT=="c4214c8d-dfcb-4d82-83ab-f82a4360fcb8" & regimecat=="TDFEFV"	
replace regimen="1" if PATIENT=="c4214c8d-dfcb-4d82-83ab-f82a4360fcb8" & regimecat=="TDF3TCEFV" & regimen=="4"

replace regimecat="TDF3TCEFV" if PATIENT=="e92b63e0-9bee-49e5-996f-38faf0125620" & regimecat=="TDF3TC"	
replace regimen="1" if PATIENT=="e92b63e0-9bee-49e5-996f-38faf0125620" & regimecat=="TDF3TCEFV" & regimen=="4"

replace regimen="1" if PATIENT=="2c22d369-ca12-4271-bbfc-d7bb42c46363" & regimecat=="TDF3TCEFV" & regimen=="4"
replace regimen="1" if PATIENT=="5426ff32-897c-4c6c-a1f6-449bd11fbeab" & regimecat=="AZT3TCNVP" & regimen=="4"
replace regimen="1" if PATIENT=="7209dc91-ddfa-4708-a18b-e620c260169f" & regimecat=="d4T3TCNVP" & regimen=="4"
replace regimen="1" if PATIENT=="7209dc91-ddfa-4708-a18b-e620c260169f" & regimecat=="AZT3TCNVP" & regimen=="4"
replace regimen="1" if PATIENT=="7258df6b-0b16-4de4-9003-b399ee92c3f0" & regimecat=="TDF3TCEFV" & regimen=="4"

replace regimecat="AZT3TCLPVr" if PATIENT=="c01e7e9d-9562-4d37-9097-91a6267dc471" & regimecat=="3TC"
replace regimen="1" if PATIENT=="c01e7e9d-9562-4d37-9097-91a6267dc471" & regimecat=="AZT3TCLPVr" & regimen=="4"
replace regimecat="AZT3TCNVP" if PATIENT=="bda6aed7-c703-45cf-b2e6-9c8409fea90a" & regimecat=="3TCNVP"
replace regimen="1" if PATIENT=="bda6aed7-c703-45cf-b2e6-9c8409fea90a" & regimecat=="AZT3TCNVP" & regimen=="4"
replace regimecat="TDF3TCEFV" if PATIENT=="84df9d0b-0db5-409a-9e12-3cfee7b81479" & regimecat=="TDFEFV"
replace regimen="1" if PATIENT=="84df9d0b-0db5-409a-9e12-3cfee7b81479" & regimecat=="TDF3TCEFV" & regimen=="4"
replace regimecat="TDF3TCEFV" if PATIENT=="5f28db45-8f07-42c2-9d95-42fbd18bd322" & regimecat=="TDF"
replace regimen="1" if PATIENT=="5f28db45-8f07-42c2-9d95-42fbd18bd322" & regimecat=="TDF3TCEFV" & regimen=="4"
replace regimecat="TDF3TCEFV" if PATIENT=="2c22d369-ca12-4271-bbfc-d7bb42c46363" & regimecat=="3TCEFV"
replace regimen="1" if PATIENT=="2c22d369-ca12-4271-bbfc-d7bb42c46363" & regimecat=="TDF3TCEFV" & regimen=="4"


replace regimecat="AZT3TCEFV" if PATIENT=="2bc0050d-84f7-4da3-86eb-2fefb02ca17d" & regimecat=="AZTEFV"
replace regimen="1" if PATIENT=="2bc0050d-84f7-4da3-86eb-2fefb02ca17d" & regimecat=="AZT3TCEFV" & regimen=="4"

replace regimecat="TDF3TCEFV" if PATIENT=="2c22d369-ca12-4271-bbfc-d7bb42c46363" & regimecat=="TDFEFV"
replace regimen="1" if PATIENT=="2c22d369-ca12-4271-bbfc-d7bb42c46363" & regimecat=="TDF3TCEFV" & regimen=="4"

replace regimecat="ABC3TCLPVr" if PATIENT=="3b721303-9d07-4db0-937f-1e869f077b3f" & regimecat=="LPVr"
replace regimen="1" if PATIENT=="3b721303-9d07-4db0-937f-1e869f077b3f" & regimecat=="ABC3TCLPVr" & regimen=="4"


replace regimecat="TDF3TCEFV" if PATIENT=="2c22d369-ca12-4271-bbfc-d7bb42c46363" & regimecat=="TDFEFV"
replace regimen="1" if PATIENT=="2c22d369-ca12-4271-bbfc-d7bb42c46363" & regimecat=="TDF3TCEFV" & regimen=="4"

replace regimecat="AZT3TCNVP" if PATIENT=="7209dc91-ddfa-4708-a18b-e620c260169f" & regimecat=="3TC"
replace regimen="1" if PATIENT=="7209dc91-ddfa-4708-a18b-e620c260169f" & regimecat=="AZT3TCNVP" & regimen=="4"

replace regimecat="TDF3TCEFV" if PATIENT=="7258df6b-0b16-4de4-9003-b399ee92c3f0" & regimecat=="TDFEFV"
replace regimen="1" if PATIENT=="7258df6b-0b16-4de4-9003-b399ee92c3f0" & regimecat=="TDF3TCEFV" & regimen=="4"

replace regimecat="TDF3TCEFV" if PATIENT=="9f4a754a-53d2-41ea-9a01-3e70cc02eabf" & regimecat=="EFV"
replace regimen="1" if PATIENT=="9f4a754a-53d2-41ea-9a01-3e70cc02eabf" & regimecat=="TDF3TCEFV" & regimen=="4"

replace regimecat="TDF3TCEFV" if PATIENT=="c4214c8d-dfcb-4d82-83ab-f82a4360fcb8" & regimecat=="3TC"
replace regimen="1" if PATIENT=="c4214c8d-dfcb-4d82-83ab-f82a4360fcb8" & regimecat=="TDF3TCEFV" & regimen=="4"

replace regimecat="TDF3TCEFV" if PATIENT=="e92b63e0-9bee-49e5-996f-38faf0125620" & regimecat=="3TC"
replace regimen="1" if PATIENT=="e92b63e0-9bee-49e5-996f-38faf0125620" & regimecat=="TDF3TCEFV" & regimen=="4"

replace regimen="1" if PATIENT=="fca072b5-5975-4316-bd9b-b1b981b14e49" & regimecat=="ABC3TCEFV" & regimen=="2"

replace regimecat="TDF3TCEFV" if PATIENT=="84df9d0b-0db5-409a-9e12-3cfee7b81479" & regimecat=="TDF"
replace regimen="1" if PATIENT=="84df9d0b-0db5-409a-9e12-3cfee7b81479" & regimecat=="TDF3TCEFV" & regimen=="4"

replace regimecat="TDF3TCEFV" if PATIENT=="2c22d369-ca12-4271-bbfc-d7bb42c46363" & regimecat=="TDF"
replace regimen="1" if PATIENT=="2c22d369-ca12-4271-bbfc-d7bb42c46363" & regimecat=="TDF3TCEFV" & regimen=="4"

replace regimecat="ABC3TCLPVr" if PATIENT=="3b721303-9d07-4db0-937f-1e869f077b3f" & regimecat=="ABC"
replace regimen="1" if PATIENT=="3b721303-9d07-4db0-937f-1e869f077b3f" & regimecat=="ABC3TCLPVr" & regimen=="4"


replace regimecat="AZT3TCLPVr" if PATIENT=="c01e7e9d-9562-4d37-9097-91a6267dc471" & regimecat=="AZT"
replace regimen="1" if PATIENT=="c01e7e9d-9562-4d37-9097-91a6267dc471" & regimecat=="AZT3TCLPVr" & regimen=="4"

replace regimecat="TDF3TCEFV" if PATIENT=="c4214c8d-dfcb-4d82-83ab-f82a4360fcb8" & regimecat=="TDF"
replace regimen="1" if PATIENT=="c4214c8d-dfcb-4d82-83ab-f82a4360fcb8" & regimecat=="TDF3TCEFV" & regimen=="4"




drop VISIT_DMY NEXT_VISIT_DMY

*the weird stuff
replace regimecat="TDF3TCEFV" if PATIENT=="5f28db45-8f07-42c2-9d95-42fbd18bd322" & regimecat=="TDFEFV"
replace regimen="1" if PATIENT=="5f28db45-8f07-42c2-9d95-42fbd18bd322" & regimecat=="TDF3TCEFV" & regimen=="4"



replace regimecat="TDF3TCEFV" if PATIENT=="84df9d0b-0db5-409a-9e12-3cfee7b81479" & regimecat=="TDF3TC"
replace regimen="1" if PATIENT=="84df9d0b-0db5-409a-9e12-3cfee7b81479" & regimecat=="TDF3TCEFV" & regimen=="4"



replace regimecat="ABC3TCLPVr" if PATIENT=="048ddb4e-fd1e-4b8f-b14d-c49eb6ba8774" & regimecat=="AZTABC3TCLPVr"
replace regimecat="TDF3TCEFV" if PATIENT=="48cf3956-a034-491a-9293-60c9919ae24a" & regimecat=="TDF3TCFTCEFV"
replace regimecat="ABC3TCLPVr" if PATIENT=="58016668-77a7-48df-b4b8-1cccc17e75fb" & regimecat=="AZTABC3TCLPVr"

replace regimecat="ABC3TCLPVr" if PATIENT=="3b721303-9d07-4db0-937f-1e869f077b3f" & regimecat=="ABC3TC"
replace regimen="1" if PATIENT=="3b721303-9d07-4db0-937f-1e869f077b3f" & regimecat=="ABC3TCLPVr" & regimen=="4"

replace regimecat="TDF3TCEFV" if PATIENT=="9f4a754a-53d2-41ea-9a01-3e70cc02eabf" & regimecat=="TDF3TC"
replace regimen="1" if PATIENT=="9f4a754a-53d2-41ea-9a01-3e70cc02eabf" & regimecat=="TDF3TCEFV" & regimen=="4"

replace regimecat="TDF3TCEFV" if PATIENT=="b95fda07-20b2-4fb2-94ed-67c4911f6455" & regimecat=="TDF3TCFTCEFV"
replace regimen="1" if PATIENT=="b95fda07-20b2-4fb2-94ed-67c4911f6455" & regimecat=="TDF3TCEFV" & regimen=="4"

replace regimecat="AZT3TCLPVr" if PATIENT=="c01e7e9d-9562-4d37-9097-91a6267dc471" & regimecat=="AZT3TC"
replace regimen="1" if PATIENT=="c01e7e9d-9562-4d37-9097-91a6267dc471" & regimecat=="AZT3TCLPVr" & regimen=="4"

replace regimecat="ABC3TCLPVr" if PATIENT=="58016668-77a7-48df-b4b8-1cccc17e75fb" & regimecat=="ABC3TC"
replace regimen="1" if PATIENT=="58016668-77a7-48df-b4b8-1cccc17e75fb" & regimecat=="ABC3TCLPVr" & regimen=="4"


replace regimecat="TDF3TCEFV" if PATIENT=="9f4a754a-53d2-41ea-9a01-3e70cc02eabf" & regimecat=="TDF"
replace regimen="1" if PATIENT=="9f4a754a-53d2-41ea-9a01-3e70cc02eabf" & regimecat=="TDF3TCEFV" & regimen=="4"

replace regimecat="AZT3TCNVP" if PATIENT=="bda6aed7-c703-45cf-b2e6-9c8409fea90a" & regimecat=="AZT"
replace regimen="1" if PATIENT=="bda6aed7-c703-45cf-b2e6-9c8409fea90a" & regimecat=="AZT3TCNVP" & regimen=="4"


replace regimecat="TDF3TCEFV" if PATIENT=="c4214c8d-dfcb-4d82-83ab-f82a4360fcb8" & regimecat=="TDF3TC"
replace regimen="1" if PATIENT=="c4214c8d-dfcb-4d82-83ab-f82a4360fcb8" & regimecat=="TDF3TCEFV" & regimen=="4"

replace regimecat="ABC3TCLPVr" if PATIENT=="58016668-77a7-48df-b4b8-1cccc17e75fb" & regimecat=="AZT3TC"
replace regimen="1" if PATIENT=="58016668-77a7-48df-b4b8-1cccc17e75fb" & regimecat=="ABC3TCLPVr" & regimen=="4"




tab regimecat
**visit reshape
save "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\VISwithdonkaaliveonly.dta", replace
use "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\VISwithdonkaaliveonly.dta", clear

drop VISIT_FAC SUBCLINIC EXAMINER MONTHSPRESCRIBED

sort PATIENT date_VISIT
by PATIENT : gen j=_n
sort PATIENT date_VISIT
by PATIENT : gen numbervisit=_N

*merge m:m PATIENT using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\PAT.dta", keepusing(date_HAART date_FRSVIS)

*gen datesinceART=VISIT_DMY-date_HAART
*gen datesincefst=VISIT_DMY-date_FRSVIS
*replace datesincefst=. if datesincefst<0
*replace datesinceART=. if datesinceART<0
*gen m6sinceART=0
*replace m6sinceART=1 if datesinceART<=186
*drop date_FRSVIS date_HAART _merge
gen lstvis=.
replace lstvis=1 if numbervisit==j

sort PATIENT
drop if j==.
egen lstdate=max(date_VISIT)
gen timesincevst=lstdate-date_VISIT
drop lstdate
drop TDF ATV RTV LPVr AZT ddI d4T TC ABC FTC NVP EFV RAL ART_ID1 REGIMEN_LINE1 date_ARTED1 date_ARTSD1 ART_ID2 REGIMEN_LINE2 date_ARTED2 date_ARTSD2 ART_ID3 REGIMEN_LINE3 date_ARTED3 date_ARTSD3 ART_ID4 REGIMEN_LINE4 date_ARTED4 date_ARTSD4 ART_ID5 REGIMEN_LINE5 date_ARTED5 date_ARTSD5 ART_ID6 REGIMEN_LINE6 date_ARTED6 date_ARTSD6 ART_ID7 REGIMEN_LINE7 date_ARTED7 date_ARTSD7 ART_ID8 REGIMEN_LINE8 date_ARTED8 date_ARTSD8 ART_ID9 REGIMEN_LINE9 date_ARTED9 date_ARTSD9 ART_ID10 REGIMEN_LINE10 date_ARTED10 date_ARTSD10 ART_ID11 REGIMEN_LINE11 date_ARTED11 date_ARTSD11 ART_ID12 REGIMEN_LINE12 date_ARTED12 date_ARTSD12 ART_ID13 REGIMEN_LINE13 date_ARTED13 date_ARTSD13 ART_ID14 REGIMEN_LINE14 date_ARTED14 date_ARTSD14 ART_ID15 REGIMEN_LINE15 date_ARTED15 date_ARTSD15 ART_ID16 REGIMEN_LINE16 date_ARTED16 date_ARTSD16 ART_ID17 REGIMEN_LINE17 date_ARTED17 date_ARTSD17 ART_ID18 REGIMEN_LINE18 date_ARTED18 date_ARTSD18 ART_ID19 REGIMEN_LINE19 date_ARTED19 date_ARTSD19 ART_ID20 REGIMEN_LINE20 date_ARTED20 date_ARTSD20 ART_ID21 REGIMEN_LINE21 date_ARTED21 date_ARTSD21 ART_ID22 REGIMEN_LINE22 date_ARTED22 date_ARTSD22 ART_ID23 REGIMEN_LINE23 date_ARTED23 date_ARTSD23 ART_ID24 REGIMEN_LINE24 date_ARTED24 date_ARTSD24  
*drop TB_STATUS



reshape wide  date_VISIT  INH TB_STATUS timesincevst date_NXTVIS lstvis WHO_STAGE PREGNANCY regimecat regimen, i(PATIENT) j(j)


gen Date2ndline=.
 forvalues i=1/193 {

  replace Date2ndline=date_VISIT`i' if Date2ndline==.   & regimen`i'=="2"
}
format Date2ndline %td

gen Date1stline=.
 forvalues i=1/193 {

  replace Date1stline=date_VISIT`i' if Date1stline==.   & regimen`i'=="1"
}
format Date1stline %td


gen firstregime=""
forvalues i=1/193 {

	replace firstregime=regimecat`i' if firstregime==""
}
gen secondregime=""
forvalues i=1/193 {

	replace secondregime=regimecat`i' if secondregime=="" & regimecat`i'!=firstregime
}


gen thirdregime=""
forvalues i=1/193 {

	replace thirdregime=regimecat`i' if thirdregime=="" & regimecat`i'!=secondregime & regimecat`i'!=firstregime
}

gen fourthregime=""
forvalues i=1/193 {

	replace fourthregime=regimecat`i' if fourthregime=="" & regimecat`i'!=thirdregime & regimecat`i'!=secondregime & regimecat`i'!=firstregime
}

gen fifthregime=""
forvalues i=1/193 {

	replace fifthregime=regimecat`i' if fifthregime=="" & regimecat`i'!=fourthregime & regimecat`i'!=thirdregime & regimecat`i'!=secondregime & regimecat`i'!=firstregime
}

gen sixthregime=""
forvalues i=1/193 {

	replace sixthregime=regimecat`i' if sixthregime=="" & regimecat`i'!=fifthregime & regimecat`i'!=fourthregime & regimecat`i'!=thirdregime & regimecat`i'!=secondregime & regimecat`i'!=firstregime
}

gen seventhregime=""
forvalues i=1/193 {

	replace seventhregime=regimecat`i' if seventhregime=="" & regimecat`i'!=sixthregime & regimecat`i'!=fifthregime & regimecat`i'!=fourthregime & regimecat`i'!=thirdregime & regimecat`i'!=secondregime & regimecat`i'!=firstregime
}

gen eigthregime=""
forvalues i=1/193 {

	replace eigthregime=regimecat`i' if eigthregime=="" & regimecat`i'!=seventhregime & regimecat`i'!=sixthregime & regimecat`i'!=fifthregime & regimecat`i'!=fourthregime & regimecat`i'!=thirdregime & regimecat`i'!=secondregime & regimecat`i'!=firstregime
}

gen secondlineregimen=""

forvalues i=1/193 {

	replace secondlineregimen=regimecat`i' if Date2ndline==date_VISIT`i' & regimen`i'=="2"
}


drop timesincevst* WHO_STAGE* PREGNANCY*  regimen* regimecat*
drop lstvis*



save "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\VISwidedonkaonly.dta", replace


import excel "D:\Users\msfuser\or GUINEA\IPD FU\bdd Master.xlsx", sheet("Extra VL") firstrow clear

drop D E F G CV4valuer CV4date
merge m:m FOLDER_NUMBER using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\DEM.dta", keepusing(PATIENT)
drop if _merg!=3
drop _merge
save "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\ExtraVL.dta", replace

***Lab data import clean 
import excel "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\LAB.xlsx", sheet("LAB") firstrow clear
destring LAB_V, replace force
generate date_LABDMY = date(LAB_DMY, "YMD")
*FOLDER_NUMBER	
*1119	TBL1957 
replace PATIENT="48cf3956-a034-491a-9293-60c9919ae24a" if PATIENT=="749504e9-731e-4ac8-b20a-a19ff7af9a0f"
*12540	TBL1711 
replace PATIENT="fc913d80-bef8-40c2-862d-09f8a52ec349" if PATIENT=="51c841ac-87fc-4f10-aecf-416c356b047d"
*14129	TBL1723 
replace PATIENT="048ddb4e-fd1e-4b8f-b14d-c49eb6ba8774" if PATIENT=="12895791-769d-4788-8ef5-b398a677e21e"
*14641	MIN3538 
replace PATIENT="58016668-77a7-48df-b4b8-1cccc17e75fb" if PATIENT=="e6edb8c9-0580-4dfe-ac28-545c86e8cac9"
*14656	TBL2056 
replace PATIENT="0e148d5c-5afa-4f7a-86ea-9293d087ea5f" if PATIENT=="4763cc0e-edcf-46af-a2c8-43d96f71e555"
*14901	FLB2892M 
replace PATIENT="4c2cdc76-4ac8-4f03-9706-aa0be844c7fd" if PATIENT=="62175593-e3d1-4e76-8cc5-7d44eb177799"
*15061	TBL1822 
replace PATIENT="b95fda07-20b2-4fb2-94ed-67c4911f6455" if PATIENT=="8a388864-6415-4a83-9e77-f18d113f2d11"
*15513	TBL1753 
replace PATIENT="6bf22e91-5a14-45b5-a0ef-079891d261ed" if PATIENT=="0aeda05b-7b59-4f07-9a51-a210b159f8be"
*329	    CLY1680M 
replace PATIENT="84eb14eb-0280-4593-aba3-01b735ee4830" if PATIENT=="e7c58db7-6b3a-4c56-87b2-fb705b91c1bb"
*9378	TBL1640 
replace PATIENT="7209dc91-ddfa-4708-a18b-e620c260169f" if PATIENT=="39ced0fb-69f5-4111-a514-9476204a310e"



format date_LABDMY %td
drop TBLABTYPE LAB_VSRES DRUG_RES TB_DRUG RNA_L LAB_T LAB_DMY
merge m:1 PATIENT using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\DEM.dta", keepusing(FOLDER_NUMBER)
drop _merge 

drop if LAB_ID!="RNA"
gen LAB_CAT=.
replace LAB_CAT=1 if LAB_V<40
replace LAB_CAT=1 if LAB_V==99
replace LAB_CAT=1 if LAB_V==90
replace LAB_CAT=2 if LAB_V>=40 & LAB_V<1000
replace LAB_CAT=3 if LAB_V>=1000 & LAB_V<50000
replace LAB_CAT=4 if LAB_V>=50000 & LAB_V<1000000000
append using "D:\Users\msfuser\or GUINEA\IPD FU\Donkalab.dta"
append using "D:\Users\msfuser\or GUINEA\Bases de données\Tables TIER\ExtraVL.dta"


drop if LAB_CAT==.
label define VLCAT 1"<40/ND" 2"40-999" 3"1.000-50.000" 4">50.000"
label values LAB_CAT VLCAT



merge m:m PATIENT using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\PAT.dta", keepusing(date_HAART date_FRSVIS)



drop _merge
merge m:1 FOLDER_NUMBER using "D:\Users\msfuser\OR Guinea\IPD FU\Donkareshape.dta", keepusing(DatedAdmission1 Datedesortie1)

drop if _merge!=3
drop _merge
merge m:1 PATIENT using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\VISwidedonkaonly.dta", keepusing(Date2ndline)





***Lab data reshape for VL


gen dateVLsinceART=date_LABDMY-date_HAART
gen dateVLsincefst=date_LABDMY-date_FRSVIS
replace dateVLsincefst=. if dateVLsincefst<0
replace dateVLsinceART=. if dateVLsinceART<0

gen VLdatesincesortie=date_LABDMY-Datedesortie1
gen VLdatesinceadmission=date_LABDMY-DatedAdmission
gen VLdatesince2ndlineswitch=date_LABDMY-Date2ndline

drop _merge


sort PATIENT date_LABDMY
by PATIENT : gen j=_n
sort PATIENT date_LABDMY
by PATIENT : gen numbervltest=_N
sort PATIENT
drop LAB_ID
rename LAB_V VL
rename date_LABDMY date_VL

gen lstVL=.
replace lstVL=1 if j==numbervltest
replace lstVL=2 if j==(numbervltest-1)



drop VL
drop D Afterhosp NamematchBDDCRR IsitintheBDDCR OutcomeBDDCR Column1 Datedesortie
drop date_FRSVIS date_HAART DatedAdmission1 Datedesortie1 Namematch Date2ndline  alternativecode
*drop FOLDER_NUMBER
drop if LAB_CAT==.

browse if FOLDER_NUMBER=="CLY1202" | FOLDER_NUMBER=="FLB0651" | FOLDER_NUMBER=="FLB2464M" | FOLDER_NUMBER=="FLB2603M" | FOLDER_NUMBER=="FLB2732" | FOLDER_NUMBER=="FLB3024" | FOLDER_NUMBER=="GP968" | FOLDER_NUMBER=="MIN1234" | FOLDER_NUMBER=="MIN2588M" | FOLDER_NUMBER=="MIN2643" | FOLDER_NUMBER=="MIN3001" | FOLDER_NUMBER=="TBL1232" | FOLDER_NUMBER=="TBL1325" | FOLDER_NUMBER=="TBL937M" | FOLDER_NUMBER=="WA2929" 
replace LAB_CAT=4 if PATIENT=="0a1b9cd5-3ea6-440c-9b44-31a485da32dc" &	date_VL==d(08jan2018)

duplicates tag date_VL FOLDER_NUMBER, generate(duplicates)

replace LAB_CAT=1 if PATIENT=="84113827-02ca-40a6-b8e9-7bc250aa0dcb" & LAB_CAT==4
replace date_VL=d(23sep2018) if PATIENT=="84113827-02ca-40a6-b8e9-7bc250aa0dcb" & LAB_CAT==3
drop if PATIENT=="aa4df6f2-2fe8-42a6-8010-b3daed5490fa" & j==2
drop if PATIENT=="b02b5572-61a2-4917-8b67-49d924d72f1c" & j==2

replace date_VL=d(20feb2018) if PATIENT=="cf3c617b-0d44-4afd-bb9f-354d48e0bfa8" & LAB_CAT==1
replace date_VL=d(24jan2017) if PATIENT=="c3c0f955-dd17-40f9-9c41-2c9d2de2363b" & LAB_CAT==3
replace LAB_CAT=1 if PATIENT=="c3c0f955-dd17-40f9-9c41-2c9d2de2363b" & LAB_CAT==3
drop duplicates

replace PATIENT="e0f2b965-4af0-4237-a793-fc9dfa2c8652" if FOLDER_NUMBER=="16105MAT"
replace PATIENT="e0f2b965-4af0-4117-a233-fc9dfa2c8652" if ( FOLDER_NUMBER=="15938" | FOLDER_NUMBER=="15938MAT")
replace FOLDER_NUMBER="15938" if FOLDER_NUMBER=="15938MAT"


drop mergeDEM
drop NOM
reshape wide LAB_CAT date_VL lstVL dateVLsincefst dateVLsinceART VLdatesincesortie VLdatesinceadmission VLdatesince2ndlineswitch, i(PATIENT) j(j)
*drop Datedesortie1 
*drop date_HAART date_FRSVIS DatedAdmission1 Date2ndline
save "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\VLWIDEdonka.dta", replace

***Lab data reshape for CD4
import excel "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\LAB.xlsx", sheet("LAB") firstrow clear
destring LAB_V, replace force
generate date_LABDMY = date(LAB_DMY, "YMD")
*FOLDER_NUMBER	
*1119	TBL1957 
replace PATIENT="48cf3956-a034-491a-9293-60c9919ae24a" if PATIENT=="749504e9-731e-4ac8-b20a-a19ff7af9a0f"
*12540	TBL1711 
replace PATIENT="fc913d80-bef8-40c2-862d-09f8a52ec349" if PATIENT=="51c841ac-87fc-4f10-aecf-416c356b047d"
*14129	TBL1723 
replace PATIENT="048ddb4e-fd1e-4b8f-b14d-c49eb6ba8774" if PATIENT=="12895791-769d-4788-8ef5-b398a677e21e"
*14641	MIN3538 
replace PATIENT="58016668-77a7-48df-b4b8-1cccc17e75fb" if PATIENT=="e6edb8c9-0580-4dfe-ac28-545c86e8cac9"
*14656	TBL2056 
replace PATIENT="0e148d5c-5afa-4f7a-86ea-9293d087ea5f" if PATIENT=="4763cc0e-edcf-46af-a2c8-43d96f71e555"
*14901	FLB2892M 
replace PATIENT="4c2cdc76-4ac8-4f03-9706-aa0be844c7fd" if PATIENT=="62175593-e3d1-4e76-8cc5-7d44eb177799"
*15061	TBL1822 
replace PATIENT="b95fda07-20b2-4fb2-94ed-67c4911f6455" if PATIENT=="8a388864-6415-4a83-9e77-f18d113f2d11"
*15513	TBL1753 
replace PATIENT="6bf22e91-5a14-45b5-a0ef-079891d261ed" if PATIENT=="0aeda05b-7b59-4f07-9a51-a210b159f8be"
*329	    CLY1680M 
replace PATIENT="84eb14eb-0280-4593-aba3-01b735ee4830" if PATIENT=="e7c58db7-6b3a-4c56-87b2-fb705b91c1bb"
*9378	TBL1640 
replace PATIENT="7209dc91-ddfa-4708-a18b-e620c260169f" if PATIENT=="39ced0fb-69f5-4111-a514-9476204a310e"



format date_LABDMY %td
drop TBLABTYPE LAB_VSRES DRUG_RES TB_DRUG RNA_L LAB_T LAB_DMY
merge m:1 PATIENT using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\DEM.dta", keepusing(FOLDER_NUMBER)
drop _merge 



merge m:m PATIENT using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\PAT.dta", keepusing(date_HAART date_FRSVIS)



drop _merge
merge m:1 FOLDER_NUMBER using "D:\Users\msfuser\OR Guinea\IPD FU\Donkareshape.dta", keepusing(DatedAdmission1 Datedesortie1)

drop if _merge!=3
drop _merge
merge m:1 PATIENT using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\VISwidedonkaonly.dta", keepusing(Date2ndline)

drop if strmatch(LAB_ID,"*CD4*")==0
duplicates drop LAB_ID date_LABDMY PATIENT, force



sort PATIENT date_LABDMY
by PATIENT : gen j=_n
sort PATIENT date_LABDMY
by PATIENT : gen numberCD4test=_N
gen lstCD4=.
replace lstCD4=1 if j==numberCD4test
replace lstCD4=2 if j==(numberCD4test-1)
sort PATIENT
rename LAB_ID CD4_ID
rename LAB_V CD4
rename date_LABDMY date_CD4


gen dateCD4sinceART=date_CD4-date_HAART
gen dateCD4sincefst=date_CD4-date_FRSVIS
replace dateCD4sincefst=. if dateCD4sincefst<0
replace dateCD4sinceART=. if dateCD4sinceART<0

gen CD4datesincesortie=date_CD4-Datedesortie1
gen CD4datesinceadmission=date_CD4-DatedAdmission
gen CD4datesince2ndlineswitch=date_CD4-Date2ndline

drop _merge
reshape wide CD4 date_CD4 CD4_ID lstCD4 dateCD4sincefst dateCD4sinceART CD4datesincesortie CD4datesinceadmission CD4datesince2ndlineswitch, i(PATIENT) j(j)
drop Datedesortie1 
drop date_HAART date_FRSVIS DatedAdmission1 Date2ndline

save "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\CD4WIDEdonka.dta", replace


***merge dataset
use "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\PAT.dta", clear
drop TB_FHV PREG_FHV
merge m:1 PATIENT using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\VLWIDEdonka.dta"
drop _merge
merge m:1 PATIENT using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\CD4WIDEdonka.dta"
drop _merge

merge m:1 PATIENT using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\VISwidedonkaonly.dta"
drop _merge
merge m:1 PATIENT using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\DEM.dta"
***
drop HOME_ADDRESS_1 HOME_ADDRESS_2 HOME_ADDRESS_3 HOME_ADDRESS_4  POST_CODE HOME_NUMBER _merge ID_NUMBER

save "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\TotalMerge.dta", replace


egen datenextvisit=rowmax(date_NXTVIS*)
format datenextvisit %td
gen dayssincelstappt=(d(04nov2018)-datenextvisit)
egen date_visite=rowmax(date_VISIT*)
format date_visite %td


label define OUTCOME 11 "Dead" 20 "Alive" 30 "TO" 40 "LTFU" 41 "PLTFU" 95 "less than 6M"

replace OUTCOME=40 if dayssincelstappt>90 & OUTCOME==41 
replace OUTCOME=40 if dayssincelstappt>90 & OUTCOME==95 
replace OUTCOME=40 if dayssincelstappt>90 & OUTCOME==20
replace OUTCOME=20 if dayssincelstappt<=90 & OUTCOME==41 
replace OUTCOME=20 if dayssincelstappt<=90 & OUTCOME==40 
replace OUTCOME=20 if dayssincelstappt<=90 & OUTCOME==95 


label values OUTCOME OUTCOME 

gen outcome_fin=1 if (OUTCOME==11 | OUTCOME==40)& OUTCOME!=.
replace outcome_fin=0 if ( OUTCOME==30| OUTCOME==.)
replace outcome_fin=0 if outcome_fin==.
tab outcome_fin


gen outcome_dead=1 if (OUTCOME==11) & OUTCOME!=.
replace outcome_dead=0 if ( OUTCOME==30| OUTCOME==40 | OUTCOME==.)
replace outcome_dead=0 if outcome_dead==.
tab outcome_dead, missing

gen outcome_ltfu=1 if (OUTCOME==40 ) & OUTCOME!=.
replace outcome_ltfu=0 if ( OUTCOME==30|  OUTCOME==.)
replace outcome_ltfu=0 if outcome_ltfu==.
tab outcome_ltfu OUTCOME, missing

gen outcome_to=1 if (OUTCOME==30 ) & OUTCOME!=.
replace outcome_to=0 if ( OUTCOME==11| OUTCOME==40| OUTCOME==.)
replace outcome_to=0 if outcome_to==.
tab outcome_to OUTCOME, missing






*duréé sous ART




replace date_FRSVIS =date_VISIT1 if date_FRSVIS==.

replace date_OUTCOME= date_visite if OUTCOME==20

gen duree_art= (date_OUTCOME- date_HAART)/30.4
tab duree_art if duree_art<0
replace duree_art=. if duree_art<0
tab duree_art if duree_art>1000





tab R6M, missing


replace R6M=1 if (datenextvisit-date_visite)>175  & datenextvisit`i'!=. & date_visite`i'!=.
replace R6M=. if (datenextvisit-date_visite)<150

replace R6M=0 if R6M==.

gen R6Manypoint=0
forvalues i=1/193 {

	replace R6Manypoint=R6Manypoint+1 if (date_NXTVIS`i'-date_VISIT`i')>175 & date_NXTVIS`i'!=. & date_VISIT`i'!=.
}




replace R6Manypoint=1 if R6Manypoint>=1

gen dateR6M=.
format dateR6M %td
forvalues i=1/193	 {

	replace dateR6M=date_VISIT`i' if (date_NXTVIS`i'-date_VISIT`i')>175 & (dateR6M==.) & date_NXTVIS`i'!=. & date_VISIT`i'!=. 
}





***criteria for R6M eligibility

*gen timer6m=date_OUTCOME-dateR6M
*gen R6Meligible=0

*last 1 vL is less than 1000
*last 2 CD4 greater than 350
*age over 16
*forget WHO stage
*pregnant last visit
*not on 2nd line
*on treatment for at least 6 months


gen lstVL=.

forvalues i=1/11 {

	replace lstVL=LAB_CAT`i' if lstVL`i'==1
}


gen lstVLdate=.

label values lstVL VLCAT

forvalues i=1/11 {

	replace lstVLdate=date_VL`i' if date_VL`i'!=.
}
format lstVLdate %td

gen SndlstVL=.

forvalues i=1/11 {

	replace SndlstVL=LAB_CAT`i' if lstVL`i'==2
}


gen SndlstVLdate=.

forvalues i=1/11 {

	replace SndlstVLdate=date_VL`i' if date_VL`i'!=. & date_VL`i'!=lstVLdate
}
label values SndlstVL VLCAT
format SndlstVLdate %td
browse lstVL lstVLdate SndlstVL SndlstVLdate LAB_CAT* date_VL* lstVL*

*replace R6Meligible=1 if lstVL<1000 & lstVL!=.

*gen reasonR6M=""
*replace reasonR6M="VL" if R6Meligible==1

gen lstCD4=.

forvalues i=1/15 {

	replace lstCD4=CD4`i' if lstCD4`i'==1 
}


gen SndlstCD4=.

forvalues i=1/15 {

	replace SndlstCD4=CD4`i' if lstCD4`i'==2 
}
browse lstCD4 SndlstCD4 CD4* 

*replace R6Meligible=1 if lstCD4>350 & SndlstCD4>350 & CD4_ID1=="CD4A" & lstCD4!=. & SndlstCD4!=.

*replace reasonR6M="CD4" if (lstCD4>350 & SndlstCD4>350 & CD4_ID1=="CD4A" & lstCD4!=. & SndlstCD4!=.) & (reasonR6M!="VL")



*replace R6Meligible=0 if WHOlstvist=="3" | WHOlstvist=="4"




*replace R6Meligible=0 if Pregnantlstvist=="1"

*gen age=(date_visite-date_BIRTH)/365.4

*replace R6Meligible=0 if age<16 


*replace R6Meligible=0 if Date2ndline!=.


*gen timesinceart=date_visite-date_HAART

*replace R6Meligible=0 if OUTCOME!=20 & timesinceart<=265


*replace R6Meligible=0 if timesinceart<=175

merge m:m PATIENT using "D:\Users\msfuser\or GUINEA\IPD FU\Donkaanalysis.dta", keepusing (Namematch) 

drop if strmatch(Namematch,"*y*")==0
drop _merge
save "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\TotalMerge.dta", replace



***need to do the BDD de contrereferences
import excel "D:\Users\msfuser\or GUINEA\IPD FU\bdd Master.xlsx", sheet("BDD CR") firstrow clear


merge m:m FOLDER_NUMBER using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\DEM.dta", keepusing(PATIENT SURNAME FIRST_NAME)

browse Instudy _merge if Instudy!=""
drop if _merge==2
drop CodePatient 
drop _merge
merge m:m FOLDER_NUMBER using "D:\Users\msfuser\or GUINEA\IPD FU\Donkaanalysis.dta", keepusing(NamematchBDDCRR)
drop if strmatch(NamematchBDDCRR,"*y*")==0
drop _merge
*drop if PATIENT==""
save "D:\Users\msfuser\or GUINEA\IPD FU\BdDdecontrereferences.dta", replace


use "D:\Users\msfuser\or GUINEA\IPD FU\Donkaanalysis.dta", clear

merge m:m PATIENT using "D:\Users\msfuser\OR Guinea\Bases de données\Tables TIER\TotalMerge.dta" 
rename _merge mergetier
tab mergetier Namematch, missing
drop if mergetier==2
drop if mergeDEM==2

merge m:m FOLDER_NUMBER using "D:\Users\msfuser\or GUINEA\IPD FU\BdDdecontrereferences.dta"


rename _merge mergeCR
tab mergeCR NamematchBDDCRR, missing
drop if mergeCR==2
merge m:1 FOLDER_NUMBER using "D:\Users\msfuser\or GUINEA\IPD FU\Donkareshape.dta"
drop _merge
merge m:1 FOLDER_NUMBER using "D:\Users\msfuser\or GUINEA\IPD FU\Matamhospireshape.dta"
drop if _merge==2
rename _merge mergeBDDHospiMatam

drop D Afterhosp IsitintheBDDCR OutcomeBDDCR Column1

drop CVadmis
drop NOM
drop  PrénometNom
drop Nom1
*drop lstCD4*
drop AF AG AH
drop if FOLDER_NUMBER=="0M"
drop if FOLDER_NUMBER=="0"


*drop if Namematch1=="nm"
*drop if Namematch1==""


drop dateCD4sinceART* dateCD4sincefst* CD4datesincesortie* CD4datesinceadmission* CD4datesince2ndlineswitch*

gen R6Mcurrent=.
replace R6Mcurrent=1 if (datenextvisit-date_visite)>175  & datenextvisit`i'!=. & date_visite`i'!=.
replace R6M=. if (datenextvisit-date_visite)<150

drop j
drop numberhosp

sort FOLDER_NUMBER DatedAdmission
by FOLDER_NUMBER : gen j=_n
sort FOLDER_NUMBER DatedAdmission
by FOLDER_NUMBER : gen numberhosp=_N
                
* TypedePriseenCharge  TypedeSortieMatam 
*DatedeRetourUSFR DatedArrivéeUSFR DateSortieUSFR TypedeSortieUSFR ModedeSortieFinal 
*RendezVousauCentre Sortie1 Sortie2 Datedesortie2 Sortie8 Datedesortie8 DatedesortieMatam1 TypedeSortieMatam1 
*TypedeSortieMatam6 DatedesortieMatam6


**final outcome is equal to first hospitalisation outcome

drop if Sortie1==.
gen final_outcome=""
replace final_outcome="Amélioré USFR" if Sortie1==1
replace final_outcome="Contre Avis Médical USFR" if Sortie1==2
replace final_outcome="Décédé USFR" if Sortie1==3
replace final_outcome="Evadé USFR" if Sortie1==4
replace final_outcome="Référé USFR" if Sortie1==5



gen final_outcomedate=Datedesortie1
format final_outcomedate %td


***replacing all other hospitalisation outcomes 
replace final_outcome="Amélioré USFR" if (Datedesortie2>final_outcomedate & Datedesortie2!=. & Sortie2==1)
replace final_outcome="Décédé USFR" if (Datedesortie2>final_outcomedate & Datedesortie2!=. & Sortie2==3)
replace final_outcome="Référé USFR" if (Datedesortie2>final_outcomedate & Datedesortie2!=. & Sortie2==5)
replace final_outcomedate=Datedesortie2 if (Datedesortie2>final_outcomedate & Datedesortie2!=.)

replace final_outcome="Amélioré USFR" if (Datedesortie3>final_outcomedate & Datedesortie3!=. & Sortie3==1)
replace final_outcome="Décédé USFR" if (Datedesortie3>final_outcomedate & Datedesortie3!=. & Sortie3==3)
replace final_outcome="Référé USFR" if (Datedesortie3>final_outcomedate & Datedesortie3!=. & Sortie3==5)
replace final_outcomedate=Datedesortie3 if (Datedesortie3>final_outcomedate & Datedesortie3!=.)

replace final_outcome="Amélioré USFR" if (Datedesortie4>final_outcomedate & Datedesortie4!=. & Sortie4==1)
replace final_outcome="Décédé USFR" if (Datedesortie4>final_outcomedate & Datedesortie4!=. & Sortie4==3)
replace final_outcomedate=Datedesortie4 if (Datedesortie4>final_outcomedate & Datedesortie4!=.)

replace final_outcome="Amélioré USFR" if (Datedesortie5>final_outcomedate & Datedesortie5!=. & Sortie5==1)
replace final_outcome="Evadé USFR" if (Datedesortie5>final_outcomedate & Datedesortie5!=. & Sortie5==4)
replace final_outcomedate=Datedesortie5 if (Datedesortie5>final_outcomedate & Datedesortie5!=.)

replace final_outcome="Amélioré USFR" if (Datedesortie6>final_outcomedate & Datedesortie6!=. & Sortie6==1)
replace final_outcomedate=Datedesortie6 if (Datedesortie6>final_outcomedate & Datedesortie6!=.)

replace final_outcome="Amélioré USFR" if (Datedesortie7>final_outcomedate & Datedesortie7!=. & Sortie7==1)
replace final_outcomedate=Datedesortie7 if (Datedesortie7>final_outcomedate & Datedesortie7!=.)

*replace final_outcome="Amélioré USFR" if (Datedesortie8>final_outcomedate & Datedesortie8!=. & Sortie8==1)
*replace final_outcomedate=Datedesortie8 if (Datedesortie8>final_outcomedate & Datedesortie8!=.)



***Matam hospi dates
replace final_outcome="Amélioré Matam IPD" if (DatedesortieMatam1>final_outcomedate & DatedesortieMatam1!=. & TypedeSortieMatam1=="Amélioré")
replace final_outcome="Amélioré Matam IPD" if (DatedesortieMatam1>final_outcomedate & DatedesortieMatam1!=. & TypedeSortieMatam1=="Améloré")
replace final_outcome="Contre Avis Médical Matam IPD" if (DatedesortieMatam1>final_outcomedate & DatedesortieMatam1!=. & TypedeSortieMatam1=="Contre Avis Médical")
replace final_outcome="Référé Matam IPD" if (DatedesortieMatam1>final_outcomedate & DatedesortieMatam1!=. & TypedeSortieMatam1=="Référé")
replace final_outcomedate=DatedesortieMatam1 if (DatedesortieMatam1>final_outcomedate & DatedesortieMatam1!=.)

replace final_outcome="Amélioré Matam IPD" if (DatedesortieMatam2>final_outcomedate & DatedesortieMatam2!=. & TypedeSortieMatam2=="Amélioré")
replace final_outcome="Décédé Matam IPD" if (DatedesortieMatam2>final_outcomedate & DatedesortieMatam2!=. & TypedeSortieMatam2=="Décédé")
replace final_outcome="Contre Avis Médical Matam IPD" if (DatedesortieMatam2>final_outcomedate & DatedesortieMatam2!=. & TypedeSortieMatam2=="Contre Avis Médical")
replace final_outcome="Référé Matam IPD" if (DatedesortieMatam2>final_outcomedate & DatedesortieMatam2!=. & TypedeSortieMatam2=="Référé")
replace final_outcomedate=DatedesortieMatam2 if (DatedesortieMatam2>final_outcomedate & DatedesortieMatam2!=.)

replace final_outcome="Amélioré Matam IPD" if (DatedesortieMatam3>final_outcomedate & DatedesortieMatam3!=. & TypedeSortieMatam3=="Amélioré")
replace final_outcome="Référé Matam IPD" if (DatedesortieMatam3>final_outcomedate & DatedesortieMatam3!=. & TypedeSortieMatam3=="Référé")
replace final_outcomedate=DatedesortieMatam3 if (DatedesortieMatam3>final_outcomedate & DatedesortieMatam3!=.)

replace final_outcome="Amélioré Matam IPD" if (DatedesortieMatam4>final_outcomedate & DatedesortieMatam4!=. & TypedeSortieMatam4=="Amélioré")
replace final_outcomedate=DatedesortieMatam4 if (DatedesortieMatam4>final_outcomedate & DatedesortieMatam4!=.)

replace final_outcome="Amélioré Matam IPD" if (DatedesortieMatam5>final_outcomedate & DatedesortieMatam5!=. & TypedeSortieMatam5=="Amélioré")
replace final_outcomedate=DatedesortieMatam5 if (DatedesortieMatam5>final_outcomedate & DatedesortieMatam5!=.)

replace final_outcome="Référé Matam" if (DatedesortieMatam6>final_outcomedate & DatedesortieMatam6!=. & TypedeSortieMatam6=="Référé")
replace final_outcomedate=DatedesortieMatam6 if (DatedesortieMatam6>final_outcomedate & DatedesortieMatam6!=.)


**final outcome Matam if finaloutcome data at Matam is superior
replace final_outcome="Décédé OPD Matam" if (DateOutcomeFinal>final_outcomedate & DateOutcomeFinal!=. & ModedeSortieFinal=="DCD")
replace final_outcome="Contre-refere de Matam" if (DateOutcomeFinal>final_outcomedate & DateOutcomeFinal!=. & ModedeSortieFinal=="Contre-référé")
replace final_outcome="Suivi Matam" if (DateOutcomeFinal>final_outcomedate & DateOutcomeFinal!=. & ModedeSortieFinal=="PDV")
replace final_outcome="PDV Matam" if (DateOutcomeFinal>final_outcomedate & DateOutcomeFinal!=. & ModedeSortieFinal=="LTFU")



**final outcome is equal to final outcome in tier.net, if tier.net outcome is after hospitalisation date
replace date_OUTCOME=final_outcomedate if strmatch(final_outcome,"*Décédé*")==1
replace OUTCOME=11 if strmatch(final_outcome,"*Décédé*")==1
replace final_outcome="Décédé tier centre" if (date_OUTCOME>final_outcomedate & date_OUTCOME!=. & OUTCOME==11 )
replace final_outcome="Actif tier centre" if (date_OUTCOME>final_outcomedate & date_OUTCOME!=. & OUTCOME==20)
replace final_outcome="Référé tier centre" if (date_OUTCOME>final_outcomedate & date_OUTCOME!=. & OUTCOME==30)
replace final_outcome="PDV Tier centre" if (date_OUTCOME>final_outcomedate & date_OUTCOME!=. & OUTCOME==40)
replace final_outcomedate=date_OUTCOME if (date_OUTCOME>final_outcomedate & date_OUTCOME!=. )



**final outcome is equal to arrival at Matam, if Matam arrival  is after hospitalisation date
replace final_outcome="Suivi Matam" if (DatedArrivéeàMatam>final_outcomedate & DatedArrivéeàMatam!=.)
replace final_outcomedate=DatedArrivéeàMatam if (DatedArrivéeàMatam>final_outcomedate & DatedArrivéeàMatam!=.)

**final outcome is equal to date leaving Matam, if Matam depart  is after hospitalisation date
replace final_outcome="Sortie de Matam" if (DatedeSortieMatam>final_outcomedate & DatedeSortieMatam!=.)
replace final_outcomedate=DatedeSortieMatam if (DatedeSortieMatam>final_outcomedate & DatedeSortieMatam!=.)

**final outcome is equal to date returning from USFR, if USFR return date to Matam is after hospitalisation date
replace final_outcome="Retourné à Matam de USFR" if (DatedeRetourUSFR>final_outcomedate & DatedeRetourUSFR!=.)
replace final_outcomedate=DatedeRetourUSFR if (DatedeRetourUSFR>final_outcomedate & DatedeRetourUSFR!=.)


replace final_outcomedate=DateOutcomeFinal if (DateOutcomeFinal>final_outcomedate & DateOutcomeFinal!=.)



gen dayssincefinaloutcome=(d(04nov2018)-final_outcomedate)

gen PDV=""
replace PDV="PDV" if dayssincefinaloutcome>100 
replace PDV="" if final_outcome=="Décédé OPD Matam"  | final_outcome=="Décédé tier centre" | final_outcome=="Décédé USFR" | final_outcome=="PDV Tier centre" 
replace PDV="" if final_outcome=="Référé tier centre"  | final_outcome=="Référé USFR" | final_outcome=="Référé Matam IPD " | final_outcome=="Référé Matam" | final_outcome=="Actif tier centre"
 

gen final_outcomewithPDV= PDV + " " + final_outcome 

replace  final_outcomedate=Datedesortie1 if Sortie1==3
replace  final_outcomewithPDV=" Décédé USFR" if Sortie1==3


browse FOLDER_NUMBER final_outcomewithPDV final_outcome final_outcomedate dayssincefinaloutcome dayssincelstappt OUTCOME date_OUTCOME DateOutcomeFinal  Datedesortie Sortie DatedeSortieMatam TypedeSortieMatam DateSortieUSFR Datedesortie1 Sortie1 Datedesortie2 Sortie2 Datedesortie3 Sortie3 Datedesortie4 Sortie4 Datedesortie5 Sortie5 Datedesortie6 Sortie6 Datedesortie7 Sortie7  DatedesortieMatam1 TypedeSortieMatam1 DatedesortieMatam2 TypedeSortieMatam2 DatedesortieMatam3 TypedeSortieMatam3 DatedesortieMatam4 TypedeSortieMatam4 DatedesortieMatam5 TypedeSortieMatam5 DatedesortieMatam6 TypedeSortieMatam6 

gen abletolink=""
replace abletolink="Linked" if strmatch(Namematch,"*y*")==1
replace abletolink="Linked" if strmatch(NamematchBDDCRR,"*y*")==1
replace abletolink="Linked" if DatedAdmissionMatam1!=.

***creating outcomes for survival analysis
gen outcomepost_fin=0  
replace outcomepost_fin=1 if strmatch(final_outcomewithPDV,"*Décédé*")==1
replace outcomepost_fin=1 if strmatch(final_outcomewithPDV,"*PDV*")==1
replace outcomepost_fin=. if Sortie1==3
replace outcomepost_fin=. if Sortie1==5
   
gen outcomepost_dead=0
replace outcomepost_dead=1 if strmatch(final_outcomewithPDV,"*Décédé*")==1
replace outcomepost_dead=. if Sortie1==3
replace outcomepost_dead=. if Sortie1==5


gen outcomepost_ltfu=0

replace outcomepost_ltfu=1 if strmatch(final_outcomewithPDV,"*PDV*")==1
replace outcomepost_ltfu=. if Sortie1==3
replace outcomepost_ltfu=. if Sortie1==5
 
gen outcomepost_to=0

replace outcomepost_to=1 if final_outcomewithPDV==" Référé USFR"
replace outcomepost_to=1 if final_outcomewithPDV==" Référé Matam"
replace outcomepost_to=1 if final_outcomewithPDV==" Référé tier centre"
replace outcomepost_to=. if Sortie1==3
replace outcomepost_to=. if Sortie1==5   

gen outcomepost=outcomepost_fin
replace outcomepost=3 if outcomepost_to==1
replace outcomepost=2 if outcomepost_dead==1
label define outcomepost 0 "Actif" 1 "PDV" 2 "DCD" 3 "TO"
label values outcomepost outcomepost

tab outcomepost outcomepost_ltfu
tab outcomepost outcomepost_to
tab outcomepost outcomepost_dead

   
 
tab final_outcomewithPDV outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing  
gen duree_posthospi= (final_outcomedate- Datedesortie1)/30.4 

browse FOLDER_NUMBER j Datedesortie1 duree_posthospi final_outcomewithPDV final_outcomedate outcomepost_fin outcomepost_dead outcomepost_ltfu outcomepost_to Sortie* Datedesortie* TypedeSortieMatam* DatedesortieMatam* OUTCOME  date_OUTCOME ModedeSortieFinal DateOutcomeFinal

 
replace LAB_CAT1= CVadmis1 if LAB_CAT1==.
replace date_VL1=DatedAdmission1 if date_VL1==. & CVadmis1!=.
replace VLdatesinceadmission1=0 if date_VL1==DatedAdmission1
replace LAB_CAT2= CVadmis2 if LAB_CAT2==.
replace date_VL2=DatedAdmission2 if date_VL2==. & CVadmis2!=.
replace LAB_CAT3= CVadmis3 if LAB_CAT3==.
replace date_VL3=DatedAdmission3 if date_VL3==. & CVadmis3!=.
replace LAB_CAT4= CVadmis4 if LAB_CAT4==.
replace date_VL4=DatedAdmission4 if date_VL4==. & CVadmis4!=.
replace LAB_CAT5= CVadmis5 if LAB_CAT5==.
replace date_VL5=DatedAdmission1 if date_VL5==. & CVadmis5!=.
replace LAB_CAT6= CVadmis6 if LAB_CAT6==.
replace date_VL6=DatedAdmission6 if date_VL6==. & CVadmis6!=.
replace LAB_CAT7= CVadmis7 if LAB_CAT7==.
replace date_VL7=DatedAdmission7 if date_VL7==. & CVadmis7!=.
*replace LAB_CAT8= CVadmis8 if LAB_CAT8==.
*replace date_VL8=DatedAdmission8 if date_VL8==. & CVadmis8!=.



gen VLbeforeadmission=.
forvalues i=11(-1)1 {

	replace VLbeforeadmission=LAB_CAT`i' if VLdatesinceadmission`i'<0 & VLbeforeadmission==.
} 



label values VLbeforeadmission VLCAT
label values CVadmis* VLCAT

gen VLadmission=.
forvalues i=1/11 {

	replace VLadmission=LAB_CAT`i' if VLdatesinceadmission`i'==0
} 

label values VLadmission VLCAT

gen nextVLafteradmission=.
forvalues i=1/11 {

	replace nextVLafteradmission=LAB_CAT`i' if VLdatesinceadmission`i'>0 & nextVLafteradmission==.
} 
 
 label values nextVLafteradmission VLCAT
 
gen dateVLbeforeadmission=.
forvalues i=11(-1)1 {

	replace dateVLbeforeadmission=date_VL`i' if VLdatesinceadmission`i'<0 & dateVLbeforeadmission==.
} 



gen dateVLadmission=.
forvalues i=1/11 {

	replace dateVLadmission=date_VL`i' if VLdatesinceadmission`i'==0
} 



gen datenextVLafteradmission=.
forvalues i=1/11 {

	replace datenextVLafteradmission=date_VL`i' if VLdatesinceadmission`i'>0 & datenextVLafteradmission==.
} 
 
format datenextVLafteradmission %td
format dateVLbeforeadmission %td
format dateVLadmission %td

gen timesinceVLbeforeadmission=dateVLbeforeadmission-DatedAdmission1 if dateVLbeforeadmission!=.
gen timesinceVLafteradmission=datenextVLafteradmission-DatedAdmission1 if datenextVLafteradmission!=.


browse  if duree_posthospi<0
browse if duree_posthospi>24
replace duree_posthospi=1/30 if duree_posthospi<=0

replace duree_posthospi=. if  Sortie1==3
replace duree_posthospi=. if  Sortie1==5
*replace duree_posthospi=. if  final_outcomewithPDV=="PDV "
*replace duree_posthospi=. if  final_outcomewithPDV==" "

gen d="d" if strmatch(FOLDER_NUMBER,"*D*")==1





gen month=month(DatedAdmission) 
gen year=year(DatedAdmission)

gen  timeperiod=.
replace timeperiod=1 if month==8 & year==2017 
replace timeperiod=2 if month==9 & year==2017 
replace timeperiod=3 if month==10 & year==2017 
replace timeperiod=4 if month==11 & year==2017 
replace timeperiod=5 if month==12 & year==2017 
replace timeperiod=6 if month==1 & year==2018 
replace timeperiod=7 if month==2 & year==2018 
replace timeperiod=8 if month==3 & year==2018 
replace timeperiod=9 if month==4 & year==2018 

label define timeperiod 1 "Aug 17" 2 "Sep 17" 3 "Oct 17" 4 "Nov 17" 5 "Dec 17" 6 "Jan 18"  7 "Feb 18"  8 "Mar 18" 9 "Apr 18" 
label values timeperiod timeperiod
tab deces if j==1

create WHOstage at inclusion
**first make clinical diagnosis at admission (if it fits WHO description for stage 3 or 4) into WHOstage
*tab depisté WHOstage3or4 , missing
*browse Diagnosticfinalprincipal1 Diagnosticfinalprincipal2 if WHOstage==. & depisté==3
*drop WHOstage
label define diaggroup_L 8"NCDs" 7"TBmeningitis" 6"TBclinical" 5"disseminatedTB" 4"pulmoTB" 3"other resp Inf"2"otherNeuro"1"otherHIVassoc", modify

gen otherHIV=0
*replace otherHIV=1 if diaggroup==1
replace otherHIV=1 if anémie==1 | Autre==1 | CandidOeso==1 | Diarr==1 |  Gale==1 | Hépatite==1 | Malnut==1 | Paludisme==1 | SK==1

replace otherHIV = 1 in 39

gen Neuro=0
*replace Neuro=1 if diaggroup==2
replace Neuro=2 if Meningitecryp==1 | Meningitebact==1 | Toxoplasmose==1

gen otherResp=0
*replace otherResp=1 if diaggroup==3
replace otherResp=3 if PCP==1 | Pneumbact==1 | Sepsis==1
gen pulmoTB=0
replace pulmoTB=4 if TypeTB==5 & Xpert==1 & LAM==0|Xpert==1 &LAM==.
replace pulmoTB=4 if TypeTB==6 & Xpert==1 & LAM==0|Xpert==1 &LAM==.
replace pulmoTB=4 if TypeTB==9 & Xpert==1 & LAM==0|Xpert==1 &LAM==.
replace pulmoTB=4 if TypeTB==11 & Xpert==1 & LAM==0|Xpert==1 &LAM==.
replace pulmoTB = 4 in 141
replace pulmoTB = 4 in 395
*replace pulmoTB=1 if diaggroup==4
gen dissemTB=0
replace dissemTB=5 if TypeTB==3 & LAM==1
replace dissemTB=5 if TypeTB==5 & LAM==1
replace dissemTB=5 if TypeTB==6 & LAM==1
replace dissemTB=5 if TypeTB==9 & LAM==1
replace dissemTB=5 if TypeTB==11 & LAM==1
*replace dissemTB=1 if diaggroup==5
gen TBclinical=0
replace TBclinical=6 if TypeTB==3 & LAM==0 &Xpert==0| TypeTB==3 & LAM==. & Xpert==0|TypeTB==3& Xpert==. &LAM==0
replace TBclinical=6 if TypeTB==5 & LAM==0 &Xpert==0| TypeTB==3 & LAM==. & Xpert==0|TypeTB==3& Xpert==. &LAM==0
replace TBclinical=6 if TypeTB==6 & LAM==0 &Xpert==0| TypeTB==3 & LAM==. & Xpert==0|TypeTB==3& Xpert==. &LAM==0
replace TBclinical=6 if TypeTB==9 & LAM==0 &Xpert==0| TypeTB==3 & LAM==. & Xpert==0|TypeTB==3& Xpert==. &LAM==0
replace TBclinical=6 if TypeTB==11 & LAM==0 &Xpert==0| TypeTB==3 & LAM==. & Xpert==0|TypeTB==3& Xpert==. &LAM==0
replace TBclinical = 6 in 60
replace TBclinical = 6 in 99
*replace TBclinical=1 if diaggroup==6
gen TBM=0
replace TBM=7 if TypeTB==4
*replace TBM=1 if diaggroup==7
gen NCD=0
replace NCD=8 if Insuffcardiaque==1 | Insuffrénale==1
*replace NCD=1 if diaggroup==8

label values otherHIV diaggroup_L
label values Neuro diaggroup_L
label values otherResp diaggroup_L
label values pulmoTB diaggroup_L
label values dissemTB diaggroup_L
label values TBclinical diaggroup_L
label values TBM  diaggroup_L
label values NCD diaggroup_L




gen WHOstage3or4=.
 replace WHOstage3or4=0 if FHV_STAGE_WHO==1
 replace WHOstage3or4=0 if FHV_STAGE_WHO==2
 replace WHOstage3or4=1 if FHV_STAGE_WHO==3
 replace WHOstage3or4=1 if FHV_STAGE_WHO==4
 tab WHOstage3or4 FHV_STAGE_WHO
 label define WHOstage_x 1 "yes" 0"no"
 label value WHOstage3or4 WHOstage_x


drop WHOstage
gen WHOstage=.
replace WHOstage=2 if Paludisme!=0 
replace WHOstage=3 if CandidOeso!=0 
replace WHOstage=3 if Diarr!=0 
replace WHOstage=3 if Meningitebact!=0 
replace WHOstage=3 if Pneumbact!=0 
replace WHOstage=3 if Gale!=0
replace WHOstage=3 if Hépatite!=0
replace WHOstage=3 if pulmoTB!=0
*drop WHOstage3
*gen WHOstage3=.
*replace WHOstage3=1 if WHOstage==3
replace WHOstage=4 if Meningitecryp!=0 
replace WHOstage=4 if Encéphalite!=0
replace WHOstage=4 if IRIS!=0 
replace WHOstage=4 if PCP!=0 
replace WHOstage=4 if Sepsis!=0 
replace WHOstage=4 if SK!=0
replace WHOstage=4 if Toxoplasmose!=0  
replace WHOstage=4 if Malnut!=0
replace WHOstage=4 if dissemTB!=0
replace WHOstage=4 if TBclinical!=0
replace WHOstage=4 if TBM!=0  
drop CD4catbin200
gen CD4catbin200=.
replace CD4catbin200=1 if CD4cat==1|CD4cat==2 
replace CD4catbin200=0 if CD4cat==3|CD4cat==4
replace WHOstage=4 if Insuffcardiaque!=0 & CD4catbin200==1
replace WHOstage=4 if Insuffrénale!=0 & CD4catbin200==1
*replace WHOstage=1 if WHOstage==2
browse WHOstage CandidOeso Diarr Encéphalite Gale Hépatite Insuffcardiaque Insuffrénale IRIS Meningitecryp Meningitebact Malnut Paludisme PCP Pneumbact Sepsis SK TypeTB Toxoplasmose if WHOstage==.
*now check distribution of added values
tab FHV_STAGE_WHO WHOstage , missing
tab FHV_STAGE_WHO WHOstage3or4, missing
*now select observations where WHO stage at admission==WHOstage at inclusion by choosing only those who have depisté==3 (=<4wks)
replace WHOstage=. if depisté!=3
tab WHOstage depisté, missing
*now integrate the new values into WHOstage3or4
tab WHOstage3or4
tab WHOstage3or4, missing nolabel
gen WHOstagecomb=FHV_STAGE_WHO  
replace WHOstagecomb=WHOstage if WHOstagecomb==.
browse WHOstage3or4 WHO FHV_STAGE_WHO WHOstage CandidOeso Diarr Encéphalite Gale Hépatite Insuffcardiaque Insuffrénale IRIS Meningitecryp Meningitebact Malnut Paludisme PCP Pneumbact Sepsis SK TypeTB Toxoplasmose

gen WHOstagecomb2=WHOstagecomb
recode WHOstagecomb2 4=3
recode WHOstagecomb2 2=1

**analysis section starts here (some further variables were created as we went along that remain below)



*To describe demographic and clinical characteristics (CD4, VL, ART status, ART failure, clinical conditions and morbidities) at admission and at exit/event of critically ill patients admitted in IPD;
tab Agecat deces if DatedAdmission>=d(01/08/2017) & DatedAdmission<=d(30/04/2018) & j==1, missing  exact chi row
tab Sex deces if DatedAdmission>=d(01/08/2017) & DatedAdmission<=d(30/04/2018) & j==1, missing  chi row
tab CD4cat deces if ARVstatut==4 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi row
tab CD41cat deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi row
tab WHOstagecomb deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing exact row
tab CVadmis1 deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, chi row
tab VL2admis deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi row
tab Neurocomb deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi row
tab rehospdonka deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi row

tab lastVL deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab ARVadmission deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab ARVstatut deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1,  chi
tab dateinitiation deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab ARVsortie deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab CVcat deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab switch deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1,  chi
tab init deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab interruption deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi row
tab temp deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi 
tab signcutanées deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab signresp deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab malnut deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab signesGI deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab GCS deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab meninges deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab signesneuro deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab symp2sem deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab LAMdone deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab LAM deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Xpertdone deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Xpert deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Cragsang deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Cragsangdone deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab CragLCR deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab CragLCRdone deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab PSI deces if Duréedeséjour>=2 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Sex deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab anémie deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Autre deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab CandidOeso deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Diarr deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Encéphalite deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Gale deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Hépatite deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Insuffcardiaque deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Insuffrénale deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab IRIS deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Meningitecryp deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Meningitebact deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Malnut deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Paludisme deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab PCP deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Pneumbact deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Sepsis deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab SK deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab TypeTB deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab Toxoplasmose deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi row
tab RaisDCD deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab diaggroup deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab VLbeforeadmission abletolink if ( ARVstatut==4 ) & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi row
tab VLbeforeadmission ARVstatut if abletolink=="Linked" & (ARVstatut==2 | ARVstatut==4 ) & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi row
browse  ARVstatut dateVLbeforeadmission DatedAdmission Date2ndline  if VLbeforeadmission>2 & abletolink=="Linked" & ( ARVstatut==4 ) & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1

* calcul médiane et moyenne avec IQ et max et min*
summarize CD4admis if deces==1 &DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1,  detail
summarize CD4admis if deces==0 &DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, detail
summarize CD4admis if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, detail
* test des médiane*
median CD4admis if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, by(deces) exact medianties(below)


summarize CD4admis if outcomepost==0 & DatedAdmission1>=d(01aug2017) & abletolink=="Linked" & DatedAdmission1<=d(30apr2018) & j==1 & suivi==1, detail
summarize CD4admis if outcomepost==1 & DatedAdmission1>=d(01aug2017) & abletolink=="Linked" & DatedAdmission1<=d(30apr2018) & j==1 & suivi==1, detail
summarize CD4admis if outcomepost==2 & DatedAdmission1>=d(01aug2017) & abletolink=="Linked" & DatedAdmission1<=d(30apr2018) & j==1 & suivi==1, detail
summarize CD4admis if outcomepost==3 & DatedAdmission1>=d(01aug2017) & abletolink=="Linked" & DatedAdmission1<=d(30apr2018) & j==1 & suivi==1, detail
summarize CD4admis if DatedAdmission1>=d(01aug2017) & abletolink=="Linked" & DatedAdmission1<=d(30apr2018) & j==1 & suivi==1, detail
median CD4admis if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, by(outcomepost) exact medianties(below)


summarize Age if outcomepost==0 & abletolink=="Linked" & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1 & suivi==1, detail
summarize Age if outcomepost==1 & abletolink=="Linked" & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1 & suivi==1, detail
summarize Age if outcomepost==2 & abletolink=="Linked" & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1 & suivi==1, detail
summarize Age if outcomepost==3 & abletolink=="Linked" & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1 & suivi==1, detail
summarize Age if  DatedAdmission1>=d(01aug2017) & abletolink=="Linked"& DatedAdmission1<=d(30apr2018) & j==1 & suivi==1, detail
median Age if DatedAdmission1>=d(01aug2017) & abletolink=="Linked" & DatedAdmission1<=d(30apr2018) & j==1 & suivi==1, by(outcomepost) exact medianties(below)

summarize Age if deces==1 &DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1,  detail
summarize Age if deces==0 &DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, detail
summarize Age if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, detail

median Age if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, by(deces) exact medianties(below)

tab visitb4hosplocation deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, chi miss
tab timebeforehospcat deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, chi miss



*To describe rates of mortality <48h and >48h of hospitalization in IPD amongst critically ill patients admitted in USFR;
tab deces
gen deces48h=deces
replace deces48h=2 if Duréedeséjour>1
replace deces48h=. if Datedesortie==.
replace deces48h=0 if deces==0
label define deces48h 0 "living" 1 "<48h" 2 ">48h"
label values deces48h deces48h

tab timeperiod deces48h  if j==1
tab timeperiod deces48h 
regress timeperiod deces
tab timeperiod outcomepost6M  if j==1 & abletolink=="Linked"
tab timeperiod outcomepost_fin  if j==1 & abletolink=="Linked"

*To describe the effects of Low Level Viraemia on outcomes in this population
tab CVadmis1 deces if DatedAdmission1>d(01aug2017) & DatedAdmission1<d(30apr2018) & j==1, chi row


*To describe timing of ART initiation of HIV naïve patients admitted and switched to second line (or third line) of patients admitted with virological ART failure. 
tab ARVadmission deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab ARVstatut deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, exact col
tab dateinitiation deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab ARVsortie deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab init deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab CVcat deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab switch deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab switch deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi

tab signcutanées deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab signresp deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi

tab signesGI deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi

  

*To describe main cause of death notified for patients during hospitalization;
tab Diagmaj deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
browse FOLDER_NUMBER DatedAdmission1 if Diagmaj==""

replace Diagmaj="TB Cerebrale" if FOLDER_NUMBER=="6277"
replace Diagmaj="?" if FOLDER_NUMBER=="WA2957"


	
	



*To describe outcomes at 6 and 12 months after hospitalization amongst the cohort of patients that was admitted in IPD.
stset duree_posthospi,failure (outcomepost_fin==1)
stset duree_posthospi,failure (outcomepost_dead==1)
stset duree_posthospi,failure (outcomepost_ltfu==1)
stset duree_posthospi,failure (outcomepost_to==1)

ltable duree_posthospi outcomepost_fin if DatedAdmission1>d(01aug2017) & DatedAdmission1<d(30apr2018) & abletolink=="Linked" & j==1, interval (0 3 6 12) 
ltable duree_posthospi outcomepost_dead if DatedAdmission1>d(01aug2017) & DatedAdmission1<d(30apr2018) & abletolink=="Linked" & j==1, interval (0 6 12) graph 
ltable duree_posthospi outcomepost_ltfu if DatedAdmission1>d(01aug2017) & DatedAdmission1<d(30apr2018) & abletolink=="Linked" & j==1, interval (0 6 12) graph 
ltable duree_posthospi outcomepost_to if DatedAdmission1>d(01aug2017) & DatedAdmission1<d(30apr2018) & abletolink=="Linked" & j==1, interval (0 6 12) graph 

ltable duree_posthospi outcomepost_to if DatedAdmission1>d(01aug2017) & DatedAdmission1<d(30apr2018) & abletolink=="Linked" & j==1, interval (0 6 12) graph 

*To describe outcomes (RIC and virological suppression) of patients over the study period.
gen outcomepost6M=0
replace outcomepost6M=1 if outcomepost_dead==1
replace outcomepost6M=2 if outcomepost_ltfu==1
replace outcomepost6M=3 if outcomepost_to==1
replace outcomepost6M=0 if duree_posthospi>=6
replace outcomepost6M=. if duree_posthospi==.

label define outcomepost6M 0 "Active" 1 "Dead" 2 "LTFU" 3 "TO" 
label values outcomepost6M outcomepost6M

tab outcomepost6M if DatedAdmission1>d(01aug2017) & DatedAdmission1<d(30apr2018) & abletolink=="Linked" & j==1
tab outcomepost6M ARVstatut if DatedAdmission1>d(01aug2017) & DatedAdmission1<d(30apr2018) & abletolink=="Linked" & j==1, chi col

gen outcomepost12M=0
replace outcomepost12M=1 if outcomepost_dead==1
replace outcomepost12M=2 if outcomepost_ltfu==1
replace outcomepost12M=3 if outcomepost_to==1
replace outcomepost12M=0 if duree_posthospi>=12
replace outcomepost12M=. if (d(4nov2018)-Datedesortie1)<365
replace outcomepost12M=. if duree_posthospi==.

label define outcomepost12M 0 "Active" 1 "Dead" 2 "LTFU" 3 "TO" 
label values outcomepost12M outcomepost12M

tab outcomepost12M if DatedAdmission1>d(01aug2017) & DatedAdmission1<d(30apr2018) & abletolink=="Linked" & j==1

*label define outcomepost6M 0 "Active" 1 "Dead" 2 "LTFU" 3 "TO" 
*label values outcomepost6M outcomepost6M


replace ARVsortie2=3 if ARVsortie2==4
replace ARVsortie3=3 if ARVsortie3==4
replace ARVsortie4=3 if ARVsortie4==4
replace ARVsortie5=3 if ARVsortie5==4
replace ARVsortie6=3 if ARVsortie6==4
replace ARVsortie7=3 if ARVsortie7==4
*replace ARVsortie8=3 if ARVsortie8==4

gen ARVfollowup=ARVstatut1
replace ARVfollowup=3 if ARVfollowup==4

replace ARVfollowup=5 if init==1
replace ARVfollowup=5 if ARV1=="premier ligne" & ARVfollowup==1
replace ARVfollowup=5 if ARV2=="premier ligne" & ARVfollowup==1
replace ARVfollowup=5 if ARV3=="premier ligne" & ARVfollowup==1
replace ARVfollowup=5 if ARV4=="premier ligne" & ARVfollowup==1
replace ARVfollowup=5 if ARV5=="premier ligne" & ARVfollowup==1
replace ARVfollowup=5 if ARV6=="premier ligne" & ARVfollowup==1
replace ARVfollowup=5 if Date1stline>Datedesortie1 & Date1stline!=.

replace ARVfollowup=4 if switch==1
replace ARVfollowup=4 if ARVsortie2==2 & ARVfollowup==3
replace ARVfollowup=4 if ARVsortie3==2 & ARVfollowup==3
replace ARVfollowup=4 if ARVsortie4==2 & ARVfollowup==3
replace ARVfollowup=4 if ARVsortie5==2 & ARVfollowup==3
replace ARVfollowup=4 if ARVsortie6==2 & ARVfollowup==3
replace ARVfollowup=4 if ARVsortie7==2 & ARVfollowup==3
*replace ARVfollowup=4 if ARVsortie8==2 & ARVfollowup==3
replace ARVfollowup=3 if ARVfollowup==. & ARVadmission==5
replace ARVfollowup=1 if ARVfollowup==. & ARVadmission==3
replace ARVfollowup=3 if ARVfollowup==. & ARVsortie==3
replace ARVfollowup=3 if date_HAART<Datedesortie1 & ARVfollowup==. 
replace ARVfollowup=5 if date_HAART>Datedesortie1 & ARVfollowup==. & date_HAART!=.

replace ARVfollowup=4 if Date2ndline>Datedesortie1 & Date2ndline!=. & ARVfollowup!=2

label define ARVfollowup 1 "pas initié" 2 "2ieme ligne" 3 "1ere ligne" 4 "switched 2nd line" 5 "initiated" 
label values ARVfollowup ARVfollowup

browse FOLDER_NUMBER ARVfollowup Datedesortie1 date_FRSVIS Date2ndline Date1stline date_HAART ARVadmission ARVstatut ARVsortie firstregime secondregime thirdregime fourthregime fifthregime sixthregime seventhregime eigthregime secondlineregimen ARVAdmissionMatam RégimeARV ARVstatut1 ARVsortie1 ARVstatut2 ARVsortie2 ARVstatut3 ARVsortie3 ARVstatut4 ARVsortie4 ARVstatut5 ARVsortie5 ARVstatut6 ARVsortie6 ARVstatut7 ARVsortie7  ARV1 ARV2 ARV3 ARV4 ARV5 ARV6


gen Neurocomb=.
replace Neurocomb=1 if GCS==1
replace Neurocomb=1 if meninges==3
replace Neurocomb=1 if signesneuro==3
replace Neurocomb=3 if GCS ==. & meninges==. & signesneuro==.
replace Neurocomb=0 if Neurocomb==.
replace Neurocomb=. if Neurocomb==3
label var Neurocomb "at least 1Neurosign"
label define Neurocomb_l 0"no" 1"yes"
label values Neurocomb Neurocomb_l
tab Neurocomb deces, row chi2

gen VLfollowup=.
replace VLfollowup=1 if lstVL==. & SndlstVL==.
replace VLfollowup=2 if lstVL==1 & SndlstVL==.
replace VLfollowup=2 if lstVL==1 & SndlstVL==1
replace VLfollowup=3 if lstVL==2 & SndlstVL==.
replace VLfollowup=3 if lstVL==2 & SndlstVL==1
replace VLfollowup=3 if lstVL==1 & SndlstVL==2
replace VLfollowup=3 if lstVL==2 & SndlstVL==2
replace VLfollowup=4 if lstVL==3 & SndlstVL==.
replace VLfollowup=4 if lstVL==4 & SndlstVL==.
replace VLfollowup=5 if lstVL==4 & SndlstVL==4
replace VLfollowup=5 if lstVL==3 & SndlstVL==4
replace VLfollowup=5 if lstVL==3 & SndlstVL==3
replace VLfollowup=5 if lstVL==4 & SndlstVL==3
replace VLfollowup=4 if lstVL==4 & SndlstVL==2
replace VLfollowup=4 if lstVL==4 & SndlstVL==1
replace VLfollowup=4 if lstVL==3 & SndlstVL==1
replace VLfollowup=4 if lstVL==3 & SndlstVL==2
replace VLfollowup=6 if lstVL==2 & SndlstVL==4
replace VLfollowup=6 if lstVL==1 & SndlstVL==4
replace VLfollowup=6 if lstVL==1 & SndlstVL==3
replace VLfollowup=6 if lstVL==2 & SndlstVL==3
label define VLfollowup 1"No VL result" 2 "VL TND" 3 "1+ VL 40-999 copies/ml" 4 "1VL>=1000" 5 "2VL >1000" 6 "2VL 1st >1000 2nd <1000"
label values VLfollowup VLfollowup


gen VL2admis=.
label values VL2admis VLfollowup
replace VL2admis=1 if CVadmis1==. & VLbeforeadmission==.
replace VL2admis=2 if CVadmis1==1 & VLbeforeadmission==.
replace VL2admis=2 if CVadmis1==1 & VLbeforeadmission==1
replace VL2admis=3 if CVadmis1==2 & VLbeforeadmission==.
replace VL2admis=3 if CVadmis1==2 & VLbeforeadmission==1
replace VL2admis=3 if CVadmis1==1 & VLbeforeadmission==2
replace VL2admis=3 if CVadmis1==2 & VLbeforeadmission==2
replace VL2admis=4 if CVadmis1==3 & VLbeforeadmission==.
replace VL2admis=4 if CVadmis1==4 & VLbeforeadmission==.
replace VL2admis=5 if CVadmis1==4 & VLbeforeadmission==4
replace VL2admis=5 if CVadmis1==3 & VLbeforeadmission==4
replace VL2admis=5 if CVadmis1==3 & VLbeforeadmission==3
replace VL2admis=5 if CVadmis1==4 & VLbeforeadmission==3
replace VL2admis=4 if CVadmis1==4 & VLbeforeadmission==2
replace VL2admis=4 if CVadmis1==4 & VLbeforeadmission==1
replace VL2admis=4 if CVadmis1==3 & VLbeforeadmission==1
replace VL2admis=4 if CVadmis1==3 & VLbeforeadmission==2
replace VL2admis=6 if CVadmis1==2 & VLbeforeadmission==4
replace VL2admis=6 if CVadmis1==1 & VLbeforeadmission==4
replace VL2admis=6 if CVadmis1==1 & VLbeforeadmission==3
replace VL2admis=6 if CVadmis1==2 & VLbeforeadmission==3
replace VL2admis=4 if CVadmis1==. & VLbeforeadmission==4
replace VL2admis=4 if CVadmis1==. & VLbeforeadmission==3
replace VL2admis=3 if CVadmis1==. & VLbeforeadmission==2
replace VL2admis=2 if CVadmis1==. & VLbeforeadmission==1

gen VL3admis=VL2admis
label values VL3admis VLfollowup
replace VL3admis=5 if CVadmis1==4 & nextVLafteradmission==4
replace VL3admis=5 if CVadmis1==3 & nextVLafteradmission==4
replace VL3admis=5 if CVadmis1==4 & nextVLafteradmission==3
replace VL3admis=5 if CVadmis1==3 & nextVLafteradmission==3
replace VL3admis=6 if CVadmis1==3 & nextVLafteradmission==2
replace VL3admis=6 if CVadmis1==3 & nextVLafteradmission==1
replace VL3admis=6 if CVadmis1==4 & nextVLafteradmission==2
replace VL3admis=6 if CVadmis1==4 & nextVLafteradmission==1
replace VL3admis=2 if CVadmis1==. & nextVLafteradmission==1 & VLbeforeadmission==.
replace VL3admis=4 if CVadmis1==. & nextVLafteradmission==3 & VLbeforeadmission==.
replace VL3admis=4 if CVadmis1==. & nextVLafteradmission==4 & VLbeforeadmission==.
replace VL3admis=3 if CVadmis1==1 & nextVLafteradmission==2 & VL2admis<4
replace VL3admis=3 if CVadmis1==. & nextVLafteradmission==2 & VL2admis<4
replace VL3admis=4 if nextVLafteradmission==3 & VL2admis<4
replace VL3admis=4 if nextVLafteradmission==4 & VL2admis<4

browse FOLDER_NUMBER VL2admis VL3admis CVadmis1 VLbeforeadmission nextVLafteradmission LAB_CAT1 date_VL1 DatedAdmission1




gen CD41cat=.
replace CD41cat=1 if CD41>=0 & CD41<100 & CD4_ID1=="CD4A"
replace CD41cat=2 if CD41>=100 & CD41<200 & CD4_ID1=="CD4A"
replace CD41cat=3 if CD41>=200 & CD41<350 & CD4_ID1=="CD4A"
replace CD41cat=4 if CD41>=350 & CD41<10000 & CD4_ID1=="CD4A"


label values CD41cat CD4cat

tab outcomepost6M if DatedAdmission1>d(01aug2017) & DatedAdmission1<d(30apr2018) & abletolink=="Linked" & j==1




ltable duree_posthospi outcomepost_fin if DatedAdmission1>d(01aug2017) & DatedAdmission1<d(30apr2018) & abletolink=="Linked" & j==1, interval (0 6 12 18 24) graph 
ltable duree_posthospi outcomepost_fin if abletolink=="Linked" & j==1, interval (0 6 12 18 24) graph 

*


*Cascade des patients admis a Donka entre 1 aout 2017 et 30 avril  2018
tab Sortie1 if DatedAdmission1<=d(30apr2018) & j==1, missing
tab d Sortie1 if DatedAdmission1<=d(30apr2018) & j==1, missing
tab abletolink Sortie1 if DatedAdmission1<=d(30apr2018) & j==1 & d=="", missing

gen suivi=Sortie1
replace suivi=. if Sortie1==3
replace suivi=. if Sortie1==5
replace suivi=1 if Sortie1==2
replace suivi=1 if Sortie1==4


tab outcomepost6M if DatedAdmission1<=d(30apr2018) & j==1 & abletolink=="Linked" & suivi==1
tab final_outcomewithPDV if outcomepost6M==1 & DatedAdmission1<=d(30apr2018) & j==1 & abletolink=="Linked" & suivi==1
tab final_outcomewithPDV if outcomepost6M==2 & DatedAdmission1<=d(30apr2018) & j==1 & abletolink=="Linked" & suivi==1
tab final_outcomewithPDV if outcomepost6M==0 & DatedAdmission1<=d(30apr2018) & j==1 & abletolink=="Linked" & suivi==1

tab outcomepost if DatedAdmission1<=d(30apr2018) & j==1 & abletolink=="Linked" & suivi==1
tab final_outcomewithPDV if outcomepost==1 & DatedAdmission1<=d(30apr2018) & j==1 & abletolink=="Linked" & suivi==1
tab final_outcomewithPDV if outcomepost==2 & DatedAdmission1<=d(30apr2018) & j==1 & abletolink=="Linked" & suivi==1
tab final_outcomewithPDV if outcomepost==0 & DatedAdmission1<=d(30apr2018) & j==1 & abletolink=="Linked" & suivi==1



replace ARVstatut=1 if FOLDER_NUMBER=="15609MAT" & date_HAART==d(17nov2017) & DatedAdmission==d(06sep2017)
replace ARVfollowup=5 if FOLDER_NUMBER=="15609MAT" & date_HAART==d(17nov2017) & DatedAdmission==d(06sep2017)
replace ARVstatut=4 if FOLDER_NUMBER=="497" & date_HAART==d(13sep2005) & DatedAdmission==d(12sep2017)
replace ARVstatut=1 if FOLDER_NUMBER=="GP3478M" & date_HAART==d(25jun2018) & DatedAdmission==d(06nov2017)
replace ARVstatut=1 if FOLDER_NUMBER=="TBL1324" & date_HAART==d(09sep2017) & DatedAdmission==d(30aug2017)
replace ARVfollowup=5 if FOLDER_NUMBER=="GP3478M" & date_HAART==d(25jun2018) & DatedAdmission==d(06nov2017)
replace ARVfollowup=5 if FOLDER_NUMBER=="TBL1324" & date_HAART==d(09sep2017) & DatedAdmission==d(30aug2017)

tab Sortie1 if DatedAdmission1>=d(01aug2017) & DatedAdmission1<d(30apr2018) & j==1 & abletolink=="Linked"
tab final_outcomewithPDV if DatedAdmission1>d(01nov2017) & DatedAdmission1<d(30apr2018) & abletolink=="Linked" & j==1

replace ARVstatut=1 if ARVstatut==. & ARVadmission==3 
replace ARVstatut=3 if ARVstatut==. & ARVadmission==5 & ARVsortie==3
browse if ARVstatut==. & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
***Cascade ARV and VL
tab ARVstatut if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing
tab VL3admis if ARVstatut==1 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing
tab VL3admis if ARVstatut==2 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing
tab VL3admis if ARVstatut==3 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing
tab VL3admis if ARVstatut==4 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing

tab ARVfollowup if ARVstatut==1 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing
tab init if ARVstatut==1 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing

tab ARVfollowup if ARVstatut==2 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing
tab ARVfollowup if ARVstatut==3 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing
tab ARVfollowup if ARVstatut==4 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing

tab VL3admis if ARVfollowup==4 & ARVstatut==4 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing
tab VL3admis if ARVfollowup==4 & ARVstatut==3 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing

tab outcomepost6M if ARVstatut==1 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing
tab outcomepost6M if ARVstatut==2 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing
tab outcomepost6M if ARVstatut==3 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing
tab outcomepost6M if ARVstatut==4 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing

tab outcomepost if ARVstatut==1 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing
tab outcomepost if ARVstatut==2 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing
tab outcomepost if ARVstatut==3 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing
tab outcomepost if ARVstatut==4 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , missing


*To investigate factors (clinical and epidemiological) associated with unfavourable outcomes at hospital discharge (death > 48 hrs or < 48hrs) and during the post-discharge period. 


tab Agecat outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Agecat outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Sex outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Sex outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab CD4cat outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab CD4cat outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab CVadmis1 outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab CVadmis1 outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

browse if ARVsortie==. & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1

replace ARVsortie=1 if FOLDER_NUMBER=="15609MAT" & DatedAdmission==d(06sep2017)
replace ARVsortie=1 if FOLDER_NUMBER=="15752MAT" & DatedAdmission==d(27oct2017)
replace ARVsortie=4 if FOLDER_NUMBER=="497" & DatedAdmission==d(12sep2017)
replace ARVsortie=3 if FOLDER_NUMBER=="TBL1324" & DatedAdmission==d(30aug2017)
replace init=1 if  FOLDER_NUMBER=="TBL1324" & DatedAdmission==d(30aug2017)



tab ARVsortie outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab ARVsortie outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
***diag
tab Diagmaj outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Diagmaj outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab diaggroup outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab diaggroup outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab Autre outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab anémie outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Diarr outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Diarr outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Encéphalite outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Encéphalite outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Hépatite outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Hépatite outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Insuffcardiaque outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Insuffcardiaque outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Insuffrénale outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Insuffrénale outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Meningitecryp outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Meningitebact outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Paludisme outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Paludisme outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab PCP outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab PCP outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Pneumbact outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Pneumbact outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Sepsis outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Sepsis outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab SK outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab SK outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Toxoplasmose outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Toxoplasmose outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab TypeTB outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab TypeTB outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi


encode Hbdadmission, generate(HB)
replace HB=. if HB==5
replace HB=3 if HB==4
replace HB=1 if HB==2
tab HB outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab HB outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab malnut outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab malnut outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab interruption outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi row
tab interruption outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab CD41cat outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab CD41cat outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
 
replace FHV_STAGE_WHO=. if FHV_STAGE_WHO==95
gen WHO=FHV_STAGE_WHO
replace WHO=1 if FHV_STAGE_WHO==2
replace WHO=4 if FHV_STAGE_WHO==3

tab FHV_STAGE_WHO outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab FHV_STAGE_WHO outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
 
tab WHO outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab WHO outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
 
 
tab Neurocomb outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Neurocomb outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

			 
tab symp2sem outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab symp2sem outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab LAM outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab LAM outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab Xpert outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Xpert outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab Cragsang outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Cragsang outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab CragLCR outcomepost if Cragsang==1 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab CragLCR outcomepost_fin if Cragsang==1 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab VL3admis outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing row col chi
tab VL3admis outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab VL2admis outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing row chi
tab VL2admis outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi


gen switch2=0 if VL2admis==5 & ARVadmission==5
replace switch2=2 if VL2admis==4 & ARVadmission==5

replace switch2=1 if ARVstatut==4 & ARVsortie==2
replace switch2=1 if ARVstatut==3 & ARVsortie==2

gen switch3=0 if VL3admis==5 & ARVadmission==5
replace switch3=2 if VL3admis==4 & ARVadmission==5

replace switch3=1 if ARVstatut==4 & ARVsortie==2
replace switch3=1 if ARVstatut==3 & ARVsortie==2
replace switch3=1 if ARVfollowup==4

tab switch2 outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab switch2 outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab switch2 deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018)  & j==1 , chi

tab switch3 outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab switch3 outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab temp outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab temp outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab PSI outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab PSI outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
 
tab ARVfollowup outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab ARVfollowup outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

gen rehospdonka=.
replace rehospdonka=0 if numberhosp==1
replace rehospdonka=1 if numberhosp==2
replace rehospdonka=2 if numberhosp>2

tab rehospdonka outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab rehospdonka outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

gen rehospmatam=0


forvalues i=1/6 {

	replace rehospmatam=rehospmatam+1 if DatedAdmissionMatam`i'!=.
} 

gen totalhosp=rehospmatam+numberhosp
replace rehospmatam=2 if rehospmatam>2

tab rehospmatam outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab rehospmatam outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

replace totalhosp=2 if totalhosp==3
replace totalhosp=4 if totalhosp>4

tab totalhosp outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab totalhosp outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi



gen visitb4hosp=.


forvalues i=193(-1)1 {

	replace visitb4hosp=date_VISIT`i' if date_VISIT`i'<=DatedAdmission & visitb4hosp==.
}
format visitb4hosp %td

gen visit2b4hosp=.

forvalues i=193(-1)1 {

	replace visit2b4hosp=date_VISIT`i' if date_VISIT`i'<=DatedAdmission & visit2b4hosp==. & visitb4hosp!=date_VISIT`i'
}
format visit2b4hosp %td

gen apptb4hosp=.


forvalues i=193(-1)1 {

	replace apptb4hosp=date_NXTVIS`i' if date_NXTVIS`i'<=DatedAdmission & apptb4hosp==.
}
format apptb4hosp %td



browse visit2b4hosp visitb4hosp DatedAdmission apptb4hosp date_NXTVIS*

gen PDVtime= DatedAdmission-apptb4hosp

browse PDVtime PDV R6Mbefore R6M timebeforehosp visit2b4hosp visitb4hosp  DatedAdmission apptb4hosp date_NXTVIS*

gen R6Mbefore=0
replace R6Mbefore=1 if (visitb4hosp-visit2b4hosp)>175
replace R6Mbefore=. if visitb4hosp==.

drop PDV
gen PDV=0 
replace PDV =1 if PDVtime>=90
replace PDV=. if PDVtime==.
replace PDV=0 if (DatedAdmission-visitb4hosp)<=90


gen INHstatutb4=""

forvalues i=193(-1)1 {

	replace INHstatutb4=INH`i' if date_VISIT`i'<=DatedAdmission & INHstatutb4==""
}
gen TBstatutb4=""
forvalues i=193(-1)1 {

	replace TBstatutb4=TB_STATUS`i' if date_VISIT`i'<=DatedAdmission & TBstatutb4==""
}

gen TBINHb4hosp=.

replace TBINHb4hosp=0 if TBstatutb4=="0"
replace TBINHb4hosp=1 if TBstatutb4=="4"
replace TBINHb4hosp=2 if INHstatutb4=="1

label define TBINH 0"screened no symptoms no INH" 1"TB treatment" 2"INH administered"
label values TBINHb4hosp TBINH

gen visitb4hosplocation=""
replace visitb4hosplocation="Tier centre" if visitb4hosp!=.
replace visitb4hosplocation="Tier centre" if DatedeRéférence>visitb4hosp &  DatedeRéférence<=DatedAdmission
replace visitb4hosp=DatedeRéférence  if DatedeRéférence>visitb4hosp &  DatedeRéférence<=DatedAdmission
replace visitb4hosplocation="Matam R" if DatedArrivéeàMatam>visitb4hosp &  DatedArrivéeàMatam<=DatedAdmission
replace visitb4hosp=DatedArrivéeàMatam  if DatedArrivéeàMatam>visitb4hosp &  DatedArrivéeàMatam<=DatedAdmission
replace visitb4hosplocation="Matam R" if DatedeSortieMatam>visitb4hosp &  DatedeSortieMatam<=DatedAdmission
replace visitb4hosp=DatedeSortieMatam  if DatedeSortieMatam>visitb4hosp &  DatedeSortieMatam<=DatedAdmission
replace visitb4hosplocation="Matam IPD" if DatedesortieMatam1>visitb4hosp &  DatedesortieMatam1<=DatedAdmission
replace visitb4hosp=DatedesortieMatam1  if DatedesortieMatam1>visitb4hosp &  DatedesortieMatam1<=DatedAdmission
replace visitb4hosplocation="Matam IPD" if DatedesortieMatam2>visitb4hosp &  DatedesortieMatam2<=DatedAdmission
replace visitb4hosp=DatedesortieMatam2  if DatedesortieMatam2>visitb4hosp &  DatedesortieMatam2<=DatedAdmission
replace visitb4hosplocation="Matam IPD" if DatedesortieMatam3>visitb4hosp &  DatedesortieMatam3<=DatedAdmission
replace visitb4hosp=DatedesortieMatam3  if DatedesortieMatam3>visitb4hosp &  DatedesortieMatam3<=DatedAdmission
replace visitb4hosplocation="Matam IPD" if DatedesortieMatam4>visitb4hosp &  DatedesortieMatam4<=DatedAdmission
replace visitb4hosp=DatedesortieMatam4  if DatedesortieMatam4>visitb4hosp &  DatedesortieMatam4<=DatedAdmission
replace visitb4hosplocation="Matam IPD" if DatedesortieMatam5>visitb4hosp &  DatedesortieMatam5<=DatedAdmission
replace visitb4hosp=DatedesortieMatam5  if DatedesortieMatam5>visitb4hosp &  DatedesortieMatam5<=DatedAdmission
replace visitb4hosplocation="Matam IPD" if DatedesortieMatam6>visitb4hosp &  DatedesortieMatam6<=DatedAdmission
replace visitb4hosp=DatedesortieMatam6  if DatedesortieMatam6>visitb4hosp &  DatedesortieMatam6<=DatedAdmission

  
gen timebeforehosp=(DatedAdmission-visitb4hosp)


gen timebeforehospcat=.
replace timebeforehospcat=0 if timebeforehosp==0
replace timebeforehospcat=1 if timebeforehosp>0 & timebeforehosp<=7
replace timebeforehospcat=2 if timebeforehosp>7 & timebeforehosp<=31
replace timebeforehospcat=4 if timebeforehosp>31 & timebeforehosp<=90
replace timebeforehospcat=5 if timebeforehosp>90 & timebeforehosp<=2000


label define timebeforehospcat 0 "jour admis" 1 "1-7 jours"  2 "8-31 jours"  4 "1M-3M" 5 "3M+" , modify
label values timebeforehospcat timebeforehospcat
tab timebeforehospcat if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing

gen PDVb4=0
replace PDVb4=1 if timebeforehosp==.
replace PDVb4=1 if timebeforehosp>=100

tab timebeforehospcat outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab timebeforehospcat outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

summarize timebeforehosp  if outcomepost==0 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, detail
summarize timebeforehosp  if outcomepost==1 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, detail
summarize timebeforehosp  if outcomepost==2 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, detail
summarize timebeforehosp  if outcomepost==3 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, detail
summarize timebeforehosp  if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, detail


tab visitb4hosplocation timebeforehospcat if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1,  chi


tab PDVb4 outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab PDVb4 outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab TBINHb4hosp outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab TBINHb4hosp outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab otherHIV outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab otherHIV outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab Neuro outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Neuro outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab otherResp outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab otherResp outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab pulmoTB outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab pulmoTB outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab dissemTB outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab dissemTB outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab TBclinical outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab TBclinical outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab TBM outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab TBM outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab NCD outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab NCD outcomepost_fin if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

*create final structure for OIs and assorted conditions out of diagmaj+TB categories+Cryptdisease+anaemia+malnutrition: the general idea is that conditions are NON exclusive so You can have one or more conditions
*objectifiable diagnoses: TB
*destring diagprincipale 1 and 2 to get info on cases already on tb treatment
*encode Diagnosticfinalprincipal1, gen (Diagnosticprincipal1_n)
*encode Diagnosticfinalprincipal2, gen (Diagnosticprincipal2_n)
*Crypto variable is already done==Cryptdisease Exclusive
*Cryptococcal disease
gen Cryptdisease=0
replace Cryptdisease=1 if CragLCR==1
replace Cryptdisease=2 if Cragsang==1 & CragLCR==0
replace Cryptdisease=3 if Cragsang==1 & CragLCR==.
replace Cryptdisease=1 if FOLDER_NUMBER=="449"
*label define Crypt_ll 0"no Crypto" 1"Cryptomeningitis" 2"Serum+CSF-" 3"Serum+CSF."
label value Cryptdisease Crypt_ll
*tab Cryptdisease deces if Cryptdisease!=0, chi2
*tab Cryptdisease deces if Cryptdisease==2, row chi2
*tab Cryptdisease deces if Cryptdisease==3, row chi2
*tabodds Cryptdisease deces if Cryptdisease==1, or
*now build TB variable
gen TBdiag=0
replace TBdiag=1 if diaggroup==9 & strmatch(Diagnosticfinalprincipal2,"*sous trai*")==0 & strmatch(Diagnosticfinalprincipal2,"*sous trai*")==0
replace TBdiag=2 if diaggroup==7 & strmatch(Diagnosticfinalprincipal2,"*sous trai*")==0 & strmatch(Diagnosticfinalprincipal2,"*sous trai*")==0
replace TBdiag=3 if diaggroup==6 & strmatch(Diagnosticfinalprincipal2,"*sous trai*")==0 & strmatch(Diagnosticfinalprincipal2,"*sous trai*")==0
replace TBdiag=4 if diaggroup==5 & strmatch(Diagnosticfinalprincipal2,"*sous trai*")==0 & strmatch(Diagnosticfinalprincipal2,"*sous trai*")==0
replace TBdiag=5 if diaggroup==4 & strmatch(Diagnosticfinalprincipal2,"*sous trai*")==0 & strmatch(Diagnosticfinalprincipal2,"*sous trai*")==0
replace TBdiag=6 if strmatch(Diagnosticfinalprincipal2,"*sous trai*")==1 | strmatch(Diagnosticfinalprincipal1,"*sous trai*")==1


*now there is some messy recoding for cases who slipped through the gaps
replace TBdiag=3 if FOLDER_NUMBER=="15652"
replace TBdiag=3 if FOLDER_NUMBER=="15785"
replace TBdiag=3 if FOLDER_NUMBER=="15869"
replace TBdiag=3 if FOLDER_NUMBER=="1954"
replace TBdiag=3 if FOLDER_NUMBER=="CLY1610"
replace TBdiag=3 if FOLDER_NUMBER=="D0567M"
replace TBdiag=3 if FOLDER_NUMBER=="D058 / 18M"
replace TBdiag=3 if FOLDER_NUMBER=="D538M"
replace TBdiag=3 if FOLDER_NUMBER=="FLB0098M"
replace TBdiag=3 if FOLDER_NUMBER=="FLB2732"
replace TBdiag=3 if FOLDER_NUMBER=="GP3509"
replace TBdiag=3 if FOLDER_NUMBER=="MIN3199"
replace TBdiag=3 if FOLDER_NUMBER=="WA2818M"
replace TBdiag=4 if FOLDER_NUMBER=="10692"
replace TBdiag=4 if FOLDER_NUMBER=="14654"
replace TBdiag=4 if FOLDER_NUMBER=="15669"
replace TBdiag=4 if FOLDER_NUMBER=="6277"

*label define TBdiag_l 1"DRTB"2"TBmeningitis"3"clinicalTB"4"disseminatedTB"5"pulmoTB"6"TBontreatment"
label values TBdiag TBdiag_l
*now build other OI-variables
*toxo= Crypto+TB Meningitis ruled out +toxo treatment started empirically Toxo is therefore EXCLUSIVE
gen Toxo=0
replace Toxo=1 if Toxoplasmose==1 & TBdiag!=2 & Cryptdisease!=1

*PCP PCP IS EXCLUSIVE
gen Pjpneumonia=0
replace Pjpneumonia=1 if PCP==1 &TBdiag==0
*Diarrea variable is already there==Diarr, Diarr is NON EXCLUSIVE
gen Diarrea=Diarr
*KS variable already there KS is NON EXCLUSIVE
gen KS=SK
*Candidasis variable already there, NON EXCLUSIVE
gen Candidasis=CandidOeso
*now build assorted conditions variable
*community acquired infections
*CAP Overruled by PCP and TB
*drop CAP
gen CaP=0
replace CaP=1 if Pneumbact==1 & Pjpneumonia==0 &TBdiag==0
*Cabsinf (comm acqu. blood stream infection) NON EXCLUSIVE because all other conditions can cause Sepsis
*drop Cabsinf
gen Cabsinf=0
replace Cabsinf=1 if Sepsis==1
replace Cabsinf=1 if RaisDCD==6
*hypovolaemic shock NON EXCLUSIVE
gen shochypo=0
replace shochypo=1 if RaisDCD==2
gen septicshoc=0
replace septicshoc=1 if RaisDCD==6
*Malaria NON EXCLUSIVE
gen Malaria=Paludisme
*Anaemia NON EXCLUSIVE

gen Hb=.
replace Hb=1 if Hbdadmission=="< 7g/dL"
replace Hb=1 if Hbdadmission=="<6 g/dl"
replace Hb=0 if Hbdadmission==">=6 g/dl"
replace Hb=0 if Hbdadmission=="> 7g/dL"
label var Hb "HB<7"
*label define Hb_L 1 "yes" 0"no"
label values Hb Hb_L
*tab Hb deces, row chi2

gen anaemia=Hb
*renal impairment NON EXCLUSIVE
gen renalimpair=Insuffrénale
*malnutrition
gen malnutrition=malnut
*severe liver impairment NON EXCLUSIVE no further info on aetiology of liver impairment
gen liverimpairment=Hépatite

*now for Rebs analysis comparing diagnostics at each hospitalisations lump OIs together in 1 variable
*logic: TB Crypto Toxo PCP are exclusive (Crypto beats TBM and Toxo,TBM beats Toxo so You can only have Toxo if You dont have any form of TB or Cryptococcal meningitis) , Chronic Diarrea is inferior to (TB Toxo Crypto PCP), KS is inferior to (Diarrea, TB, TOxo, Crypto, PCP), Candida is inferior to (Diarrea, KS, TB Toxo, Crypto, PCP)
*drop Oidiag
gen Oidiag=0
replace Oidiag=1 if TBdiag==1
replace Oidiag=2 if TBdiag==2
replace Oidiag=3 if TBdiag==3
replace Oidiag=4 if TBdiag==4
replace Oidiag=5 if TBdiag==5
replace Oidiag=6 if TBdiag==6
replace Oidiag=7 if Cryptdisease==1
replace Oidiag=8 if Toxo==1 & TBdiag==0 & Cryptdisease!=1
replace Oidiag=9 if Pjpneumonia==1 & Toxo==0 & TBdiag==0 & Cryptdisease!=1 
replace Oidiag=10 if Diarrea==1 & TBdiag==0 & Cryptdisease!=1 & Toxo==0
replace Oidiag=11 if KS==1 & Diarrea==0 & TBdiag==0 & Cryptdisease!=1 & Toxo==0
replace Oidiag=12 if Candidasis==1 & KS==0 & Diarrea==0 & TBdiag==0 & Cryptdisease!=1 & Toxo==0
*label define Oidiag_L 1"DRTB"2"TBmeningitis"3"clinicalTB"4"disseminatedTB"5"pulmoTB"6"TBontreatment"7"CM"8"Toxo"9"PCP"10"Diarrea"11"KS"12"candida"
label values Oidiag Oidiag_L

       
gen timeonART=DatedAdmission-date_HAART
gen timeosincefst=DatedAdmission-date_FRSVIS
replace timeonART=0 if ARVstatut==1

recode instudy=1 if DatedAdmission1<d(01may2018) & DatedAdmission1>=d(01aug2017) & abletolink=="Linked" & j==1 & suivi==1
replace instudy=1 if DatedAdmission1<d(01may2018) & DatedAdmission1>=d(01aug2017) & abletolink=="Linked" & j==1 & suivi==1

save "D:\Users\msfuser\or GUINEA\IPD FU\Master", replace


****analysis of diagnosis between hospitalisations
use "C:\Users\harrisonr\Downloads\Master (3).dta", clear
merge m:m FOLDER_NUMBER using "C:\Users\harrisonr\Downloads\combinedmatamdonkadiag.dta", keepusing(diagcompdiff diagcompsame diagcomp1 diagcomp2 diagcomp3 diagcomp4 diagcomp5 diagcomp6 timebtweenhosp* Oidiag*)

label define Oidiag_L 1"DRTB" 2"TBmeningitis" 3"clinicalTB" 4"disseminatedTB" 5"pulmoTB" 6"TBontreatment" 7"CM" 8"Toxo" 9"PCP" 10"Diarrea" 11"KS" 12"candida", modify
label values Oidiag* Oidiag_L
label values oidiagcomb* Oidiag_L

tab Oidiag1 if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 & rehospdonka>0,  

gen oidiagcomb1=Oidiag1
gen oidiagcomb2=Oidiag2
replace oidiagcomb1=6 if Oidiag1==1
replace oidiagcomb1=6 if Oidiag1==2
replace oidiagcomb1=6 if Oidiag1==3
replace oidiagcomb1=6 if Oidiag1==4
replace oidiagcomb1=6 if Oidiag1==5
replace oidiagcomb2=6 if Oidiag2==1
replace oidiagcomb2=6 if Oidiag2==2
replace oidiagcomb2=6 if Oidiag2==3
replace oidiagcomb2=6 if Oidiag2==4
replace oidiagcomb2=6 if Oidiag2==5

gen diagcompTB1=""
replace diagcompTB1="Same" if oidiagcomb1==oidiagcomb2 & DatedAdmission1!=. & DatedAdmission2!=.
replace diagcompTB1="Diff" if oidiagcomb1!=oidiagcomb2 & DatedAdmission1!=. & DatedAdmission2!=.

tab Oidiag1 diagcomp1  if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 & rehospdonka>0,  
tab Oidiag1 Oidiag2 if diagcomp1=="Diff" & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 & rehospdonka>0,  

tab oidiagcomb1 diagcompTB1  if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 & rehospdonka>0, 
tab oidiagcomb1 oidiagcomb2 if diagcompTB1=="Diff" & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 & rehospdonka>0, 

gen ARTstat=.
replace ARTstat=2 if ARVstatut==2
replace ARTstat=2 if ARVstatut==3
replace ARTstat=2 if ARVstatut==4
replace ARTstat=3 if interruption==3
replace ARTstat=1 if ARVstatut==1




tab VLadmis outcomepost if ARTstat==1 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab VLadmis outcomepost if ARTstat==2 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab VLadmis outcomepost if ARTstat==3 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab VLadmis outcomepost if (CD4cat==3 | CD4cat==4)  & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab VLadmis outcomepost if (CD4cat==1 | CD4cat==2) & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi


tab Oidiag outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Cryptdisease outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab TBdiag outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Toxo outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Pjpneumonia outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab KS outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Candidasis outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab CaP outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Cabsinf outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab shochypo outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab septicshoc outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Malaria outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab Hb outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab anaemia outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab renalimpair outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab malnutrition outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
tab liverimpairment outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi

tab Diarrea outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
                

tab TBdiag deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi
tab PDVb4 deces if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi

tab Diagmaj1 Diagmaj2 if instudy==1 & totalhosp>1 &  diagcomp1=="Diff"

tab Sex interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi row
tab ARVstatut interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi row
tab Agecat interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & j==1, missing chi row



***cox regression for survival after hospitalisation. For each independent variable - we looked at the first three outcomes - but final presentation is using combined attrition

stset duree_posthospi,failure (outcomepost_fin==1)
stset duree_posthospi,failure (outcomepost_dead==1)
stset duree_posthospi,failure (outcomepost_ltfu==1)
stset duree_posthospi,failure (outcomepost_to==1)

***graphing overall attrition
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 ,  risktable

sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(Agecat) 
sts test Agecat if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
***yes p=0.0140
***yes 0.0281
**not reallt 0.0876
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(Sex) risktable
sts test Sex if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
***no p=.2238 but worth graphing cos of males at beginning
**no p=.8803
**almost p=0.0875 this graph is particularly worth showing more than overall attrition
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(CD4cat2) risktable
sts test CD4cat2 if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
****no p=0.7796 but also graph a bit interesting as its especially those with a CD4 between 350-499 who are lost quickly
***no p=0.2981
**no p=0.4286
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(CD4cat) risktable
sts test CD4cat if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
**no p==0.9980
**no p=0.2178
**no p=0.2960
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(ARVsortie) 
sts test ARVsortie if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
**no p=0.8492
**no p=0.5176
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(interruption) risktable
sts test interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
***p=0.0307 yes
**no p=0.1254
**no p=0.5501
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(CD41cat)
sts test CD41cat if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
***no p=0.6245
**no p=0.3524
**no 0.2770
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(Neurocomb) risktable
sts test Neurocomb if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
**no p=0.9185
**no p=.7027
***no 0.6531
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(FHV_STAGE_WHO) 
sts test FHV_STAGE_WHO if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
***yes p=0.0035
**no p=0.2720
**yes p=0.0124
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(WHOstagecomb) risktable
sts test WHOstagecomb if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
***yes p=0.0000
**not much p=0.0980
**yes p=0.0619
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(WHOstagecomb2) risktable
sts test WHOstagecomb2 if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
**no

sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(rehospdonka) risktable
sts test rehospdonka if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
***yes p=0.0011
**yes
**yes
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(rehospmatam) risktable
sts test rehospmatam  if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
***yes p=0.0009
**yes
**no
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(totalhosp) risktable
sts test totalhosp if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
**yes p=0.0002
**yes
***no
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(ARVstatut) risktable
sts test ARVstatut if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
***no p=0.6409
**no p=.8343
**no p=.2558
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(ARVstatut) risktable
sts test ARVstatut if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
**no p=.6409
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(VL2admis) risktable
sts test VL2admis if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
***no p=0.9524
**no p=0.5382
**no p=.739
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(VL3admis2) risktable
sts test VL3admis2 if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
**yes 0.0143
***yes 0.0336
**yes 0.0107

sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(VL2admis2) risktable
sts test VL2admis2 if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
**no
***no
**no

sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(VL3admis) risktable
sts test VL3admis if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
***yes p=0.0266
**yes p==0.0306
**yes p=0.0055
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(diaggroup) 
sts test diaggroup if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
**no p=0.1245
**yes p=0.0337
**no
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(ARVfollowup) 
sts test ARVfollowup if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
**yes p=.0024
*yes just p=.0696
**yes p=0.0060
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(switch3) risktable
sts test switch3 if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
***no but interesting to graph p==0.5205
*no p=0.9874
**no
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(temp) 
sts test temp if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
***yes p==0.0031
*no p=0.1707
**yes p=0.0065
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(PSI) risktable
sts test PSI if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
***no but interesting to graph p==0.1788
*nearly p=0.0696
**no p=0.7857

sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(otherHIV) risktable
sts test otherHIV if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
***no

sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(Neuro) risktable
sts test Neuro if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
*no
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(otherResp) risktable
sts test otherResp if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
*yes
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(pulmoTB) risktable
sts test pulmoTB if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
*no
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(dissemTB ) risktable
sts test dissemTB  if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
*no
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(TBclinical) risktable
sts test TBclinical if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
*no
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(TBM) risktable
sts test TBM if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
*no borderline
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(NCD) risktable
sts test NCD if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
*no




      



gen numberVL=0

forvalues i=1/11 {

	replace numberVL=numberVL+1 if LAB_CAT`i'!=.
}


replace numberVL=2 if numberVL==3
replace numberVL=4 if numberVL>4
tab numberVL

*Agecat Age interruption WHO total hosp VL3admis2 temp numberVL
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, by(numberVL) 
sts test numberVL if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1, logrank
*no bordeline 0.1641
**no
** yes 0.0026


stcox i.Agecat if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
**yes 0.0332
**yes 0.0179
**no 0.1044

stcox Age if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
**yes 0.0001
**yes 0.0002
**no 0.0.063

stcox i.Sex if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
**no 0.2330
**no .8802
**almost 0.0973
stcox i.ARVstatut if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
**NO 0.6509
**no .8607
**no 0.2660
stcox i.ARVsortie if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
**NO 0.8482
**no .5904
**no 0.5444
stcox i.ARVadmission if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
**no 0.5436
**no 0.7070
**no .1715
stcox i.temp if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
**yes 0.0017
**no .1521
**yes .0034
stcox i.PSI if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
**no 0.2054
**borderline 0.0978
**no .7928
stcox i.Neurocomb if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
***no 0.9196
**no 0.6990
**no .6632
stcox i.NCD if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
***no 0.5819
**no 0.6990
**no .6632

stcox i.LAM if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
***no 0.4326
**yes 0.0036
**no .1527
stcox i.FHV_STAGE_WHO if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
**yes 0.0185
**no .4104
***yes 0.0436
stcox i.WHOstage if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
**yes 0.0854
stcox i.WHOstagecomb if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
**yes
**no
**no


stcox i.CVadmis1 if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
***no 0.8209
**no .8179
**no .5440
stcox i.VL2admis if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
***no 0.9450
**no 0.4960
***no .6650
stcox i.VL2admis2 if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
stcox i.VL3admis if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
***yes 0.0205
**yes 0.0136
**yes  0.0035
stcox i.CVcat if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
***no 0.6587
**no .4182
**no .4358
stcox i.CD4cat if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
**NO 0.9981
**no .1740
**no .3258
stcox i.CD4cat2 if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
**NO 0.7718
**no .2695
**no .4703
stcox i.CD41cat if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
**NO 0.6350
**no .2697
**no .3237
stcox i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
***YES 0.0402
**no .1409
**no .1511
stcox i.signesneuro if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
***No 0.4408
**no 0.6817
**no .5095
stcox i.ARVfollowup if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
***Yes 0.0080
**no .1526
**yes 0.0099
stcox i.VLfollowup if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
***yes 0.0055
**yes 0.0134
**yes 0.0005
gen VLfollowup2=VLfollowup
replace VLfollowup2=. if VLfollowup==1
label values VLfollowup2 VLfollowup
gen VL2admis2=VL2admis
replace VL2admis2=. if VL2admis==1
label values VL2admis2 VLfollowup
gen VL3admis2=VL3admis
replace VL3admis2=. if VL3admis==1
label values VL3admis2 VLfollowup
stcox i.VLfollowup2 if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
***yes p=0.0171
***yes 0.0075
**yes 0.0132
stcox i.VL2admis2 if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
***no p=0.5371
stcox i.VL3admis2 if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
***yzq p=0.0078

stcox i.totalhosp if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
***yes 0.0004
**yes 0.0000
**no 0.2270

stcox i.numberVL if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
**yes 0.019
**no 0.9529
**yes 0.0018

stcox timeosincefst if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
**no
stcox timeonART if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
**no
stcox otherResp if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1




***backwards stepwise
stcox i.temp i.totalhosp otherResp i.VL3admis2 i.numberVL i.ARVsortie i.WHOstagecomb i.Agecat i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store a
stcox i.temp i.totalhosp otherResp i.VL3admis2 i.numberVL i.ARVsortie i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store b
lrtest ( a) ( b), force
***otherResp no

stcox i.temp i.totalhosp  i.VL3admis2 i.numberVL i.ARVsortie i.WHOstagecomb i.Agecat i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store a
stcox i.temp i.totalhosp  i.VL3admis2 i.numberVL i.ARVsortie i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store b
lrtest ( a) ( b), force
***age yes

stcox i.temp i.totalhosp  i.VL3admis2 i.numberVL  i.ARVfollowup i.WHOstagecomb Age i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store a
stcox i.temp i.totalhosp  i.VL3admis2 i.numberVL  i.ARVfollowup i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store b
lrtest ( a) ( b), force
***age yes 

stcox i.temp i.totalhosp i.VL3admis2 i.numberVL  Age i.ARVfollowup i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store a
stcox i.temp i.totalhosp i.VL3admis2 i.numberVL  Age i.ARVfollowup i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store b
lrtest ( a) ( b), force
***WHO yes



stcox  i.temp i.totalhosp i.VL3admis2 i.numberVL  Age i.ARVfollowup  i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store a
stcox i.temp i.totalhosp   i.numberVL  Age i.ARVfollowup i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store b
lrtest ( a) ( b), force
***VL yes

stcox  i.temp i.totalhosp i.VL2admis2 i.numberVL  Age i.ARVfollowup  i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store a
stcox i.temp i.totalhosp   i.numberVL  Age i.ARVfollowup  i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store b
lrtest ( a) ( b), force
***VL yes

stcox  i.temp i.totalhosp i.VL3admis2 i.numberVL  Age i.ARVfollowup i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store a
stcox i.temp i.totalhosp  i.VL3admis2 Age i.ARVfollowup  i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store b
lrtest ( a) ( b), force
***no for number VL

stcox  i.temp i.totalhosp Age i.ARVfollowup i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store a
stcox  i.temp i.totalhosp  Age  i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store b
lrtest ( a) ( b), force
*** ARV no 

stcox i.temp i.totalhosp  i.VL3admis2 Age  i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store a
stcox i.totalhosp  i.VL3admis2 Age  i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store b
lrtest ( a) ( b), force
***temp yes 




stcox i.temp i.totalhosp Age i.VL3admis2 i.ARVsortie i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store a
stcox i.temp i.totalhosp  Age  i.VL3admis2 i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store b
lrtest ( a) ( b), force
*** ARV sortie no 

stcox  i.temp i.totalhosp Age i.VL3admis2 i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store a
stcox  i.temp i.totalhosp Age i.VL3admis2 i.WHOstagecomb  if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store b
lrtest ( a) ( b), force
***interruption yes

stcox i.temp i.totalhosp  Age i.VL3admis2 i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store a
stcox  i.temp Age i.VL3admis2 i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
estimates store b
lrtest ( a) ( b), force
***totalhosp borderline yes



final models:
***first forwards stepwise
stcox Age i.VL3admis2 i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1


Checking assumptions
**the assumption to check is that there are proportional hazards
***log log plot for categorical variables
stphplot, by(Agecat)
**yes
stphplot, by(temp)
**Yes
stphplot, by(ARVsortie)
**yes
stphplot, by(totalhosp)
**bit of a problem with the value 1 for this one
stphplot, by(ARVfollowup)
**yes
stphplot, by(FHV_STAGE_WHO)
stphplot, by(WHO)
**yes 
stphplot, by(VL3admis2)
**yes
stphplot, by(numberVL)
**looks fine
stphplot, by(VLfollowup)
**still problematic with the 2VL greater than 1000
stphplot, by(VLfollowup2)
***same problem
stphplot, by(interruption)
***yes
stphplot, by(PSI)
***yes
stphplot, by(Sex)
**yes


**the lines should be roughly parallel


stcox i.temp  Age i.VL3admis2 i.WHOstagecomb i.interruption if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1

estimates store a

***the formal proportional hazard test
estat phtest
**0.0643

***p value needs to be high to show that the proportional hazards assumptions are met

stcox i.temp  Age i.VL3admis2 i.WHOstagecomb i.interruption i.ARVfollowup if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1

**logistic regression of death during hospitalisation (not the one used in the final analysis)

*create model with promising variables from bivariate analysis which are: Age, CD4admis Oesophcandida, renalimpair, Neurocomb, symp2sem, VL2admis WHOstageinclusion
*drop VL2admis
logit deces Age CD4admis CandidOeso Neurocomb symp2sem WHOstageinclusion renalimpair VL2admis, or
estimates store s_all
logit deces Age CD4admis CandidOeso Neurocomb symp2sem WHOstageinclusion renalimpair, or
estimates store s_allmin
lrtest s_all s_allmin
*p value 0.06--> drop VL2admis
*now drop renalimpair
logit deces Age CD4admis CandidOeso Neurocomb symp2sem WHOstageinclusion renalimpair, or
estimates store s_all
logit deces Age CD4admis CandidOeso Neurocomb symp2sem WHOstageinclusion, or
estimates store s_allmin
lrtest s_all s_allmin
*p value 0.005 -->keep renal impairment
*now drop WHOstageinclusion
logit deces Age CD4admis CandidOeso Neurocomb symp2sem WHOstageinclusion renalimpair, or
estimates store s_all
logit deces Age CD4admis CandidOeso Neurocomb symp2sem renalimpair, or
estimates store s_allmin
lrtest s_all s_allmin, force
*keep WHOstaginclusion
*now drop symp2sem
logit deces Age CD4admis CandidOeso Neurocomb symp2sem WHOstageinclusion renalimpair, or
estimates store s_all
logit deces Age CD4admis CandidOeso Neurocomb WHOstageinclusion renalimpair, or
estimates store s_allmin
lrtest s_all s_allmin, force
*keep symp2sem
*drop Neurocomb
logit deces Age CD4admis CandidOeso Neurocomb symp2sem WHOstageinclusion renalimpair, or
estimates store s_all
logit deces Age CD4admis CandidOeso symp2sem WHOstageinclusion renalimpair, or
estimates store s_allmin
lrtest s_all s_allmin, force
*keep Neurocomb
*now drop Candida
logit deces Age CD4admis CandidOeso Neurocomb symp2sem WHOstageinclusion renalimpair, or
estimates store s_all
logit deces Age CD4admis Neurocomb symp2sem WHOstageinclusion renalimpair, or
estimates store s_allmin
lrtest s_all s_allmin, force
*too little observations-->drop Candida
*now drop CD4admis
logit deces Age CD4admis Neurocomb symp2sem WHOstageinclusion renalimpair, or
estimates store s_all
logit deces Age Neurocomb symp2sem WHOstageinclusion renalimpair, or
estimates store s_allmin
lrtest s_all s_allmin, force
*keep CD4admis
*now drop Age
logit deces Age CD4admis Neurocomb symp2sem WHOstageinclusion renalimpair, or
estimates store s_all
logit deces CD4admis Neurocomb symp2sem WHOstageinclusion renalimpair, or
estimates store s_allmin
lrtest s_all s_allmin, force
*keep Age
*final model: deces Age CD4admis Neurocomb symp2sem WHOstageinclusion renalimpair, or
logit deces Age CD4admis Neurocomb symp2sem WHOstageinclusion renalimpair, or


* analyse ramzia pour rapport********************************************************
tab VLadmission if j==1 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018), miss
tab VLadmission if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, miss
tab CD41cat if j==1 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018), miss
tab CD41cat if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, miss
tab VLadmission CD41cat if (ARVadmission==5 | ARVadmission==2) & j==1 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018), miss
tab VLadmission CD41cat if ARVadmission==3 & j==1 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018), miss
tab ARVadmission if j==1 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018), miss
tab deces timeperiod if j==1 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018)
tab deces timeperiod if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018)
tab CVadmis1 deces if CD4catbin200==1 & DatedAdmission>=d(01/08/2017) & DatedAdmission<=d(30/04/2018) & j==1,  exact chi row
tab CVadmis1 deces if CD4catbin200==0 & DatedAdmission>=d(01/08/2017) & DatedAdmission<=d(30/04/2018) & j==1, missing  exact chi row
tab TypeTB, nolabel
gen TB=""
replace TB="TB1" if TypeTB==3
replace TB="TB1" if TypeTB==5 |TypeTB==6 | TypeTB==9 | TypeTB==11
replace TB="TBC" if TypeTB==4
gen TBG=.
replace TBG=1 if TB=="TB1"
replace TBG=0 if TBG!=1
tab TBG deces if j==1 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018), missing exact row
gen TBC=.
replace TBC=1 if TB=="TBC"
replace TBC=0 if TBC!=1
tab TBC deces if j==1 & DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018), missing exact row
tab renalimpair, nolabel
logit deces renalimpair, or
* calcul de la survie par méthode de KP après sest 
sts list if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1 , at(0 1 3 6 12 14) 
* regroupement des catégorie pour regression de cox post-hospi
tab VLfollowup if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, nolabel
gen VLSuivi=VLfollowup
replace VLSuivi=4 if VLfollowup==5 | VLfollowup==6
tab VLSuivi if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
stcox i.VLSuivi if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
* cette variable contient les patients n'ayant pas de CV qui sont la référence, on crée une variable sans eux
gen VLsuivi2=VLfollowup
replace VLsuivi2=. if VLfollowup==1
replace VLsuivi2=1 if VLfollowup==2
replace VLsuivi2=2 if VLfollowup==3
replace VLsuivi2=3 if VLfollowup==4
replace VLsuivi2=4 if VLfollowup==5
replace VLsuivi2=5 if VLfollowup==6
tab VLsuivi if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, miss
tab VLsuivi2 outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing chi
stcox i.VLsuivi2 if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
stcox i.temp  Age i.VLsuivi2 i.WHOstagecomb i.interruption i.ARVfollowup if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
gen VLsuivi3=VLsuivi2
* regroupement des CV avec manquant et ARV en cours de suivi 
replace VLsuivi3=3 if VLsuivi2==4
replace VLsuivi3=3 if VLsuivi2==5
label define VLsuivi3 1"CV<40" 2"CV 40-999" 3"CV>=1000"
label values VLsuivi3 VLsuivi3

tab VLsuivi3 if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, miss
stcox i.VLsuivi3 if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
stcox i.temp  Age i.VLsuivi3 i.WHOstagecomb i.interruption i.ARVfollowup if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
stphplot, by(VLsuivi3)
gen ARVFollow=ARVfollowup
tab ARVfollowup
tab ARVfollowup, nolabel
replace ARVFollow=2 if ARVfollowup==4
replace ARVFollow=4 if ARVfollowup==5
tab ARVFollow
tab ARVFollow outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, missing exact row
stcox i.ARVFollow if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
stcox i.temp  Age i.Sex i.CD4cat i.ARVsortie i.totalhosp i.VLsuivi3 i.WHOstagecomb i.interruption i.ARVFollow if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
stphplot, by(ARVFollow)
stcox  Age i.VLsuivi3 i.WHOstagecomb i.interruption i.ARVFollow if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
* commande erronée
gen VLafterhosp=.
forvalues i=11(-1)1 {

	replace VLafterhosp=LAB_CAT`i' if VLdatesinceadmission`i'<0 & VLafterhosp==.
} 
*bon
gen VLposthosp=nextVLafteradmission
replace VLposthosp=VLadmission if nextVLafteradmission==.
tab VLposthosp if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, miss
tab VLposthosp outcomepost if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, exact row
stcox i.VLposthosp if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
stcox i.temp  Age i.totalhosp i.VLposthosp i.WHOstagecomb i.interruption i.ARVFollow if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
* introduire la cohorte d esuivi dans le modèle: pas possible car les centres non MSf ne font pas partir du suivi post hospi
gen cohortesuiv=.
replace cohortesuiv=1 if CentredeSuivi=="Coléah"
replace cohortesuiv=1 if CentredeSuivi=="Flamboyant"
replace cohortesuiv=1 if CentredeSuivi=="Gbessia Port"
replace cohortesuiv=1 if CentredeSuivi=="Minière"
replace cohortesuiv=1 if CentredeSuivi=="Tombolia"
replace cohortesuiv=1 if CentredeSuivi=="Wanidara"
replace cohortesuiv=2 if CentredeSuivi=="Matam"
replace cohortesuiv=3 if CentredeSuivi=="Pas clair/inconnu" | CentredeSuivi=="Nongo" | CentredeSuivi=="Ignace Deen" | CentredeSuivi=="Dermato" | CentredeSuivi=="De l'interieur" | CentredeSuivi=="DREAM" | CentredeSuivi=="Autre"
stcox i.cohortesuiv if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1
tab cohortesuiv if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, miss
* Kaplan meir stratifié par CV
tab VL2admis
gen CVadmis=.
replace CVadmis=0 if VL2admis==2 
replace CVadmis=1 if VL2admis==3
replace CVadmis=2 if VL2admis==4| VL2admis==5| VL2admis==6
label define CVadmis 0"VL<40" 1"VL 40-999" 2"VL>=1000"
label values CVadmis Cvadmis
tab CVadmis, miss
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1& suivi==1, by(CVadmis) risktable
sts test CVadmis if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, logrank
* avec CVadmis croisement des courbes
tab VLfollowup
gen CVsuivi=.
replace CVsuivi=0 if VLfollowup==2 |   VLfollowup==3
replace CVsuivi=1 if VLfollowup==4 | VLfollowup==5 | VLfollowup==6
tab CVsuivi, miss
sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1& suivi==1, by(CVsuivi) risktable
sts test CVsuivi if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, logrank
* Avc CVsuiv idem

sts graph if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1& suivi==1, by(VLsuivi3) risktable
sts test VLsuivi3 if DatedAdmission1>=d(01aug2017) & DatedAdmission1<=d(30apr2018) & abletolink=="Linked" & j==1 & suivi==1, logrank

