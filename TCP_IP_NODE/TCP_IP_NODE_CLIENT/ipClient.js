const net = require('net');
require('dotenv').config();

const serverHost = process.env.IP;
const serverPort = process.env.PORT;

const datosenviados = '¡Hola, servidor!';

const client = net.createConnection({ host: serverHost, port: serverPort }, () => {
 console.log('Conexión establecida con el servidor');
 client.write(datosenviados);
});

client.on('data', (data) => {
 console.log(`Datos recibidos del servidor: ${data}`);
 client.end();
});

client.on('end', () => {
 console.log('Conexión cerrada por el servidor');
});

client.on('error', (err) => {
 console.error(`Error de conexión: ${err}`);
});

client.on('close', () => {
 console.log('Conexión cerrada');
});