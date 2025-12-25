<?php

try {
    $pdo = new PDO('sqlite:clinic.db');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Ошибка подключения: " . $e->getMessage());
}

// Получаем всех врачей
$stmt = $pdo->query("SELECT employee_id, full_name FROM Employee ORDER BY full_name");
$doctors = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (empty($doctors)) {
    die("В базе нет врачей.\n");
}

echo "\nСписок врачей:\n";
foreach ($doctors as $doc) {
    printf("%d — %s\n", $doc['employee_id'], $doc['full_name']);
}

echo "\nВведите ID врача или нажмите Enter для всех: ";
$handle = fopen("php://stdin", "r");
$input = trim(fgets($handle));
fclose($handle);

$selectedId = null;
if ($input !== '') {
    if (!is_numeric($input)) {
        die("\nОшибка: введите число!\n");
    }
    $selectedId = (int)$input;
    $ids = array_column($doctors, 'employee_id');
    if (!in_array($selectedId, $ids)) {
        die("\nОшибка: врач с ID $selectedId не найден!\n");
    }
}

// Запрос данных
$sql = "
    SELECT
        e.employee_id,
        e.full_name,
        w.work_start,
        s.name AS service_name,
        w.actual_price
    FROM WorkRecord w
    JOIN Employee e ON w.employee_id = e.employee_id
    JOIN Service s ON w.service_id = s.service_id
";

$params = [];
if ($selectedId !== null) {
    $sql .= " WHERE w.employee_id = :employee_id";
    $params[':employee_id'] = $selectedId;
}

$sql .= " ORDER BY e.full_name, w.work_start";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$records = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (empty($records)) {
    echo "\nНет записей.\n";
    exit;
}

// Псевдографика
echo "\n" . str_repeat("─", 110) . "\n";
printf("| %-8s | %-25s | %-20s | %-30s | %-10s |\n",
    'ID врача', 'ФИО', 'Дата работы', 'Услуга', 'Стоимость'
);
echo "|" . str_repeat("─", 110) . "|\n";

foreach ($records as $r) {
    printf("| %-8d | %-25s | %-20s | %-30s | %-10.2f |\n",
        $r['employee_id'],
        substr($r['full_name'], 0, 25),
        date('Y-m-d H:i', strtotime($r['work_start'])),
        substr($r['service_name'], 0, 30),
        $r['actual_price']
    );
}
echo "|" . str_repeat("─", 110) . "|\n";