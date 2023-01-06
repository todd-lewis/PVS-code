* People's Voice Survey data cleaning and appending
* Date of last update: Jan 5, 2023
* Last updated by: N Kapoor

/*
This file cleans data by country and appends data into a multi-country dataset.

Cleaning includes:
	- Dropping any unusable records 
	- Recoding outliers to missing 
	- Recoding skip patterns, refused, and don't know 
	- Creating new variables (e.g., time variables), renaming variables, labeling variables 
	- Correcting any values and value labels and their direction 
	
Missingness codes: .a = NA (skipped), .r = refused, .d = don't know, . = true missing 

*/

clear all
set more off 

******************************* ETHIOPIA & KENYA *******************************

* Import raw data 
use "$data_mc/01 raw data/PVS_ET and KE weighted_22.12.22.dta", clear

*------------------------------------------------------------------------------*

*Change all variable names to lower case

rename *, lower

*------------------------------------------------------------------------------*

* Fix interview length variable and other time variables 
* Edit this section to include other date and time variables as needed 

* Converting interview length to minutes so it can be summarized
gen int_length = intlength / 60

* Converting Q46 and Q47 to minutes so it can be summarized
gen q46_min = q46 / 60
gen q47_min = q47 / 60

*------------------------------------------------------------------------------*

* Drop any unwanted/empty variables
* Generate any new needed variables

* Drop respondents under 18 
drop if q2 == 1 | q1 < 18

* Drop interviews that are short and could be low-quality 
* NK Note: Ipsos previously provided qc_short var (<10 min; previously dopped 165 interviews)
* When I run the command below instead it drops more than 165 

list country int_length if int_length < 10
drop if int_length < 10 & country == 5

* Q23/Q24 mid-point var 
gen q23_q24 = q23 
recode q23_q24 (997 = 0) (996 = 0) if q24 == 1
recode q23_q24 (997 = 2.5) (996 = 2.5) if q24 == 2
recode q23_q24 (997 = 7) (996 = 7) if q24 == 3
recode q23_q24 (997 = 10) (996 = 10) if q24 == 4
recode q23_q24 (997 = 996) if q24 == 996

*------------------------------------------------------------------------------*

*TL: PREFER TO DO THIS WITH THE VARIABLES BELOW SINCE THAT STEP HAS TO HAPPEN ANYWAY
*NK: Noted for future. This will require updating all implausible value and skip pattern code  

* Recode all Refused and Don't know responses

* In raw data, 997 = "don't know" 
recode q23 q25_a q25_b q27 q28 q28_new q30 q31 q32 q33 q34 q35 q36 q38 q63 ///
	   q66 q67 (997 = .d)

* In raw data, 996 = "refused" 
recode q1 q2 q3 q4 q5 q6 q7 q8 q9 q10 q11 q12 q13 q14_new q15_new q16 q17 /// 
	   q18 q19 q20 q21 q22 q23 q23_q24 q24 q25_a q25_b q26 q27 q28 q28_new q29 q30 /// 
	   q31 q32 q33 q34 q35 q36 q38 q39 q40 q41 q42 q43 q44 q45 q46 q47 ///
	   q46_refused q47_refused q48_a q48_b q48_c q48_d q48_e q48_f q48_g /// 
	   q48_h q48_i q48_j q49 q50_a q50_b q50_c q50_d q51 q52 q53 q54 q55 /// 
	   q56 q57 q58 q59 q60 q61 q62 q63 q66 q67 (996 = .r)	

*------------------------------------------------------------------------------*

* Recode implausible values to missing 

* All visit count variables and wait time variables:
* q23, q25_b, q27, q28, q28_new, q46_min, q47_min   
 
 foreach var in q23 q25_b q27 q28 q28_new q46_min q47_min {
	foreach i in 3 5 {
		extremes `var' country if country == `i', high 
		
	}				
	 }
	
* Most visit values seem plausible, most 50 and below 
* Ethiopia: 92 visits for q28 
recode q28 (92 = .)

* q46_min, above 1440 minutes (24 hours) seems implausible 
replace q46_min = . if q46_min > 1440 & q46_min < .
* One implausible value recoded in Kenya, two in Ethiopia 

* q47_min, above 120 minutes (2 hours) seems implausible 
replace q47_min = . if q47_min > 120 & q47_min < .
* 9 values recoded in Kenya, 38 recoded in Ethiopia
* NK Note: This seems like a high number in Ethiopia. Should we do above 180 minutes?
* 19 people said 180 minutes, 5 people said 240 minutes, 7 said 300 minutes 

* Check for other implausible values 

list q23_q24 q25_b country if q25_b > q23_q24 & q25_b < . 
* Note: okay in Kenya and Ethiopia data

list q23_q24 q27 country if q27 > q23_q24 & q27 < . 
* Note: okay in Kenya and Ethiopia data (2.5 is mid-point value)

list q26 q27 country if q27 == 0 | q27 == 1
* NK Note: I suggest recoding these to missing or refused, see command below
* recode q27 (0 = .) (1 = .) if q27 <= 1

list q23_q24 q39 q40 country if q39 == 3 & q23_q24 > 0 & q23_q24 < . /// 
							  | q40 == 3 & q23_q24 > 0 & q23_q24 < .
* NK Note: I suggest recoding Q39 and Q40 to refused for these respondents 
* recode q40 (2 = .r) if q39 == 3
* recode q39 q40 (3 = .r) if q23_q24 > 0 & q23_q24 < .


*------------------------------------------------------------------------------*

* Recode missing values to NA for intentionally skipped questions

*q1/q2 
recode q2 (. = .a) if q1 != .r
recode q1 (. = .r) if q2 > 1 & q2 <= 8 | q2 == .r 
* Note: Some missing values in q1 that should be refused 


* q7 
recode q7 (. = .a) if q6 == 2 | q6 == .r 

* q13 
recode q13 (. = .a) if q12 == 2 | q12 == .r 
* Note: Removed don't know here
* I think maybe in one country don't know was an option here. Will check

* q15
recode q15_new (. = .a) if q14_new == 3 | q14_new == 4 | q14_new == 5 | q14_new == .r 

*q19-22
recode q19 q20 q21 q22 (. = .a) if q18 == 2 | q18 == .r 
recode q20 (. = .a) if q19 == 4 | q19 == .r

* NA's for q24-27 
recode q24 (. = .a) if q23 != .d | q23 != .r
recode q25_a (. = .a) if q23 != 1
recode q25_b (. = .a) if q23 == 0 | q23 == 1 | q24 == 1 | q24 == .r 
recode q26 (. = .a) if q23 == 0 | q23 == 1 | q24 == 1 | q24 == .r 
recode q27 (. = .a) if q26 != 2
* Note: for other data add q28c 

* q31 & q32
recode q31 (. = .a) if q3 == 1 | q1 < 50 | q2 == 1 | q2 == 2 | q2 == 3 | q2 == 4 | q1 == .r | q2 == .r 
recode q32 (. = .a) if q3 == 1 | q1 == .r | q2 == .r

* q42
recode q42 (. = .a) if q41 == 2 | q41 == .r

* q43-49 na's
recode q43 q44 q45 q46 q46_min q46_refused q47 q47_min q47_refused q48_a q48_b q48_c q48_d q48_e q48_f /// 
	   q48_g q48_h q48_i q48_j q49 (. = .a) if q23 == 0 | q24 == 1 | q24 == .r
	   
recode q44 (. = .a) if q43 == 4 | q43 == .r

*q46/q47 refused
recode q46 q46_min (. = .r) if q46_refused == 1
recode q47 q47_min (. = .r) if q47_refused == 1

*q66/67
recode q67 (. = .a) if q66 == 2 | q66 == .d | q66 == .r 
recode q66 q67 (. = .a) if mode == 2

*------------------------------------------------------------------------------*

* Recode value labels:
* Recode values and value labels so that their values and direction make sense

* All Yes/No questions

recode q6 q11 q12 q13 q18 q25_a q26 q29 q41 ///
	   (1 = 1 Yes) (2 = 0 No) (.r = .r Refused) (.a = .a NA), ///
	   pre(rec) label(yes_no)

recode q30 q31 q32 q33 q34 q35 q36 q38 q66 ///
	   (1 = 1 Yes) (2 = 0 No) (.r = .r Refused) (.d = .d "Don't know") /// 
	   (.a = .a NA), ///
	   pre(rec) label(yes_no_dk)

lab val q46_refused q47_refused yes_no

* Note: for other data add q37_b

recode q39 q40 /// 
	   (1 = 1 Yes) (2 = 0 No) ///
	   (3 = .a "I did not get healthcare in past 12 months") ///
	   (.r = .r Refused), ///
	   pre(rec) label(yes_no_na)
	   
* All Excellent to Poor scales

recode q9 q10 q48_a q48_b q48_c q48_d q48_f q48_g q48_h q48_i q54 q55 q56 q59 q60 q61 ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (.r = .r Refused) (.a = .a NA), /// 
	   pre(rec) label(exc_poor)
	   
recode q22  ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) (5 = 0 Poor) /// 
	   (6 = .a "I did not receive healthcare form this provider in the past 12 months") /// 
	   (.r = .r Refused), /// 
	   pre(rec) label(exc_pr_hlthcare)
	   
recode q48_e ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (6 = .a "I have not had prior visits or tests") (.r = .r Refused), /// 
	   pre(rec) label(exc_pr_visits)
	 
recode q48_j ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (6 = .a "The clinic had no other staff") (.r = .r Refused), /// 
	   pre(rec) label(exc_poor_staff)
	   
recode q50_a q50_b q50_c q50_d ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (6 = .d "I am unable to judge") (.r = .r Refused) ///
	   (.a = .a NA), /// 
	   pre(rec) label(exc_poor_judge)

* All Very Confident to Not at all Confident scales 
	   
recode q16 q17 q51 q52 q53 ///
	   (1 = 3 "Very confident") (2 = 2 "Somewhat confident") /// 
	   (3 = 1 "Not too confident") (4 = 0 "Not at all confident") /// 
	   (.r = .r Refused) (.a = .a NA), /// 
	   pre(rec) label(vc_nc)
	   
* Miscellaneous questions with unique answer options

recode interviewer_gender ///
	(1 = 0 Male) (2 = 1 Female), ///
	pre(rec) label(int_gender)

* Note: Without relabeling (removing the appostrophe) next command will not run 
lab var q2 
recode q2 (2 = 0 "18 to 29") (3 = 1 "30-39") (4 = 2 "40-49") (5 = 3 "50-59") ///
		  (6 = 4 "60-69") (7 = 5 "70-79") (8 = 6 "80+") (.r = .r "Refused") ///
		  (.a = .a "NA"), pre(rec) label(age_cat)

recode q3 ///
	(1 = 0 Male) (2 = 1 Female) (3 = 2 "Another gender") (.r = .r Refused), ///
	pre(rec) label(gender)

recode q14_new ///
	(1 = 0 "0- no doses received") (2 = 1 "1 dose") (3 = 2 "2 doses") ///
	(4 = 3 "3 doses") (5 = 4 "More than 3 doses") (.r = .r Refused) (.a = .a NA), ///
	pre(rec) label(covid_vacc)
	
recode q15 /// 
	   (1 = 1 "Yes, I plan to receive all required doses") ///
	   (2 = 0 "No, don't plan to receive all required doses") ///
	   (.r = .r Refused) (.a = .a NA), ///
	   pre(rec) label(yes_no_doses)
	   
recode q24 ///
	(1 = 0 "0") (2 = 1 "1-4") (3 = 2 "5-9") (4 = 3 "10 or more") ///
	(.r = .r Refused) (.a = .a NA), ///
	pre(rec) label(number_visits)
	
recode q49 ///
	(1 = 0 "0") (2 = 1 "1") (3 = 2 "2") (4 = 3 "3") (5 = 4 "4") (6 = 5 "5") ///
	(7 = 6 "6") (8 = 7 "7") (9 = 8 "8") (10 = 9 "9") (11 = 10 "10") ///
	(.r = .r Refused) (.a = .a NA), ///
	pre(rec) label(prom_score)

recode q57 ///
	(3 = 0 "Getting worse") (2 = 1 "Staying the same") (1 = 2 "Getting better") ///
	(.r = .r "Refused") , pre(rec) label(system_outlook)

* Numeric questions needing NA and Refused value labels 
lab def na_rf .a "NA" .r "Refused"
lab val q1 q23 q25_b q27 q28 q28_new q46 q46_min q47 q47_min q67 na_rf

* NOTE:
* Some country-specific questions or questions with 8+ options (e.g., q20) have 
* value labels, but not labels for .a or .r. Will edit this in future. 

*------------------------------------------------------------------------------*
*TL: THIS IS FINE BUT I THINK IT WOULD HAVE BEEN FINE AND ALSO EASIER TO JUST RENAME THE VARIABLES WE HAD DIRECTLY.
*NK: Not sure what this means   

* Renaming variables 
* Rename variables to match question numbers in current survey 

***Drop all the ones that were recoded, then drop the recode, and rename then according to the documents
drop interviewer_gender q2 q3 q6 q11 q12 q13 q18 q25_a q26 q29 q41 q30 q31 /// 
	 q32 q33 q34 q35 q36 q38 q66 q39 q40 q9 q10 q22 q48_a q48_b q48_c q48_d ///
	 q48_f q48_g q48_h q48_i q54 q55 q56 q59 q60 q61 q48_e q48_j q50_a q50_b ///
	 q50_c q50_d q16 q17 q51 q52 q53 q3 q14_new q15 q24 q49 q57

ren rec* *
 
ren q14_new q14
ren q15_new q15
ren q19_4 q19_other
ren q21_9 q21_other
ren q28 q28_a
ren q28_new q28_b
ren q42_10 q42_other
ren q43_4 q43_other
ren q66 q64
ren q67 q65
ren time_new time
drop respondent_id
ren ecs_id respondent_id
ren interviewerid_recoded interviewer_id
* Check ID variable and interviewer ID variable in other data 
* Q37_B not currently in these data 

*Reorder variables
order q*, sequential
order q*, after(interviewer_id)


* Drop other unecessary variables 
drop intlength q46 q47 mode2
* Note: mode2 seems to be missing for Kenya data, but there is mode var 


*------------------------------------------------------------------------------*

* Labeling variables 

lab var country "Country"
lab var respondent_id "Respondent ID"
lab var interviewer_id "Interviewer ID"
lab var int_length "Interview length (in minutes)"
lab var interviewer_gender "Interviewer gender"
lab var q1 "Q1. Respondent еxact age"
lab var q2 "Q2. Respondent's age group"
lab var q3 "Q3. Respondent gender"
lab var q4 "Q4. Type of area where respondent lives"
lab var q5 "Q5. County, state, region where respondent lives"
lab var q6 "Q6. Do you have health insurance?"
lab var q7 "Q7. What type of health insurance do you have?"
lab var q7_other "Q7_other. Other type of health insurance"
lab var q8 "Q8. Highest level of education completed by the respondent"
lab var q9 "Q9. In general, would you say your health is:"
lab var q10 "Q10. In general, would you say your mental health is?"
lab var q11 "Q11. Do you have any longstanding illness or health problem?"
lab var q12 "Q12. Have you ever had COVID-19 or coronavirus?"
lab var q13 "Q13. Was it confirmed by a test?"
lab var q14 "Q14. How many doses of a COVID-19 vaccine have you received?"
lab var q15 "Q15. Do you plan to receive all recommended doses if they are available to you?"
lab var q16 "Q16. How confident are you that you are responsible for managing your health?"
lab var q17 "Q17. Can tell a healthcare provider your concerns even when not asked?"
lab var q18 "Q18. Is there one healthcare facility or provider's group you usually go to?"
lab var q19 "Q19. Is this a public, private, or NGO/faith-based healthcare facility?"
lab var q19_other "Q19. Other"
lab var q20 "Q20. What type of healthcare facility is this?"
lab var q20_other "Q20. Other"
lab var q21 "Q21. Why did you choose this healthcare facility?"
lab var q21_other "Q21. Other"
lab var q22 "Q22. Overall respondent's rating of the quality received in this facility"
lab var q23 "Q23. How many healthcare visits in total have you made in the past 12 months?"
lab var q24 "Q24. Total number of healthcare visits in the past 12 months (range)"
lab var q23_q24 "Q23/Q24. Total mumber of visits made in past 12 months (q23, q24 mid-point)"
lab var q25_a "Q25_A. Was this visit for COVID-19?"
lab var q25_b "Q25_B. How many of these visits were for COVID-19? "
lab var q26 "Q26. Were all of the visits you made to the same healthcare facility?"
lab var q27 "Q27. How many different healthcare facilities did you go to?"
lab var q28_a "Q28_A. How many visits did you have with a healthcare provider at your home?"
lab var q28_b "Q28_B. How many virtual or telemedicine visits did you have?"
lab var q29 "Q29. Did you stay overnight at a healthcare facility as a patient?"
lab var q30 "Q30. Blood pressure tested in the past 12 months"
lab var q31 "Q31. Received a mammogram in the past 12 months"
lab var q32 "Q32. Received cervical cancer screening, like a pap test or visual inspection"
lab var q33 "Q33. Had your eyes or vision checked in the past 12 months"
lab var q34 "Q34. Had your teeth checked in the past 12 months"
lab var q35 "Q35. Had a blood sugar test in the past 12 months"
lab var q36 "Q36. Had a blood cholesterol test in the past 12 months"
*lab var q37 "Q37_B. Had a test for HIV in the past 12 months"
lab var q38 "Q38. Received care for depression, anxiety, or another mental health condition"
lab var q39 "Q39. A medical mistake was made in your treatment or care in the past 12 months"
lab var q40 "Q40. You were treated unfairly or discriminated against in the past 12 months"
lab var q41 "Q41. Have you needed medical attention but you did not get it in past 12 months?"
lab var q42 "Q42. The last time this happened, what was the main reason?"
lab var q42_other "Q42. Other"
lab var q43 "Q43. Last healthcare visit in a public, private, or NGO/faith-based facility?"
lab var q43_other "Q43. Other"
lab var q44 "Q44. What type of healthcare facility is this?"
lab var q44_other "Q44. Other"
lab var q45 "Q45. What was the main reason you went?"
lab var q45_other "Q45. Other"
lab var q46_refused "Q46. Refused"
lab var q46_min "Q46. In minutes: Approximately how long did you wait before seeing the provider?"
lab var q47_refused "Q47. Refused"
lab var q47_min "Q47. In minutes: Approximately how much time did the provider spend with you?"
lab var q48_a "Q48_A. How would you rate the overall quality of care you received?"
lab var q48_b "Q48_B. How would you rate the knowledge and skills of your provider?"
lab var q48_c "Q48_C. How would you rate the equipment and supplies that the provider had?"
lab var q48_d "Q48_D. How would you rate the level of respect your provider showed you?"
lab var q48_e "Q48_E. How would you rate your provider knowledge about your prior visits?"
lab var q48_f "Q48_F. How would you rate whether your provider explained things clearly?"
lab var q48_g "Q48_G. How would you rate whether you were involved in your care decisions?"
lab var q48_h "Q48_H. How would you rate the amount of time your provider spent with you?"
lab var q48_i "Q48_I. How would you rate the amount of time you waited before being seen?"
lab var q48_j "Q48_J. How would you rate the courtesy and helpfulness at the facility?"
lab var q49 "Q49. How likely would recommend this facility to a friend or family member?"
lab var q50_a "Q50_A. How would you rate the quality of care provided for care for pregnancy?"
lab var q50_b "Q50_B. How would you rate the quality of care provided for children?"
lab var q50_c "Q50_C. How would you rate the quality of care provided for chronic conditions?"
lab var q50_d "Q50_D. How would you rate the quality of care provided for the mental health?"
lab var q51 "Q51. How confident are you that you'd get good healthcare if you were very sick?"
lab var q52 "Q52. How confident are you that you'd be able to afford the care you requiered?"
lab var q53 "Q53. How confident are you that the government considers the public's opinion?"
lab var q54 "Q54. How would you rate the quality of public healthcare system in your country?"
lab var q55 "Q55. How would you rate the quality of private for-profit healthcare?"
lab var q56 "Q56. How would you rate the quality of the NGO or faith-based healthcare?"
lab var q57 "Q57. Is your country's health system is getting better, same or worse?"
lab var q58 "Q58. Which of these statements do you agree with the most?"
lab var q59 "Q59. How would you rate the government's management of the COVID-19 pandemic?"
lab var q60 "Q60. How would you rate the quality of care provided? (Vignette, option 1)"
lab var q61 "Q61. How would you rate the quality of care provided? (Vignette, option 2)"
lab var q62 "Q62. Respondent's mother tongue or native language"
lab var q62_other "Q62. Other"
lab var q63 "Q63. Total monthly household income"
lab var q64 "Q64. Do you have another mobile phone number besides this one?"
lab var q65 "Q65. How many other mobile phone numbers do you have?"

*------------------------------------------------------------------------------*

* Save data

save "$data_mc/02 recoded data/pvs_et_ke.dta", replace


*------------------------------------------------------------------------------*

************************************* LAC **************************************

clear all

* Import raw data 

import spss using "/$data_mc/01 raw data/LATAM(Co_Pe_Ur)_v1_completes_backcoded_weighted 122222.sav", clear

*------------------------------------------------------------------------------*

*Change all variable names to lower case

rename *, lower

*------------------------------------------------------------------------------*

* Fix interview length variable and other time variables 
* Edit this section to include other date and time variables as needed 

* Converting interview length to minutes so it can be summarized

gen int_length = (hh(intlength)*3600 + mm(intlength)*60 + ss(intlength)) / 60

* Converting Q46 and Q47 to minutes so it can be summarized

gen q46_min = (hh(q46)*3600 + mm(q46)*60 + ss(q46)) / 60

gen q47_min = (hh(q47)*3600 + mm(q47)*60 + ss(q47)) / 60

*------------------------------------------------------------------------------*

* Drop any unwanted/empty variables
* Generate any new needed variables

drop if q2 == 1 | q1 < 18

gen mode = 1	

* Q23/Q24 mid-point var 
gen q23_q24 = q23 
recode q23_q24 (997 = 0) (996 = 0) if q24 == 1
recode q23_q24 (997 = 2.5) (996 = 2.5) if q24 == 2
recode q23_q24 (997 = 7) (996 = 7) if q24 == 3
recode q23_q24 (997 = 10) (996 = 10) if q24 == 4
recode q23_q24 (997 = 996) if q24 == 996
	 
*------------------------------------------------------------------------------*

* Recode all Refused and Don't know

* Don't know is 997 in these raw data 
recode q13b q13e q23 q25_a q25_b q27 q28 q28_new q30 q31 q32 q33 q34 q35 q36 ///
	   q38 q63 q66 q67 (997 = .d)

* Refused is 996 in these raw data 
recode q1 q2 q3 q3a q4 q5 q6 q7 q8 q9 q10 q11 q12 q13 q13b q13e q14_new /// 
	   q15_new q16 q17 q18 q19_pe q19_uy q19_co q20 q21 q22 q23 q24 q23_q24 q25_a /// 
	   q25_b q26 q27 q28 q28_new q29 q30 q31 q32 q33 q34 q35 q36 q38 q39 q40 /// 
	   q41 q42 q43_pe q43_uy q43_co q44 q45 q46 q47 q48_a q48_b q48_c q48_d /// 
	   q48_e q48_f q48_g q48_h q48_i q48_j q49 q50_a q50_b q50_c q50_d q51 /// 
	   q52 q53 q54 q55 q56_uy q56_pe q57 q58 q59 q60 q61 q62 q63 q66 q67 /// 
	   (996 = .r)	
	
*------------------------------------------------------------------------------*

* Recode implausible values to missing 

* All visit count variables and wait time variables:
* q23, q25_b, q27, q28, q28_new, q46_min, q47_min   
 
 foreach var in q23 q25_b q27 q28 q28_new q46_min q47_min {
	foreach i in 2 7 10 {
		extremes `var' country if country == `i', high 
		
	}				
	 }

* Uruguay: q23 values seem implausible 
recode q23 (200 = .) (156 = .)	 
* Colombia q28_new values seem implausible 
recode q28_new (80 = .)
* q46_min seems okay for all (no more than 12 hours)
* q47_min 31 values over 120 minutes, 25 values over 180 minutes 
* NK Note: Thoughts on these values? 
			
* Check for other implausible values 

list q23_q24 q25_b country if q25_b > q23_q24 & q25_b < . 
* Note: okay in LAC data

list q23_q24 q27 country if q27 > q23_q24 & q27 < . 
* Note: okay in LAC data (2.5 is mid-point value)

list q26 q27 country if q27 == 0 | q27 == 1
* Note: okay in LAC data 

list q23_q24 q39 q40 country if q39 == 3 & q23_q24 > 0 & q23_q24 < . /// 
							  | q40 == 3 & q23_q24 > 0 & q23_q24 < .
* NK Note: I suggest recoding Q39 and Q40 to refused for these respondents 
* recode q40 (2 = .r) if q39 == 3
* recode q39 q40 (3 = .r) if q23_q24 > 0 & q23_q24 < .


*------------------------------------------------------------------------------*

* Recode missing values to NA for questions respondents would not have been asked due to skip patterns

*q1/q2 
recode q2 (. = .a) if q1 != .r
recode q1 (. = .r) if q2 > 1 & q2 <= 8 | q2 == .r 

* q6 was not asked, all respondents were asked q7
recode q6 (. = .a)
* NOTE: q7, none is 14 

* q13 
recode q13 (. = .a) if q12 == 2 | q12 == .r 
recode q13b (. = .a) if q12 == 2 | q12 == .r 
recode q13e (. = .a) if q13b == .a | q13b == 1 | q13b == .d | q13b == .r
* NOTE: Changed these to .a for all other countries after merge

* q15
recode q15_new (. = .a) if q14_new == 3 | q14_new == 4 | q14_new == 5 | q14_new == .r


* q19-22
recode q19_pe q19_uy q19_co q20 q21 q22 (. = .a) if q18 == 2 | q18 == .r 
recode q19_pe (. = .a) if country != 7
recode q19_uy (. = .a) if country != 10
recode q19_co (. = .a) if country != 2
* recode Q20 (. = .a) if Q19_PE == 4 | Q19_UY == 4 | Q19_CO  == 4

* NOTE: Other, specify functioning differently here than other data 

* NOTE: UY appears to have NGO when it should be other
recode q19_uy (3 = 995)


recode q20 (. = .a) if q19_pe == .r | q19_uy == .r | q19_co  == .r

* NA's for q23-27 
recode q24 (. = .a) if q23 != .d | q23 != .r
recode q25_a (. = .a) if q23 != 1
recode q25_b (. = .a) if q23 == 0 | q23 == 1 | q24 == 1 | q24 == .r 
recode q26 (. = .a) if q23 == 0 | q23 == 1 | q24 == 1 | q24 == .r 
recode q27 (. = .a) if q26 != 2

* q31 & q32
recode q31 (. = .a) if q3a == 1 | q1 < 50 | q2 == 1 | q2 == 2 | q2 == 3 | q2 == 4 | q1 == .r | q2 == .r 
recode q32 (. = .a) if q3a == 1 | q1 == .r | q2 == .r

* NOTE: q3a was assigned sex at birth, used for skip pattern in LAC

* q42
recode q42 (. = .a) if q41 == 2 | q41 == .r


* q43-49 NA's
recode q43_co q43_pe q43_uy q44 q45 q46 q46_min q46_996 q47 q47_min q47_996  q48_a q48_b q48_c q48_d q48_e q48_f /// 
	   q48_g q48_h q48_i q48_j q49 (. = .a) if q23 == 0 | q24 == 1 | q24 == .r
	   
recode q43_pe (. = .a) if country != 7
recode q43_uy (. = .a) if country != 10
recode q43_co (. = .a) if country != 2
recode q44 (. = .a) if q43_pe == .r | q43_uy == .r | q43_co  == .r
* recode q44 (. = .a) if q43 == 4 


*q46/q47 refused
recode q46_min (. = .r) if q46_996 == 1 
recode q47_min (. = .r) if q47_996 == 1
recode q46_996 (. = 0) if q46 != .
recode q47_996 (. = 0) if q47 != .
* Note: This refusal var has a lot of missing
*		Still some missing values in Q46 and Q47 that are not noted in the refusal var

* q56_pe, q56_uy
recode q56_pe (. = .a) if country != 7
recode q56_uy (. = .a) if country != 10

*q62
recode q62 (. = .a) if country == 10

* NOTE: q62 was not asked in UY

*q66/67
recode q67 (. = .a) if q66 == 2 | q66 == .d | q66 == .r

*------------------------------------------------------------------------------*

* Recode value labels 
* Recode values and value labels so that their values and direction make sense

* Relabeling - some labels that prevent commands from running
* Generally due to the appostrophes in the label
* Add any other variables if needed

lab var q2
lab var q13e 
lab var q48_f 
lab var q53 

* All Yes/No questions

recode q6 q11 q12 q13 q13b q18 q25_a q26 q29 q41 ///
	   (1 = 1 Yes) (2 = 0 No) (.r = .r Refused) (.a = .a NA), ///
	   pre(rec) label(yes_no)

recode q30 q31 q32 q33 q34 q35 q36 q38 q66 ///
	   (1 = 1 Yes) (2 = 0 No) (.r = .r Refused) (.d = .d "Don't know") /// 
	   (.a = .a NA), ///
	   pre(rec) label(yes_no_dk) 

recode q39 q40 /// 
	   (1 = 1 Yes) (2 = 0 No) ///
	   (3 = .a "I did not get healthcare in past 12 months") ///
	   (.r = .r Refused), ///
	   pre(rec) label(yes_no_na)
	   
* All Excellent to Poor scales

recode q9 q10 q48_a q48_b q48_c q48_d q48_f q48_g q48_h q48_i q54 q55 q56_pe q56_uy q59 q60 q61 ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (.r = .r Refused) (.a = .a NA), /// 
	   pre(rec) label(exc_poor)
	   
recode q22  ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) (5 = 0 Poor) /// 
	   (6 = .a "I did not receive healthcare form this provider in the past 12 months") /// 
	   (.r = .r Refused), /// 
	   pre(rec) label(exc_pr_hlthcare)
	   
recode q48_e ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (6 = .a "I have not had prior visits or tests") (.r = .r Refused), /// 
	   pre(rec) label(exc_pr_visits)
	 
recode q48_j ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (6 = .a "The clinic had no other staff") (.r = .r Refused), /// 
	   pre(rec) label(exc_poor_staff)
	   
recode q50_a q50_b q50_c q50_d ///
	   (1 = 4 Excellent) (2 = 3 "Very Good") (3 = 2 Good) (4 = 1 Fair) /// 
	   (5 = 0 Poor) (6 = .d "I am unable to judge") (.r = .r Refused) ///
	   (.a = .a NA), /// 
	   pre(rec) label(exc_poor_judge)

* All Very Confident to Not at all Confident scales 
	   
recode q16 q17 q51 q52 q53  ///
	   (1 = 3 "Very confident") (2 = 2 "Somewhat confident") /// 
	   (3 = 1 "Not too confident") (4 = 0 "Not at all confident") /// 
	   (.r = .r Refused) (.a = .a NA), /// 
	   pre(rec) label(vc_nc)
	   
* Miscellaneous questions with unique answer options

recode interviewer_gender ///
	(1 = 0 Male) (2 = 1 Female), ///
	pre(rec) label(int_gender)

recode q2 (2 = 0 "18 to 29") (3 = 1 "30-39") (4 = 2 "40-49") (5 = 3 "50-59") ///
		  (6 = 4 "60-69") (7 = 5 "70-79") (8 = 6 "80+") (.r = .r "Refused") ///
		  (.a = .a "NA"), pre(rec) label(age_cat)

recode q3 ///
	(1 = 0 Male) (2 = 1 Female) (3 = 2 "Another gender") (.r = .r Refused), ///
	pre(rec) label(gender)

recode q3a ///
	(1 = 0 Man) (2 = 1 Woman) (.r = .r Refused) (.a = .a "NA"), ///
	pre(rec) label(gender2)

recode q14_new ///
	(1 = 0 "0- no doses received") (2 = 1 "1 dose") (3 = 2 "2 doses") ///
	(4 = 3 "3 doses") (5 = 4 "More than 3 doses") (.r = .r Refused) (.a = .a NA), ///
	pre(rec) label(covid_vacc)
	
recode q15 /// 
	   (1 = 1 "Yes, I plan to receive all required doses") ///
	   (2 = 0 "No, don't plan to receive all required doses") ///
	   (.r = .r Refused) (.a = .a NA), ///
	   pre(rec) label(yes_no_doses)
	   
recode q24 ///
	(1 = 0 "0") (2 = 1 "1-4") (3 = 2 "5-9") (4 = 3 "10 or more") ///
	(.r = .r Refused) (.a = .a NA), ///
	pre(rec) label(number_visits)

recode q45 ///
	(13 = 1 "Care for an urgent or acute health problem (accident or injury, fever, diarrhea, or a new pain or symptom)" ) ///
	(14 = 2 "Follow-up care for a longstanding illness or chronic disease (hypertension or diabetes; mental health conditions") ///
	(15 = 3 "Preventive care or a visit to check on your health (for example, antenatal care, vaccination, or eye checks)") ///
	(.a = .a "NA") (995 = 995 "Other, specify") (.r = .r "Refused"), ///
	pre(rec) label(main_reason)
	
	
recode q49 ///
	(1 = 0 "0") (2 = 1 "1") (3 = 2 "2") (4 = 3 "3") (5 = 4 "4") (6 = 5 "5") ///
	(7 = 6 "6") (8 = 7 "7") (9 = 8 "8") (10 = 9 "9") (11 = 10 "10") ///
	(.r = .r Refused) (.a = .a NA), ///
	pre(rec) label(prom_score)

recode q57 ///
	(3 = 0 "Getting worse") (2 = 1 "Staying the same") (1 = 2 "Getting better") ///
	(.r = .r "Refused") , pre(rec) label(system_outlook)

* Numeric questions needing NA and Refused value labels 
lab def na_rf .a "NA" .r "Refused"
lab val q1 q23 q25_b q27 q28 q28_new q46 q46_min q47 q47_min q67 na_rf

* Kenya/Ethiopia data uses interviewer_id values 1 - 22 
gen interviewer_id = interviewerid_recoded + 22
* NOTE: 16 seems like a low number of interviewers across all three countries


*------------------------------------------------------------------------------*

* Renaming variables 
* Rename variables to match question numbers in current survey 

* Drop all the ones that were recoded, then drop the recode, and rename then according to the documents
drop interviewer_gender q2 q3 q3a q6 q11 q12 q13 q13b q18 q25_a q26 q29 q41 /// 
	 q30 q31 q32 q33 q34 q35 q36 q38 q66 q39 q40 q9 q10 q22 q45 q48_a q48_b q48_c ///
	 q48_d q48_f q48_g q48_h q48_i q54 q55 q56_pe q56_uy q59 q60 q61 q48_e /// 
	 q48_j q50_a q50_b q50_c q50_d q16 q17 q51 q52 q53 q3 q14_new q15 q24 q49 q57 ///
	 

ren rec* *
 
ren q7_995 q7_other
ren q14_new q14
ren q15_new q15
ren q19_4 q19_other
ren q20_other q20_other
ren q21_9 q21_other
ren q28 q28_a
ren q28_new q28_b
ren q42_10 q42_other
ren q43_4 q43_other
ren q44_other q44_other
ren q45_11 q45_other
ren q66 q64
ren q67 q65
ren time_new time
ren (q46_996 q47_996) (q46_refused q47_refused)

* Reorder variables
order q*, sequential
order q*, after(interviewer_id)

* Drop other unecessary variables 
drop intlength q46 q47 interviewerid_recoded

*------------------------------------------------------------------------------*

* Labeling variables 

lab var country "Country"
lab var respondent_id "Respondent ID"
lab var interviewer_id "Interviewer ID"
lab var int_length "Interview length (in minutes)"
lab var interviewer_gender "Interviewer gender"
lab var interviewer_gender "Interviewer gender"
lab var q1 "Q1. Respondent еxact age"
lab var q2 "Q2. Respondent's age group"
lab var q3 "Q3. Respondent gender"
lab var q3a "Q3A. Are you a man or a woman?"
lab var q4 "Q4. Type of area where respondent lives"
lab var q5 "Q5. County, state, region where respondent lives"
lab var q6 "Q6. Do you have health insurance?"
lab var q7 "Q7. What type of health insurance do you have?"
lab var q7_other "Q7_other. Other type of health insurance"
lab var q8 "Q8. Highest level of education completed by the respondent"
lab var q9 "Q9. In general, would you say your health is:"
lab var q10 "Q10. In general, would you say your mental health is?"
lab var q11 "Q11. Do you have any longstanding illness or health problem?"
lab var q12 "Q12. Have you ever had COVID-19 or coronavirus?"
lab var q13 "Q13. Was it confirmed by a test?"
lab var q13b "Q13B. Did you seek health care for COVID-19? (LAC Countries)"
lab var q13e "Q13E. Why didnt you receive health care for COVID-19? (LAC Countries)"
lab var q13e_10 "Q13E. Other"
lab var q14 "Q14. How many doses of a COVID-19 vaccine have you received?"
lab var q15 "Q15. Do you plan to receive all recommended doses if they are available to you?"
lab var q16 "Q16. How confident are you that you are responsible for managing your health?"
lab var q17 "Q17. Can tell a healthcare provider your concerns even when not asked?"
lab var q18 "Q18. Is there one healthcare facility or provider's group you usually go to?"
lab var q19_pe "Q19. Peru: Is this a public or private healthcare facility?"
lab var q19_uy "Q19. Uruguay: Is this a public, private, or mutual healthcare facility?"
lab var q19_co "Q19. Colombia: Is this a public or private healthcare facility?"
lab var q19_other "Q19. Other"
lab var q20 "Q20. What type of healthcare facility is this?"
lab var q20_other "Q20. Other"
lab var q21 "Q21. Why did you choose this healthcare facility?"
lab var q21_other "Q21. Other"
lab var q22 "Q22. Overall respondent's rating of the quality received in this facility"
lab var q23 "Q23. How many healthcare visits in total have you made in the past 12 months?"
lab var q24 "Q24. Total number of healthcare visits in the past 12 months (range)"
lab var q23_q24 "Q23/Q24. Total mumber of visits made in past 12 months (q23, q24 mid-point)"
lab var q25_a "Q25_A. Was this visit for COVID-19?"
lab var q25_b "Q25_B. How many of these visits were for COVID-19? "
lab var q26 "Q26. Were all of the visits you made to the same healthcare facility?"
lab var q27 "Q27. How many different healthcare facilities did you go to?"
lab var q28_a "Q28_A. How many visits did you have with a healthcare provider at your home?"
lab var q28_b "Q28_B. How many virtual or telemedicine visits did you have?"
lab var q29 "Q29. Did you stay overnight at a healthcare facility as a patient?"
lab var q30 "Q30. Blood pressure tested in the past 12 months"
lab var q31 "Q31. Received a mammogram in the past 12 months"
lab var q32 "Q32. Received cervical cancer screening, like a pap test or visual inspection"
lab var q33 "Q33. Had your eyes or vision checked in the past 12 months"
lab var q34 "Q34. Had your teeth checked in the past 12 months"
lab var q35 "Q35. Had a blood sugar test in the past 12 months"
lab var q36 "Q36. Had a blood cholesterol test in the past 12 months"
lab var q38 "Q38. Received care for depression, anxiety, or another mental health condition"
lab var q39 "Q39. A medical mistake was made in your treatment or care in the past 12 months"
lab var q40 "Q40. You were treated unfairly or discriminated against in the past 12 months"
lab var q41 "Q41. Have you needed medical attention but you did not get it in past 12 months?"
lab var q42 "Q42. The last time this happened, what was the main reason?"
lab var q42_other "Q42. Other"
lab var q43_pe "Q43. Peru: Is this a public or private healthcare facility?"
lab var q43_uy "Q43. Uruguay: Is this a public, private, or mutual healthcare facility?"
lab var q43_co "Q43. Colombia: Is this a public or private healthcare facility?"
lab var q43_other "Q43. Other"
lab var q44 "Q44. What type of healthcare facility is this?"
lab var q44_other "Q44. Other"
lab var q45 "Q45. What was the main reason you went?"
lab var q45_other "Q45. Other"
lab var q46_min "Q46. In minutes: Approximately how long did you wait before seeing the provider?"
lab var q47_min "Q47. In minutes: Approximately how much time did the provider spend with you?"
lab var q46_refused "Q46. Refused"
lab var q47_refused "Q47. Refused"
lab var q48_a "Q48_A. How would you rate the overall quality of care you received?"
lab var q48_b "Q48_B. How would you rate the knowledge and skills of your provider?"
lab var q48_c "Q48_C. How would you rate the equipment and supplies that the provider had?"
lab var q48_d "Q48_D. How would you rate the level of respect your provider showed you?"
lab var q48_e "Q48_E. How would you rate your provider knowledge about your prior visits?"
lab var q48_f "Q48_F. How would you rate whether your provider explained things clearly?"
lab var q48_g "Q48_G. How would you rate whether you were involved in your care decisions?"
lab var q48_h "Q48_H. How would you rate the amount of time your provider spent with you?"
lab var q48_i "Q48_I. How would you rate the amount of time you waited before being seen?"
lab var q48_j "Q48_J. How would you rate the courtesy and helpfulness at the facility?"
lab var q49 "Q49. How likely would recommend this facility to a friend or family member?"
lab var q50_a "Q50_A. How would you rate the quality of care provided for care for pregnancy?"
lab var q50_b "Q50_B. How would you rate the quality of care provided for children?"
lab var q50_c "Q50_C. How would you rate the quality of care provided for chronic conditions?"
lab var q50_d "Q50_D. How would you rate the quality of care provided for the mental health?"
lab var q51 "Q51. How confident are you that you'd get good healthcare if you were very sick?"
lab var q52 "Q52. How confident are you that you'd be able to afford the care you requiered?"
lab var q53 "Q53. How confident are you that the government considers the public's opinion?"
lab var q54 "Q54. How would you rate the quality of public healthcare system in your country?"
lab var q55 "Q55. How would you rate the quality of private for-profit healthcare?"
lab var q56_pe "Q56. Peru: How would you rate the quality of the social security system?"
lab var q56_uy "Q56. Uruguay: How would you rate the quality of the mutual healthcare system?"
lab var q57 "Q57. Is your country's health system is getting better, same or worse?"
lab var q58 "Q58. Which of these statements do you agree with the most?"
lab var q59 "Q59. How would you rate the government's management of the COVID-19 pandemic?"
lab var q60 "Q60. How would you rate the quality of care provided? (Vignette, option 1)"
lab var q61 "Q61. How would you rate the quality of care provided? (Vignette, option 2)"
lab var q62 "Q62. Respondent's mother tongue or native language"
*lab var q62_other "q62. Other"
lab var q63 "Q63. Total monthly household income"
lab var q64 "Q64. Do you have another mobile phone number besides this one?"
lab var q65 "Q65. How many other mobile phone numbers do you have?"

* NOTE: Variables not in these data: PSU_ID Interviewer_Language Language, and others 

save "$data_mc/02 recoded data/pvs_lac.dta", replace

*------------------------------------------------------------------------------*

* NK Note: Left off here, still updating

********************************* Append data *********************************

u "$data_mc/02 recoded data/pvs_lac.dta", clear
append using "$data_mc/02 recoded data/pvs_et_ke.dta"

*append using "$data_mc/02 recoded data/pvs_la.dta"


* NOTE: Rodrigo to check append 
* NOTE: Fix Kenya date on append 

* Kenya/Ethiopia variables 
ren q19 q19_ke_et 
lab var q19_ke_et "Q19. Kenya/Ethiopia: Is this a public, private, or NGO/faith-based facility?"
ren q43 q43_ke_et 
lab var q43_ke_et "Q43. Kenya/Ethiopia: Is this a public, private, or NGO/faith-based facility?"
ren q56 q56_ke_et 
lab var q56_ke_et "Q56. Kenya/Ethiopia: How would you rate quality of NGO/faith-based healthcare?"

* Mode
lab val mode mode
lab var mode "Mode of interview"

* Country-specific skip patterns
recode q19_ke_et q43_ke_et q56_ke_et (. = .a) if country != 5 | country != 3  
recode q3a q13b q13e (. = .a) if country == 5 | country == 3 | country == 11 
recode q19_uy q43_uy q56_uy (. = .a) if country != 10
recode q19_pe q43_pe q56_pe (. = .a) if country != 7
recode q19_co q43_co (. = .a) if country != 2
recode q18a_la q1920a_la q18b_la q1920b_la q43_la q44_la ///		
		(. = .a) if country != 11
		
* Country-specific value labels 
recode language (. = 0) if country == 10 | country == 7 | country == 2
lab def Language 0 "Spanish" 6 "Lao" 7 "Khmou" 8 "Hmong", modify 

*Q4
label define labels6 18 "City" 19 "Rural area"  20 "Suburb", modify

*Q5
label define labels7 201 "Attapeu" 202 "Bokeo" 203 "Bolikhamxai" 204 "Champasak" 205 "Houaphan" 206 "Khammouan" 207 "Louangnamtha" 208 "Louangphabang" 209 "Oudoumxai" 210 "Phongsali" 211 "Salavan" 212 "Savannakhet" 213 "Vientiane_capital" 214 "Vientiane_province" 215 "Xainyabouli" 216 "Xaisoumboun" 217 "Xekong" 218 "Xiangkhouang", modify

*Q7
label define labels9 29 "Public" 30 "Private", modify

*Q8
label define labels10 45 "None" 46 "Primary (primary 1-5 years)" /// 
					  47 "Lower secondary (1-4 years)" /// 
					  48 "Upper secondary (5-7 years)" ///
					  49 "Post-secondary and non-tertiary (13-15 years)" ///
					  50 "Tertiary (Associates or higher)", modify

*Q62
label define labels51 101 "Lao" 102 "Hmong" 103 "Kmou" 104 "Other", modify

*Q63
label define labels52 101 "Range A (Less than 1,000,000) Kip" 102 "Range B (1,000,000 to 1,500,000) Kip" 103 "Range C (1,500,001 to 2,000,000) Kip" 104 "Range D (2,000,001 to 2,500,000) Kip" 105 "Range E (2,500,001 to 3,000,000) Kip" 106 "Range F (3,000,001 to 3,500,000) Kip" 107 "Range G (More than 3,500,000) Kip", replace

order q*, sequential
order respondent_serial respondent_id unique_id psu_id interviewerid_recoded /// 
interviewer_language interviewer_gender mode country language date time /// 
intlength int_length q1_codes

* NOTE: What variables to keep/drop? 

save "$data_mc/02 recoded data/pvs_appended.dta", replace

* NOTE: 
* Ethiopia data missing value labels on Q63 and Q62, it's fine for now 

*------------------------------------------------------------------------------*

* NOTE: Optional data quality checks 

/*
***************************** Data quality checks *****************************

u "$data_mc/02 recoded data/pvs_ke_et_lac_01.dta", replace

* Macros for these commands
gl inputfile	"$data_mc/03 test output/Input/dq_inputs.xlsm"	
gl dq_output	"$output/dq_output.xlsx"				
gl id 			"respondent_id"	
gl key			"respondent_serial"	
gl enum			"interviewerid_recoded"
gl date			"date"	
gl time			"time"
gl duration		"int_length"
gl keepvars 	"country"
global all_dk 	"q13b q13e q23 q25_a q25_b q27 q28_a q28_b q30 q31 q32 q33 q34 q35 q36 q38 q50_a q50_b q50_c q50_d q63 q64 q65"
global all_num 	"q1 q2 q3 q4 q5 q6 q7 q8 q9 q10 q11 q12 q13 q14 q15 q16 q17 q18 q19_ke_et q19_co q19_pe q19_uy q20 q21 q22 q23 q24 q25_a q25_b q26 q27 q28_a q28_b q29 q30 q31 q32 q33 q34 q35 q36 q38 q39 q40 q41 q42 q43_ke_et q43_co q43_pe q43_uy q44 q45 q46 q47 q46_min q46_refused q47_min q47_refused q48_a q48_b q48_c q48_d q48_e q48_f q48_g q48_h q48_i q48_j q49 q50_a q50_b q50_c q50_d q51 q52 q53 q54 q55 q56_ke_et q56_pe q56_uy q57 q58 q59 q60 q61 q62 q63 q64 q65"


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

*format %td date
 
ipacheckspecify using "${inputfile}",			///
	id(${id})									///
	enumerator(${enum})							///	
	date(${date})	 							///
	sheet("other specify")						///
    outfile("${dq_output}") 					///
	outsheet1("other specify")					///
	outsheet2("other specify (choices)")		///
	sheetreplace
	
*	loc childvars "`r(childvarlist)'"

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
