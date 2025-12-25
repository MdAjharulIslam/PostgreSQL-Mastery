
select fname, sum(salery) 
over(order by salery)
from employees