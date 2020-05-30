--1. INSERT
	--1. Без указания списка полей
	INSERT INTO salon 
	VALUES
		('Komsomolskaya St.', '89318549302', 'Krasilov Petr', '89279587764');

--2. С указанием списка полей
	INSERT INTO hairdresser
		(id_salon, last_name, first_name, birth_date, phone_number)
	VALUES
		(1, 'Ivanov', 'Ivan', '1990-01-12', '89311234567');

--3. С чтением значения из другой таблицы
	INSERT INTO done (total_cost) SELECT cost FROM service;
	SELECT * FROM done;

--2. DELETE
	--1. Всех записей
		DELETE FROM done;
	--2. По условию
		DELETE FROM service WHERE name = 'hair styling';
	--3. Очистить таблицу
		TRUNCATE TABLE client;

--3. UPDATE
	--1. Всех записей
		UPDATE client SET regular_customer = 0;
	--2. По условию обновляя один атрибут
		UPDATE service
		SET materials = NULL
		WHERE name = 'haircut';
	--3. По условию обновляя несколько атрибутов
		UPDATE service
		SET materials = CONCAT(materials, ' hair dye'), cost = cost + 400
		WHERE name LIKE '%dying%';

--4. SELECT
	--1. С определенным набором извлекаемых атрибутов
		SELECT first_name, last_name FROM hairdresser;
	--2. Со всеми атрибутами
		SELECT * FROM salon;
	--3. С условием по атрибуту
		SELECT * FROM client WHERE regular_customer = 1;

--5. SELECT ORDER BY + TOP (LIMIT)
    --1. С сортировкой по возрастанию ASC + ограничение вывода количества записей
		SELECT TOP 3 name, cost
		FROM service
		ORDER BY cost ASC;
    --2. С сортировкой по убыванию DESC
		SELECT name, cost
		FROM service
		ORDER BY cost DESC;
    --3. С сортировкой по двум атрибутам + ограничение вывода количества записей
		SELECT TOP 5 * FROM client
		ORDER BY last_name, first_name;
    --4. С сортировкой по первому атрибуту, из списка извлекаемых
		SELECT CONCAT(last_name, ' ', first_name) AS full_name, phone_number
		FROM hairdresser
		ORDER BY 1;

--6. Работа с датами. Необходимо, чтобы одна из таблиц содержала атрибут с типом DATETIME.
    --1. WHERE по дате
		SELECT * FROM done WHERE date = '2019-08-27';
    --2. Извлечь из таблицы не всю дату, а только год. Например, год рождения автора.
		SELECT id_hairdresser, YEAR(birth_date) AS year FROM hairdresser;

--7. SELECT GROUP BY с функциями агрегации
    --1. MIN
		SELECT name, MIN(cost) AS cheapest_service
		FROM service GROUP BY name;
    --2. MAX
		SELECT name, MAX(cost) AS most_expensive_service
		FROM service GROUP BY name;
    --3. AVG
		--сколько в среднем платил каждый клиент
		SELECT id_client, AVG(total_cost) AS average_payment
		FROM done GROUP BY id_client;
    --4. SUM
		--суммарный доход от каждой услуги
		SELECT id_service, SUM(total_cost) AS service_revenue
		FROM done GROUP BY id_service;
    --5. COUNT
		--сколько визитов нанёс каждый клиент
		SELECT id_client, COUNT(total_cost) AS visits
		FROM done GROUP BY id_client;

--8. SELECT GROUP BY + HAVING
    --1. Написать 3 разных запроса с использованием GROUP BY + HAVING
		--услуги, доход от которых превысил 500.00
		SELECT id_service, SUM(total_cost) AS service_revenue FROM done
		GROUP BY id_service
		HAVING SUM(total_cost) > 500.00;

		--парикмахеры, у которых цена самой дешёвой услуги = 200.00
		SELECT name, MIN(cost) AS cheapest_cost FROM service
		GROUP BY name
		HAVING MIN(cost) = 200.00;

		--фамилии клиентов, встречающиеся среди них более 1 раза (однофамильцы)
		SELECT last_name, COUNT(last_name) AS clients_with_same_last_name FROM client
		GROUP BY last_name
		HAVING COUNT(last_name) > 1;

--9. SELECT JOIN
    --1. LEFT JOIN двух таблиц и WHERE по одному из атрибутов
		SELECT * FROM done
		LEFT JOIN service ON done.id_service = service.id_service
		WHERE total_cost > 200.0;
    --2. RIGHT JOIN. Получить такую же выборку, как и в 9.1
		SELECT * FROM service
		RIGHT JOIN done ON done.id_service = service.id_service
		WHERE total_cost > 200.0;
    --3. LEFT JOIN трех таблиц + WHERE по атрибуту из каждой таблицы
		SELECT * FROM done
		LEFT JOIN service ON service.id_service = done.id_service
		LEFT JOIN client ON client.id_client = done.id_client
		WHERE done.total_cost > 300 AND service.materials IS NOT NULL AND client.regular_customer = 1;

    --4. FULL OUTER JOIN двух таблиц
		--салоны и парикмахеры
		SELECT * FROM salon
		FULL OUTER JOIN hairdresser ON salon.id_salon = hairdresser.id_salon;

--10. Подзапросы
    --1. Написать запрос с WHERE IN (подзапрос)
		--услуги, которыми люди воспользовались более одного раза
		SELECT * FROM service
		WHERE id_service IN (
			SELECT id_service FROM done
			GROUP BY id_service
			HAVING COUNT(*) > 1
		)
    --2. Написать запрос SELECT atr1, atr2, (подзапрос) FROM ...
		--имена, телефоны и адреса работы парикмахеров
		SELECT
			CONCAT(first_name, ' ', last_name) AS full_name,
			phone_number,
			(SELECT address FROM salon WHERE salon.id_salon = hairdresser.id_salon) AS address
		FROM hairdresser;