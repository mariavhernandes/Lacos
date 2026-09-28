<?php

header('Content-Type: application/json');

$uploadDir = dirname(__DIR__) . '/uploads/';

if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0775, true);
}

if (!isset($_FILES['imageFile'])) {
    http_response_code(400);

    echo json_encode([
        'success' => false,
        'message' => 'Nenhuma imagem foi enviada.'
    ]);

    exit;
}

$file = $_FILES['imageFile'];

if ($file['error'] !== UPLOAD_ERR_OK) {
    http_response_code(400);

    echo json_encode([
        'success' => false,
        'message' => 'Erro ao receber a imagem.',
        'error' => $file['error']
    ]);

    exit;
}

$allowedTypes = [
    'image/jpeg',
    'image/jpg'
];

if (!in_array($file['type'], $allowedTypes)) {
    http_response_code(400);

    echo json_encode([
        'success' => false,
        'message' => 'Formato de imagem não permitido.'
    ]);

    exit;
}

$fileName = uniqid('lacos_', true) . '.jpg';

$filePath = $uploadDir . $fileName;

if (!move_uploaded_file($file['tmp_name'], $filePath)) {
    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Não foi possível salvar a imagem.'
    ]);

    exit;
}

echo json_encode([
    'success' => true,
    'message' => 'Imagem enviada com sucesso.',
    'fileName' => $fileName,
    'url' => '/uploads/' . $fileName
]);