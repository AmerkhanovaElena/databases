--1. INSERT
	--1. ��� �������� ������ �����
	INSERT INTO salon 
	VALUES
		('Komsomolskaya St.', '89318549302', 'Krasilov Petr', '89279587764');

--2. � ��������� ������ �����
	INSERT INTO hairdresser
		(id_salon, last_name, first_name, birth_date, phone_number)
	VALUES
		(1, 'Ivanov', 'Ivan', '1990-01-12', '89311234567');

--3. � ������� �������� �� ������ �������
	INSERT INTO done (total_cost) SELECT cost FROM service;
	SELECT * FROM done;

--2. DELETE
	--1. ���� �������
		DELETE FROM done;
	--2. �� �������
		DELETE FROM service WHERE name = 'hair styling';
	--3. �������� �������
		TRUNCATE TABLE client;

--3. UPDATE
	--1. ���� �������
		UPDATE client SET regular_customer = 0;
	--2. �� ������� �������� ���� �������
		UPDATE service
		SET materials = NULL
		WHERE name = 'haircut';
	--3. �� ������� �������� ��������� ���������
		UPDATE service
		SET materials = CONCAT(materials, ' hair dye'), cost = cost + 400
		WHERE name LIKE '%dying%';

--4. SELECT
	--1. � ������������ ������� ����������� ���������
		SELECT first_name, last_name FROM hairdresser;
	--2. �� ����� ����������
		SELECT * FROM salon;
	--3. � �������� �� ��������
		SELECT * FROM client WHERE regular_customer = 1;

--5. SELECT ORDER BY + TOP (LIMIT)
    --1. � ����������� �� ����������� ASC + ����������� ������ ���������� �������
		SELECT TOP 3 name, cost
		FROM service
		ORDER BY cost ASC;
    --2. � ����������� �� �������� DESC
		SELECT name, cost
		FROM service
		ORDER BY cost DESC;
    --3. � ����������� �� ���� ��������� + ����������� ������ ���������� �������
		SELECT TOP 5 * FROM client
		ORDER BY last_name, first_name;
    --4. � ����������� �� ������� ��������, �� ������ �����������
		SELECT CONCAT(last_name, ' ', first_name) AS full_name, phone_number
		FROM hairdresser
		ORDER BY 1;

--6. ������ � ������. ����������, ����� ���� �� ������ ��������� ������� � ����� DATETIME.
    --1. WHERE �� ����
		SELECT * FROM done WHERE date = '2019-08-27';
    --2. ������� �� ������� �� ��� ����, � ������ ���. ��������, ��� �������� ������.
		SELECT id_hairdresser, YEAR(birth_date) AS year FROM hairdresser;

--7. SELECT GROUP BY � ��������� ���������
    --1. MIN
		SELECT name, MIN(cost) AS cheapest_service
		FROM service GROUP BY name;
    --2. MAX
		SELECT name, MAX(cost) AS most_expensive_service
		FROM service GROUP BY name;
    --3. AVG
		--������� � ������� ������ ������ ������
		SELECT id_client, AVG(total_cost) AS average_payment
		FROM done GROUP BY id_client;
    --4. SUM
		--��������� ����� �� ������ ������
		SELECT id_service, SUM(total_cost) AS service_revenue
		FROM done GROUP BY id_service;
    --5. COUNT
		--������� ������� ���� ������ ������
		SELECT id_client, COUNT(total_cost) AS visits
		FROM done GROUP BY id_client;

--8. SELECT GROUP BY + HAVING
    --1. �������� 3 ������ ������� � �������������� GROUP BY + HAVING
		--������, ����� �� ������� �������� 500.00
		SELECT id_service, SUM(total_cost) AS service_revenue FROM done
		GROUP BY id_service
		HAVING SUM(total_cost) > 500.00;

		--�����������, � ������� ���� ����� ������� ������ = 200.00
		SELECT name, MIN(cost) AS cheapest_cost FROM service
		GROUP BY name
		HAVING MIN(cost) = 200.00;

		--������� ��������, ������������� ����� ��� ����� 1 ���� (������������)
		SELECT last_name, COUNT(last_name) AS clients_with_same_last_name FROM client
		GROUP BY last_name
		HAVING COUNT(last_name) > 1;

--9. SELECT JOIN
    --1. LEFT JOIN ���� ������ � WHERE �� ������ �� ���������
		SELECT * FROM done
		LEFT JOIN service ON done.id_service = service.id_service
		WHERE total_cost > 200.0;
    --2. RIGHT JOIN. �������� ����� �� �������, ��� � � 9.1
		SELECT * FROM service
		RIGHT JOIN done ON done.id_service = service.id_service
		WHERE total_cost > 200.0;
    --3. LEFT JOIN ���� ������ + WHERE �� �������� �� ������ �������
		SELECT * FROM done
		LEFT JOIN service ON service.id_service = done.id_service
		LEFT JOIN client ON client.id_client = done.id_client
		WHERE done.total_cost > 300 AND service.materials IS NOT NULL AND client.regular_customer = 1;

    --4. FULL OUTER JOIN ���� ������
		--������ � �����������
		SELECT * FROM salon
		FULL OUTER JOIN hairdresser ON salon.id_salon = hairdresser.id_salon;

--10. ����������
    --1. �������� ������ � WHERE IN (���������)
		--������, �������� ���� ��������������� ����� ������ ����
		SELECT * FROM service
		WHERE id_service IN (
			SELECT id_service FROM done
			GROUP BY id_service
			HAVING COUNT(*) > 1
		)
    --2. �������� ������ SELECT atr1, atr2, (���������) FROM ...
		--�����, �������� � ������ ������ ������������
		SELECT
			CONCAT(first_name, ' ', last_name) AS full_name,
			phone_number,
			(SELECT address FROM salon WHERE salon.id_salon = hairdresser.id_salon) AS address
		FROM hairdresser;