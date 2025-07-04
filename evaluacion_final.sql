-- ====================================================
-- 📘 EVALUACIÓN FINAL - MÓDULO 2: Consultas SQL
-- ====================================================

-- Asegúrate de usar la base de datos correcta:
USE sakila;

-- 1. Selecciona todos los nombres de las películas sin que aparezcan duplicados.

SELECT DISTINCT title -- Pedimos que se muestren solo las filas únicas
FROM film;

-- 2. Muestra los nombres de todas las películas que tengan una clasificación de "PG-13".

SELECT title
FROM film
WHERE rating = "PG-13"; -- En este filtro avanzado podríamos usar LIKE porque daría en este caso el mismo resultado pero como queremos que la coincidencia sea exacta es más preciso usar =

-- 3. Encuentra el título y la descripción de todas las películas que contengan la palabra "amazing" en su descripción.

SELECT title, description
FROM film
WHERE description LIKE '%amazing%'; -- Usamos LIKE y no REGEXP porque es más rápido en búsquedas simples, lo que lo hace más idóneo para casos donde una cadena contiene algo

-- 4. Encuentra el título de todas las películas que tengan una duración mayor a 120 minutos.

SELECT title
FROM film
WHERE length > '120'; -- Donde la longitud es mayor a

-- 5. Recupera los nombres de todos los actores.

SELECT first_name
FROM actor;

-- 6. Encuentra el nombre y apellido de los actores que tengan "Gibson" en su apellido.

SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%Gibson%';

-- 7. Encuentra los nombres de los actores que tengan un actor_id entre 10 y 20.

SELECT first_name
FROM actor
WHERE actor_id BETWEEN 10 AND 20;

-- 8. Encuentra el título de las películas en la tabla film que no sean ni "R" ni "PG-13" en cuanto a su clasificación.

SELECT title
FROM film
WHERE rating NOT IN ('R', 'PG-13'); -- Donde la columna rating no contenga "R" o "PG-13"

-- 9. Encuentra la cantidad total de películas en cada clasificación de la tabla film y muestra la clasificación junto con el recuento.

SELECT rating, COUNT(film_id) AS total_peliculas -- COUNT cuenta el número de filas (películas) en cada grupo
FROM film
GROUP BY rating;

-- 10. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del cliente, su nombre y apellido junto con la cantidad de películas alquiladas.

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(r.rental_id) AS total_alquiladas
FROM customer c
INNER JOIN rental r USING (customer_id)
GROUP BY c.customer_id, c.first_name, c.last_name; -- Toda columna de SELECT que no está en una función agregada debe aparecer en el GROUP BY

-- 11. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de la categoría junto con el recuento de alquileres.

SELECT
	c.name AS categoría,
    COUNT(r.rental_id) AS total_alquileres
FROM rental r
INNER JOIN inventory i USING (inventory_id)
INNER JOIN film f USING (film_id)
INNER JOIN film_category fc USING (film_id)
INNER JOIN category c USING (category_id)
GROUP BY c.name; -- Cuando combinamos una columna agregada con columnas normales (no agregadas) es obligatorio usar GROUP BY para decirle a SQL cómo agrupar esos datos

-- 12. Encuentra el promedio de duración de las películas para cada clasificación de la tabla film y muestra la clasificación junto con el promedio de duración.

SELECT rating, AVG(length) AS promedio_duración -- Calculamos con AVG la media de los valores de la columna numérica length
FROM film
GROUP BY rating;

-- 13. Encuentra el nombre y apellido de los actores que aparecen en la película con title "Indian Love".

SELECT CONCAT(a.first_name, ' ', a.last_name) AS nombre_completo -- Concatenamos varios valores en una sola cadena de texto para renombrar la columna
FROM actor a
INNER JOIN film_actor fa USING (actor_id)
INNER JOIN film f USING (film_id)
WHERE f.title = "Indian Love";

-- 14. Muestra el título de todas las películas que contengan la palabra "dog" o "cat" en su descripción.

SELECT title
FROM film
WHERE description LIKE '%dog%' OR description LIKE '%cat%';

-- 15. Encuentra el título de todas las películas que fueron lanzadas entre el año 2005 y 2010.

SELECT title
FROM film
WHERE release_year BETWEEN 2005 AND 2010;

-- 16. Encuentra el título de todas las películas que son de la misma categoría que "Family".
-- NOTA: No hay ninguna película titulada Family, las más similares son 'Cyclone Family', 'Dogma Family' y 'Family Sweet',
-- así que haremos el ejercicio con esta última frente al resto por comenzar por la palabra indicada en el enunciado.

SELECT f.title
FROM film f
INNER JOIN film_category fc USING (film_id)
INNER JOIN category c USING (category_id)
WHERE c.name LIKE (
	SELECT c.name
	FROM category c
	INNER JOIN film_category fc USING (category_id)
	INNER JOIN film f USING (film_id)
	WHERE f.title LIKE '%Family Sweet%'
	);

-- 17. Encuentra el título de todas las películas que son "R" y tienen una duración mayor a 2 horas en la tabla film.

SELECT f.title
FROM film f
WHERE f.rating LIKE 'R' AND f.length > 120;

-- ////////////////////////////////////////////////////
-- 🧪 BONUS: Consultas avanzadas
-- ////////////////////////////////////////////////////

-- 18. Muestra el nombre y apellido de los actores que aparecen en más de 10 películas.

SELECT CONCAT(a.first_name, ' ', a.last_name) AS nombre_completo
FROM actor a
INNER JOIN film_actor fa USING (actor_id)
GROUP BY a.actor_id, a.first_name, a.last_name -- Agrupamos por actor, usando su actor_id y nombres para asegurarnos que cada grupo corresponde a un actor único. Esto es necesario porque usamos una función agregada (COUNT) y estamos seleccionando columnas no agregadas.
HAVING COUNT(fa.film_id) > 10; -- Indicamos que solo queremos actores que hayan actuado en más de 10 películas (fa.film_id cuenta las películas relacionadas).

-- 19. ¿Hay algún actor o actriz que no aparezca en ninguna película en la tabla film_actor?
-- Respuesta: Negativo, todos han participado en alguna película.

SELECT CONCAT(a.first_name, ' ', a.last_name) AS nombre_completo
FROM actor a
LEFT JOIN film_actor fa USING (actor_id) -- Usamos un LEFT JOIN porque queremos incluir todos los actores, incluso aquellos que no tienen registros relacionados en la tabla film_actor
WHERE fa.film_id IS NULL;

-- 20. Encuentra las categorías de películas que tienen un promedio de duración superior a 120 minutos y muestra el nombre de la categoría junto con el promedio de duración.

SELECT c.name AS categoria, AVG(f.length) AS duracion_media
FROM category c
INNER JOIN film_category fc USING (category_id)
INNER JOIN film f USING (film_id)
GROUP BY c.category_id, c.name
HAVING AVG(f.length) > 120;

-- 21. Encuentra los actores que han actuado en al menos 5 películas y muestra el nombre del actor junto con la cantidad de películas en las que han actuado.

SELECT CONCAT(a.first_name, ' ', a.last_name) AS nombre_completo, COUNT(f.film_id) AS total_películas
FROM actor a
INNER JOIN film_actor fa USING (actor_id)
INNER JOIN film f USING (film_id)
GROUP BY a.first_name, a.last_name -- Agrupamos los datos por actor para contar cuántas películas tiene cada uno y con HAVING filtramos aquellos con más de 5 participaciones.
HAVING COUNT(f.film_id) > 5;

-- 22. Encuentra el título de todas las películas que fueron alquiladas por más de 5 días.
-- Utiliza una subconsulta para encontrar los rental_id con una duración superior a 5 días y luego selecciona las películas correspondientes.

SELECT DISTINCT f.title
FROM film f
INNER JOIN inventory i USING (film_id)
INNER JOIN rental r USING (inventory_id)
WHERE r.rental_id IN (
	SELECT rental_id
	FROM rental
	WHERE DATEDIFF(return_date, rental_date) > 5 -- Esta función calcula la diferencia en días entre dos fechas
	);

-- 23. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría "Horror".
-- Utiliza una subconsulta para encontrar los actores que han actuado en películas de la categoría "Horror" y luego exclúyelos de la lista de actores.

SELECT DISTINCT CONCAT( a.first_name, ' ', a.last_name) AS nombre_completo
FROM actor a
INNER JOIN film_actor fa USING (actor_id)
INNER JOIN film f USING (film_id)
WHERE a.actor_id NOT IN ( 
	SELECT CONCAT(a.first_name, ' ', a.last_name) AS nombre_completo
	FROM actor a
	INNER JOIN film_actor fa USING (actor_id)
	INNER JOIN film f USING (film_id)
	INNER JOIN film_category fc USING (film_id)
	INNER JOIN category c USING (category_id)
	WHERE c.name = 'Horror'
	);

-- 24. Encuentra el título de las películas que son comedias y tienen una duración mayor a 180 minutos en la tabla film.

SELECT title
FROM film f
INNER JOIN film_category fc USING (film_id)
INNER JOIN category c USING (category_id)
WHERE c.name = 'Comedy' AND f.length > 180;

-- 25. Encuentra todos los actores que han actuado juntos en al menos una película. 
-- La consulta debe mostrar el nombre y apellido de los actores y el número de películas en las que han actuado juntos.

SELECT DISTINCT 
	CONCAT(a1.first_name, ' ', a1.last_name) AS actor_1,
	CONCAT(a2.first_name, ' ', a2.last_name) AS actor_2,
    COUNT(*) AS peliculas_juntos
FROM film_actor fa1
INNER JOIN film_actor fa2 -- Usamos un SELF JOIN porque queremos comparar actores entre sí dentro de la misma tabla de relaciones
	ON fa1.film_id = fa2.film_id 
    AND fa1.actor_id < fa2.actor_id  -- Evitamos que se repitan las parejas en orden invertido, manteniendo solo una combinación única por pareja
INNER JOIN actor a1 ON fa1.actor_id = a1.actor_id
INNER JOIN actor a2 ON fa2.actor_id = a2.actor_id
GROUP BY actor_1, actor_2
HAVING COUNT(*) >= 1; -- Filtramos para mostrar solo parejas que hayan hecho al menos una película juntos (en realidad este filtro es redundante porque cualquier grupo tiene al menos un elemento, pero podría usarse para otro umbral mayor)

