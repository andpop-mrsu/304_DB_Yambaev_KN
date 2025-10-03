#!/bin/bash

echo "Запуск генерации SQL-скрипта..."
python make_db_init.py

echo "Создание базы данных movies_rating.db..."
sqlite3 movies_rating.db < db_init.sql

echo "Проверка созданных таблиц..."
sqlite3 movies_rating.db ".tables"

echo "Статистика базы данных:"
echo "======================="
sqlite3 movies_rating.db "SELECT 'movies: ' || COUNT(*) FROM movies;"
sqlite3 movies_rating.db "SELECT 'users: ' || COUNT(*) FROM users;"
sqlite3 movies_rating.db "SELECT 'ratings: ' || COUNT(*) FROM ratings;"
sqlite3 movies_rating.db "SELECT 'tags: ' || COUNT(*) FROM tags;"

echo "Готово! База данных movies_rating.db создана и заполнена."