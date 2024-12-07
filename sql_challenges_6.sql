/*

*******************************************************************************
*******************************************************************************

SQL CHALLENGES 6

*******************************************************************************
*******************************************************************************

In the exercises below you will need to use the following clauses:
    - IN (NOT IN)
    - BETWEEN (AND)

--------------------------------------------------------------------------------

In SQL we can have many databases, they will show up in the schemas list
We must first define which database we will be working with. */

USE publications;


/*******************************************************************************
IN

https://www.w3schools.com/sql/sql_in.asp
*******************************************************************************/

/* 1. Select the name and state of all stores located in either California (CA)
   or Oregon (OR) */

SELECT stor_name, state FROM stores WHERE state IN ('CA', 'OR');

/* 2. Using "IN", select all titles of type "psychology", "mod_cook" and
"trad_cook" */

SELECT title FROM titles WHERE type IN ('psychology', 'mod_cook', 'trad_cook');

/* 3. Select all the authors from the author table that do not come from the
cities Salt Lake City, Ann Arbor, and Oakland. */

SELECT au_fname, au_lname FROM authors WHERE city NOT IN ('Salt Lake City', 'Ann Arbor', 'Oakland');

/* The differences between =, LIKE and IN

= :   takes a single value to look for and matches only the exact value.

LIKE: takes a single to look for and allows wildcards (%, _) to match patterns
      in different positions.

IN :  takes many values to look for, such as a list of values, but does not
      work with the wildcards (%, _). */


/*******************************************************************************
BETWEEN

https://www.w3schools.com/sql/sql_between.asp
*******************************************************************************/

/* 4. Select all the order numbers with a quantity sold between 25 and 45 from
   the table sales */

SELECT ord_num FROM sales WHERE qty BETWEEN 25 AND 45;

-- 5. Select all the orders between 1993-03-11 and 1994-09-13

SELECT * FROM sales WHERE ord_date BETWEEN '1993-03-11' AND '1994-09-13';

/* 6. Select all job descriptions with a maximum level ("max_lvl") between 150
     and 200. */

SELECT job_desc FROM jobs WHERE max_lvl BETWEEN 150 AND 200;