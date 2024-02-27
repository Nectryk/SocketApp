//require('dotenv').config();
const getDatabaseCredentials = require('./credentials');
const mysql = require('mysql2');

getDatabaseCredentials().then(credentials => {
    const { dbEndpoint, dbUsername, dbPassword, dbName } = credentials;

    console.log("Database Endpoint:", dbEndpoint);
    console.log("Database Username:", dbUsername);
    console.log("Database Password:", dbPassword);
    console.log("Database Name:", dbName);



const connection = mysql.createConnection({
    host: dbEndpoint,
    user: dbUsername,
    password: dbPassword,
    database: dbName
});

function openConnection() {
    connection.connect((err) => {
        if (err) {
            console.error('Error al conectar con MySQL: ' + err.stack);
            return;
        }
        console.log('Conexión exitosa a MySQL como id ' + connection.threadId);
    });
}

function insertClientData(clientAddress, clientPort) {
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

function closeConnection() {
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

}).catch(error => {
    console.error("Error retrieving database credentials:", error);
});