const net = require('net');
require('dotenv').config();
const db = require('./db');

db.openConnection();

const server = net.createServer((socket) => {
    console.log('Cliente conectado');
    console.log('Dirección IP del cliente: ' + socket.remoteAddress);
    console.log('Puerto del cliente: ' + socket.remotePort);

    socket.write('Bienvenido al servidor TCP!\r\n');

    socket.on('data', (data) => {
        console.log(`Datos recibidos del cliente: ${data}`);
    });

    db.insertClientData(socket.remoteAddress, socket.remotePort);

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
    db.closeConnection();
});