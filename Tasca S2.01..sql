# NIVELL 1
-- Exercici 1: A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules. 
-- Mostra les característiques principals de l'esquema creat i explica les diferents taules i variables que existeixen. 
-- Assegura't d'incloure un diagrama que il·lustri la relació entre les diferents taules i variables.
use transactions; 
show tables;
describe company;
select * from company;
describe transaction;
select * from transaction;
select table_name, column_name, constraint_name, referenced_table_name, referenced_column_name
from information_schema.key_column_usage
where table_schema = "transactions";

-- Exercici 2: Utilitzant JOIN realitzaràs les següents consultes:
#Llistat dels països que estan fent compres.
select distinct country as countries_that_are_buying
from company
join transaction on company.id = transaction.company_id;

#Des de quants països es realitzen les compres.
select count(distinct country) as number_of_countries_from_purchases_are_made
from company
join transaction on company.id = transaction.company_id;

#Identifica la companyia amb la mitjana més gran de vendes.
select company.company_name, avg(transaction.amount) as highest_sales_average
from company
join transaction on company.id = transaction.company_id
where transaction.declined = false
group by company.company_name
order by highest_sales_average desc
limit 1;

-- Exercici 3: Utilitzant només subconsultes (sense utilitzar JOIN):
#Mostra totes les transaccions realitzades per empreses d'Alemanya
select *
from transaction
where company_id in ( select id from company where country = "Germany");

#Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
select distinct company_name
from company
where id in (select company_id from transaction where amount > (select avg(amount) from transaction) 
and company_id is not null);

#Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
select company_name 
from company 
where not exists (select transaction.id from transaction where transaction.company_id = company.id);

##NIVELL 2
-- Exercici 1: Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
-- Mostra la data de cada transacció juntament amb el total de les vendes.
select date(timestamp) as data, sum(amount) as total_revenue
from transaction
where declined = false
group by data
order by total_revenue desc
limit 5;

-- Exercici 2: Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
select distinct company.country, avg(transaction.amount) as average
from company
join transaction on company.id = transaction.company_id
where declined = false
group by company.country
order by average desc;

-- Exercici 3: En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries 
-- per a fer competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions 
-- realitzades per empreses que estan situades en el mateix país que aquesta companyia.
-- Mostra el llistat aplicant JOIN i subconsultes.
select *
from transaction
join company on company.id = transaction.company_id
where company.country = (select country from company where company_name = 'Non Institute') 
and company.company_name != 'Non Institute';
-- Mostra el llistat aplicant solament subconsultes.
select *
from transaction
where company_id in ( select id from company where country = (select country from company where company_name = 'Non Institute')
and company.company_name != 'Non Institute');

### NIVELL 3
-- Exercici 1: Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb 
-- un valor comprès entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. 
-- Ordena els resultats de major a menor quantitat.
select company.company_name as nome, company.phone, company.country, transaction.timestamp as date, transaction.amount
from company
join transaction on company.id = transaction.company_id
where transaction.amount between 100 and 200 and date(transaction.timestamp) in ('2021-04-29','2021-07-20','2022-03-13')
order by transaction.amount desc;

-- Exercici 2: Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
-- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen 
-- més de 4 transaccions o menys.
select company.company_name, count(transaction.id) as transaction_numbers,
case 
when count(transaction.id) > 4 then 'more'
else 'less'
end as transactions_about_4
from company
join transaction on company.id = transaction.company_id
group by company.company_name
having count(transaction.id) != 4;

