--1. �������� ������� �����.
	ALTER TABLE room
		ADD CONSTRAINT FK_room_id_hotel FOREIGN KEY (id_hotel)
			REFERENCES hotel (id_hotel)
			ON DELETE CASCADE
			ON UPDATE CASCADE

	ALTER TABLE room
		ADD CONSTRAINT FK_room_id_room_category FOREIGN KEY (id_room_category)
			REFERENCES room_category (id_room_category)
			ON DELETE CASCADE
			ON UPDATE CASCADE

	ALTER TABLE room_in_booking
		ADD CONSTRAINT FK_room_in_booking_id_room FOREIGN KEY (id_room)
			REFERENCES room (id_room)
			ON DELETE CASCADE
			ON UPDATE CASCADE

	ALTER TABLE room_in_booking
		ADD CONSTRAINT FK_room_in_booking_id_booking FOREIGN KEY (id_booking)
			REFERENCES booking (id_booking)
			ON DELETE CASCADE
			ON UPDATE CASCADE

	ALTER TABLE booking
		ADD CONSTRAINT FK_booking_id_client FOREIGN KEY (id_client)
			REFERENCES client (id_client)
			ON DELETE CASCADE
			ON UPDATE CASCADE

--2. ������ ���������� � �������� ��������� �������, ����������� � ������� ��������� ����� �� 1 ������ 2019�.
	SELECT * FROM client
	WHERE id_client IN (
		SELECT id_client FROM booking
		WHERE id_booking IN (
			SELECT id_booking FROM room_in_booking
			WHERE checkin_date <= '2019-04-01' AND checkout_date > '2019-04-01' AND id_room IN (
				SELECT id_room FROM room
				WHERE id_room_category = (
					SELECT id_room_category FROM room_category
					WHERE name = '����'
				) AND id_hotel = (
					SELECT id_hotel FROM hotel
					WHERE name = '������'
				)
			)
		)
	)

--3. ���� ������ ��������� ������� ���� �������� �� 22 ������.
	SELECT * FROM room
	WHERE id_room NOT IN (
		SELECT id_room FROM room_in_booking
		WHERE checkin_date <= '2019-04-22' AND checkout_date > '2019-04-22'
	)
	ORDER BY room.id_room;

--4. ���� ���������� ����������� � ��������� ������� �� 23 ����� �� ������ ��������� �������.
	SELECT room_category.name, COUNT(id_room_in_booking) FROM room_in_booking
	INNER JOIN room ON room_in_booking.id_room = room.id_room
	INNER JOIN room_category ON room.id_room_category = room_category.id_room_category
	WHERE room.id_hotel IN (
		SELECT id_hotel FROM hotel
		WHERE name = '������'
	) AND room_in_booking.checkin_date <= '2019-03-23' AND room_in_booking.checkout_date > '2019-03-23'
	GROUP BY room_category.name;

--5. ���� ������ ��������� ����������� �������� �� ���� �������� ��������� �������, ��������� � ������ � ��������� ���� ������.
	SELECT last_room_booking.id_room, client.name, client.phone, last_room_booking.last_checkout FROM client
	INNER JOIN booking ON booking.id_client = client.id_client
	INNER JOIN room_in_booking ON room_in_booking.id_booking = booking.id_booking
	INNER JOIN (SELECT room_in_booking_april.id_room, MAX(room_in_booking_april.checkout_date) AS last_checkout
		FROM (SELECT * FROM room_in_booking
			WHERE checkout_date >= '2019-04-01' AND checkout_date <= '2019-04-30') AS room_in_booking_april
		GROUP BY room_in_booking_april.id_room) AS last_room_booking ON last_room_booking.id_room = room_in_booking.id_room
	INNER JOIN room ON room_in_booking.id_room = room.id_room
	INNER JOIN (SELECT * FROM hotel WHERE hotel.name = '������') AS hotel ON hotel.id_hotel = room.id_hotel
	WHERE (room_in_booking.id_room = last_room_booking.id_room AND last_room_booking.last_checkout = room_in_booking.checkout_date)
	ORDER BY room.id_room;
	
--6. �������� �� 2 ��� ���� ���������� � ��������� ������� ���� �������� ������ ��������� �������, ������� ���������� 10 ���.
	UPDATE room_in_booking
	SET checkout_date = DATEADD(day, 2, checkout_date)
	FROM room
	INNER JOIN hotel ON hotel.id_hotel = room.id_hotel
	INNER JOIN room_category ON room_category.id_room_category = room.id_room_category
	WHERE hotel.name = '������' AND room_category.name = '������' AND room_in_booking.checkin_date = '2019-05-10';

--7. ����� ��� "��������������" �������� ����������. ���������� ���������: �� ����� ���� ������������ ���� ����� �� ���� ���� ��������� ���, 
--�.�. ������ ���������� ���������� �������� � ���� �����. ������ � ������� room_in_booking � id_room_in_booking = 5 � 2154 �������� ��������
--������������� ���������, ������� ���������� �����. �������������� ������ ������� ������ ��������� ���������� � ���� ������������� �������.
	SELECT * FROM room_in_booking AS rib1
	INNER JOIN room_in_booking AS rib2 ON rib1.id_room_in_booking != rib2.id_room_in_booking
		WHERE rib1.id_room = rib2.id_room
		AND rib1.checkin_date >= rib2.checkin_date
		AND rib1.checkin_date < rib2.checkout_date
	ORDER BY rib1.id_room_in_booking;

--8. ������� ������������ � ����������.
	BEGIN TRANSACTION
		INSERT INTO client
		VALUES ('������� ������ ��������', '7(800)555-35-35')

		INSERT INTO booking
		VALUES (SCOPE_IDENTITY(), '2020-06-07')

		INSERT INTO room_in_booking
		VALUES (SCOPE_IDENTITY(), 169, '2020-08-01', '2020-08-10')
	COMMIT;

--9. �������� ����������� ������� ��� ���� ������.

--booking
	CREATE NONCLUSTERED INDEX [IX_booking_id_client] ON dbo.booking
	(
		id_client ASC
	)

--room_in_booking
	CREATE NONCLUSTERED INDEX [IX_room_in_booking_checkin_date-checkout_date] ON dbo.room_in_booking
	(
		checkin_date ASC,
		checkout_date ASC
	)

	CREATE NONCLUSTERED INDEX [IX_room_in_booking_id_room] ON dbo.room_in_booking
	(
		id_room ASC
	)

	CREATE NONCLUSTERED INDEX [IX_room_in_booking_id_booking] ON dbo.room_in_booking
	(
		id_booking ASC
	)

--room
	CREATE NONCLUSTERED INDEX [IX_room_id_room_category] ON dbo.room
	(
		id_room_category ASC
	)

	CREATE NONCLUSTERED INDEX [IX_room_id_hotel] ON dbo.room
	(
		id_hotel ASC
	)

--hotel
	CREATE NONCLUSTERED INDEX [IX_hotel_name] ON dbo.hotel
	(
		name ASC
	)

--room_category
	CREATE NONCLUSTERED INDEX [IX_room_category_name] ON dbo.room_category
	(
		name ASC
	)