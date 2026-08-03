USE sakila;

-- Parte 1 - SELECT y WHERE

-- 1. Mostrar nombre y apellido de todos los clientes
-- Solo necesito dos columnas de la tabla customer,
-- por eso las pido directamente sin filtrar nada (no necesito WHERE).

SELECT first_name, last_name
FROM customer;

-- 2. Peliculas con duracion mayor a 120 minutos
-- Uso WHERE para filtrar solo las filas donde la columna
-- length (duracion en minutos) sea mayor a 120.

SELECT title, length
FROM film
WHERE length > 120;

-- Parte 2 - ORDER BY

-- 3. Ordenar clientes por apellido de la A a la Z
-- ORDER BY reorganiza el resultado. ASC significa ascendente,
-- o sea de la A a la Z.

SELECT first_name, last_name
FROM customer
ORDER BY last_name ASC;

-- 4. Top 5 peliculas mas largas
-- Primero ordeno las peliculas de mayor a menor duracion
-- con ORDER BY length DESC, y despues con LIMIT 5 le digo a SQL
-- que solo me muestre las primeras 5 filas de ese resultado ya ordenado.

SELECT title, length
FROM film
ORDER BY length DESC
LIMIT 5;

-- Parte 3 - INNER JOIN

-- 5. Cantidad pagada y fecha del pago con nombre y apellido del cliente
-- La tabla payment tiene el monto y la fecha, pero no el nombre
-- del cliente, solo su customer_id. Por eso uso INNER JOIN para conectar
-- payment con customer, usando customer_id como columna en comun,
-- y asi puedo traer datos de las dos tablas en una sola consulta.

SELECT customer.first_name, customer.last_name, payment.amount, payment.payment_date
FROM payment
INNER JOIN customer ON payment.customer_id = customer.customer_id;

-- 6. Peliculas alquiladas (Rental - Inventory - Film)
-- Aqui necesito unir 3 tablas porque rental no tiene el titulo
-- de la pelicula directamente, solo tiene inventory_id. inventory es
-- la tabla intermedia que conecta cada copia fisica con su film_id,
-- y film es la que finalmente tiene el titulo. Por eso hago dos JOIN
-- en cadena: rental -> inventory -> film.

SELECT film.title, rental.rental_date
FROM rental
INNER JOIN inventory ON rental.inventory_id = inventory.inventory_id
INNER JOIN film ON inventory.film_id = film.film_id;

-- Parte 4 - LEFT JOIN

-- 7. Nombre y apellido de clientes sin pagos
-- Con LEFT JOIN traigo TODOS los clientes, tengan o no pagos.
-- Cuando un cliente no tiene ningun pago relacionado, las columnas
-- de payment quedan en NULL. Por eso en el WHERE filtro donde
-- payment.payment_id IS NULL, para quedarme solo con los clientes
-- que nunca aparecen en la tabla payment.

SELECT customer.first_name, customer.last_name
FROM customer
LEFT JOIN payment ON customer.customer_id = payment.customer_id
WHERE payment.payment_id IS NULL;

-- 8. Peliculas y su duracion que no tienen actores
-- Misma idea que el punto anterior. Uso LEFT JOIN entre film
-- y film_actor para traer todas las peliculas, tengan o no actores
-- asociados. Si una pelicula no tiene actores, la columna actor_id
-- de film_actor queda en NULL, entonces filtro con WHERE
-- film_actor.actor_id IS NULL para quedarme solo con esas peliculas.

SELECT film.title, film.length
FROM film
LEFT JOIN film_actor ON film.film_id = film_actor.film_id
WHERE film_actor.actor_id IS NULL;

-- Parte 5 - INSERT, UPDATE, DELETE

-- 9. Insertar actor temporal
-- Con INSERT INTO agrego una fila nueva a la tabla actor,
-- indicando en que columnas voy a meter datos (first_name, last_name)
-- y los valores que le corresponden a cada una. Este actor es solo
-- de prueba, por eso lo llamo "Diego Temporal".

INSERT INTO actor (first_name, last_name)
VALUES ('Diego', 'Temporal');

-- 10. Actualizar actor
-- UPDATE modifica filas que ya existen. Si no le pongo WHERE,
-- SQL actualizaria el first_name de TODOS los actores de la tabla,
-- por eso el WHERE es obligatorio: le digo que solo actualice la fila
-- donde el nombre y apellido coincidan exactamente con el actor
-- temporal que inserte en el punto 9.

UPDATE actor
SET first_name = 'DiegoActualizado'
WHERE first_name = 'Diego' AND last_name = 'Temporal';

-- 11. Eliminar actor
-- Igual que en el UPDATE, el WHERE es indispensable en un
-- DELETE, porque sin el se borrarian todos los registros de la tabla.
-- Aqui elimino unicamente la fila del actor de prueba que ya
-- actualice en el paso anterior, identificandolo por nombre y apellido.

DELETE FROM actor
WHERE first_name = 'DiegoActualizado' AND last_name = 'Temporal';

-- Parte 6 - Consultas avanzadas

-- 12. Top 5 clientes con mayor cantidad de dinero pagado
-- Uno payment con customer para saber el nombre de cada
-- cliente. Despues con GROUP BY customer.customer_id agrupo todos
-- los pagos que pertenecen a un mismo cliente, y uso SUM(payment.amount)
-- para sumar el total que ha pagado cada uno. Al final ordeno de mayor
-- a menor con ORDER BY total_pagado DESC y uso LIMIT 5 para quedarme
-- solo con los 5 que mas han pagado.

SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS total_pagado
FROM payment
INNER JOIN customer ON payment.customer_id = customer.customer_id
GROUP BY customer.customer_id
ORDER BY total_pagado DESC
LIMIT 5;

-- 13. Top 5 peliculas mas alquiladas
-- Parecido al punto 6, uno rental -> inventory -> film para
-- llegar al titulo de cada pelicula. Despues agrupo con
-- GROUP BY film.film_id para juntar todas las rentas de una misma
-- pelicula, y uso COUNT(rental.rental_id) para contar cuantas veces
-- aparece cada pelicula en la tabla rental, es decir, cuantas veces
-- se ha alquilado. Ordeno de mayor a menor y con LIMIT 5 me quedo
-- con las 5 peliculas mas alquiladas.

SELECT film.title, COUNT(rental.rental_id) AS veces_alquilada
FROM rental
INNER JOIN inventory ON rental.inventory_id = inventory.inventory_id
INNER JOIN film ON inventory.film_id = film.film_id
GROUP BY film.film_id
ORDER BY veces_alquilada DESC
LIMIT 5;
