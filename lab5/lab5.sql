--1. Добавить внешние ключи.
	ALTER TABLE [order]
		ADD CONSTRAINT FK_order_id_pharmacy FOREIGN KEY (id_pharmacy)
			REFERENCES pharmacy (id_pharmacy)
			ON DELETE CASCADE
			ON UPDATE CASCADE

	ALTER TABLE [order]
		ADD CONSTRAINT FK_order_id_production FOREIGN KEY (id_production)
			REFERENCES production (id_production)
			ON DELETE NO ACTION
			ON UPDATE NO ACTION

	ALTER TABLE [order]
		ADD CONSTRAINT FK_order_id_dealer FOREIGN KEY (id_dealer)
			REFERENCES dealer (id_dealer)
			ON DELETE NO ACTION
			ON UPDATE NO ACTION

	ALTER TABLE dealer
		ADD CONSTRAINT FK_dealer_id_company FOREIGN KEY (id_company)
			REFERENCES company (id_company)
			ON DELETE CASCADE
			ON UPDATE CASCADE

	ALTER TABLE production
		ADD CONSTRAINT FK_production_id_company FOREIGN KEY (id_company)
			REFERENCES company (id_company)
			ON DELETE CASCADE
			ON UPDATE CASCADE

	ALTER TABLE production
		ADD CONSTRAINT FK_production_id_medicine FOREIGN KEY (id_medicine)
			REFERENCES medicine (id_medicine)
			ON DELETE CASCADE
			ON UPDATE CASCADE

--2. Выдать информацию по всем заказам лекарства “Кордерон” компании “Аргус” с указанием названий аптек, дат, объема заказов.
	SELECT pharmacy.name, [order].date, [order].quantity FROM [order]
	INNER JOIN pharmacy ON pharmacy.id_pharmacy = [order].id_pharmacy
	WHERE [order].id_production IN (
		SELECT id_production FROM production
		WHERE id_medicine = (
			SELECT id_medicine FROM medicine
			WHERE name = 'Кордерон'
		) AND id_company = (
			SELECT id_company FROM company
			WHERE name = 'Аргус'
		)
	)

--3. Дать список лекарств компании “Фарма”, на которые не были сделаны заказы до 25 января.
	SELECT id_medicine, name FROM medicine
	WHERE id_medicine IN (
		SELECT id_medicine FROM production
		LEFT JOIN [order] ON production.id_production = [order].id_production
		WHERE production.id_company = (
			SELECT id_company FROM company
			WHERE name = 'Фарма'
		)
		GROUP BY id_medicine
		HAVING MIN(date) > '2019-01-25' OR MIN(date) IS NULL
	)

--4. Дать минимальный и максимальный баллы лекарств каждой фирмы, которая оформила не менее 120 заказов.
	SELECT 
		id_company,
		(SELECT name FROM company WHERE company.id_company = production.id_company) AS company_name, 
		MIN(rating) AS min_rating,
		MAX(rating) AS max_rating 
	FROM production
	WHERE id_company IN (
		SELECT production.id_company FROM [order]
		INNER JOIN production ON production.id_production = [order].id_production
		GROUP BY production.id_company
		HAVING COUNT(*) > 120
	)
	GROUP BY production.id_company;

--5. Дать списки сделавших заказы аптек по всем дилерам компании “AstraZeneca”. Если у дилера нет заказов, в названии аптеки проставить NULL.
	WITH az_dealer (id_dealer, name)
	AS
	(
		SELECT id_dealer, name FROM dealer
		WHERE id_company = (
			SELECT id_company FROM company
			WHERE name = 'AstraZeneca'
		)
	)
	SELECT az_dealer.id_dealer, az_dealer.name AS dealer_name, pharmacy.name AS pharmacy_name FROM az_dealer
	LEFT JOIN [order] ON [order].id_dealer = az_dealer.id_dealer
	LEFT JOIN pharmacy ON pharmacy.id_pharmacy = [order].id_pharmacy
	GROUP BY az_dealer.id_dealer, az_dealer.name, pharmacy.name;

--6. Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а длительность лечения не более 7 дней.
	UPDATE production
	SET price = price * 0.8
	WHERE price > 3000.00
		AND id_medicine IN (
		SELECT id_medicine FROM medicine
		WHERE cure_duration <= 7
	)

--7. Добавить необходимые индексы

	--используется в заданиях 2, 4
	CREATE NONCLUSTERED INDEX [IX_order_id_production] ON dbo.[order]
	(
		id_production ASC
	)

	--используется в задании 2
	CREATE NONCLUSTERED INDEX [IX_production_id_medicine] ON dbo.production
	(
		id_medicine ASC
	)

	--используется в заданиях 3, 4
	CREATE NONCLUSTERED INDEX [IX_production_id_company] ON dbo.production
	(
		id_company ASC
	)
	
	--используется в задании 5
	CREATE NONCLUSTERED INDEX [IX_dealer_id_company] ON dbo.dealer
	(
		id_company ASC
	)