--1. Добавить внешние ключи.
ALTER TABLE student
	ADD CONSTRAINT FK_student_id_group FOREIGN KEY (id_group)
		REFERENCES [group] (id_group)
		ON DELETE CASCADE
		ON UPDATE CASCADE

ALTER TABLE mark
	ADD CONSTRAINT FK_mark_id_student FOREIGN KEY (id_student)
		REFERENCES student (id_student)
		ON DELETE CASCADE
		ON UPDATE CASCADE

ALTER TABLE mark
	ADD CONSTRAINT FK_mark_id_lesson FOREIGN KEY (id_lesson)
		REFERENCES lesson (id_lesson)
		ON DELETE CASCADE
		ON UPDATE CASCADE

ALTER TABLE lesson
	ADD CONSTRAINT FK_lesson_id_group FOREIGN KEY (id_group)
		REFERENCES [group] (id_group)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION

ALTER TABLE lesson
	ADD CONSTRAINT FK_lesson_id_subject FOREIGN KEY (id_subject)
		REFERENCES subject (id_subject)
		ON DELETE CASCADE
		ON UPDATE CASCADE

ALTER TABLE lesson
	ADD CONSTRAINT FK_lesson_id_teacher FOREIGN KEY (id_teacher)
		REFERENCES teacher (id_teacher)
		ON DELETE CASCADE
		ON UPDATE CASCADE
GO

--2. Выдать оценки студентов по информатике если они обучаются данному предмету. Оформить выдачу данных с использованием view.
CREATE VIEW student_infromatics_mark AS
SELECT student.name, mark.mark FROM student
LEFT JOIN mark ON mark.id_student = student.id_student
WHERE mark.id_lesson IN (
	SELECT id_lesson FROM lesson
	WHERE id_subject = (
		SELECT id_subject FROM subject
		WHERE name = 'Информатика'
	)
)
GO

SELECT * FROM student_infromatics_mark
GO

--3. Дать информацию о должниках с указанием фамилии студента и названия предмета. Должниками считаются студенты,
-- не имеющие оценки по предмету, который ведется в группе. Оформить в виде процедуры, на входе идентификатор группы.
CREATE PROCEDURE no_mark_student
	@id_group AS INT
AS
	WITH group_subjects (id_subject, subject_name)
	AS
	(
		SELECT lesson.id_subject, subject.name FROM lesson
		LEFT JOIN subject ON subject.id_subject = lesson.id_subject
		WHERE lesson.id_group = @id_group
		GROUP BY lesson.id_subject, subject.name
	)
	SELECT student.name, group_subjects.subject_name FROM student
	LEFT JOIN group_subjects ON student.id_group = @id_group
	LEFT JOIN mark ON mark.id_student = student.id_student
	WHERE student.id_group = @id_group AND mark IS NULL
	GROUP BY student.name, group_subjects.subject_name
GO

EXECUTE no_mark_student @id_group = 1;
EXECUTE no_mark_student @id_group = 2;
EXECUTE no_mark_student @id_group = 3;
EXECUTE no_mark_student @id_group = 4;

--4. Дать среднюю оценку студентов по каждому предмету для тех предметов, по которым занимается не менее 35 студентов.
SELECT subject.id_subject, subject.name AS subject_name, AVG(mark.mark) AS average_mark FROM mark
LEFT JOIN student ON student.id_student = mark.id_student
LEFT JOIN lesson ON lesson.id_lesson = mark.id_lesson
LEFT JOIN subject ON subject.id_subject = lesson.id_subject
GROUP BY subject.id_subject, subject.name
HAVING COUNT(DISTINCT student.id_student) >= 35

--5. Дать оценки студентов специальности ВМ по всем проводимым предметам с указанием группы, фамилии, предмета, даты.
--При отсутствии оценки заполнить значениями NULL поля оценки.
SELECT [group].name AS group_name, student.name AS student_name, subject.name AS subject_name, lesson.date, mark.mark FROM student
LEFT JOIN [group] ON [group].id_group = student.id_group
LEFT JOIN mark ON mark.id_student = student.id_student
LEFT JOIN lesson ON lesson.id_lesson = mark.id_lesson
LEFT JOIN subject ON subject.id_subject = lesson.id_subject
WHERE student.id_group = (
	SELECT id_group FROM [group]
	WHERE name = 'ВМ'
);

--6. Всем студентам специальности ПС, получившим оценки меньшие 5 по предмету БД до 12.05, повысить эти оценки на 1 балл.
UPDATE mark
SET mark = mark + 1
WHERE id_lesson IN (
	SELECT id_lesson FROM lesson
	WHERE id_group = (
		SELECT id_group FROM [group]
		WHERE name = 'ПС'
	) AND id_subject IN (
		SELECT id_subject FROM subject
		WHERE name = 'БД'
	) AND date < '2019-05-12'
) AND mark < 5

--7. Добавить необходимые индексы.

--Используется в п. 6
CREATE NONCLUSTERED INDEX [IX_mark_id_lesson] ON dbo.mark
(
	id_lesson ASC
)
INCLUDE (mark)

-- Используется в п.3, 4, 5
CREATE NONCLUSTERED INDEX [IX_student_id_group] ON dbo.student
(
	id_group ASC
)
INCLUDE ([name])

-- Используется в п.2, 4, 6
CREATE NONCLUSTERED INDEX [IX_lesson_id_subject] ON dbo.lesson
(
	id_subject ASC
)