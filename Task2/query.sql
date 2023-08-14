-- Создаю таблицу для хранения временных данных (SubId, SubLevel).
DECLARE @T TABLE (SubId INT, SubLevel INT)
-- Создаю переменную для хранения текущей вложенности.
DECLARE @SubLevel INT

-- Инициализирую переменную текущего уровня вложенности (начальный уровень вложенности 1).
SET @SubLevel = 1
-- Добавляю идентификаторы первого уровня вложенности, в котором находится "Сотрудник 1".
INSERT INTO @T
	(SubId, SubLevel)
SELECT 
	s.Id
	,@SubLevel
FROM [subdivisions] s
WHERE s.parent_id = (
	SELECT c.subdivision_id
	FROM [collaborators] c
	WHERE
		c.Id = 710253
		AND
		c.name = 'Сотрудник 1'
)
-- Создаю переменную текущего идентификатора подразделения.
DECLARE @SubId INT

-- Создаю курсор по временной таблице.
DECLARE tCursor CURSOR LOCAL FOR
SELECT SubId, SubLevel
FROM @T

-- Добавляю во временную таблицу все дочерние элементы текущего элемента.
OPEN tCursor
FETCH tCursor INTO @SubId, @SubLevel
WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO @T
	(SubId, SubLevel)
	SELECT 
		s.Id
		,@SubLevel + 1
	FROM [subdivisions] s
	WHERE s.parent_id = @SubId

	FETCH NEXT FROM tCursor INTO @SubId, @SubLevel
END

CLOSE tCursor
DEALLOCATE tCursor

-- Получаю результат.
SELECT
	s.id AS 'id'
	, c.name AS 'name'
	, s.name AS 'sub_name'
	, c.id AS 'sub_id'
	, t.SubLevel AS 'sub_level'
	, (SELECT COUNT(*) FROM [collaborators] WHERE subdivision_id = c.subdivision_id) AS 'colls_count'
	FROM collaborators c WITH (NOLOCK)
	JOIN subdivisions s WITH (NOLOCK)
		ON c.subdivision_id = s.id
	JOIN @T t
		ON t.SubId = c.subdivision_id
	WHERE 
		age < 40
		AND LEN(s.name) > 11
		AND subdivision_id NOT IN (100055, 100059)
	ORDER BY sub_level ASC