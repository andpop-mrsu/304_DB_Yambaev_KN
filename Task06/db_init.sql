DROP TABLE IF EXISTS WorkRecord;
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS Service;
DROP TABLE IF EXISTS CarCategory;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Box;

CREATE TABLE CarCategory (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);


CREATE TABLE Box (
    box_id INTEGER PRIMARY KEY AUTOINCREMENT,
    number INTEGER NOT NULL UNIQUE CHECK (number > 0)
);

CREATE TABLE Employee (
    employee_id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    hire_date DATE NOT NULL DEFAULT (date('now')),
    dismissal_date DATE,  -- NULL = работает
    commission_percent REAL NOT NULL CHECK (commission_percent BETWEEN 0 AND 100)
);

CREATE TABLE Service (
    service_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    base_price REAL NOT NULL CHECK (base_price >= 0),
    category_id INTEGER NOT NULL,
    FOREIGN KEY (category_id) REFERENCES CarCategory(category_id) ON DELETE RESTRICT
);

CREATE TABLE Booking (
    booking_id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL,
    box_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    car_plate TEXT NOT NULL,
    booking_time DATETIME NOT NULL,
    status TEXT NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'completed', 'cancelled')),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id) ON DELETE RESTRICT,
    FOREIGN KEY (box_id) REFERENCES Box(box_id) ON DELETE RESTRICT,
    FOREIGN KEY (service_id) REFERENCES Service(service_id) ON DELETE RESTRICT,
    UNIQUE (box_id, booking_time)
);

CREATE TABLE WorkRecord (
    work_id INTEGER PRIMARY KEY AUTOINCREMENT,
    booking_id INTEGER,  -- может быть NULL (если работа без записи)
    employee_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    box_id INTEGER NOT NULL,
    car_plate TEXT NOT NULL,
    work_start DATETIME NOT
    NULL,
    work_end DATETIME NOT NULL,
    actual_price REAL NOT NULL CHECK (actual_price >= 0),
    is_paid BOOLEAN NOT NULL DEFAULT 1,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE SET NULL,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id) ON DELETE RESTRICT,
    FOREIGN KEY (service_id) REFERENCES Service(service_id) ON DELETE RESTRICT,
    FOREIGN KEY (box_id) REFERENCES Box(box_id) ON DELETE RESTRICT,
    CHECK (work_end > work_start)
);


INSERT INTO CarCategory (name) VALUES
('Седан'), ('Хэтчбек'), ('Внедорожник'), ('Микроавтобус');

INSERT INTO Box (number) VALUES (1), (2), (3);

INSERT INTO Employee (full_name, hire_date, commission_percent) VALUES
('Иванов И.И.', '2023-01-15', 15.0),
('Петров П.П.', '2023-03-01', 20.0);

INSERT INTO Employee (full_name, hire_date, dismissal_date, commission_percent) VALUES
('Сидоров С.С.', '2022-06-10', '2024-10-01', 10.0);

INSERT INTO Service (name, duration_minutes, base_price, category_id) VALUES
('Мойка кузова', 30, 500.0, 1),
('Мойка кузова', 35, 600.0, 3),
('Химчистка салона', 60, 1200.0, 1),
('Полировка', 90, 2000.0, 2);

INSERT INTO Booking (employee_id, box_id, service_id, car_plate, booking_time, status) VALUES
(1, 1, 1, 'А123ВС77', '2025-11-30 10:00:00', 'completed'),
(2, 2, 3, 'Б456ДЕ99', '2025-11-30 11:00:00', 'planned');

INSERT INTO WorkRecord (booking_id, employee_id, service_id, box_id, car_plate, work_start, work_end, actual_price, is_paid) VALUES
(1, 1, 1, 1, 'А123ВС77', '2025-11-30 10:00:00', '2025-11-30 10:30:00', 500.0, 1),
(NULL, 2, 2, 2, 'К789ЛМ777', '2025-11-29 14:00:00', '2025-11-29 14:35:00', 600.0, 1);