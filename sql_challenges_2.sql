/*
*******************************************************************************
*******************************************************************************

SQL CHALLENGES 2

*******************************************************************************
*******************************************************************************

In the exercises below you will need to use the following clauses:
	- WHERE
	- AND / OR / NOT

In SQL we can have many databases, they will show up in the schemas list
We must first define which database we will be working with.
*/
use publications;
/******************************************************************************
WHERE

https://www.w3schools.com/sql/sql_where.asp
******************************************************************************/

/* 1. Select first and last name from authors who have the last name "Ringer" */

select au_fname, au_lname from authors where au_lname='ringer';

/* 2. Select the order number and order date of all orders where exactly 20
   books were sold */

select ord_num, ord_date from sales where qty='20';

/* 3. Select first and last name from authors whose last name is "Ringer" and
   first name is "Anne"
   https://www.w3schools.com/sql/sql_and_or.asp */

select au_fname, au_lname from authors where au_fname='anne' and au_lname='ringer';

/* 4. Select the name and city of publishers based in either Germany or France
   https://www.w3schools.com/sql/sql_and_or.asp */

select pub_name, city from publishers where country='germany' or country='france';

/* 5. Select first name, last name, and city from authors whose
   first name is "Dean" and whose city is either "Oakland" or "Berkeley"
   HINT: parenthesis "()" can help */

SELECT au_fname, au_lname, city FROM authors WHERE au_fname = 'Dean' AND (city = 'Oakland' OR city = 'Berkeley');

/* 6. Select the name, city and country of publishers not based in the USA
    https://www.w3schools.com/sql/sql_and_or.asp */

SELECT pub_name, city, country FROM publishers WHERE country != 'USA';

/* 7. Select first, last name, and city from authors whose city is "Oakland"
   or "Berkeley", and last name is NOT "Straight"*/

SELECT au_fname, au_lname, city FROM authors WHERE (city = 'Oakland' OR city = 'Berkeley') AND au_lname != 'Straight';