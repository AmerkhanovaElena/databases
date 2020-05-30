--1. INSERT
	--1. Áåç óêàçàíèÿ ñïèñêà ïîëåé
	INSERT INTO salon 
	VALUES
		('Komsomolskaya St.', '89318549302', 'Krasilov Petr', '89279587764');

--2. Ñ óêàçàíèåì ñïèñêà ïîëåé
	INSERT INTO hairdresser
		(id_salon, last_name, first_name, birth_date, phone_number)
	VALUES
		(1, 'Ivanov', 'Ivan', '1990-01-12', '89311234567');

--3. Ñ ÷òåíèåì çíà÷åíèÿ èç äðóãîé òàáëèöû
	INSERT INTO done (total_cost) SELECT cost FROM service;
	SELECT * FROM done;

--2. DELETE
	--1. Âñåõ çàïèñåé
		DELETE FROM done;
	--2. Ïî óñëîâèþ
		DELETE FROM service WHERE name = 'hair styling';
	--3. Î÷èñòèòü òàáëèöó
		TRUNCATE TABLE client;

--3. UPDATE
	--1. Âñåõ çàïèñåé
		UPDATE client SET regular_customer = 0;
	--2. Ïî óñëîâèþ îáíîâëÿÿ îäèí àòðèáóò
		UPDATE service
		SET materials = NULL
		WHERE name = 'haircut';
	--3. Ïî óñëîâèþ îáíîâëÿÿ íåñêîëüêî àòðèáóòîâ
		UPDATE service
		SET materials = CONCAT(materials, ' hair dye'), cost = cost + 400
		WHERE name LIKE '%dying%';

--4. SELECT
	--1. Ñ îïðåäåëåííûì íàáîðîì èçâëåêàåìûõ àòðèáóòîâ
		SELECT first_name, last_name FROM hairdresser;
	--2. Ñî âñåìè àòðèáóòàìè
		SELECT * FROM salon;
	--3. Ñ óñëîâèåì ïî àòðèáóòó
		SELECT * FROM client WHERE regular_customer = 1;

--5. SELECT ORDER BY + TOP (LIMIT)
    --1. Ñ ñîðòèðîâêîé ïî âîçðàñòàíèþ ASC + îãðàíè÷åíèå âûâîäà êîëè÷åñòâà çàïèñåé
		SELECT TOP 3 name, cost
		FROM service
		ORDER BY cost ASC;
    --2. Ñ ñîðòèðîâêîé ïî óáûâàíèþ DESC
		SELECT name, cost
		FROM service
		ORDER BY cost DESC;
    --3. Ñ ñîðòèðîâêîé ïî äâóì àòðèáóòàì + îãðàíè÷åíèå âûâîäà êîëè÷åñòâà çàïèñåé
		SELECT TOP 5 * FROM client
		ORDER BY last_name, first_name;
    --4. Ñ ñîðòèðîâêîé ïî ïåðâîìó àòðèáóòó, èç ñïèñêà èçâëåêàåìûõ
		SELECT CONCAT(last_name, ' ', first_name) AS full_name, phone_number
		FROM hairdresser
		ORDER BY 1;

--6. Ðàáîòà ñ äàòàìè. Íåîáõîäèìî, ÷òîáû îäíà èç òàáëèö ñîäåðæàëà àòðèáóò ñ òèïîì DATETIME.
    --1. WHERE ïî äàòå
		SELECT * FROM done WHERE date = '2019-08-27';
    --2. Èçâëå÷ü èç òàáëèöû íå âñþ äàòó, à òîëüêî ãîä. Íàïðèìåð, ãîä ðîæäåíèÿ àâòîðà.
		SELECT id_hairdresser, YEAR(birth_date) AS year FROM hairdresser;

--7. SELECT GROUP BY ñ ôóíêöèÿìè àãðåãàöèè
    --1. MIN
		SELECT name, MIN(cost) AS cheapest_service
		FROM service GROUP BY name;
    --2. MAX
		SELECT name, MAX(cost) AS most_expensive_service
		FROM service GROUP BY name;
    --3. AVG
		--ñêîëüêî â ñðåäíåì ïëàòèë êàæäûé êëèåíò
		SELECT id_client, AVG(total_cost) AS average_payment
		FROM done GROUP BY id_client;
    --4. SUM
		--ñóììàðíûé äîõîä îò êàæäîé óñëóãè
		SELECT id_service, SUM(total_cost) AS service_revenue
		FROM done GROUP BY id_service;
    --5. COUNT
		--ñêîëüêî âèçèòîâ íàí¸ñ êàæäûé êëèåíò
		SELECT id_client, COUNT(total_cost) AS visits
		FROM done GROUP BY id_client;

--8. SELECT GROUP BY + HAVING
    --1. Íàïèñàòü 3 ðàçíûõ çàïðîñà ñ èñïîëüçîâàíèåì GROUP BY + HAVING
		--óñëóãè, äîõîä îò êîòîðûõ ïðåâûñèë 500.00
		SELECT id_service, SUM(total_cost) AS service_revenue FROM done
		GROUP BY id_service
		HAVING SUM(total_cost) > 500.00;

		--ïàðèêìàõåðû, ó êîòîðûõ öåíà ñàìîé äåø¸âîé óñëóãè = 200.00
		SELECT name, MIN(cost) AS cheapest_cost FROM service
		GROUP BY name
		HAVING MIN(cost) = 200.00;

		--ôàìèëèè êëèåíòîâ, âñòðå÷àþùèåñÿ ñðåäè íèõ áîëåå 1 ðàçà (îäíîôàìèëüöû)
		SELECT last_name, COUNT(last_name) AS clients_with_same_last_name FROM client
		GROUP BY last_name
		HAVING COUNT(last_name) > 1;

--9. SELECT JOIN
    --1. LEFT JOIN äâóõ òàáëèö è WHERE ïî îäíîìó èç àòðèáóòîâ
		SELECT * FROM done
		LEFT JOIN service ON done.id_service = service.id_service
		WHERE total_cost > 200.0;
    --2. RIGHT JOIN. Ïîëó÷èòü òàêóþ æå âûáîðêó, êàê è â 9.1
		SELECT * FROM service
		RIGHT JOIN done ON done.id_service = service.id_service
		WHERE total_cost > 200.0;
    --3. LEFT JOIN òðåõ òàáëèö + WHERE ïî àòðèáóòó èç êàæäîé òàáëèöû
		SELECT * FROM done
		LEFT JOIN service ON service.id_service = done.id_service
		LEFT JOIN client ON client.id_client = done.id_client
		WHERE done.total_cost > 300 AND service.materials IS NOT NULL AND client.regular_customer = 1;
    --4. FULL OUTER JOIN äâóõ òàáëèö
		--ñàëîíû è ïàðèêìàõåðû
		SELECT * FROM salon
		FULL OUTER JOIN hairdresser ON salon.id_salon = hairdresser.id_salon;

--10. Ïîäçàïðîñû
    --1. Íàïèñàòü çàïðîñ ñ WHERE IN (ïîäçàïðîñ)
		--óñëóãè, êîòîðûìè ëþäè âîñïîëüçîâàëèñü áîëåå îäíîãî ðàçà
		SELECT * FROM service
		WHERE id_service IN (
			SELECT id_service FROM done
			GROUP BY id_service
			HAVING COUNT(*) > 1
		)
    --2. Íàïèñàòü çàïðîñ SELECT atr1, atr2, (ïîäçàïðîñ) FROM ...
		--èìåíà, òåëåôîíû è àäðåñà ðàáîòû ïàðèêìàõåðîâ
		SELECT
			CONCAT(first_name, ' ', last_name) AS full_name,
			phone_number,
			(SELECT address FROM salon WHERE salon.id_salon = hairdresser.id_salon) AS address
		FROM hairdresser;
