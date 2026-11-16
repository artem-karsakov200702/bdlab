-- a) ЧИСЛОВЫЕ УСЛОВИЯ
-- 1. Начисления, где сотрудник отработал больше 35 часов
SELECT *
FROM "Nachislenie"
WHERE "Количество_часов" > 35;

-- 2. Начисления, где сотрудник отработал меньше 40 часов
SELECT *
FROM "Nachislenie"
WHERE "Количество_часов" < 40;

-- 3. Начисления, где сотрудник отработал ровно 40 часов
SELECT *
FROM "Nachislenie"
WHERE "Количество_часов" = 40;

-- 4. Начисления, где сотрудник отработал от 30 до 50 часов
SELECT *
FROM "Nachislenie"
WHERE "Количество_часов" BETWEEN 30 AND 50;



-- b) ТЕКСТОВЫЕ УСЛОВИЯ
-- 1. Сотрудники, фамилия которых начинается на «Иван»
SELECT *
FROM "Sotrudnik"
WHERE "ФИО" LIKE 'Иван%';

-- 2. Сотрудники с выбранными должностями
SELECT
    s."ФИО",
    d."Наименование"
FROM "Sotrudnik" s
JOIN "Dolzhnost" d
    ON s."id_должности" = d."id_должности"
WHERE d."Наименование" IN (
    'Бухгалтер',
    'Экономист',
    'Менеджер'
);



-- c) ВЫЧИСЛЯЕМОЕ ПОЛЕ
-- Расчёт средней ставки за час для каждого вида ставки
SELECT
    "id_ставки",
    "Нижняя_граница",
    "Верхняя_граница",
    ("Нижняя_граница" + "Верхняя_граница") / 2.0
        AS "Средняя_ставка"
FROM "StavkaZaChas";



-- d) ЗАПРОС К НЕСКОЛЬКИМ ТАБЛИЦАМ БЕЗ JOIN
-- Вывод сотрудников и названий их должностей
SELECT
    s."ФИО",
    d."Наименование"
FROM "Sotrudnik" s, "Dolzhnost" d
WHERE s."id_должности" = d."id_должности";



-- e) АГРЕГИРУЮЩИЕ ФУНКЦИИ
-- Статистика по количеству отработанных часов
SELECT
    AVG("Количество_часов") AS "Среднее_количество_часов",
    SUM("Количество_часов") AS "Всего_часов",
    COUNT(*) AS "Количество_начислений",
    MIN("Количество_часов") AS "Минимум_часов",
    MAX("Количество_часов") AS "Максимум_часов"
FROM "Nachislenie";



-- f) ГРУППИРОВКА GROUP BY
-- Количество начислений и часов по каждому сотруднику
SELECT
    s."ФИО",
    COUNT(n."id_начисления") AS "Количество_начислений",
    SUM(n."Количество_часов") AS "Всего_часов"
FROM "Sotrudnik" s
JOIN "Nachislenie" n
    ON s."id_сотрудника" = n."id_сотрудника"
GROUP BY
    s."id_сотрудника",
    s."ФИО";



-- g) СОРТИРОВКА ORDER BY
-- Сотрудники от самого давно работающего к недавно принятому
SELECT
    "ФИО",
    "Дата_устройства"
FROM "Sotrudnik"
ORDER BY "Дата_устройства" ASC;


-- h) ВЛОЖЕННЫЕ ПОДЗАПРОСЫ
-- 1. Скалярный подзапрос:
-- Начисления, в которых часов больше среднего значения
SELECT *
FROM "Nachislenie"
WHERE "Количество_часов" > (
    SELECT AVG("Количество_часов")
    FROM "Nachislenie"
);

-- 2. Подзапрос с IN:
-- Сотрудники, у которых были начисления в апреле 2023 года
SELECT *
FROM "Sotrudnik"
WHERE "id_сотрудника" IN (
    SELECT "id_сотрудника"
    FROM "Nachislenie"
    WHERE "Дата_начисления" >= DATE '2023-04-01'
      AND "Дата_начисления" < DATE '2023-05-01'
);

-- 3. Коррелированный подзапрос с EXISTS:
-- Сотрудники, у которых есть начисления с налогом выше среднего
SELECT s."ФИО"
FROM "Sotrudnik" s
WHERE EXISTS (
    SELECT 1
    FROM "Nachislenie" n
    WHERE n."id_сотрудника" = s."id_сотрудника"
      AND n."Налог" > (
          SELECT AVG("Налог")
          FROM "Nachislenie"
      )
);



-- i) UNION
-- Объединение сотрудников с должностями
-- «Бухгалтер» и «Экономист»
SELECT
    s."ФИО",
    d."Наименование"
FROM "Sotrudnik" s
JOIN "Dolzhnost" d
    ON s."id_должности" = d."id_должности"
WHERE d."Наименование" = 'Бухгалтер'

UNION

SELECT
    s."ФИО",
    d."Наименование"
FROM "Sotrudnik" s
JOIN "Dolzhnost" d
    ON s."id_должности" = d."id_должности"
WHERE d."Наименование" = 'Экономист';


-- j) INTERSECT
-- Сотрудники с должностями из первой шестёрки,
-- у которых также есть начисления
SELECT "id_сотрудника"
FROM "Sotrudnik"
WHERE "id_должности" BETWEEN 1 AND 6

INTERSECT

SELECT "id_сотрудника"
FROM "Nachislenie";


-- k) EXCEPT
-- Сотрудники, у которых не было начислений в апреле 2023 года
SELECT "id_сотрудника"
FROM "Sotrudnik"

EXCEPT

SELECT "id_сотрудника"
FROM "Nachislenie"
WHERE "Дата_начисления" >= DATE '2023-04-01'
  AND "Дата_начисления" < DATE '2023-05-01';


-- l) ВЫРАЖЕНИЕ CASE
-- Категории начислений по количеству отработанных часов
SELECT
    "id_начисления",
    "Количество_часов",
    CASE
        WHEN "Количество_часов" < 30
            THEN 'Мало часов'
        WHEN "Количество_часов" <= 40
            THEN 'Среднее количество'
        ELSE 'Много часов'
    END AS "Категория"
FROM "Nachislenie";



-- m) ПЯТЬ ВИДОВ JOIN
-- 1. INNER JOIN
-- Сотрудники и существующие должности
SELECT
    s."ФИО",
    d."Наименование"
FROM "Sotrudnik" s
INNER JOIN "Dolzhnost" d
    ON s."id_должности" = d."id_должности";

-- 2. LEFT JOIN
-- Все сотрудники и их должности
SELECT
    s."ФИО",
    d."Наименование"
FROM "Sotrudnik" s
LEFT JOIN "Dolzhnost" d
    ON s."id_должности" = d."id_должности";

-- 3. RIGHT JOIN
-- Все должности и сотрудники, занимающие их
SELECT
    s."ФИО",
    d."Наименование"
FROM "Sotrudnik" s
RIGHT JOIN "Dolzhnost" d
    ON s."id_должности" = d."id_должности";

-- 4. FULL JOIN
-- Все сотрудники и все должности
SELECT
    s."ФИО",
    d."Наименование"
FROM "Sotrudnik" s
FULL JOIN "Dolzhnost" d
    ON s."id_должности" = d."id_должности";

-- 5. CROSS JOIN
-- Все возможные сочетания должностей и видов льгот
SELECT
    d."Наименование",
    t."Название" AS "Вид_льготы"
FROM "Dolzhnost" d
CROSS JOIN "TipOsvobozhdenia" t;



-- n) ИЕРАРХИЧЕСКИЙ ЗАПРОС
-- Добавляем столбец для хранения ID руководителя
ALTER TABLE "Sotrudnik"
ADD COLUMN IF NOT EXISTS "id_руководителя" INTEGER;

-- Создаём внешний ключ на таблицу сотрудников
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_sotrudnik_rukovoditel'
          AND conrelid = '"Sotrudnik"'::regclass
    ) THEN
        ALTER TABLE "Sotrudnik"
        ADD CONSTRAINT fk_sotrudnik_rukovoditel
        FOREIGN KEY ("id_руководителя")
        REFERENCES "Sotrudnik" ("id_сотрудника");
    END IF;
END $$;

-- Построение иерархии сотрудников по руководителям
WITH RECURSIVE "Ierarhiya" AS (

    -- Начальный уровень: сотрудники без руководителя
    SELECT
        "id_сотрудника",
        "ФИО",
        "id_руководителя",
        1 AS "Уровень",
        ARRAY["id_сотрудника"] AS "Путь"
    FROM "Sotrudnik"
    WHERE "id_руководителя" IS NULL

    UNION ALL

    -- Следующие уровни: подчинённые найденных сотрудников
    SELECT
        s."id_сотрудника",
        s."ФИО",
        s."id_руководителя",
        i."Уровень" + 1,
        i."Путь" || s."id_сотрудника"
    FROM "Sotrudnik" s
    JOIN "Ierarhiya" i
        ON s."id_руководителя" = i."id_сотрудника"
    WHERE NOT s."id_сотрудника" = ANY(i."Путь")
)
SELECT
    "id_сотрудника",
    "ФИО",
    "id_руководителя",
    "Уровень"
FROM "Ierarhiya"
ORDER BY "Уровень", "id_сотрудника";


-- ЧАСТЬ 2. ИНДИВИДУАЛЬНОЕ ЗАДАНИЕ
-- Удаляем старые представления в правильном порядке
DROP VIEW IF EXISTS "v4_ZarabotokVysheSrednego";
DROP VIEW IF EXISTS "v4_NalogPoMesyacam";
DROP VIEW IF EXISTS "v4_Samyj_Staryj_Sotrudnik";
DROP VIEW IF EXISTS "v4_ZarabotokSotrudnikov";
DROP VIEW IF EXISTS "v4_VyplatyPoVidamRaboty";
DROP VIEW IF EXISTS "v4_RaschetOplaty";



-- 1. РАСЧЁТ ОПЛАТЫ ЗА ВЫПОЛНЕННУЮ РАБОТУ
-- Вспомогательное представление для расчёта оплаты
CREATE VIEW "v4_RaschetOplaty" AS
SELECT
    n."id_начисления",
    n."Дата_начисления",
    n."id_вид_работы",
    w."Описание" AS "Вид_работы",
    s."id_сотрудника",
    s."ФИО",
    n."Количество_часов",

    r."Ставка_за_час",

    ROUND(
        (n."Количество_часов" * r."Ставка_за_час")::NUMERIC,
        2
    ) AS "Сумма_выплаты",

    n."Налог" AS "Сумма_налога"

FROM "Nachislenie" n

JOIN "Sotrudnik" s
    ON n."id_сотрудника" = s."id_сотрудника"

JOIN "WorkType" w
    ON n."id_вид_работы" = w."id_вид_работы"

JOIN "StavkaZaChas" st
    ON w."id_ставки" = st."id_ставки"

CROSS JOIN LATERAL (
    SELECT
        CASE
            -- Стаж меньше одного года
            WHEN s."Дата_устройства" >
                 n."Дата_начисления" - INTERVAL '1 year'
            THEN st."Нижняя_граница"

            -- Стаж от одного года до пяти лет
            WHEN s."Дата_устройства" >=
                 n."Дата_начисления" - INTERVAL '5 years'
            THEN (
                st."Нижняя_граница" +
                st."Верхняя_граница"
            ) / 2.0

            -- Стаж более пяти лет
            ELSE st."Верхняя_граница"
        END AS "Ставка_за_час"
) r;



-- 2. ВЫПЛАТЫ ПО ВИДАМ РАБОТ ЗА КАЖДЫЙ МЕСЯЦ
CREATE VIEW "v4_VyplatyPoVidamRaboty" AS
SELECT
    DATE_TRUNC('month', "Дата_начисления")::DATE AS "Месяц",
    "id_вид_работы",
    "Вид_работы",
    SUM("Количество_часов") AS "Всего_часов",
    SUM("Сумма_выплаты") AS "Общая_сумма_выплат"
FROM "v4_RaschetOplaty"
GROUP BY
    DATE_TRUNC('month', "Дата_начисления")::DATE,
    "id_вид_работы",
    "Вид_работы";



-- 3. ЕЖЕМЕСЯЧНЫЙ ЗАРАБОТОК КАЖДОГО СОТРУДНИКА
CREATE VIEW "v4_ZarabotokSotrudnikov" AS
SELECT
    DATE_TRUNC('month', "Дата_начисления")::DATE AS "Месяц",
    "id_сотрудника",
    "ФИО",
    SUM("Сумма_выплаты") AS "Ежемесячный_заработок"
FROM "v4_RaschetOplaty"
GROUP BY
    DATE_TRUNC('month', "Дата_начисления")::DATE,
    "id_сотрудника",
    "ФИО";



-- 4. СОТРУДНИК С НАИБОЛЬШИМ СТАЖЕМ
CREATE VIEW "v4_Samyj_Staryj_Sotrudnik" AS
SELECT
    "id_сотрудника",
    "ФИО",
    "Дата_устройства",
    AGE(CURRENT_DATE, "Дата_устройства") AS "Стаж_работы"
FROM "Sotrudnik"
WHERE "Дата_устройства" = (
    SELECT MIN("Дата_устройства")
    FROM "Sotrudnik"
);



-- 5. СУММА НАЛОГА ПО КАЖДОМУ МЕСЯЦУ
CREATE VIEW "v4_NalogPoMesyacam" AS
SELECT
    DATE_TRUNC('month', "Дата_начисления")::DATE AS "Месяц",
    SUM("Налог") AS "Общая_сумма_налога"
FROM "Nachislenie"
GROUP BY
    DATE_TRUNC('month', "Дата_начисления")::DATE;



-- 6. СОТРУДНИКИ С ЗАРАБОТКОМ ВЫШЕ СРЕДНЕГО
CREATE VIEW "v4_ZarabotokVysheSrednego" AS
WITH "Zarabotok" AS (

    -- Ежемесячный заработок сотрудников
    SELECT
        "Месяц",
        "id_сотрудника",
        "ФИО",
        "Ежемесячный_заработок"
    FROM "v4_ZarabotokSotrudnikov"
),

"Srednee" AS (

    -- Средний заработок за каждый месяц
    SELECT
        *,
        AVG("Ежемесячный_заработок")
            OVER (PARTITION BY "Месяц")
            AS "Средний_заработок"
    FROM "Zarabotok"
)

-- Сотрудники с заработком выше среднего
SELECT
    "Месяц",
    "id_сотрудника",
    "ФИО",
    "Ежемесячный_заработок",
    "Средний_заработок"
FROM "Srednee"
WHERE "Ежемесячный_заработок" > "Средний_заработок";



-- ЧАСТЬ 3. ПРОВЕРКА СОЗДАННЫХ ПРЕДСТАВЛЕНИЙ
-- 1. Выплаты по каждому виду работ за каждый месяц
SELECT *
FROM "v4_VyplatyPoVidamRaboty"
ORDER BY "Месяц", "id_вид_работы";


-- 2. Ежемесячный заработок сотрудников
SELECT *
FROM "v4_ZarabotokSotrudnikov"
ORDER BY "Месяц", "ФИО";


-- 3. Сотрудник с наибольшим стажем
SELECT *
FROM "v4_Samyj_Staryj_Sotrudnik";


-- 4. Сумма налога по месяцам
SELECT *
FROM "v4_NalogPoMesyacam"
ORDER BY "Месяц";


-- 5. Сотрудники с заработком выше среднего
SELECT *
FROM "v4_ZarabotokVysheSrednego"
ORDER BY "Месяц", "Ежемесячный_заработок" DESC;
