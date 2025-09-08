// backend/decryption.js
const crypto = require('crypto');

function decryptData(encryptedData, key, iv, authTag) {
  try {
    const decipher = crypto.createDecipheriv('aes-256-gcm', key, iv);
    decipher.setAuthTag(authTag);
    
    let decrypted = decipher.update(encryptedData, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return JSON.parse(decrypted);
  } catch (error) {
    console.error("Error decrypting data:", error);
    throw new Error(`Decryption failed: ${error.message}`);
  }
}

module.exports = { decryptData };