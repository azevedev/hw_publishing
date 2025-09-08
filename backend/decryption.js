// backend/decryption.js
const crypto = require('crypto');

function decryptData(combinedData, keyParam, ivParam, authTagParam) {
  try {
      const algorithm = 'aes-256-gcm';
      
      // Convert inputs to buffers
      const key = Buffer.from(keyParam, 'hex');
      const iv = Buffer.from(ivParam, 'hex');
      const encryptedBuffer = Buffer.from(combinedData, 'hex');
      const authTag = Buffer.from(authTagParam, 'hex');
      
      console.log('Using values:', algorithm, combinedData, keyParam, ivParam);
      console.log('IV length:', iv.length);
      console.log('Auth tag length:', authTag.length);
      console.log('Ciphertext length:', encryptedBuffer.length);
      console.log('Key length:', key.length);


      // Create decipher and set auth tag
      const decipher = crypto.createDecipheriv(algorithm, key, iv);
      decipher.setAuthTag(authTag);

      // Decrypt the data
      let decrypted = decipher.update(encryptedBuffer, null, 'utf8');
      decrypted += decipher.final('utf8');
      
      // Return as JSON
      return JSON.parse(decrypted);
  } catch (error) {
      console.error('Decryption error:', error.message);
      throw error;
  }
}

module.exports = { decryptData };