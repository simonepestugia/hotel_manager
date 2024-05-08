<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

require_once 'DBHandler.php';

$pdo = DBHandler::getPDO();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Carica tutti gli account
    $sql = "SELECT * FROM login";
    $stmt = $pdo->query($sql);
    if ($stmt) {
        $accounts = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($accounts);
    } else {
        echo json_encode(['error' => 'Failed to fetch accounts']);
    }
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Aggiunge un nuovo account
    $data = json_decode(file_get_contents("php://input"), true);
    $email = trim($data['email']);
    $password = trim($data['password']);
    $nome = trim($data['nome']);
    $cognome = trim($data['cognome']);

    $sql_insert = "INSERT INTO login (email, password, nome, cognome) VALUES (:email, :password, :nome, :cognome)";
    $stmt_insert = $pdo->prepare($sql_insert);
    $stmt_insert->bindParam(':email', $email);
    $stmt_insert->bindParam(':password', $password);
    $stmt_insert->bindParam(':nome', $nome);
    $stmt_insert->bindParam(':cognome', $cognome);

    echo $stmt_insert->execute() ? json_encode(['success' => true]) : json_encode(['success' => false]);
} elseif ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    // Elimina un account
    $data = json_decode(file_get_contents("php://input"), true);
    $ID_account = $data['ID_account'];
    $sql_delete = "DELETE FROM login WHERE ID_account = :ID_account";
    $stmt_delete = $pdo->prepare($sql_delete);
    $stmt_delete->bindParam(':ID_account', $ID_account);
    echo $stmt_delete->execute() ? json_encode(['success' => true]) : json_encode(['success' => false]);
} elseif ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    // Aggiorna un account esistente
    $data = json_decode(file_get_contents("php://input"), true);
    $ID_account = $data['ID_account'];
    $new_email = trim($data['new_email']);

    $sql_update = "UPDATE login SET email = :new_email WHERE ID_account = :ID_account";
    $stmt_update = $pdo->prepare($sql_update);
    $stmt_update->bindParam(':new_email', $new_email);
    $stmt_update->bindParam(':ID_account', $ID_account);
    echo $stmt_update->execute() ? json_encode(['success' => true]) : json_encode(['success' => false]);
}
