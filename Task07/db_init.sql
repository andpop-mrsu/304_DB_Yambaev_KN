-- Удаляем старые таблицы (если существуют)
DROP TABLE IF EXISTS WorkRecord;
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS Service;
DROP TABLE IF EXISTS ServiceCategory;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS DentalBox;

-- 1. Категории услуг
CREATE TABLE ServiceCategory (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

-- 2. Стоматологические кабинеты
CREATE TABLE DentalBox (
    box_id INTEGER PRIMARY KEY AUTOINCREMENT,
    number INTEGER NOT NULL UNIQUE CHECK (number > 0)
);

-- 3. Врачи (сотрудники)
CREATE TABLE Employee (
    employee_id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    hire_date DATE NOT NULL DEFAULT (date('now')),
    dismissal_date DATE,  -- NULL = работает
    commission_percent REAL NOT NULL CHECK (commission_percent BETWEEN 0 AND 100),
    specialization TEXT NOT NULL
);

-- 4. Услуги
CREATE TABLE Service (
    service_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    base_price REAL NOT NULL CHECK (base_price >= 0),
    category_id INTEGER NOT NULL,
    FOREIGN KEY (category_id) REFERENCES ServiceCategory(category_id) ON DELETE RESTRICT
);

-- 5. Предварительная запись (опционально для задачи, но по ТЗ есть)
CREATE TABLE Booking (
    booking_id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL,
    box_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    patient_name TEXT NOT NULL,
    booking_time DATETIME NOT NULL,
    status TEXT NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'completed', 'cancelled')),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
    FOREIGN KEY (box_id) REFERENCES DentalBox(box_id),
    FOREIGN KEY (service_id) REFERENCES Service(service_id),
    UNIQUE (box_id, booking_time)
);

-- 6. Фактически выполненные работы (основная таблица для отчётов)
CREATE TABLE WorkRecord (
    work_id INTEGER PRIMARY KEY AUTOINCREMENT,
    booking_id INTEGER,  -- может быть NULL
    employee_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    box_id INTEGER NOT NULL,
    patient_name TEXT NOT NULL,
    work_start DATETIME NOT NULL,
    work_end DATETIME NOT NULL,
    actual_price REAL NOT NULL CHECK (actual_price >= 0),
    is_paid BOOLEAN NOT NULL DEFAULT 1,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE SET NULL,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
    FOREIGN KEY (service_id) REFERENCES Service(service_id),
    FOREIGN KEY (box_id) REFERENCES DentalBox(box_id),
    CHECK (work_end > work_start)
);

-- === ЗАПОЛНЕНИЕ ДАННЫМИ ===

-- Категории услуг
INSERT INTO ServiceCategory (name) VALUES
('Терапевтическая стоматология'),
('Хирургическая стоматология'),
('Ортопедическая стоматология'),
('Ортодонтия');

-- Кабинеты
INSERT INTO DentalBox (number) VALUES (1), (2), (3);

-- Врачи (включая уволенного)
INSERT INTO Employee (full_name, specialization, hire_date, commission_percent) VALUES
('Иванова А.Б.', 'терапевт', '2023-01-15', 15.0),
('Петров С.В.', 'хирург', '2023-03-01', 20.0);

INSERT INTO Employee (full_name, specialization, hire_date, dismissal_date, commission_percent) VALUES
('Сидоров К.Л.', 'ортодонт', '2022-06-10', '2024-10-01', 10.0);

-- Услуги
INSERT INTO Service (name, duration_minutes, base_price, category_id) VALUES
('Лечение кариеса', 45, 3500.0, 1),
('Удаление зуба', 30, 2500.0, 2),
('Установка коронки', 60, 12000.0, 3),
('Консультация ортодонта', 30, 1500.0, 4),
('Отбеливание зубов', 90, 8000.0, 1);

-- Выполненные работы (основные данные для лабораторной)
INSERT INTO WorkRecord (employee_id, service_id, box_id, patient_name, work_start, work_end, actual_price, is_paid) VALUES
(1, 1, 1, 'Иванов Иван', '2025-12-01 10:00:00', '2025-12-01 10:45:00', 3500.0, 1),
(2, 2, 2, 'Петрова Мария', '2025-12-01 11:00:00', '2025-12-01 11:30:00', 2500.0, 1),
(1, 5, 1, 'Сидорова Анна', '2025-11-30 14:00:00', '2025-11-30 15:30:00', 8000.0, 1),
(3, 4, 3, 'Кузнецов Дмитрий', '2024-09-15 09:00:00', '2024-09-15 09:30:00', 1500.0, 1),
(2, 2, 2, 'Васильева Елена', '2025-11-29 15:00:00', '2025-11-29 15:30:00', 2500.0, 1);