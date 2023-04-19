
********************************* Append data *********************************

u "$data_mc/02 recoded data/pvs_co_pe_uy.dta", clear

tempfile label1
label save q4_label q5_label q7_label q8_label q20_label q44_label q62_label q63_label using `label1'
label drop q4_label q5_label q7_label q8_label q20_label q44_label q62_label q63_label 

append using "$data_mc/02 recoded data/pvs_et_in_ke_za.dta"

qui do `label1'

tempfile label2
label save q4_label q5_label q7_label q8_label q20_label q44_label q62_label q63_label using `label2'
label drop q4_label q5_label q7_label q8_label q20_label q44_label q62_label q63_label

append using "$data_mc/02 recoded data/pvs_la.dta"

qui do `label2'

tempfile label3
label save q4_label q5_label q7_label q8_label q20_label q44_label q62_label q63_label using `label3'
label drop q4_label q5_label q7_label q8_label q20_label q44_label q62_label q63_label

append using "$data_mc/02 recoded data/pvs_it_mx_us.dta"

qui do `label3'

tempfile label4
label save q4_label q5_label q7_label q8_label q20_label q44_label q62_label q63_label q66_label using `label4'
label drop q4_label q5_label q7_label q8_label q20_label q44_label q62_label q63_label q66_label

append using "$data_mc/02 recoded data/pvs_kr.dta"

qui do `label4'

tempfile label5
label save q4_label q5_label q7_label q8_label q20_label q44_label q63_label using `label5'
label drop q4_label q5_label q7_label q8_label q20_label q44_label q63_label

append using "$data_mc/02 recoded data/pvs_ar.dta"

qui do `label5'

tempfile label6
label save q4_label q5_label q7_label q8_label q20_label q44_label q63_label using `label6'
label drop q4_label q5_label q7_label q8_label q20_label q44_label q63_label

append using "$data_mc/02 recoded data/pvs_uk.dta"

qui do `label6'


* Country
lab def labels0 11 "Lao PDR" 12 "United States" 13 "Mexico" 14 "Italy" 15 "Republic of Korea" 16 "Argentina (Mendoza)" ///
				17 "United Kingdom", modify

* Kenya/Ethiopia variables 
ren q19 q19_et_in_ke_za
lab var q19_et_in_ke_za "Q19. ET/IN/KE/ZA only: Is this a public, private, or NGO/faith-based facility?"
ren q43 q43_et_in_ke_za_la
lab var q43_et_in_ke_za_la "Q43. ET/IN/KE/ZA/LA only: Is this a public, private, or NGO/faith-based facility?"
* NOTE: Q43 also asked like this in Laos
ren q56 q56_et_in_ke_za 
lab var q56_et_in_ke_za "Q56. ET/IN/KE/ZA only: How would you rate quality of NGO/faith-based healthcare?"

* Mode
recode mode (3 = 1) (4 = 3)
lab def mode 1 "CATI" 2 "F2F" 3 "CAWI", replace
label val mode mode
lab var mode "Mode of interview (CATI, F2F, or CAWI)"

* Country-specific skip patterns - check this 
recode q19_et_in_ke_za q56_et_in_ke_za (. = .a) if country != 5 | country != 3  | country != 9  
recode q43_et_in_ke_za_la (. = .a) if country != 5 | country != 3  | country != 9 | country != 11
recode q19_uy q43_uy q56_uy (. = .a) if country != 10
recode q56_pe (. = .a) if country != 7
recode q19_co_pe q43_co_pe (. = .a) if country != 2 & country != 7 
recode q6_za q37_za (. = .a) if country != 9
recode q6_la q14_la q15_la q18a_la q19_q20a_la q18b_la q19_q20b_la ///		
		(. = .a) if country != 11
recode q14 q15 (. = .a) if country == 11 
recode q18 q20 q64 q65 (. = .a) if country == 11 
recode q6_it q19_it q43_it (. = .a) if country != 14
recode q19_mx q43_mx q56a_mx q56b_mx q62_mx (. = .a) if country != 13
recode q62a_us q62b_us q66a_us q66b_us (. = .a) if country != 12
recode q28_c q46a q46b q46b_refused q48_k ///
	   (. = .a) if country != 12 | country != 13 | country != 14	   
recode q66 (. = .a) if country != 13 | country != 14 | country != 15
recode q6_kr q7_kr q19_kr q43_kr (. = .a) if country != 15
recode q7 (. = .a) if country == 15 
* Add the line to recode q6 to .a if the country has country specific q6. This might have been done in each individual cleaning program but do it again here to be sure
recode q6 (. = .a) if inlist(country,9,11,14,15) 
recode q3a_co_pe_uy_ar q13b_co_pe_uy_ar q13e_co_pe_uy_ar (. = .a) if country != 2 | country != 7 |  country != 11 | country != 16 
recode q19_ar q43_ar q56a_ar q56b_ar q56c_ar (. = .a) if country != 16 
recode q37_in (. = .a) if country != 4
recode q64 q65 q46_refused q47_refused (. = .a) if country == 15 
recode q6_uk q19a_uk q19b_uk q43a_uk q43b_uk q62_uk q66_uk (. = .a) if country != 17

	   
* Country-specific value labels -edit for ssrs-
lab def Language 2011 "CO: Spanish" 3003 "ET: Amharic" 3004 "ET: Oromo" 3005 "ET: Somali" ///
				 4001 "IN: English" 4011 "IN: Hindi" 4012 "IN: Kannada" 4013 "IN: Tamil" 4014 "IN: Bengali" 4015 "IN: Telugu" ///
				 5001 "KE: English" 5002 "KE: Swahili" 7011 "PE: Spanish" 9001 "ZA: English" ///
				 9006 "ZA: Sesotho" 9007 "ZA: isiZulu" 9008 "ZA: Afrikaans" ///
				 9009 "ZA: Sepedi" 9010 "ZA: isiXhosa" 10011 "UY: Spanish" 11001 "LA: Lao" ///
				 11002 "LA: Khmou" 11003 "LA: Hmong" 12009 "US: English" 12010 "US: Spanish" ///
				 13058 "MX: Spanish" 14016 "IT: Italian" 15001 "KR: Korean" 16001 "AR: Spanish"
				 
				 
lab val language Language
lab var language "Language of interview"

* Other value label modifcations
lab def q4_label .a "NA" .r "Refused", modify
lab def q5_label .a "NA" .r "Refused", modify
lab def q6_kr .a "NA" , modify
lab def q7_label .a "NA" .r "Refused", modify
lab def q8_label .a "NA" .r "Refused", modify
lab def covid_vacc_la .a "NA" , modify
lab def q20_label .a "NA" .r "Refused", modify
lab def q44_label .a "NA" .r "Refused", modify
lab def q62_label .a "NA" .r "Refused", modify
lab def q63_label .a "NA" .r "Refused" .d "Don't know", modify
lab def labels16 .a "NA" .r "Refused", modify
lab def labels24 .a "NA" .r "Refused", modify
lab def labels22 .a "NA" .r "Refused", modify
lab def labels23 .a "NA" .r "Refused", modify
lab def labels26 .a "NA" .r "Refused", modify
lab def labels37 11 " AR: Delay to get a turn " .a "NA" .r "Refused", modify
lab def labels39 .a "NA" .r "Refused", modify
lab def labels40 .a "NA" .r "Refused", modify
lab def labels50 .r "Refused", modify
lab def Q19 .a "NA" .r "Refused", modify
lab def Q43 .a "NA" .r "Refused", modify
lab def place_type .a "NA" .r "Refused", modify
lab def fac_owner .a "NA" .r "Refused", modify
lab def fac_type1 .a "NA" .r "Refused", modify
lab def fac_type3 .a "NA" .r "Refused", modify
lab def gender2 3 "AR: Other gender", modify
lab def labels26 10 "AR: Short waiting time to get appointments", modify
 
*** weights ***
drop weight
ren weight_educ weight
lab var weight "Final weight (based on gender, age, region, education)"

*** Code for survey set ***
gen respondent_num = _n 
sort mode psu_id respondent_num
gen short_id = _n if mode == 1 | mode == 3
replace psu_id = subinstr(psu_id, " ", "", .) if mode == 1 | mode == 3
encode psu_id, gen(psu_id_numeric) // this makes a numeric version of psu_id; an integer with a value label 
gen long psu_id_for_svy_cmds = cond(mode==1 | mode==3, 1e5+short_id, 2e5+psu_id_numeric) 
drop short_id psu_id_numeric
label variable psu_id_for_svy_cmds "PSU ID for every respondent (100 prefix for CATI/CAWI and 200 prefix for F2F)"
 
* This will have values 100001 up to 102006 for the Kenya data CATI folks and (if there were 20 PSUs) 200002 to 200021 for F2F  (200001 is skipped because Stata thinks of psu_id_numeric == 1 as being the CATI respondents.
* Each person will have their own PSU ID for CATI and each sampled cluster will have a unique ID for the F2F.
 
* Now the svyset syntax will simply be:
* svyset psu_id_for_svy_cmds [pw=weight], strata(mode)
* or equivalently
* svyset psu_id_for_svy_cmds , strata(mode) weight(weight)

* Keep variables relevant for data sharing and analysis  
* Dropping time for now 
* 4/10: Mia removed region_stratum kebele matrix sum_size_region dw_psu n_unit dw_unit n_elig sublocation rim_region_ke rim_educ rim_gender rim_region rim_education rim_eduction dw_overall dw_ind dw_overall_relative rim_region_et rim_age province county total
drop rim1_gender rim2_age rim3_region w_des w_des_uncapped rim4_educ respondent_num interviewer_gender interviewer_id time q1_codes interviewerid_recoded 


**** Other Specify Recode ****

* This command recodes all "other specify" variables as listed in /specifyrecode_inputs spreadsheet
* This command requires an input file that lists all the variables to be recoded and their new values
* The command in data quality checks below extracts other, specify values 


*All (Laos and Argentina pending)

gen q7_other_original = q7_other
label var q7_other_original "Q7_other. Other type of health insurance?"

gen q13e_other_co_pe_uy_ar_original = q13e_other_co_pe_uy_ar
label var q13e_other_co_pe_uy_ar_original "Q13E. CO/PE/UY only: Other"
	
gen q19_other_original = q19_other
label var q19_other_original "Q19. Other"

gen q19_q20a_other_original = q19_q20a_other
label var q19_q20a_other_original "Q19A. LA only: Other"

gen q19_q20b_other_original = q19_q20b_other
label var q19_q20b_other_original "Q19B. LA only: Other"

gen q20_other_original = q20_other
label var q20_other_original "Q20. Other"

gen q21_other_original = q21_other
label var q21_other_original "Q21. Other"

gen q42_other_original = q42_other
label var q42_other_original "Q42. Other"

gen q43_other_original = q43_other
label var q43_other_original "Q43. Other"

gen q44_other_original = q44_other
label var q44_other_original "Q44. Other"
	
gen q45_other_original = q45_other
label var q45_other_original "Q45. Other"	

gen q62_other_original = q62_other
label var q62_other_original "Q62. Other"	

gen q62b_other_us_original = q62b_other_us
label var q62b_other_us_original "Q62B. US only: Other"	


*Remove "" from responses for macros to work
replace q7_other = subinstr(q7_other,`"""',  "", .)
replace q13e_other_co_pe_uy_ar = subinstr(q13e_other_co_pe_uy_ar,`"""',  "", .)
replace q19_other = subinstr(q19_other,`"""',  "", .)
*replace q19_q20a_other = subinstr(q19_q20a_other,`"""',  "", .)
*replace q19_q20b_other = subinstr(q19_q20b_other,`"""',  "", .)
replace q20_other = subinstr(q20_other,`"""',  "", .)
replace q21_other = subinstr(q21_other,`"""',  "", .)
replace q42_other = subinstr(q42_other,`"""',  "", .)
replace q43_other = subinstr(q43_other,`"""',  "", .)
replace q44_other = subinstr(q44_other,`"""',  "", .)
replace q45_other = subinstr(q45_other,`"""',  "", .)
replace q62_other = subinstr(q62_other,`"""',  "", .)
replace q62b_other_us = subinstr(q62b_other_us,`"""',  "", .)

**Numbers correspond to the value labels for each country.
gl id 			"respondent_id"	

foreach i in 2 3 4 5 7 9 10 11 12 13 14 15 16 {

ipacheckspecifyrecode using "$data_mc/03 test output/Input/specifyrecode_inputs/specifyrecode_inputs_`i'.xlsm",	///
	sheet(other_specify_recode)							///	
	id(respondent_id)	
 
}	

order q*, sequential
order respondent_serial respondent_id mode country language date ///
	  int_length psu_id_for_svy_cmds weight 	

drop q7_other q13e_other_co_pe_uy_ar q19_other q19_q20a_other_la q19_q20b_other_la q20_other ///
	 q21_other q42_other q43_other q44_other q45_other q62_other q62b_other_us
	 
ren q7_other_original q7_other
ren q13e_other_co_pe_uy_ar_original q13e_other_co_pe_uy_ar
ren q19_other_original q19_other
ren q19_q20a_other_original q19_q20a_other_la
ren q19_q20b_other_original q19_q20b_other_la
ren q20_other_original q20_other
ren q21_other_original q21_other
ren q42_other_original q42_other
ren q43_other_original q43_other
ren q44_other_original q44_other
ren q45_other_original q45_other
ren q62_other_original q62_other
ren q62b_other_us_original q62b_other_us


* Reorder variables
order q*, sequential
order respondent_serial respondent_id mode country language date ///
	  int_length psu_id_for_svy_cmds weight 
	
*Save recoded data
save "$data_mc/02 recoded data/pvs_appended.dta", replace

*------------------------------------------------------------------------------*

/*
* NOTE: Optional data quality checks 


***************************** Data quality checks *****************************

use "$data_mc/02 recoded data/pvs_appended.dta", clear

* Macros for these commands
gl inputfile	"$data_mc/03 test output/Input/dq_inputs.xlsm"	
gl dq_output	"$output/dq_output.xlsx"				
gl id 			"respondent_id"	
gl key			"respondent_serial"	
gl enum			"interviewer_id"
gl date			"date"	
gl time			"time"
gl duration		"int_length"
gl keepvars 	"country"
global all_dk 	"q13b q13e q23 q25_a q25_b q27 q28_a q28_b q30 q31 q32 q33 q34 q35 q36 q38 q50_a q50_b q50_c q50_d q63 q64 q65"
global all_num 	"q1 q2 q3 q4 q5 q6 q7 q8 q9 q10 q11 q12 q13 q14 q15 q16 q17 q18 q19_et_in_ke_za q19_co q19_pe q19_uy q20 q21 q22 q23 q24 q25_a q25_b q26 q27 q28_a q28_b q29 q30 q31 q32 q33 q34 q35 q36 q38 q39 q40 q41 q42 q43_et_in_ke_za q43_co q43_pe q43_uy q44 q45 q46 q47 q46_min q46_refused q47_min q47_refused q48_a q48_b q48_c q48_d q48_e q48_f q48_g q48_h q48_i q48_j q49 q50_a q50_b q50_c q50_d q51 q52 q53 q54 q55 q56_ke_et q56_pe q56_uy q57 q58 q59 q60 q61 q62 q63 q64 q65"


*====================== Check start/end date of survey ======================* 


* list $id if $date < date("01-Jul-2020", "DMY") | $date > date("01-Dec-2022", "DMY") 

* list $id if Time > date("18:00:00", "07:00:00") | Time < date("18:00:00", "%tcHH:MM:SS")												
												
* NOTE: The above lines are still not working well for me. It runs - but appears to not be accurate 
* Just leaving in case we decide to add	them back 											
												
*========================== Find Survey Duplicates ==========================* 

 * This command finds and exports duplicates in Survey ID

 
ipacheckids ${id},							///
	enumerator(${enum}) 					///	
	date(${date})	 						///
	key(${key}) 							///
	outfile("${dq_output}") 				///
	outsheet("id duplicates")				///
	keep(${keepvars})	 					///
	sheetreplace							
						

    * Other methods 

	isid $id
	duplicates list $id

*=============================== Outliers ==================================* 
 
* This command checks for outliers among numeric survey variables 
* This code requires an input file that lists variables to check for outliers 

* NOTE: This should be done before dropping outliers 
* The "by" function may not be working

ipacheckoutliers using "${inputfile}",			///
	id(${id})									///
	enumerator(${enum}) 						///	
	date(${date})	 							///
	sheet("outliers")							///
    outfile("${dq_output}") 					///
	outsheet("outliers")						///
	sheetreplace

   
*============================= Other Specify ===============================* 
 
* This command lists all other, specify values
* This command requires an input file that lists all the variables with other, specify text 

use "$data_mc/02 recoded data/pvs_appended.dta", clear

*The code below generates a non-relevant interviewer id for the code to run, however it is not accurate because the interviewer id is deleted at a previous stage of data cleaning.
gen interviewer_id = respondent_serial
*This section trims those "other specify" responses that just have a space and should be empty
replace q19_other=trim(q19_other)
replace q20_other=trim(q20_other)
replace q21_other=trim(q21_other)
replace q42_other=trim(q42_other)
replace q43_other=trim(q43_other)
replace q44_other=trim(q44_other)
replace q45_other=trim(q45_other)
replace q62_other=trim(q62_other)
replace q7_other=trim(q7_other)

*Remove "" from responses for macros to work
replace q19_other = subinstr(q19_other,`"""',  "", .)
replace q43_other = subinstr(q43_other,`"""',  "", .)
replace q45_other = subinstr(q45_other,`"""',  "", .)

foreach i in 2 3 4 5 7 9 10 11 12 13 14 15 16 {

 preserve
 keep if country == `i'
  
 ipacheckspecify using "$data_mc/03 test output/Input/dq_inputs/dq_inputs_`i'.xlsm",   ///
 id(${id})         ///
 enumerator(${enum})       /// 
 date(${date})         ///
 sheet("other specify")      ///
    outfile("$output/dq_output/dq_output_`i'.xlsx")      ///
 outsheet1("other specify")     ///
 outsheet2("other specify (choices)")  ///
 sheetreplace
 
 loc childvars "`r(childvarlist)'"
 
 restore 
 
}	

*========================= Summarizing All Missing ============================* 

* Below I summarize NA (.a), Don't know (.d), Refused (.r) and true Missing (.) 
* across the numeric variables(only questions) in the dataset by country
* This is helpful to check if cleaning commands above are working (esp skip pattern recode)
   
* Count number of NA, Don't know, and refused across the row 
ipaanycount $all_num, gen(na_count) numval(.a)
ipaanycount $all_dk, gen(dk_count) numval(.d)
ipaanycount $all_num, gen(rf_count) numval(.r)

* Count of total true missing 
egen all_missing_count = rowmiss($all_num)
gen missing_count = all_missing_count  - (na_count + dk_count + rf_count)

* Denominator for percent of NA and Refused 
egen nonmissing_count = rownonmiss($all_num)
gen total_miss = all_missing_count + nonmissing_count

* Denominator for percent of Don't know 
egen dk_nonmiss_count = rownonmiss($all_dk) 
egen dk_miss_count = rowmiss($all_dk) 
gen total_dk = dk_nonmiss_count + dk_miss_count 


preserve

collapse (sum) na_count dk_count rf_count missing_count total_miss total_dk, by(country)
gen na_perc = na_count/total_miss
gen dk_perc = dk_count/total_dk
gen rf_perc = rf_count/total_miss
gen miss_perc = missing_count/total_miss 
lab var na_perc "NA (%)" 
lab var dk_perc "Don't know (%)"
lab var rf_perc "Refused (%)"
lab var miss_perc "Missing (%)"
export exc country na_perc dk_perc rf_perc miss_perc using "$dq_output", sh(missing, replace) first(varl)

restore 

* Other options 
* misstable summarize Q28_A