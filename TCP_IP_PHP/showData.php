<?php
$servername = "localhost";
$username = "admin";
$password = "password";
$database = "clientRegister";

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);
}

$sql = "SELECT INET_NTOA(IP) AS IP, PORT FROM clientData";
$result = $conn->query($sql);

// Crear un array para almacenar los datos
$data = array();

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
}

$conn->close();

echo json_encode($data);
?>
