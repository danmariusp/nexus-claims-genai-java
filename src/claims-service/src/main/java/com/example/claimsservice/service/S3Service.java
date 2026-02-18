package com.example.claimsservice.service;

import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.ResponseBytes;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import org.springframework.beans.factory.annotation.Value;
import java.nio.charset.StandardCharsets;

@Service
public class S3Service {

    private final S3Client s3Client;
    
    // Bucket name will be injected from environment variable or properties
    @Value("${aws.s3.bucket-name}")
    private String bucketName;

    public S3Service(S3Client s3Client) {
        this.s3Client = s3Client;
    }

    public String getClaimNotes(String claimId) {
        // Assuming notes are stored as simple text files with claimId as key or part of key
        // For lab simplicity: claimId.txt
        String key = claimId + ".txt";
        
        try {
            GetObjectRequest getObjectRequest = GetObjectRequest.builder()
                    .bucket(bucketName)
                    .key(key)
                    .build();

            ResponseBytes<GetObjectResponse> objectBytes = s3Client.getObjectAsBytes(getObjectRequest);
            return objectBytes.asString(StandardCharsets.UTF_8);
        } catch (Exception e) {
            // Handle S3 exceptions (e.g., key not found)
            return "No notes found for claim ID: " + claimId;
        }
    }
}
