const net = require('net');
require('dotenv').config();
const { openConnection, insertClientData, closeConnection } = require('./db');
const getDatabaseCredentials = require('./retrieveCred');

getDatabaseCredentials().then(credentials => {
    const { dbEndpoint, dbUsername, dbPassword, dbName } = credentials;

    console.log("Database Endpoint:", dbEndpoint);
    console.log("Database Username:", dbUsername);
    console.log("Database Password:", dbPassword);
    console.log("Database Name:", dbName);

    // Call the openConnection function with retrieved credentials
    const connection = openConnection(dbEndpoint, dbUsername, dbPassword, dbName);
    const server = net.createServer((socket) => {
    console.log('Cliente conectado');
    console.log('Dirección IP del cliente: ' + socket.remoteAddress);
    console.log('Puerto del cliente: ' + socket.remotePort);

    socket.write('Bienvenido al servidor TCP!\r\n');

    socket.on('data', (data) => {
        console.log(`Datos recibidos del cliente: ${data}`);
    });

    insertClientData(socket.remoteAddress, socket.remotePort, connection);

    socket.on('end', () => {
        console.log('Cliente desconectado');
    });
});



const PORT = process.env.PORT || 3000;

server.listen(PORT, () => {
    console.log(`Servidor TCP escuchando en el puerto ${PORT}`);
});

server.on('close', () => {
    console.log('Cerrando conexión con MySQL');
    closeConnection(connection);
});
}).catch(error => {
    console.error("Error retrieving database credentials:", error);
});