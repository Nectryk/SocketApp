const AWS = require('aws-sdk');

const ssm = new AWS.SSM({
    region: 'us-east-1',
});

async function getDatabaseCredentials() {
    try {
        const data = await ssm.getParameter({
            Name: '/dev/DB_CREDENTIALS',
            WithDecryption: true,
        }).promise();

        // Access the credentials
        const credentials = JSON.parse(data.Parameter.Value);
        const dbEndpoint = credentials['db-endpoint'];
        const dbUsername = credentials['username'];
        const dbPassword = credentials['password'];
        const dbName = credentials['db-name'];

        return { dbEndpoint, dbUsername, dbPassword, dbName };
    } catch (error) {
        console.error("Error retrieving database credentials:", error);
        throw error;
    }
}

module.exports = getDatabaseCredentials;