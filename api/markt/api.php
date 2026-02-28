<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, POST");
header("Content-Type: application/json");

$FILE = "market-stats.json";

// Datei erzeugen, falls nicht vorhanden
if (!file_exists($FILE)) {
    file_put_contents($FILE, json_encode([
        "market" => new stdClass(),
        "history" => new stdClass(),
        "fixed" => new stdClass()
    ], JSON_PRETTY_PRINT));
}

// GET → Daten abrufen
if ($_SERVER["REQUEST_METHOD"] === "GET") {
    echo file_get_contents($FILE);
    exit;
}

// POST → Daten speichern
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $input = file_get_contents("php://input");

    if (!$input) {
        echo json_encode(["error" => "No data received"]);
        exit;
    }

    $data = json_decode($input, true);

    if (!$data) {
        echo json_encode(["error" => "Invalid JSON"]);
        exit;
    }

    file_put_contents($FILE, json_encode($data, JSON_PRETTY_PRINT));

    echo json_encode(["success" => true]);
    exit;
}
?>
