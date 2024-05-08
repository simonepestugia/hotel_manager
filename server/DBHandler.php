<?php
class DBHandler {
    private static $pdo;

    public static function getPDO() {
        if (!self::$pdo) {
            $host = 'localhost';
            $db = 'rest_hotel';
            $user = 'root';  // Modifica questi valori se necessario
            $pass = '';      // Modifica questi valori se necessario
            $charset = 'utf8mb4';

            $dsn = "mysql:host=$host;dbname=$db;charset=$charset";
            $options = [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ];

            try {
                self::$pdo = new PDO($dsn, $user, $pass, $options);
            } catch (PDOException $e) {
                throw new PDOException($e->getMessage(), (int) $e->getCode());
            }
        }

        return self::$pdo;
    }
}
