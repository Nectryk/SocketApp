//require('dotenv').config();
const mysql = require('mysql2');

function openConnection(dbEndpoint, dbUsername, dbPassword, dbName) {
    console.log(dbEndpoint);
    const connection = mysql.createConnection({
        host: dbEndpoint,
        user: dbUsername,
        password: dbPassword,
        database: dbName
    });
    connection.connect((err) => {
        if (err) {
            console.error('Error al conectar con MySQL: ' + err.stack);
            return;
        }
        console.log('Conexión exitosa a MySQL como id ' + connection.threadId);
    });
    return connection
}

function insertClientData(clientAddress, clientPort, connection) {
    const ipv4Address = clientAddress.split(':').pop(); 
    const post = [ipv4Address, clientPort];

    console.log(post);
    const insertQuery = 'INSERT INTO clientData (IP, PORT) VALUES (INET_ATON(?), ?)';

    const query = connection.query(insertQuery, post, (error, results, fields) => {
        if (error) {
            console.error('Error al insertar en MySQL: ' + error.stack);
            return;
        }
        console.log('Datos insertados correctamente en MySQL');
    });
}

function closeConnection(connection) {
    connection.end((err) => {
        if (err) {
            console.error('Error al cerrar la conexión con MySQL: ' + err.stack);
            return;
        }
        console.log('Conexión a MySQL cerrada correctamente');
    });
}

module.exports = {
    openConnection,
    insertClientData,
    closeConnection
};