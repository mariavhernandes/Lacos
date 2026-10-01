<?php

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// Responde imediatamente às requisições de teste "preflight" (OPTIONS) do navegador
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

header('Content-Type: application/json');

date_default_timezone_set('America/Sao_Paulo');

$uploadDir = dirname(__DIR__) . '/uploads/';

if (!is_dir($uploadDir)) {
    echo json_encode([
        'success' => true,
        'photos' => []
    ]);

    exit;
}

// Limpa o cache de estado de arquivos para garantir o timestamp correto
clearstatcache();

$files = glob($uploadDir . '*.jpg');

$photos = [];

foreach ($files as $filePath) {
    $fileName = basename($filePath);

    // Obtém o timestamp exato de modificação do arquivo no disco
    $timestamp = filemtime($filePath);

    $date = new DateTime('@' . $timestamp);
    $date->setTimezone(new DateTimeZone('America/Sao_Paulo'));

    $photos[] = [
        'fileName' => $fileName,
        'url' => '/uploads/' . $fileName,
        'capturedAt' => $date->format(DateTime::ATOM),
        'timestamp' => (int)$timestamp
    ];
}

// Garante ordenação estrita do mais recente (maior timestamp) para o mais antigo
usort($photos, function ($a, $b) {
    return (int)$b['timestamp'] <=> (int)$a['timestamp'];
});

echo json_encode([
    'success' => true,
    'photos' => $photos
]);