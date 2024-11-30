/*
Objectives: Flu shot dashboard for 2022

1) Total % of patients getting flu shots stratified by 
	a. Age
	b. Race
	c. County
	d. Overall
2)Running total of flu shots over the course of 2022
3)Total number of flu shots given in 2022
4)A list of patients that show whether or not they received the flu shots

Requirements:
Patients must have been 'Active at our hospital'

*/

select * from public.patients
select * from public.immunizations
select * from public.encounters

with active_patients as
( select distinct patient
from encounters as e
join patients as pat
on e.patient=pat.id
where start between '2020-01-01 00:00' and '2022-12-31 23:59'
and pat.deathdate is null
and EXTRACT(EPOCH FROM age('2022-12-31', pat.birthdate)) / 2592000 >= 6
),


flu_shot_2022 as
(select patient, min(Date) as earliest_shot
from immunizations 
where description = 'Seasonal Flu Vaccine'
	and date between '2022-01-01 00:00' and '2022-12-31 23:59'
group by patient
)


select pat.birthdate, 
		pat.race, 
		pat.county,
		pat.id,
		pat.first,
		pat.last,
		pat.gender,
		extract(YEAR FROM age('2022-12-31', birthdate)) as age,
		flu.earliest_shot,
		flu.patient,
		case when flu.patient is not null then 1
		else 0
		end as flu_shot
from patients as pat
left join flu_shot_2022 as flu
on pat.id=flu.patient
where 1=1
and pat.id in (select patient from active_patients)

