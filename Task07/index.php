<?php
// index.php

try {
    $pdo = new PDO('sqlite:clinic.db');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Ошибка подключения: " . $e->getMessage());
}

// Все врачи
$doctors = $pdo->query("SELECT employee_id, full_name FROM Employee ORDER BY full_name")->fetchAll();

$selectedId = $_GET['employee_id'] ?? null;
if ($selectedId !== null && !ctype_digit($selectedId)) {
    $selectedId = null;
}

// Услуги
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
if ($selectedId) {
    $sql .= " WHERE w.employee_id = :employee_id";
    $params[':employee_id'] = (int)$selectedId;
}
$sql .= " ORDER BY e.full_name, w.work_start";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$services = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Услуги стоматологической клиники</title>
    <style>
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #000; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        select, button { padding: 5px 10px; margin: 10px 0; }
    </style>
</head>
<body>
    <h1>Оказанные услуги</h1>

    <form method="GET">
        <label for="employee_id">Выберите врача:</label>
        <select name="employee_id" id="employee_id">
            <option value="">— Все врачи —</option>
            <?php foreach ($doctors as $doc): ?>
                <option value="<?= htmlspecialchars($doc['employee_id']) ?>"
                    <?= ($selectedId == $doc['employee_id']) ? 'selected' : '' ?>>
                    <?= htmlspecialchars($doc['full_name']) ?>
                </option>
            <?php endforeach; ?>
        </select>
        <button type="submit">Показать</button>
    </form>

    <?php if (!empty($services)): ?>
        <table>
            <thead>
                <tr>
                    <th>ID врача</th>
                    <th>ФИО</th>
                    <th>Дата работы</th>
                    <th>Услуга</th>
                    <th>Стоимость</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($services as $s): ?>
                    <tr>
                        <td><?= htmlspecialchars($s['employee_id']) ?></td>
                        <td><?= htmlspecialchars($s['full_name']) ?></td>
                        <td><?= date('Y-m-d H:i', strtotime($s['work_start'])) ?></td>
                        <td><?= htmlspecialchars($s['service_name']) ?></td>
                        <td><?= number_format($s['actual_price'], 2, ',', ' ') ?> руб.</td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    <?php else: ?>
        <p>Нет данных для отображения.</p>
    <?php endif; ?>
</body>
</html>