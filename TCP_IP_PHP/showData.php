<?php
require 'vendor/autoload.php';

use Aws\Ssm\SsmClient;

$current_user = get_current_user();
$config = include 'config.php';

$accessKeyId = $config['AWS_ACCESS_KEY_ID'];
$secretAccessKey = $config['AWS_SECRET_ACCESS_KEY'];
$sessionToken = $config['AWS_SESSION_TOKEN'];

$ssmClient = new SsmClient([
    'version' => 'latest',
    'region' => 'us-east-1',
    'credentials' => [
        'key' => $accessKeyId,
        'secret' => $secretAccessKey,
        'token' => $sessionToken
    ],
]);

$parameterName = '/dev/DB_CREDENTIALS';

$result = $ssmClient->getParameter([
    'Name' => $parameterName,
    'WithDecryption' => true,
]);

$credentials = json_decode($result['Parameter']['Value'], true);
$dbEndpoint = $credentials['db-endpoint'];
$dbUsername = $credentials['username'];
$dbPassword = $credentials['password'];
$dbName = $credentials['db-name'];

$servername = $dbEndpoint;
$username = $dbUsername;
$password = $dbPassword;
$database = $dbName;


$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);
}

$sql = "SELECT INET_NTOA(IP) AS IP, PORT FROM clientData";
$result = $conn->query($sql);

$data = array();

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
}

$conn->close();

echo json_encode($data);
?>
