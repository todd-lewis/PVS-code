* People's Voice Survey data cleaning for China
* Date of last update: 17 April 2024
* Last updated by: Xiaohui Wang, Shalom Sabwa

/*

This file cleans Ipsos data for China. 

Cleaning includes:
	- Recoding skip patterns, refused, and don't know 
	- Creating new variables (e.g., time variables), renaming variables, labeling variables 
	- Correcting any values and value labels and their direction
	- Comparison with PVS V1.0 and make the changes and variable codequestionnaire for future V2.0 users
	
Missingness codes: .a = NA (skipped), .r = refused, .d = don't know, . = true missing 
*/

clear all
set more off 

*********************** CHINA ***********************

* Import data 
*use "$data/China/01 raw data/PVS_China_raw_01102024_label_recode.dta", clear
*note: This version is mainly focused on variable names and labels.

import excel "$data/China/01 raw data/PVS data_IPSOS.xlsx", sheet("常规访问数据") firstrow 

* Note: .a means NA, .r means refused, .d is don't know, . is missing 
*------------------------------------------------------------------------------*

*change variable type to keep consistant with V1.0 varible types
* 4-22 SS edits: changed q12_a & q12_b to q12a & q12b, and no "language" var
destring q1code q1value q2 q3 q4region_province _1region_city _2region_couty _2region_couty_name _2other q5 q6 q7 q8 q9 q10 q11 q12a q12b q13 q14 q15 q16 q17 q18code q18value q19 q20 q21code q21value q22code q22value q23code q23value q24 q25 q26 q27a q27b q27bi q27bii q27c q27d q27e q27f q27g q27h q28a q28b q29 q30 q31a q31b q32 q33 q34 q35 q36 q37 q37other q38c q38a q38b q38d q38e q38f q38g q38h q38i q38k q38j q39code q39value q40a q40b q40c q40d q41a q41b q41c q42 q43 q45 q46 q47 q48 q49 q50 q51a q51b CELL1 CELL2, replace

* Renaming and labeling variables, and some recoding if variable will be dropped or change 
ren q12a q12a
ren q12b q12b

rename Interviewtimeminutes int_length
rename Interviewdate date

replace q1value = 999 if q1value == .
ren q1value q1
drop q1code


rename q4region_province q4
rename _1region_city q4_1
rename _2region_couty q4_2
rename _2region_couty_name q4_2_1
rename _2other q4_2_other
drop  q4_2_other

rename q7other q7_other

rename q14other q14_other
rename q15other q15_other
rename q16other q16_other
rename q18code q18_code
rename q18value q18_value

drop q18_code
rename q18_value q18 //delete q18_code and rename q18_value, only keep variable q18

rename q21code q21_code
rename q21value q21_value

drop q21_code
ren q21_value q21

rename q22code q22_code
rename q22value q22_value

ren q22_value q22
drop q22_code

rename q23code q23_code
rename q23value q23_value

ren q23_value q23
drop q23_code

rename q24other q24_other

rename q27a q27_a
rename q27b q27_b
rename q27bi q27_bi
rename q27bii q27_bii
rename q27c q27_c
rename q27d q27_d
rename q27e q27_e
rename q27f q27_f
rename q27g q27_g
rename q27h q27_h

rename q28a q28_a
rename q28b q28_b

rename q30other q30_other
rename q31a q31_a
rename q31b q31_b

rename q32other q32_other
rename q33other q33_other

rename q34other q34_other

rename q37other q37_specify

rename q38a q38_a
rename q38b q38_b
rename q38c q38_c
rename q38d q38_d
rename q38e q38_e
rename q38f q38_f
rename q38g q38_g
rename q38h q38_h
rename q38i q38_i
rename q38j q38_j
rename q38k q38_k

drop q39code
ren q39value q39

rename q40a q40_a
rename q40b q40_b
rename q40c q40_c
rename q40d q40_d

rename q41a q41_a
rename q41b q41_b
rename q41c q41_c

*note: q44 NA in China
gen q44=.

rename q50other q50_other

rename q51a q51_a
rename q51b q51_b

rename huifang retest
rename country Country

order q*, sequential

*------------------------------------------------------------------------------*
/* Fix interview length variable and other time variables - SS: confirm if this needs to be done for China

generate recdate = dofc(date)
format recdate %td

format intlength %tcHH:MM:SS
gen int_length = (hh(intlength)*60 + mm(intlength) + ss(intlength)/60) 

format q46 %tcHH:MM
gen recq46 = (hh(q46)*60 + mm(q46))

/* raw format is in: hours, days, weeks - need to troubleshoot
format q46b %tcHH:MM:SS
gen recq46b = (hh(q46b)*60 + mm(q46b) + ss(q46b)/60) 
*/

format q47 %tcMM:SS
gen recq47 = (hh(q47)*60 + mm(q47)) 

*/

*----------------------------Fix time variables-----------------------------------------*
generate recdate = dofc(date)
format recdate %td

*------------------------------------------------------------------------------*
*language data collection did in Chinese ony, which is the offical langue in China, people can communicate with Chiese"
gen language = .
replace language = 21001
lab def lang 21001 "CN: Chinese"
lab values language lang

order q*, sequential
order respondent_id date int_length mode weight weight_educ //dropped country and lang

gen country = 21
lab def country 21 "China"
lab values country country 

gen mode = "CATI"
*gen weight=. (需要计算和赋值)
*gen weight_educ=.(需要计算和赋值)


* gen rec variable for variables that have overlap values to be country code * 1000 + variable 
* replace the value to .r if the original one is "Refused"

gen recq4 = reccountry*1000 + q4
replace recq4 = .r if q4 == 996
gen recq5 = reccountry*1000 + q5
replace recq5 = .r if q5 == 996
gen recq8 = reccountry*1000 + q8
replace recq8 = .r if q8 == 996
gen recq20 = reccountry*1000 + q20
replace recq20 = .r if q20 == 996
gen recq44 = reccountry*1000 + q44
replace recq44 = .r if q44 == 999
gen recq62 = reccountry*1000 + q62
replace recq62 = .r if q62== 996
gen recq63 = reccountry*1000 + q63
replace recq63 = .r if q63 == 996

local q4l labels8
local q5l labels9
local q8l labels12
local q20l labels23
local q44l labels23
local q62l labels53
local q63l labels54

foreach q in q4 q5 q8 q20 q44 q62 q63{
	qui elabel list ``q'l'
	local `q'n = r(k)
	local `q'val = r(values)
	local `q'lab = r(labels)
	local g 0
	foreach i in ``q'lab'{
		local ++g
		local gr`g' `i'
	}

	qui levelsof rec`q', local(`q'level)

	forvalues i = 1/``q'n' {
		local recvalue`q' = 19000+`: word `i' of ``q'val''
		foreach lev in ``q'level'{
			if strmatch("`lev'", "`recvalue`q''") == 1{
				elabel define `q'_label (= 19000+`: word `i' of ``q'val'') ///
									    (`"RO: `gr`i''"'), modify			
			}	
		}                 
	}

	
	label val rec`q' `q'_label
}

label define q4_label .a "NA" .r "Refused" , modify
label define q5_label .a "NA" .r "Refused" , modify
label define q8_label .a "NA" .r "Refused" , modify
label define q20_label .a "NA" .r "Refused" , modify
label define q44_label .a "NA" .r "Refused" , modify
label define q62_label .a "NA" .r "Refused" , modify
label define q63_label .a "NA" .r "Refused" , modify

* add label for "Refused"

label define labels52 .r "Refused", add

**** Combining/recoding some variables ****

**recode q46_refused (. = 0) if q46 != .
** no q36_refused in CN data
recode q47_refused (. = 0) if q47 != .
** Q47: Dropped in V2.0 (time spent with provider).
* no q46b_refused in CN data (V1.0 Q46b changed to q36 in V2.0 )
recode q36 (999 = .r)
*recode q36_refused (. = 0) if q36b != .
* no q36_refused in CN data (V1.0 Q46b changed to q36 in V2.0 )


*------------------------------------------------------------------------------*

* Drop unused variables 

**# drop later on
* Drop unused variables 

drop respondent_id ecs_id time_new intlength q2 q4 q5 q8 q20 q21 q45 q42 q44 q46 q47 q62 q63 q66 rim_age rim_gender rim_region rim_eduction dw_overall interviewer_id interviewer_gender interviewer_language language // q46b

*------------------------------------------------------------------------------*
* Generate variables 
gen respondent_id_cn = "CN" + respondent_id
drop respondent_id
rename respondent_id_cn respondent_id
label variable respondent_id "respondent ID"


* Q18/Q19 mid-point var ////ask shalom 996换成999，997换成998，最后一个997换成997不符合逻辑？
gen q18_q19 = q18 
recode q18_q19 (999 = 0) (998 = 0) if q19 == 1
recode q18_q19 (999 = 2.5) (998 = 2.5) if q19 == 2
recode q18_q19 (999 = 7) (998 = 7) if q19 == 3
recode q18_q19 (999 = 10) (998 = 10) if q19 == 4
recode q18_q19 (998 = .r) if q19 == 999

*Q7 V1.0 Q7=V2.0 Q7-insurance
gen recq7 = reccountry*1000 + q7
replace recq7 = .a if q7 == .a
replace recq7 = .r if q7 == 999
label def q7_label 21001 "CN:Urban employee medical insurance" ///
                   21002 "CN:Urban and rural resident medical insurance (integrated urban resident medical insurance and new rural cooperative medical insurance)" ///
				   21003 "CN:Government medical insurance" ///
				   21004 "CN:Private medical insurance" ///
				   21005 "CN:Long-term care insurance" ///
				   21006 "CN:Other" .a "NA" .r "Refused"
label values recq7 q7_label
*drop q7 
///will drop all variables later on最后drop不用的变量

/*
*------------------------------------------------------------------------------*
* Recode refused and don't know values 
recode q18 q21 q22 q23 (998 = .d)

recode q27_c q27_d q27_f q27_g q27_h (998 = .d)

* In raw data, 999 = "refused" -change from V1.0 996 to 999 in V2.0 & all questions have 999	  
recode q2 recq2 q3 q4 recq4 q5 recq5 q6 q7 recq7 q8 recq8 q9 q10 q11 q12a q12b ///
       q13 q14 q15 recq15 recq16 q17 q18 q19 q20 q21 q22 q23 q24 q25 q26 q27_a ///
	   q27_b q27_bi q27_bii q27_c q27_d q27_e q27_f q27_g q27_h q28_a q28_b q29 ///
	   q30 recq30 q31_a q31_b q32 q33 recq33 q34 recq34 q35 q36 recq34 q37 q38_a ///
	   q38_b q38_c q38_d q38_e q38_f q38_g q38_h q38_i q38_j q38_k q39 q40_a q40_b ///
	   q40_c q40_d q41_a q41_b q41_c q42 q43 q45 q46 q47 q48 q49 q50 recq50 q51 ///
	   recq51 CELL1 CELL2 (999 = .r)

*/

*------------------------------------------------------------------------------*
	 
* Check for implausible values - review

* Q25_b
list q23_q24 q25_b if q25_b > q23_q24 & q25_b < . 
* Note: okay in these data

* Q26, Q27 
list q23_q24 q27 if q27 > q23_q24 & q27 < . 
* Note: This is fine because 10 is a mid-pint value

list q26 q27 if q27 == 0 | q27 == 1
* Some implasuible values of 0 and 1
* Recode 0 values for q27 to .a for q27 and "No" for q26
* Recode 1 values to 2, because respondent likely meant 1 additional facility 
recode q27 (0 = .a) 
recode q27 (1 = 2) 

* Q39, Q40 
* list if they say "I did not get healthcare in past 12 months" but they have visit values in past 12 months 
egen visits_total = rowtotal(q23_q24 q28_a q28_b) 

* Recoding Q39 and Q40 to refused if they say "I did not get healthcare in past 12 months" but they have visit values in past 12 months 
list visits_total q39 q40 if q39 == 3 & visits_total > 0 & visits_total < . /// 
							  | q40 == 3 & visits_total > 0 & visits_total < .

* Recoding Q39 and Q40 to refused if they say "I did not get healthcare in past 12 months" but they have visit values in past 12 months 
recode q39 q40 (3 = .r) if visits_total > 0 & visits_total < .
* 10 changes to q39 and 6 changes to q40							  
							  
				 
* List if missing for q39/q40 but does have a visit
list visits_total q39 q40 if q39 == .a & visits_total > 0 & visits_total < . /// 
						   | q40 == .a & visits_total > 0 & visits_total < .
							  *Ok in data							 
							  
list visits_total q39 q40 if q39 != 3 & visits_total == 0 /// 
						   | q40 != 3 & visits_total == 0
							  
* Recoding Q39 and Q40 to "I did not get healthcare in past 12 months" if they choose no but they have no visit values in past 12 months 
recode q39 q40 (1 = 3) (2 = 3) if visits_total == 0 //recode no/yes to no visit if they said they had 0 visit in past 12 months
* total of 214 changes made to q39, 218 changes made to q40
							  
* Recoding Q39 and Q40 to "I did not get healthcare in past 12 months" if they choose no but they have no visit values in past 12 months 
recode q39 q40 (.r = .a) if visits_total == 0 //recode no/yes to no visit if they said they had 0 visit in past 12 months
* total of 1 change to q39 and 0 changes to q40

drop visits_total

*------------------------------------------------------------------------------*

*------------------------------------------------------------------------------*
* Recode missing values to NA for questions respondents would not have been asked 
* due to skip patterns

*------------------------------------------------------------------------------*

replace q7 = .a if q7 == .  //Because Q6 skip (responded no insurance)

replace q14= .a if q14==.  //due to Q13 skip (responded no usual care facility) //V1.0 q19_multi 

replace q15=.a if q15==. //due to Q13 skip (responded have usual care facility)
replace q16=.a if q16==.  
replace q16=.a if q13==0 //ASK IF Q13=1, Skip if q13=0 (responded have usual care facility) 

replace q17=.a if q13==0 //due to Q13 skip (responded have usual care facility)


replace q18_value=998 if q18_code==998

replace q19 =.a if q18!=998 //ASK IF Q18=998

**# Bookmark #7 此处有问题，按照询问条件替换之后，q20就没有值了
replace q20 =.a if  q20 == . //(ASK IF Q18>1 VISIT OR Q19=2,3,4; HAD AT LEAST TWO VISITS IN THE PAST 12 MONTHS)
replace q20 =.a if q19==2 | q19==3| q19==4

replace q21_value = 998 if q21_code == 998
replace q21_value =. a if q21_value == . //ASK IF Q20 = 0

replace q22_value=998 if q22_code==998

replace q23_value=998 if q23_code==998

replace q24=.a if q24==.  // ASK IF Q23>0 VISITS & q23!=0

replace q25=.a if q23==0 | q23==998 //ask if q23>0 & q23!=998 (ASK IF Q23>0 VISITS)

replace q28_a=.a if q28_a!=0 & q28_a!=1 
//check the skip patterns///count if q18>0 & q18!=998 |q19==2|q19==3|q19==4
//ASK IF Q18>0 VISITS OR Q19=2,3,4; HAD AT LEAST ONE VISIT IN THE PAST 12 MONTHS

replace q28_b =.a if q28_b!=0 & q28_b!=1 
//check the skip patterns///count if q18>0 &q18!=998 |q19==2|q19==3|q19==4
//ASK IF Q18>0 VISITS OR Q19=2,3,4; HAD AT LEAST ONE VISIT IN THE PAST 12 MONTHS

replace q30=.a if q29!=1 
//ask if Q29=1

replace q32=.a if q32==.
///ASK IF Q18>0 VISITS OR Q19=2,3,4//count if q18>0 & q18!=998 | q19==2 | q19==3 |q19==4

replace q33 = .a if q33 == .	//ASK IF Q18>0 VISITS OR Q19=2,3,4//count if q18>0 & q18!=998 | q19==2 | q19==3 |q19==4

replace q34=.a if q34==.
///ASK IF Q18>0 VISITS OR Q19=2,3,4//count if q18>0 & q18!=998 | q19==2 | q19==3 |q19==4

replace q35=.a if q35==.

replace q36=.a if q35!=1 //ASK IF Q35=1

replace q37=.a if q37==. //ASK IF Q18>0 VISITS OR Q19=2,3,4//count if q18>0 & q18!=998 | q19==2 | q19==3 |q19==4

replace q38_a=.a if q38_a==.

replace q38_b=.a if q38_b==.

replace q38_c=.a if q38_c==.

replace q38_d=.a if q38_d==.

replace q38_e=.a if q38_e==.

replace q38_f=.a if q38_f==.

replace q38_g=.a if q38_g==.

replace q38_h=.a if q38_h==.

replace q38_i=.a if q38_i==.

replace q38_j=.a if q38_j==.

replace q39=.a if q39==. //ASK IF Q18>0 VISITS OR Q19=2,3,4//count if q18>0 & q18!=998 | q19==2 | q19==3 |q19==4


*------------------------------------------------------------------------------*
* Recode values and value labels:
* Recode values and value labels so that their values and direction make sense
rename Country country
gen reccountry = 21
lab def country 21 "CN"
lab values reccountry country 

recode q2 (0 = 0 "under 18") ///
          (1 = 1 "18-29") ///
		  (2 = 2 "30-39") ///
		  (3 = 3 "40-49") ///
		  (4 = 4 "50-59") ///
		  (5 = 5 "60-69") ///
		  (6 = 6 "70-79") ///
		  (7 = 7 ">80") ///
		  (999 = .r "refused"), gen(recq2)
recode q16 (1 = 1 "Low cost") ///
           (2 = 2 "Short distance") ///
		   (3 = 3 "Short waiting time") ///
		   (4 = 4 "Good healthcare provider skills") ///
		   (5 = 5 "Staff shows respect") ///
		   (6 = 6 "Medicines and equipment are available") ///
		   (7 = 7 "Only facility available") ///
		   (8 = 8 "Covered by insurance") ///
		   (9 = 9 "Other, specify"), gen(recq16)
recode q30 (1 = 1 "High cost (e.g., high out of pocket payment, not covered by insurance)") ///
           (2 = 2 "Far distance (e.g., too far to walk or drive, transport not readily available)") ///
		   (3 = 3 "Long waiting time (e.g., long line to access facility, long wait for the provider)") ///
		   (4 = 4 "Poor healthcare provider skills (e.g., spent too little time with patient, did not conduct a thorough exam)") ///
		   (5 = 5 "Staff didn't show respect (e.g., staff is rude, impolite, dismissive)") ///
		   (6 = 6 "Medicines and equipment are not available (e.g., medicines regularly out of stock, equipment like X-ray machines broken or unavailable)") ///
		   (7 = 7 "Illness not serious enough") ///
		   (8 = 8 "Other, specify") ///
		   (999 = .r "Refused"), gen(recq30)

recode q34 (1 = 1 "Care for an urgent or new health problem") ///
		   (2 = 2 "Follow-up care for a longstanding illness or chronic disease") ///
		   (3 = 3 "Preventive care or a visit to check on your health") ///
		   (4 = 4 "Other,specify") ///
		   (999 = .r "Refused"), gen(recq34)
		   
gen recq4 = reccountry*1000 + q4		  
label define recq4 21001 "CN:安徽省" 21002"CN:北京市" 21003"CN:福建省" 21004"CN:甘肃省" 21005"CN:广东省" 21006"CN:广西壮族自治区" ///
                     21007 "CN:贵州省" 21008"CN:海南省" 21009"CN:河北省" 21010"CN:河南省" 21011"CN:黑龙江省" 21012"CN:湖北省" ///
					21013 "CN:湖南省" 21014"CN:吉林省" 21015"CN:江苏省" 21016"CN:江西省" 21017"CN:辽宁省" 21018"CN:内蒙古自治区" ///
					21019 "CN:宁夏回族自治区" 21020"青海省" 21021"CN:山东省" 21022"CN:山西省" 21023"CN:陕西省" 21024"CN:上海市" ///
					21025 "CN:四川省" 21026"CN:天津市" 21027"CN:西藏自治区" 21028"CN:新疆维吾尔自治区" 21029"CN:云南省" ///
					21030 "CN:浙江省" 21031"CN:重庆市"
label values recq4 recq4	
//this approach is the same as for q2 & q16 and the following
//V1.0 q5 changed to q4 in V2.0
	   
recode q5 (1 = 21001 "CN:City") ///
          (2 = 21002 "CN:Suburb of city") ///
		  (3 = 21003 "CN:Small town") ///
		  (4 = 21004 "CN:Rural area") ///
		  (9 = 999 "Refused"), gen(recq5)
replace recq5 = .r if q5 == 999 
//V2.0 .r==999，V1.0 q4 changed to q5 in V2.0	  
		  
recode q8 (1 = 21001 "CN:No formal education (illiterate)") ///
          (2 = 21002 "CN:Did not finish primary school") ///
		  (3 = 21003 "CN:Elementary school") ///
		  (4 = 21004 "CN:Middle school") ///
		  (5 = 21005 "CN:High school") ///
		  (6 = 21006 "CN:Vocational school") ///
		  (7 = 21007 "CN:Two-/Three-Year College/Associate degree") ///
		  (8 = 21008 "CN:Four-Year College/Bachelor's degree") ///
		  (9 = 21009 "CN:Master's degree") ///
		  (10 = 21010	"CN:Doctoral degree/Ph.D.") ///
		  (999 = .r "Refused"), gen (recq8)
recode q15 (1 = 21001 "CN:General hospital (Not including traditional chinese medicine hospital)") ///
           (2 = 21002 "CN:Specialized hospital (Not including traditional chinese medicine hospital") ///
		   (3 = 21003 "CN:Chinese medicine hospital") ///  
		   (4 = 21004 "CN:Community healthcare center") ///  
		   (5 = 21005 "CN:Township hospital") ///  
		   (6 = 21006 "CN:Health care post") ///  
		   (7 = 21007 "CN:Village clinic/Private clinic") ///  
		   (8 = 21008 "CN:Other") ///
		   (999 = .r "Refused"), gen(recq15)
recode q33 (1 = 21001 "CN:General hospital (Not including traditional chinese medicine hospital)") ///
           (2 = 21002 "CN:Specialized hospital (Not including traditional chinese medicine hospital") ///
		   (3 = 21003 "CN:Chinese medicine hospital") ///  
		   (4 = 21004 "CN:Community healthcare center") ///  
		   (5 = 21005 "CN:Township hospital") ///  
		   (6 = 21006 "CN:Health care post") ///  
		   (7 = 21007 "CN:Village clinic/Private clinic") ///  
		   (8 = 21008 "CN:Other") ///
		   (999 = .r "Refused"), gen(recq33)
recode q50 (1 = 210001 "CN:Mandarin Chinese") ///
           (2 = 210002 "CN:other languages") ///
		   (999 = .r "Refused"), gen(recq50)
recode q51 (1 = 21001 "CN:<700") ///
           (2 = 21002 "CN:700-1499") ///
		   (3 = 21003 "CN:1500-2499") ///  
		   (4 = 21004 "CN:2500-3999") ///  
		   (5 = 21005 "CN:4000-6999") ///  
		   (6 = 21006 "CN:>=7000") /// 
           (999 = .r "Refused"), gen(recq51)
		   
* add label for "Refused"

label define labels52 .r "Refused", add		   
		   

*------------------------------------------------------------------------------*
**# PVS ROMANIA - CATEGORIZATION OF "OTHER, SPECIFY" RESPONSES

replace q7_other = "不知道" if q7_other == "不清楚" ///
                              | q7_other == "不知道." ///
							  | q7_other == "不知道。" ///
							  | q7_other == "不知道没注意，每次都是直接支付宝" ///
							  | q7_other== "不知道，不清楚" ///
							  | q7_other== "不知道，我忘了，说不清楚" ///
							  | q7_other == "不记得" ///
							  | q7_other == "家里给买的不太清楚" ///
							  | q7_other == "我不清楚，我爸帮我搞的。" ///
							  | q7_other == "我不知道这两个的区别，是公司买的" ///
							  | q7_other == "我也不知道，我没了解过这个方面" ///
							  | q7_other == "这个我不知道"
							  
replace q7_other = "社保" if q7_other == "个人买的社保" ///
                              | q7_other == "社会医保" ///
							  | q7_other == "社保。" ///
							  | q7_other == "社保，不知道是什么" 
replace q7_other = "城镇职工医疗保险和商业医疗保险" if q7_other == "城乡和商业都有，一样重要" ///
                              | q7_other == "城镇职工医疗保险和商业医疗保险都有在用，如果去私立医院就是商业医疗保险，去公立医院就是城镇职工医疗保险。" ///
							  | q7_other == "我有职工和商业险，我不知道哪个最主要" 
replace q7_other = "城乡居民医疗保险和商业医疗保险" if q7_other=="城镇职工医疗保险和商业医疗保险都有，都重要啊"  ///
							  | q7_other == "城乡居民医疗保险，和商业医疗"
replace q7=2 if q7_other == "每年120元"
replace q7_other = "4种保险" if q7_other == "什么都有，公费，个人都有，有四个，我不知道哪个最重要"
replace q7_other=".d" if q7_other == "不知道" ///

replace q14_other="不知道" if q14_other=="不清楚"
replace q14_other=".d" if q14_other=="不知道"

replace q15_other = "不知道" if q15_other == "不清楚" ///
                              | q15_other == "三甲医院" ///
                              | q15_other == "中西五医院" ///
							  | q15_other == "中西结合医院" ///
							  | q15_other == "保健院" ///
							  | q15_other == "天门市妇幼保健院" ///
							  | q15_other == "工人医院"
replace q15_other=".d" if q15_other == "不知道"

replace q16=8 if q16_other == "单位附属医院" ///
               | q16_other == "员工" ///
			   | q16_other == "因为我在那里上班。" ///
			   | q16_other == "在医院工作"  ///
			   | q16_other == "就在本单位工作，所以选择这家医院"  ///
			   | q16_other == "我在那工作"  ///
			   | q16_other == "我是在这个医院读书"  ///
			   | q16_other == "自己的医院"  ///
			   | q16_other == "这家医院的职工"
list q16_other if q16_other == "单位附属医院" ///
               | q16_other == "员工" ///
			   | q16_other == "因为我在那里上班。" ///
			   | q16_other == "在医院工作"  ///
			   | q16_other == "就在本单位工作，所以选择这家医院"  ///
			   | q16_other == "我在那工作"  ///
			   | q16_other == "我是在这个医院读书"  ///
			   | q16_other == "自己的医院"  ///
			   | q16_other == "这家医院的职工"
replace q16=7 if q16_other == "没得选择"
list q16_other if q16_other == "没得选择"
replace q16=6 if q16_other == "设备好"
list q16_other if q16_other == "设备好"
replace q16=5 if q16_other == "医院服务好"
list q16_other if q16_other == "医院服务好"
replace q16=3 if q16_other == "人少"
list q16_other if q16_other == "人少"
replace q16=4 if q16_other == "三甲医院" ///
               | q16_other == "出名"  ///
	           | q16_other == "因为那家医院是当地最好的" ///
			   | q16_other == "大医院比较权威"  ///
			   | q16_other == "大医院，比较有公信力"  ///
			   | q16_other == "当地名气最大"  ///
			   | q16_other == "最好的医院"  ///	
			   | q16_other == "机构比较权威。" ///
			   | q16_other == "权威" ///
			   | q16_other == "权威机构"  ///
			   | q16_other == "比较权威"  ///
			   | q16_other == "比较权威靠谱"  ///
			   | q16_other == "这是三甲医院"  ///
			   | q16_other == "医院比较大，医院等级"  ///
			   | q16_other == "医院规模比较大"  ///
			   | q16_other == "医院较大，比较专业有安全感"  ///
			   | q16_other == "因为它是市级医院，比较大一些"  ///
			   | q16_other == "大医院好一点"  ///
			   | q16_other == "大医院，比较放心"  ///
			   | q16_other == "大医院好一点"  ///
			   | q16_other == "最大的，安全一些"  ///
			   | q16_other == "比较正规吧大医院"  ///
			   | q16_other == "大医院好一点"  ///
			   | q16_other == "专科"  ///
			   | q16_other == "这里最大的医院"
list q16_other if q16_other == "三甲医院" ///
               | q16_other == "出名"  ///
	           | q16_other == "因为那家医院是当地最好的" ///
			   | q16_other == "大医院比较权威"  ///
			   | q16_other == "大医院，比较有公信力"  ///
			   | q16_other == "当地名气最大"  ///
			   | q16_other == "最好的医院"  ///	
			   | q16_other == "机构比较权威。" ///
			   | q16_other == "权威" ///
			   | q16_other == "权威机构"  ///
			   | q16_other == "比较权威"  ///
			   | q16_other == "比较权威靠谱"  ///
			   | q16_other == "这是三甲医院"  ///
			   | q16_other == "医院比较大，医院等级"  ///
			   | q16_other == "医院规模比较大"  ///
			   | q16_other == "医院较大，比较专业有安全感"  ///
			   | q16_other == "因为它是市级医院，比较大一些"  ///
			   | q16_other == "大医院好一点"  ///
			   | q16_other == "大医院，比较放心"  ///
			   | q16_other == "大医院好一点"  ///
			   | q16_other == "最大的，安全一些"  ///
			   | q16_other == "比较正规吧大医院"  ///
			   | q16_other == "大医院好一点"  ///
			   | q16_other == "专科" ///
			   | q16_other == "这里最大的医院"
replace q16=2 if q16_other == "乡镇医院方便" ///
               | q16_other == "综合因素，距离近公立方便多种原因"
list q16_other if q16_other == "乡镇医院方便" ///
               | q16_other == "综合因素，距离近公立方便多种原因"
replace q16_other = "相信中医" if q16_other == "中医比西医好一点" ///
               | q16_other == "中药对人体副作用伤害小" ///
			   | q16_other == "主要是想看中医" ///
			   | q16_other == "我支持中医" ///
			   | q16_other == "我相信中医这块。" ///
			   | q16_other == "更相信中医" ///
			   | q16_other == "要看中医"	   
replace q16_other = "专科" if q16_other == "专病专治" ///
               | q16_other == "这是专科医院" ///
			   | q16_other == "专业对口"
replace q16_other = "朋友推荐" if q16_other == "别人推荐的" ///
               | q16_other == "熟人介绍" 
replace q16_other = "环境好" if q16_other == "环境比较好" 
replace q16_other = "医疗条件好" if q16_other == "医疗条件有保障"
replace q16_other = "有熟人" if q16_other == "有熟人在，可以帮忙" ///
                                | q16_other == "有熟人，有认识的人" ///
								| q16_other == "有熟人。" ///
								| q16_other == "有家人在" ///
								| q16_other == "因为我老婆在那里上班。" ///
								| q16_other == "有熟人在，可以帮忙。" ///
								| q16_other == "我以前在这里工作"
								
replace q16_other = "信任医院" if q16_other == "具有安全感、靠谱" ///
								| q16_other == "口碑" ///
								| q16_other == "口碑好" ///
								| q16_other == "安心些" ///
								| q16_other == "存在时间长，从出生就在" ///
								| q16_other == "对医院的信任吧。" ///
								| q16_other == "放心" /// 
								| q16_other == "正规医疗机构比较放心" ///
								| q16_other == "正规医院" ///
								| q16_other == "比较规范" ///
								| q16_other == "镇医院有保障撒。" ///
								| q16_other == "放心一点不会乱收费"
replace q16_other = "公立医院" if q16_other == "公立医院有保障" ///
                                | q16_other == "公立医院，比较可靠" ///
								| q16_other == "国家医院，正规" ///
								| q16_other == "当地时间最早的公立医院" ///
								| q16_other == "是公立医院，上公立医院方便"
replace q16_other="习惯了" if q16_other == "习惯" ///
                            | q16_other == "习惯性。" ///
							| q16_other == "我去习惯了。" ///
							| q16_other == "已经习惯去这家医院" ///
							| q16_other == "长期调理" ///
							| q16_other == "全家人都在这家机构打疫苗" ///
							| q16_other == "长期看病的地方"
replace q16_other = "信任医院" if q16_other == "习惯了"
replace q16_other = "信任医院" if q16_other == "公立医院"
*听录音能否这样归类
replace q16_other="综合原因" if q16_other == "三甲医院.距离近可以报销等综合因素" ///
                            | q16_other == "就是综合方面比较好" ///
							| q16_other == "医疗资源好" ///
							| q16_other == "医疗有保障" ///
							| q16_other == "医疗条件好" ///
							| q16_other == "环境好"

replace q24 = 1 if q24_other == "体检后，发现有问题去检查。"
list q24_other if q24_other == "体检后，发现有问题去检查。"
replace q24_other = "" in 526 //526 is the result of "list"
replace q24 = 1 if q24_other == "无明确病症，健康咨询"
list q24_other if q24_other == "无明确病症，健康咨询"
replace q24_other = "" in 947 //947 is the result of "list"
replace q24 = 1 if q24_other == "就是开药"
list q24_other if q24_other == "就是开药"
replace q24_other = "" in 2045 //2045 is the result of "list"
replace q24 = 1 if q24_other == "用药咨询"
list q24_other if q24_other == "用药咨询"
replace q24_other = "" in 1679 //1679 is the result of "list"
							
							
replace q30 = 1 if q30_other == "医保不能报销"  ///
	| q30_other == "异地报销，不给报销"  ///
	| q30_other == "没法报销医保" ///
	| q30_other == "不报销"
list q30_other if q30_other == "医保不能报销"  ///
	| q30_other == "异地报销，不给报销"  ///
	| q30_other == "没法报销医保" ///
	| q30_other == "不报销"
replace q30_other = "" if q30_other == "医保不能报销"  ///
	| q30_other == "异地报销，不给报销"  ///
	| q30_other == "没法报销医保" ///
	| q30_other == "不报销"	
	
replace q30=3 if q30_other=="不好挂号"  ///
	 | q30_other == "人员满了，没排上号"  ///
	 | q30_other == "人太多，医生太少了"  ///
	 | q30_other == "医护人员不足"  ///
	 | q30_other == "医院人满为患，排不了队了" | ///
     | q30_other == "挂不上号" ///
	 | q30_other == "排不上号"  ///
	 | q30_other == "没挂上号。"  ///
	 | q30_other == "没有挂到号"  
replace q30_other = "" if q30_other == "不好挂号"  ///
	 | q30_other == "人员满了，没排上号"  ///
	 | q30_other == "人太多，医生太少了"  ///
	 | q30_other == "医护人员不足"  ///
	 | q30_other == "医院人满为患，排不了队了" | ///
     | q30_other == "挂不上号" ///
	 | q30_other == "排不上号"  ///
	 | q30_other == "没挂上号。"  ///
	 | q30_other == "没有挂到号"  
replace q30 = 7 if q30_other == "自己在家吃药"
replace q30_other = "" if q30_other == "自己在家吃药"
replace q30_other = "COVID (COVID restritions or COVID fear)" if q30_other == "因为新冠疫情，医院科室停诊" ///
      | q30_other == "因为新冠的时候出不去。" ///
	  | q30_other == "新冠期间" ///
	  | q30_other == "新冠期间，就诊比较困难。"  ///
	  | q30_other == "新冠肺炎" ///
	  | q30_other == "疫情期间医护人员不够" ///
      | q30_other == "疫情期间，医院不接诊，需要转移到别的医院" ///
      | q30_other == "隔离。" 
replace q30_other = "没有时间" if q30_other == "工作原因" ///
      | q30_other == "没时间" ///
	  | q30_other == "工作忙。" ///
	  | q30_other == "没有时间去" ///
	  | q30_other == "家里走不开。"							
							
replace q32_other = "不知道" if q32_other == "不知道。" ///
	  | q32_other == "没记住。"  ///
	  | q32_other == "单位固定医疗机构体检"  ///
	  | q32_other == "农村的诊所，不知道是公立还是私立" 
replace q32 = 2 if q32_other == "国际"
replace q32_other = "" if q32_other == "国际"
replace q32_other = ".d" if q32_other == "不知道"							

replace q33_other = "不知道" if q33_other == "不清楚" ///
                | q33_other == "不清楚。" /// 
				| q33_other=="忘记了。" ///
				|q33_other=="私人医院不清楚" 
replace q33_other = "体检机构" if q33_other == "不知道名字，就是一个体检机构" ///
                | q33_other == "体检中心" /// 
				| q33_other=="体检医院" ///
				| q33_other=="公司的体检中心" /// 
				| q33_other=="和谐健康体检中心" ///
				| q33_other=="实名体检中心" ///
				| q33_other=="美兆体检中心" 
replace q33_other = "妇幼保健医院" if q33_other == "天门市妇幼保健院" ///
                | q33_other == "妇幼保健院" 
replace q33 = 1 if q33_other == "中西结合医院" | q33_other == "工人医院"
replace q33_other = "" if q33_other == "中西结合医院" | q33_other == "工人医院"							
							
replace q34 = 1 if q34_other == "内分泌不调" ///
	| q34_other == "去医院做手术"  ///
	| q34_other == "囊肿"  ///
	| q34_other == "拔牙"  ///
	| q34_other == "消化不良"  ///
	| q34_other == "看牙"  ///
	| q34_other == "箍牙"  ///
	| q34_other == "补牙"  ///
	| q34_other == "补牙齿"  ///
	| q34_other == "没事儿干，去医院溜达。我也不知道啥原因了，感觉有点疼，B超，ct,检查后，医生说没什么问题。"  ///
	| q34_other == "配假牙"
replace q34_other = ""  if q34_other == "内分泌不调" ///
	| q34_other == "去医院做手术"  ///
	| q34_other == "囊肿"  ///
	| q34_other == "拔牙"  ///
	| q34_other == "消化不良"  ///
	| q34_other == "看牙"  ///
	| q34_other == "箍牙"  ///
	| q34_other == "补牙"  ///
	| q34_other == "补牙齿" ///
	| q34_other == "没事儿干，去医院溜达。我也不知道啥原因了，感觉有点疼，B超，ct,检查后，医生说没什么问题。"  ///
	| q34_other == "配假牙"
replace q34 = 2 if q34_other == "调理身体"
replace q34_other = "" if q34_other == "调理身体"
replace q34_other = "生孩子"  if q34_other == "生产" | ///
	q34_other == "生孩子去的" | ///
	q34_other == "生小孩" 
replace q34_other=".d" if q34_other=="不清楚" ///
      | q34_other=="不知道" ///
	  | q34_other=="我也不知道，搞不懂"							

	  
replace q37=.r if q37_specify=="不清楚"
replace q37_specify = "" in 2259
replace q37_specify = "24" if q37_specify == "第二天"
replace q37_specify = "5" if q37_specify == "4-5小时内"
replace q37_specify = "48" if q37_specify == "48小时" |  q37_specify = "两天"
replace q37_specify = "9" if q37_specify == "9小时"
destring q37_specify, replace	  
	  
	  
replace q50_other = "蒙古族" if q50_other == "蒙族" | q50_other == "蒙古"
replace q50_other = "维吾尔族" if q50_other == "新疆维吾尔族"
replace q50 = 1 if q50_other == "闽南语"
replace q50_other = "" if q50_other == "闽南语"							
							

*----------------CN country = 21, country_reg = 12----------------*


order q*, sequential
rename ID respondent_id



order respondent_id date int_length mode weight weight_educ




*------------------------------------------------------------------------------*