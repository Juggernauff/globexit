-- ������ ������� ��� �������� ��������� ������ (SubId, SubLevel).
DECLARE @T TABLE (SubId INT, SubLevel INT)
-- ������ ���������� ��� �������� ������� �����������.
DECLARE @SubLevel INT

-- ������������� ���������� �������� ������ ����������� (��������� ������� ����������� 1).
SET @SubLevel = 1
-- �������� �������������� ������� ������ �����������, � ������� ��������� "��������� 1".
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
		c.name = '��������� 1'
)
-- ������ ���������� �������� �������������� �������������.
DECLARE @SubId INT

-- ������ ������ �� ��������� �������.
DECLARE tCursor CURSOR LOCAL FOR
SELECT SubId, SubLevel
FROM @T

-- �������� �� ��������� ������� ��� �������� �������� �������� ��������.
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

-- ������� ���������.
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