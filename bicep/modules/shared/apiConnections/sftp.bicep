// SFTP API Connection Module
// Specialized module for creating SFTP API connections for Logic Apps

@description('Name of the API connection')
param connectionName string

@description('Azure region for the connection')
param location string

@description('Tags to apply to the connection')
param tags object = {}

@description('Display name for the connection')
param displayName string = 'SFTP'

@description('SFTP server host address')
param sftpHost string

@description('SFTP server port (default: 22)')
param sftpPort int = 22

@description('SFTP username')
param sftpUsername string

@description('SFTP password')
@secure()
param sftpPassword string = ''

@description('SSH private key (if using key-based authentication)')
@secure()
param sftpSshPrivateKey string = ''

@description('SSH private key passphrase (if private key is encrypted)')
@secure()
param sftpSshPrivateKeyPassphrase string = ''

@description('Root folder path on SFTP server')
param sftpRootFolder string = '/'

@description('Accept any SSH host key (true for self-signed certificates)')
param acceptAnySshHostKey bool = true

@description('Give up security for orange host key')
param giveUpSecurityAndAcceptAnySshHostKey bool = true

@description('Disable certificate validation')
param disableCertificateValidation bool = false

// Determine authentication type based on provided credentials
var usePasswordAuth = !empty(sftpPassword)
var useSshKeyAuth = !empty(sftpSshPrivateKey)

// Build parameter values based on authentication type
var parameterValues = usePasswordAuth ? {
  hostName: sftpHost
  userName: sftpUsername
  password: sftpPassword
  portNumber: sftpPort
  rootFolder: sftpRootFolder
  acceptAnySshHostKey: acceptAnySshHostKey
  giveUpSecurityAndAcceptAnySshHostKey: giveUpSecurityAndAcceptAnySshHostKey
  disableCertificateValidation: disableCertificateValidation
} : useSshKeyAuth ? {
  hostName: sftpHost
  userName: sftpUsername
  sshPrivateKey: sftpSshPrivateKey
  sshPrivateKeyPassphrase: sftpSshPrivateKeyPassphrase
  portNumber: sftpPort
  rootFolder: sftpRootFolder
  acceptAnySshHostKey: acceptAnySshHostKey
  giveUpSecurityAndAcceptAnySshHostKey: giveUpSecurityAndAcceptAnySshHostKey
  disableCertificateValidation: disableCertificateValidation
} : {}

// Deploy SFTP API Connection
resource sftpConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: connectionName
  location: location
  tags: tags
  properties: {
    displayName: displayName
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'sftp')
    }
    parameterValues: parameterValues
  }
}

// Outputs
@description('API Connection resource ID')
output id string = sftpConnection.id

@description('API Connection name')
output name string = sftpConnection.name

@description('Full connection object for Logic App parameters')
output connectionInfo object = {
  id: sftpConnection.id
  connectionId: sftpConnection.id
  connectionName: sftpConnection.name
  connectionProperties: {
    authentication: {
      type: 'Raw'
    }
  }
}
