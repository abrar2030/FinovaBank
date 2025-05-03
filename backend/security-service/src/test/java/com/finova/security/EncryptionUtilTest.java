package com.finovabank.security;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

// Assuming the utility class exists in the original project at:
// com.finova.security.encryption.EncryptionUtil
// Adjust the import path if necessary.
// import com.finova.security.encryption.EncryptionUtil;

// Placeholder for actual EncryptionUtil class
class MockEncryptionUtil {
    private static final String MOCK_KEY = "mock-secret-key-1234567890123456"; // Example key (use secure generation in real app)

    public static String encrypt(String data) {
        // Replace with actual encryption logic for testing
        if (data == null) return null;
        return new StringBuilder(data).reverse().toString() + "_encrypted";
    }

    public static String decrypt(String encryptedData) {
        // Replace with actual decryption logic for testing
        if (encryptedData == null || !encryptedData.endsWith("_encrypted")) return null;
        String reversedData = encryptedData.substring(0, encryptedData.length() - "_encrypted".length());
        return new StringBuilder(reversedData).reverse().toString();
    }
}

public class EncryptionUtilTest {

    @Test
    public void testEncryptDecryptSuccess() {
        String originalData = "SensitiveInformation123";
        // Replace MockEncryptionUtil with the actual class
        String encryptedData = MockEncryptionUtil.encrypt(originalData);

        assertNotNull(encryptedData);
        assertNotEquals(originalData, encryptedData);
        System.out.println("Encrypted: " + encryptedData);

        String decryptedData = MockEncryptionUtil.decrypt(encryptedData);
        assertNotNull(decryptedData);
        assertEquals(originalData, decryptedData);
        System.out.println("Decrypted: " + decryptedData);
    }

    @Test
    public void testEncryptNull() {
        String encryptedData = MockEncryptionUtil.encrypt(null);
        assertNull(encryptedData);
    }

    @Test
    public void testDecryptNull() {
        String decryptedData = MockEncryptionUtil.decrypt(null);
        assertNull(decryptedData);
    }

    @Test
    public void testDecryptInvalidData() {
        String decryptedData = MockEncryptionUtil.decrypt("invalidEncryptedData");
        assertNull(decryptedData);
    }

    // Add more tests for edge cases, different data types, key management if applicable
}

